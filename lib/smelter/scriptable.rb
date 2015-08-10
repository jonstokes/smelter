module Smelter
  module Scriptable

    # Scriptable classes must support the following methods
    # class Script
    #   include Smelter::Scriptable
    #
    #   runner_include Buzzsaw::DSL
    #
    #   def self.find(id)
    #     returns a script object
    #   end
    #
    #   def id
    #     returns the id of the script
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
      instance_eval source, id, 1
    end

    module ClassMethods
      def runner_include(mod)
        Smelter::ScriptRunner.include(mod)
      end

      def runner(id=nil)
        return ScriptRunner.new unless id
        script = find(id)
        script.register
      end

      def define(id, &block)
        definition_proxy = DefinitionProxy.new(id)
        definition_proxy.instance_eval(&block)
      end
    end
  end
end
