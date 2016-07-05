require "lxc/logging"
require "lxc/interaction"
require "lxc/file_exchange"
require "lxc/api"
require "lxc/container"
require "lxc/version"

class LXC
  def initialize; end
  private :initialize

  extend Logging
  extend Interaction
  extend FileExchange
  extend Api
end
