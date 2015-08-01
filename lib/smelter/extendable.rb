module Smelter
  module Extendable
    def self.included(base)
      Smelter::Settings.configure do |config|
        config.extension_class = base
      end
    end

    def register
      instance_eval data, key, 1
    end

    def self.register_all
      keys.each do |key|
        next if registry[key]
        extension = find(key, user)
        extension.register
      end
    end

    def self.registry
      @registry ||= ThreadSafe::Cache.new
    end

    def self.register(script_name, &block)
      @registry ||= ThreadSafe::Cache.new
      @registry[script_name.to_s] = block
    end

  end
end
