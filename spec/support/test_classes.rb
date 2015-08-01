module Test
  module Utils
    def add(a, b)
      a + b
    end
  end

  class Script
    include Redis::Objects
    include Smelter::Scriptable

    # This module will be included on every ScriptRunner so that
    # every script will have access to its methods.
    runner_include Test::Utils

    attr_reader :id

    def initialize(id)
      @id = id
      connect_to_redis
      @index << @id unless @index.include?(@id)
    end

    def name;         @name.value;         end
    def name=(val);   @name.value = val;   end
    def source;       @source.value;       end
    def source=(val); @source.value = val; end

    def self.find(id)
      raise "Script #{id} not found" unless exists?(id)
      self.new(id)
    end

    def self.find_by_name(name)
      retval = nil
      index.detect do |script_id|
        script = find(script_id)
        retval = script if script.name == name
      end
      retval
    end

    def self.exists?(id)
      index.include?(id)
    end

    private

    def connect_to_redis
      @index  = Redis::List.new(self.class.name)
      @name   = Redis::Value.new("#{@id}::name")
      @source = Redis::Value.new("#{@id}::source")
    end

    def self.index
      @index ||= Redis::List.new(self.name)
    end
  end

  class Extension < Script
    include Smelter::Extendable

    def self.all_names
      index.map { |id| Extension.find(id).name }
    end
  end
end
