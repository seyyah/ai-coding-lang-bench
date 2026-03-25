# frozen_string_literal: true

require 'fileutils'
require 'json'

# Base class for AI codex adapters
# Each codex implementation must implement the abstract methods defined here
class BaseCodex
  class CodexError < StandardError; end

  attr_reader :name

  def initialize(name, config = {})
    @name = name
    @config = config

    # Shared configuration loaded from config/codexes.yml
    @supported_extensions = config[:supported_extensions] || []
    @language_mappings = config[:language_mappings] || {}
    @shebangs = config[:shebangs] || {}
    @description = config[:description] || "Generic API Adapter"
  end

  # Abstract: Run code generation with the given prompt
  def run_generation(prompt, dir:, log_path: nil)
    raise NotImplementedError, "#{self.class} must implement #run_generation"
  end

  # Abstract: Get the version string of this codex
  def version
    raise NotImplementedError, "#{self.class} must implement #version"
  end

  # Optional: Perform warmup to initialize caches
  def warmup(warmup_dir)
    # Default no-op implementation
    { success: true, elapsed_seconds: 0.0 }
  end

  # Optional: Parse raw output to extract metrics
  def parse_metrics(raw_output)
    nil
  end

  protected

  attr_reader :config

  # Orchestrates file extraction, naming, and language-specific target resolution
  def save_generated_code(response_text, dir)
    lang = read_benchmark_value(dir, '.benchmark-language') || infer_language_from_dir(dir)
    # Binary name is fetched dynamically from the benchmark environment
    binary_name = read_benchmark_value(dir, '.benchmark-binary-name') || 'output'
    
    blocks = extract_code_blocks(response_text, binary_name)
    written_files = []

    # Iterate through extracted blocks and write identified files
    blocks.select { |block| block[:filename] }.each do |block|
      path = File.join(dir, block[:filename])
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, block[:code])
      written_files << block[:filename]
    end

    # Handle cases where multiple blocks exist or no explicit filenames are found
    primary_block = choose_primary_block(blocks, lang)
    if primary_block
      # binary_name parameter is passed dynamically here
      target = primary_target_for(lang, binary_name)
      if target && !written_files.include?(target)
        code = normalize_script_for_target(primary_block[:code], lang, target, binary_name: binary_name)
        File.write(File.join(dir, target), code)
        written_files << target
      end
    elsif written_files.empty? && response_text.length > 100
      # Final fallback: Strip markdown and treat the whole response as primary source
      target = primary_target_for(lang, binary_name: binary_name) || binary_name
      clean_code = response_text.gsub(/```[a-z0-9_+-]*|```/i, '').strip
      code = normalize_script_for_target(clean_code, lang, target, binary_name: binary_name)
      File.write(File.join(dir, target), code)
      written_files << target
    end

    # Ensure build scripts and necessary boilerplate files are present
    ensure_runtime_files(lang, dir, written_files, binary_name: binary_name)
    
    # Apply execution permissions to build and binary files
    [binary_name, 'build.sh', 'Makefile'].each do |f|
      path = File.join(dir, f)
      FileUtils.chmod(0755, path) if File.exist?(path)
    end
  end

  # Uses regex to isolate code segments within triple backticks
  def extract_code_blocks(response_text, binary_name)
    blocks = []
    response_text.to_enum(:scan, /```[ \t]*(?<lang>[A-Za-z0-9_+-]*)[ \t]*\r?\n(?<code>.*?)```/m).each do
      match = Regexp.last_match
      context = response_text[[match.begin(0) - 400, 0].max...match.begin(0)]
      blocks << {
        fence_lang: match[:lang].to_s.downcase.strip,
        filename: infer_filename_from_context(context, binary_name),
        code: match[:code].strip
      }
    end
    blocks
  end

  # Heuristic search for filenames in the text surrounding a code block
  def infer_filename_from_context(context, binary_name)
    binary_pattern = Regexp.escape(binary_name)
    
    # Build a dynamic regex pattern from the supported extensions list
    ext_pattern = @supported_extensions.join('|')
    
    backticked = context.scan(/`([^`\n]+)`/).flatten.reverse.find do |token|
      # Match against the binary name, common build files, or the dynamic extensions list
      token.match?(/\A(?:#{binary_pattern}|Makefile|makefile|build\.sh|[\w.\/-]+\.(?:#{ext_pattern}))\z/)
    end
    return backticked if backticked
    context[/file named\s+[`"]?([A-Za-z0-9._\/-]+)[`"]?/i, 1]
  end

  # Selects the best code block for the target language from the LLM response
  def choose_primary_block(blocks, lang)
    return nil if blocks.empty?
    
    # Use mappings from config, falling back to the language name itself if not defined
    expected = @language_mappings.fetch(lang, [lang])
    
    blocks.find { |b| expected.include?(b[:fence_lang]) } || blocks.max_by { |b| b[:code].length }
  end

  # Maps benchmark languages to their default entry-point filenames
  def primary_target_for(lang, binary_name)
    targets = { 
      'python' => binary_name, 
      'ruby' => binary_name, 
      'go' => 'main.go', 
      'rust' => 'main.rs', 
      'c' => 'main.c',
      'lua' => 'main.lua',
      'scheme' => 'main.scm',
      'ocaml' => 'main.ml',
      'haskell' => 'main.hs',
      'perl' => 'main.pl',
      'java' => 'Main.java',
      'javascript' => 'main.js',
      'typescript' => 'main.ts',
      'php' => 'main.php',
      'csharp' => 'Program.cs'
    }
    targets[lang] || "#{binary_name}.#{lang}"
  end

  # Injects shebang lines for interpreted languages if missing
  def normalize_script_for_target(code, lang, target, binary_name:)
    return code if code.start_with?('#!')
    
    # Use shebangs from config based on the language
    shebang = @shebangs[lang]
    shebang ? "#{shebang}\n#{code}\n" : code
  end

  # Generates language-specific build scripts (build.sh) for compiled languages
  def ensure_runtime_files(lang, dir, written_files, binary_name: 'minigit')
    case lang
    when 'go' then write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\ngo build -o #{binary_name} main.go\n", written_files)
    when 'rust' then write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nrustc -O main.rs -o #{binary_name}\n", written_files)
    when 'c' then write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\ngcc -O2 -o #{binary_name} main.c\n", written_files)
    when 'ocaml' then write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nocamlopt -o #{binary_name} main.ml\n", written_files)
    when 'haskell' then write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nghc -O2 -o #{binary_name} main.hs\n", written_files)
    when 'java' then write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\njavac Main.java\n", written_files)
    end
  end

  # Utility to read local benchmark configuration files
  def read_benchmark_value(dir, filename)
    path = File.join(dir, filename)
    File.file?(path) ? File.read(path, encoding: 'UTF-8').strip : nil
  rescue StandardError; nil; end

  # Extracts the target language from the directory name using a regex pattern
  def infer_language_from_dir(dir)
    dir_name = File.basename(dir)
    dir_name[/-(rust|go|c|typescript|javascript|java|perl|python|ruby|lua|scheme|ocaml|haskell|php|csharp)-\d+-v[12]$/, 1] || 'python'
  end

  # Helper method to prevent overwriting files already created by the LLM
  def write_if_missing(dir, rel_path, content, written)
    return if written.include?(rel_path)
    File.write(File.join(dir, rel_path), content)
    written << rel_path
  end
end
