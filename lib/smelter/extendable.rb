module Smelter
  module Extendable

    # Extendable classes must support the following methods
    # def self.all_names
    #   In an ActiveRecord model this could be just pluck(:name)
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
      Smelter::Settings.configure do |config|
        config.extension_class = base
      end

      base.class_eval do
        extend ClassMethods
      end
    end

    def register
      instance_eval source, name, 1
    end

    module ClassMethods
      def register_all
        self.all_names do |name|
          next if registry[name.to_s]
          extension = find_by(name: name)
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
    end
  end
end
