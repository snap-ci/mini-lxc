class MiniLXC
  class << self
    attr_accessor :default_logger
  end

  module Logging
    def log(message, level=:info)
      @logger.send(level, message) if @logger
    end

    def debug(message)
      log(message, :debug)
    end

    def warn(message)
      log(message, :warn)
    end

    def error(message)
      log(message, :error)
    end
  end
end
