require "rubygems"
require File.expand_path("lib/lxc/version", File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name       = "lxc-ruby"
  s.version    = LXC::VERSION
  s.summary    = "Ruby API for LXC"
  s.author     = "Marques Lee"
  s.email      = "snap-ci@thoughtworks.com"

  s.files      = Dir.glob("lib/**/*.rb")

  s.add_development_dependency "rake", "~> 11.2.2"
  s.add_development_dependency "minitest", "~> 5.9.0"

  s.homepage    = "https://github.com/snap-ci/lxc-ruby"
  s.description = <<-EOF
    lxc-ruby is a Ruby frontend to the LXC command-line API, allowing
    Ruby scripts to create and manage Linux containers.
  EOF
end
