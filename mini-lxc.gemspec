require "rubygems"
require File.expand_path("lib/mini-lxc/version", File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name       = "mini-lxc"
  s.version    = MiniLXC::VERSION
  s.summary    = "Ruby API for LXC"
  s.author     = "Marques Lee"
  s.email      = "malee@thoughtworks.com"

  s.files      = Dir.glob("lib/**/*.rb")

  s.add_development_dependency "rake", "10.5.0" # highest version supported by all rubies we care about
  s.add_development_dependency "minitest", "~> 5.10.1"

  s.homepage    = "https://github.com/snap-ci/mini-lxc"
  s.description = <<-EOF
    mini-lxc is a Ruby frontend to the LXC command-line API, allowing
    Ruby scripts to create and manage Linux containers. mini-lxc is
    developed and tested with unprivileged containers in mind.
  EOF
end
