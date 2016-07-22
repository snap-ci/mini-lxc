require "shellwords"

require "mini-lxc/logging"
require "mini-lxc/interaction"
require "mini-lxc/file_exchange"
require "mini-lxc/api"
require "mini-lxc/container"
require "mini-lxc/version"

class MiniLXC
  def initialize; end
  private :initialize

  extend Logging
  extend Interaction
  extend FileExchange
  extend Api
  extend Version
end
