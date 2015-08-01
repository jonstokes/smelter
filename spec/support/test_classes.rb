module Test
  module Utils
    def add(a, b)
      a + b
    end
  end

  class Script
    include Redis::Objects
    include Smelter::Scriptable
    include Test::Utils
    
    runner_include Test::Utils

    attr_reader :id

    def initialize(id)
      @id = id
      connect_to_redis
      @index << @id unless @index.include?(@id)
    end

    def name; @name.value; end
    def name=(val); @name.value = val; end
    def source; @source.value; end
    def source=(val); @source.value = val; end

    def self.find(id)
      raise "Script #{id} not found" unless exists?(id)
      self.new(id)
    end

    def self.find_by_name(name)
      index.detect do |script_id|
        self.find(script_id).name == name
      end
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
end
