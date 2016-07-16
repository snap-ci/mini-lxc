class MiniLXC
  # This class is purely for convenience. It wraps calls to the static methods on MiniLXC, so
  # everything that an instance does can be done using the MiniLXC api alone.
  class Container
    attr_reader :name, :base_container

    def initialize(name, base_container)
      @name = name
      @base_container = base_container
    end

    def attach(command)
      MiniLXC.attach(name, command)
    end

    def reify
      MiniLXC.clone(base_container, name)
    end

    def start(options=["-d"])
      MiniLXC.start(name, options)
    end

    def stop
      MiniLXC.stop(name)
    end

    def destroy
      MiniLXC.destroy(name)
    end

    def running?
      # Alternatively, we could parse `lxc-info -n NAME` output, but `lxc-ls`
      # can be handled in a simpler way since it won't fail if the container
      # doesn't exist.
      MiniLXC.ls(["--running", "-1"]) do |pid, status, output|
        output.split("\n").compact.map(&:strip).include?(name)
      end
    end

    def copy_file_from_host(source_path_on_host, target_path_on_container)
      MiniLXC.copy_from_host_to_container(name, source_path_on_host, target_path_on_container)
    end

    def read_file_from_container(path_on_container)
      MiniLXC.read_file_from_container(name, path_on_container)
    end

    def stream_from_host_to_container(ios, target_path_on_container)
      MiniLXC.stream_from_host_to_container(name, ios, target_path_on_container)
    end

    def stream_file_from_container(path_on_container, ios, &block)
      MiniLXC.stream_file_from_container(name, path_on_container, ios, &block)
    end
  end

end
