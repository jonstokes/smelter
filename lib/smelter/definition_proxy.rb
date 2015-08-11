module Smelter
  class DefinitionProxy
    attr_reader :script_id
    attr_reader :extensions

    def initialize(script_id)
      @script_id = script_id
    end

    def extensions(glob)
      @extensions = glob
    end

    def script(&block)
      runner = ScriptRunner.new

      # Define all locally registered extensions on this runner instance
      if self.class.extension_class
        self.class.extension_class.registry.each_pair do |extension_id, block|
          next unless matches_extensions_glob?(extension_id)
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
      self.class.extension_class.register(script_id, &block)
    end

    def self.extension_class=(val)
      @extension_class = val
    end

    def self.extension_class
      @extension_class
    end

    private

    def matches_extensions_glob?(extension_id)
      if @extensions.is_a?(String)
        File.fnmatch?(@extensions, extension_id)
      else
        @extensions.select { |ext| File.fnmatch?(ext, extension_id) }.any?
      end
    end
  end
end
