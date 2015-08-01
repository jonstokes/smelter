module Smelter
  module Scriptable
    def self.included(base)
      Smelter::Settings.configure do |config|
        config.script_class = base
      end
    end
  end
end
