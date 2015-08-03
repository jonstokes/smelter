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
      if self.class.extension_class
        self.class.extension_class.registry.each_pair do |extension_name, block|
          next unless matches_extensions_glob?(extension_name.to_s)
          runner.instance_eval(&block)
        end
      end

      # Set up runner instance for use
      if block_given?
        runner.instance_eval(&block)
      end

      runner
    end

    def extension(&block)
      self.class.extension_class.register(script_name, &block)
    end

    def self.extension_class=(val)
      @extension_class = val
    end

    def self.extension_class
      @extension_class
    end

    private

    def matches_extensions_glob?(extension_name)
      if @extensions.is_a?(String)
        File.fnmatch?(@extensions, extension_name)
      else
        @extensions.select { |ext| File.fnmatch?(ext, extension_name) }.any?
      end
    end
  end
end
