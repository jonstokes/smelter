module Smelter
  module Scriptable
    def self.included(base)
      Smelter::Settings.configure do |config|
        config.script_class = base
      end
    end

    def register
      # NOTE: This returns a populated instance of ScriptRunner
      # that has all extensions defined on it and contains
      # Procs for the code defined in @data
      runner = instance_eval data, key, 1
      runner.user = user
      runner
    end

    def self.runner(opts)
      key = opts[:name]
      return ScriptRunner.new unless key
      script = find_by(name: name)
      script.register
    end

    def self.define(name, &block)
      definition_proxy = DefinitionProxy.new(name)
      definition_proxy.instance_eval(&block)
    end

    def self.create_from_source(source, user=nil)
      load_source(source).map do |reg_hash|
        type = reg_hash.extract!(:type)[:type]
        klass = "Stretched::#{type}".constantize
        klass.create(reg_hash.merge(user: user))
      end
    end

    def self.create_from_file(filename, user=nil)
      load_file(filename).map do |reg_hash|
        type = reg_hash.extract!(:type)[:type]
        klass = "Stretched::#{type}".constantize
        klass.create(reg_hash.merge(user: user))
      end
    end

    def self.load_file(filename)
      source = get_source(filename)
      load_source(source)
    end

    def self.load_source(source)
      key = source[/(define)\s+\".*?\"/].split(/(define) \"/).last.split(/\"/).last
      type = source[/Stretched::(Extension|Script)/].split('::').last
      [{key: key, type: type , data: source}]
    end

  end
end
