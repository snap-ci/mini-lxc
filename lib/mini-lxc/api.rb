class MiniLXC
  module Api

    def self.extended(base)
      base.extend(LXCv2)
      base.extend(LXCv1)
    end

    def create_unprivileged(name, template_spec={:dist => "ubuntu", :release => "trusty"}, params=[], exec_options={}, &block)
      validate_template_spec!(template_spec)
      template_spec = {:arch => "amd64"}.merge(template_spec) unless (template_spec.has_key?(:a) || template_spec.has_key?(:arch)) # default to amd64

      base_command = ["lxc-create", "-n", name, "-t", "download"]
      base_command += parameterize_template_spec(template_spec)

      exec build_command(base_command, params), exec_options, &block
    end

    def start(name, params=["-d"], exec_options={}, &block)
      exec build_command(["lxc-start", "-n", name], params), exec_options, &block
    end

    def stop(name, params=[], exec_options={}, &block)
      exec build_command(["lxc-stop", "-n", name], params), exec_options, &block
    end

    def destroy(name, params=[], exec_options={}, &block)
      exec build_command(["lxc-destroy", "-n", name], params), exec_options, &block
    end

    def ls(params=["--active"], exec_options={}, &block)
      exec build_command(["lxc-ls"], params), exec_options, &block
    end

    def attach(name, command, params=["--clear-env", "-o", "/dev/stdout"], exec_options={}, &block)
      exec build_command(["lxc-attach", "-n", name, "--", command], params), exec_options, &block
    end

    def config(key="-l", exec_options={}, &block)
      exec ["lxc-config", key], exec_options, &block
    end

    def info(name, params=[], exec_options={}, &block)
      exec build_command(["lxc-info", "-n", name], params), exec_options, &block
    end

    module LXCv2
      def copy(name, original, params=["-d", "-e", "-s", "-B", "overlay"], exec_options={}, &block)
        exec build_command(["lxc-copy", "-n", original, "-N", name], params), exec_options, &block
      end
    end

    module LXCv1
      def start_ephemeral(name, original, params=["-d"], exec_options={}, &block)
        exec build_command(["lxc-start-ephemeral", "-n", name, "-o", original], params), exec_options, &block
      end

      def clone(name, original, params=["-s", "--backingstore=overlayfs"], exec_options={}, &block)
        exec build_command(["lxc-clone", "-n", name, "-o", original], params), exec_options, &block
      end
    end

    private

    def parameterize_template_spec(spec)
      spec = spec.dup # never modify original

      # order the main options first
      basic = [:dist, :d, :release, :r, :arch, :a].inject(["--"]) do |memo, key|
        value = spec.delete(key)
        unless value.nil? || value.to_s.strip == ""
          memo << (key.to_s.size == 1 ? "-#{key}" : "--#{key}")
          memo << value.to_s
        end
        memo
      end

      # add all other options alphabetically. having a deterministic order ensures test stability across rubies
      spec.keys.map(&:to_s).sort.inject(basic) do |memo, key|
        memo << (key.size == 1 ? "-#{key}" : "--#{key}") # handle short and long opts
        memo << spec[key.to_sym].to_s
        memo
      end
    end

    def validate_template_spec!(spec)
      unless spec.is_a?(Hash) && spec.keys.all? {|k| k.is_a?(Symbol)}
        raise ArgumentError.new("all template spec options must be symbols")
      end

      unless (spec.has_key?(:dist) || spec.has_key?(:d)) && (spec.has_key?(:release) || spec.has_key?(:r))
        raise ArgumentError.new("template spec must at the very least include the :dist|:d and :release|:r keys")
      end

      # the following options are equivalent, so one should not specify duplicate options
      {:d => :dist, :r => :release, :a => :arch}.each do |short, long|
        raise ArgumentError.new("template spec should only contain one of #{short.inspect} or #{long.inspect}, but not both") if spec.has_key?(short) && spec.has_key?(long)
      end
    end

  end
end
