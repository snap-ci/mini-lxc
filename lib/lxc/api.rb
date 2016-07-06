class LXC
  module Api
    def start_ephemeral(original, name, options=["-d"], &block)
      exec build_command(["lxc-start-ephemeral", "-o", original, "-n", name], options), &block
    end

    def clone(original, name, options=["-s", ["--backingstore", "overlayfs"]], &block)
      exec build_command(["lxc-clone", "-o", original, "-n", name], options), &block
    end

    def start(name, options=["-d"], &block)
      exec build_command(["lxc-start", "-n", name], options), &block
    end

    def stop(name, options=[], &block)
      exec build_command(["lxc-stop", "-n", name], options), &block
    end

    def destroy(name, options=[], &block)
      exec build_command(["lxc-destroy", "-n", name], options), &block
    end

    def ls(options=["--active"], &block)
      exec build_command(["lxc-ls"], options), &block
    end

    def attach(name, command, options=["--clear-env", ["-o", "/dev/stdout"], ["-l", "DEBUG"]], &block)
      exec build_command(["lxc-attach", "-n", name, "--", command], options), &block
    end

    def config(key, &block)
      exec ["lxc-config", key], &block
    end
  end
end
