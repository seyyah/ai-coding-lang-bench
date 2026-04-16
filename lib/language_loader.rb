# frozen_string_literal: true

require 'yaml'
require_relative 'codex_loader'

# Loads language configurations from config file
class LanguageLoader
  CONFIG_FILE = File.join(__dir__, '..', 'config', 'languages.yml')
  LOCAL_CONFIG_FILE = File.join(__dir__, '..', 'config', 'languages.local.yml')

  def self.load_config
    unless File.exist?(CONFIG_FILE)
      raise "Languages configuration file not found: #{CONFIG_FILE}"
    end

    yaml = File.read(CONFIG_FILE)
    config = YAML.safe_load(yaml, permitted_classes: [], aliases: true)

    if File.exist?(LOCAL_CONFIG_FILE)
      local_yaml = File.read(LOCAL_CONFIG_FILE)
      local_config = YAML.safe_load(local_yaml, permitted_classes: [], aliases: true)
      config = CodexLoader.deep_merge(config, local_config)
    end

    CodexLoader.symbolize_keys(config['languages'])
  end
end
