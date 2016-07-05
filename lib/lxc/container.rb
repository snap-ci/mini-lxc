class LXC
  # This class is purely for convenience. It wraps calls to the static methods on LXC, so
  # everything that an instance does can be done using the LXC api alone.
  class Container
    attr_reader :name, :base_container

    def initialize(name, base_container)
      @name = name
      @base_container = base_container
    end

    def attach(command)
      LXC.attach(name, command)
    end

    def reify
      LXC.clone(base_container, name)
    end

    def start(options=["-d"])
      LXC.start(name, options)
    end

    def stop
      LXC.stop(name)
    end

    def destroy
      LXC.destroy(name)
    end

    def running?
      # Alternatively, we could parse `lxc-info -n NAME` output, but `lxc-ls`
      # can be handled in a simpler way since it won't fail if the container
      # doesn't exist.
      LXC.ls(["--running", "-1"]) do |pid, status, output|
        output.split("\n").compact.map(&:strip).include?(name)
      end
    end

    def copy_file_from_host(source_path_on_host, target_path_on_container)
      LXC.copy_from_host_to_container(name, source_path_on_host, target_path_on_container)
    end

    def read_file_from_container(path_on_container)
      LXC.read_file_from_container(name, path_on_container)
    end
  end

end
