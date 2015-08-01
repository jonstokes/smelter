module Smelter
  module Scriptable

    # Scriptable classes must support the following methods
    # class Script
    #   include Smelter::Scriptable
    #
    #   runner_include Buzzsaw::DSL
    #
    #   def self.find_by_name(name)
    #     returns a script object
    #   end
    #
    #   def name
    #     returns the name of the script
    #   end
    #
    #   def source
    #     returns the source file for the script
    #   end
    # end

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    def register
      # NOTE: This returns a populated instance of ScriptRunner
      # that has all extensions defined on it and contains
      # Procs for the code defined in source
      instance_eval source, name, 1
    end

    module ClassMethods
      def runner_include(mod)
        Smelter::ScriptRunner.include(mod)
      end

      def runner(name=nil)
        return ScriptRunner.new unless name
        script = find_by_name(name)
        script.register
      end

      def define(name, &block)
        definition_proxy = DefinitionProxy.new(name)
        definition_proxy.instance_eval(&block)
      end
    end
  end
end
