class MiniLXC

  module Version
    VERSION = "0.4.2"

    def lxc_version
      exec %w(lxc-ls --version) do |p, s, o|
        Gem::Version.new(o) if s.success?
      end
    end

    def lxc_v1?
      Gem::Requirement.new("~> 1").satisfied_by? lxc_version
    end

    def lxc_v2?
      Gem::Requirement.new("~> 2").satisfied_by? lxc_version
    end
  end

end
