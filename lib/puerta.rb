require "puerta/version"
require "puerta/config"
require "puerta/nl/checkout"


module Puerta
  # Your code goes here...
  class << self
    attr_accessor :config
  end


  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(self.config)
    self.config
  end

  def self.reset_config
    @config = Config.new
  end
end
