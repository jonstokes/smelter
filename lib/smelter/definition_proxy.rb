module Smelter
  class DefinitionProxy
    attr_reader :script_name
    attr_reader :extensions

    def initialize(script_name)
      @script_name = script_name
    end

    def extensions(glob)
      @extensions = glob
    end

    def script(&block)
      runner = ScriptRunner.new

      # Define all locally registered extensions on this runner instance
      extension_class.registry.each_pair do |extension_name, block|
        next unless matches_extensions_glob?(extension_name.to_s)
        runner.instance_eval(&block)
      end

      # Set up runner instance for use
      if block_given?
        runner.instance_eval(&block)
      end

      runner
    end

    def extension(&block)
      extension_class.register(extension_name, &block)
    end

    private

    def extension_class
      Smelter::Settings.extension_class
    end

    def matches_extensions_glob?(extension_name)
      if @extensions.is_a?(String)
        File.fnmatch?(@extensions, extension_name)
      else
        @extensions.select { |ext| File.fnmatch?(ext, extension_name) }.any?
      end
    end
  end
end
