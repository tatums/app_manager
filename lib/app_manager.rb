require_relative "app_manager/version"
require_relative "app_manager/site"

module AppManager
  class Config
    attr_accessor :sites_path

    def initialize
      ##NOTE - no trailing slash
      @sites_path = "./sites"
    end
  end
end

module AppManager
  class << self
    attr_writer :configuration
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end
end

