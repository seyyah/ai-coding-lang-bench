# frozen_string_literal: true

require 'yaml'
require 'fileutils'

# Loads and instantiates codex adapters from configuration
class CodexLoader
  CONFIG_FILE = File.join(__dir__, '..', 'config', 'codexes.yml')
  LOCAL_CONFIG_FILE = File.join(__dir__, '..', 'config', 'codexes.local.yml')

  def self.load_config
    unless File.exist?(CONFIG_FILE)
      raise "Codex configuration file not found: #{CONFIG_FILE}"
    end

    yaml = File.read(CONFIG_FILE)
    # Expand environment variables in YAML (both ${VAR} and $VAR formats)
    expanded = yaml.gsub(/\$\{(\w+)\}|\$(\w+)/) { ENV[$1 || $2] || '' }
    config = YAML.safe_load(expanded, permitted_classes: [], aliases: true)

    # Merge with local config if it exists (for user-specific settings)
    if File.exist?(LOCAL_CONFIG_FILE)
      local_yaml = File.read(LOCAL_CONFIG_FILE)
      local_expanded = local_yaml.gsub(/\$\{(\w+)\}|\$(\w+)/) { ENV[$1 || $2] || '' }
      local_config = YAML.safe_load(local_expanded, permitted_classes: [], aliases: true)
      config = deep_merge(config, local_config)
    end

    config
  end

  def self.deep_merge(hash1, hash2)
    hash1.merge(hash2) do |_key, oldval, newval|
      oldval.is_a?(Hash) && newval.is_a?(Hash) ? deep_merge(oldval, newval) : newval
    end
  end

  def self.available_codexes
    config = load_config
    config['codexes'].select { |_, cfg| cfg['enabled'] }.keys
  end

  def self.default_codex
    config = load_config
    config['default'] || 'claude'
  end

  def self.model_for(name)
    config = load_config
    codex_config = config.fetch('codexes', {}).fetch(name, {})
    adapter_config = codex_config['config'] || {}
    model = adapter_config['model'] || adapter_config['model_name']
    model = model.to_s.strip
    model.empty? ? 'default' : model
  end

  def self.model_path_parts(name)
    parts = model_for(name).split('/').reject(&:empty?).map do |part|
      sanitized = part.gsub(/[^A-Za-z0-9._-]+/, '-')
      sanitized.empty? ? 'default' : sanitized
    end
    parts.empty? ? ['default'] : parts
  end

  def self.default_output_root(name, problem:, base_dir:, dry_run: false)
    path = File.join(base_dir, 'artifacts', name, *model_path_parts(name), problem)
    dry_run ? File.join(path, 'dry-run') : path
  end

  def self.create_codex(name)
    config = load_config
    codex_config = config['codexes'][name]

    raise "Codex '#{name}' not found in configuration" unless codex_config
    raise "Codex '#{name}' is not enabled" unless codex_config['enabled']

    class_name = codex_config['class']
    adapter_config = symbolize_keys(codex_config['config'] || {})
    adapter_file = codex_config['file'] || "#{name.tr('-', '_')}_codex"

    # Require the adapter file
    require_relative "codexes/#{adapter_file}"

    # Instantiate the adapter
    Object.const_get(class_name).new(adapter_config)
  rescue NameError => e
    raise "Failed to load codex class '#{class_name}': #{e.message}"
  end

  def self.symbolize_keys(value)
    case value
    when Hash
      value.each_with_object({}) do |(key, nested_value), memo|
        memo[key.respond_to?(:to_sym) ? key.to_sym : key] = symbolize_keys(nested_value)
      end
    when Array
      value.map { |item| symbolize_keys(item) }
    else
      value
    end
  end
end
