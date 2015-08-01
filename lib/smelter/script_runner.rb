module Stretched
  class ScriptRunner
    include Stretched::DocQueries

    attr_reader :attributes, :context
    attr_accessor :user

    def initialize
      @attributes = {}
    end

    def set_context(context)
      @context = context
      attrs = @context.is_a?(Hash) ? @context.keys : @context.members
      attrs.each do |attr|
        self.define_singleton_method(attr) do
          @context[attr]
        end
      end
    end

    def run(instance={})
      attributes.each do |attribute_name, value|
        result = value.is_a?(Proc) ? value.call(instance) : value
        instance[attribute_name] = result
      end
      instance
    end

    def load_registration(opts)
      # FIXME: I have to find a way to secure this so that
      # you can't access other users' registrations in scripts
      reg_type = "Stretched::#{opts[:type].to_s.capitalize}".constantize
      reg_type.find(opts[:key], user)
    end

    def method_missing(name, *args, &block)
      if block_given?
        attributes[name.to_s] = block
      else
        attributes[name.to_s] = args[0]
      end
    rescue RuntimeError => e
      if !!e.message[/add a new key into hash during iteration/]
        super
      else
        raise e
      end
    end
  end
end
