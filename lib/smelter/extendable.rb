module Smelter
  module Extendable
    def self.included(base)
      Smelter::Settings.configure do |config|
        config.extension_class = base
      end
    end
  end
end
