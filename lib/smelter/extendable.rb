module Smelter
  module Extendable

    # Extendable classes must support the following methods
    # def self.find_each
    #   I.e. as with an ActiveRecord model
    # end
    #
    # def name
    #   returns the name of the script
    # end
    #
    # def source
    #   returns the source file for the script
    # end

    def self.included(base)
      Smelter::DefinitionProxy.extension_class = base

      base.class_eval do
        extend ClassMethods
      end
    end

    def register
      instance_eval source, name, 1
    end

    module ClassMethods
      def register_all
        self.find_each do |extension|
          next if registry[extension.id]
          extension.register
        end
      end

      def registry
        @registry ||= ThreadSafe::Cache.new
      end

      def register(extension_name, &block)
        @registry ||= ThreadSafe::Cache.new
        @registry[extension_name.to_s] = block
      end

      def define(name, &block)
        definition_proxy = DefinitionProxy.new(name)
        definition_proxy.instance_eval(&block)
      end
    end
  end
end
