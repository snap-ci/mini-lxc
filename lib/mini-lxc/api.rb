class MiniLXC
  module Api
    def start_ephemeral(original, name, params=["-d"], options={}, &block)
      exec build_command(["lxc-start-ephemeral", "-o", original, "-n", name], params), options, &block
    end

    def clone(original, name, params=["-s", "--backingstore=overlayfs"], options={}, &block)
      exec build_command(["lxc-clone", "-o", original, "-n", name], params), options, &block
    end

    def start(name, params=["-d"], options={}, &block)
      exec build_command(["lxc-start", "-n", name], params), options, &block
    end

    def stop(name, params=[], options={}, &block)
      exec build_command(["lxc-stop", "-n", name], params), options, &block
    end

    def destroy(name, params=[], options={}, &block)
      exec build_command(["lxc-destroy", "-n", name], params), options, &block
    end

    def ls(params=["--active"], options={}, &block)
      exec build_command(["lxc-ls"], params), options, &block
    end

    def attach(name, command, params=["--clear-env", "-o", "/dev/stdout"], options={}, &block)
      exec build_command(["lxc-attach", "-n", name, "--", command], params), options, &block
    end

    def config(key, options={}, &block)
      exec ["lxc-config", key], options, &block
    end
  end
end
