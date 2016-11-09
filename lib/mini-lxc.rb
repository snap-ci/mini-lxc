require "shellwords"

require "mini-lxc/logging"
require "mini-lxc/interaction"
require "mini-lxc/file_exchange"
require "mini-lxc/api"
require "mini-lxc/container"
require "mini-lxc/version"

class MiniLXC
  include Logging
  include Interaction
  include FileExchange
  include Api
  include Version

  def initialize(logger=MiniLXC.default_logger)
    @logger = logger
  end
end
