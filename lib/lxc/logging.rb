class LXC
  module Logging
    def use_logger(logger)
      @logger = logger
    end

    def log(message, level=:info)
      @logger.send(level, message) if @logger
    end

    def info(message)
      log(message, :info)
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
