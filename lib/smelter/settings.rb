module Smelter
  module Settings

    class SettingsData < Struct.new(:logger, :script_class, :extension_class)
    end

    def self.configuration
      @configuration ||= Smelter::Settings::SettingsData.new
    end

    def self.configure
      yield configuration
    end

    def self.script_class
      return unless configured?
      configuration.script_class
    end

    def self.extension_class
      return unless configured?
      configuration.extension_class
    end

    def self.logger
      return unless configured?
      configuration.logger
    end

    def self.configured?
      !!configuration
    end
  end
end
