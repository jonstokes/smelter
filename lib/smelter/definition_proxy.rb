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
      Smelter::Settings.extension_class.registry.each_pair do |extname, block|
        next unless matches_extensions_glob?(extname.to_s)
        runner.instance_eval(&block)
      end

      # Set up runner instance for use
      if block_given?
        runner.instance_eval(&block)
      end

      runner
    end

    def extension(&block)
      Smelter::Settings.extension_class.register(script_name, &block)
    end

    private

    def matches_extensions_glob?(extname)
      if @extensions.is_a?(String)
        File.fnmatch?(@extensions, extname)
      else
        @extensions.select { |ext| File.fnmatch?(ext, extname) }.any?
      end
    end
  end
end
