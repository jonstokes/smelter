module Test
  module Utils
    def add(a, b)
      a + b
    end
  end

  class StoredObject
    include Redis::Objects
    attr_reader :id

    def initialize(id)
      @id = id
      connect_to_redis
      @index << @id unless @index.include?(@id)
    end

    def source;       @source.value;       end
    def source=(val); @source.value = val; end

    def self.find(id)
      raise "Script #{id} not found" unless exists?(id)
      self.new(id)
    end

    def self.exists?(id)
      index.include?(id)
    end

    private

    def connect_to_redis
      @index  = Redis::List.new(self.class.name)
      @source = Redis::Value.new("#{@id}::source")
    end

    def self.index
      @index ||= Redis::List.new(self.name)
    end

  end

  class Script < StoredObject
    include Smelter::Scriptable

    # This module will be included on every ScriptRunner so that
    # every script will have access to its methods.
    runner_include Test::Utils
  end

  class Extension < StoredObject
    include Smelter::Extendable

    def self.find_each
      index.each do |id|
        yield new(id)
      end
    end
  end
end
