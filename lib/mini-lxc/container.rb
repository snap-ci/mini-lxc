require "yaml"

class MiniLXC
  # This class represents the high-level API, which provides some abstractions and conveniences for container
  # creation and management. It wraps calls to the static methods on MiniLXC, so everything that an instance
  # does can be done using the MiniLXC api alone if more fine-tuned control is needed
  class Container

    attr_reader :name

    class << self
      def create_unprivileged(name, template_spec={:distro => "ubuntu", :release => "trusty"}, options={})
        params = (options || {}).delete(:params) || []
        pid, status, output = MiniLXC.create_unprivileged(name, template_spec, params, options)
        raise "Failed to create container #{name} (exited with status #{status.to_i}: #{output}" unless status.success?
        self.new(name)
      end

      def create_from_base_container(name, base_container, options={})
        params = (options || {}).delete(:params)

        pid, status, output = if MiniLXC.lxc_v1?
          params ||= ["-s", "-B", "overlayfs"]
          MiniLXC.clone(name, base_container, params, options)
        else
          params ||= ["-s", "-B", "overlay"]
          MiniLXC.copy(name, base_container, params, options)
        end

        raise "Failed to create container #{name} (exited with status #{status.to_i}: #{output}" unless status.success?
        self.new(name)
      end

      def ephemeral(name, base_container, options={})
        params = (options || {}).delete(:params)

        pid, status, output = if MiniLXC.lxc_v1?
          params ||= ["-s", "-d", "-B", "overlayfs"]
          MiniLXC.start_ephemeral(name, base_container, params, options)
        else
          params = (["-e"] + (params || ["-s", "-d", "-B", "overlay"])).uniq
          MiniLXC.copy(name, base_container, params, options)
        end

        raise "Failed to create container #{name} (exited with status #{status.to_i}: #{output}" unless status.success?
        self.new(name)
      end
    end

    def initialize(name)
      @name = name
    end

    def attach(command, options={})
      params = (options || {}).delete(:params) || []
      MiniLXC.attach(name, command, params, options)
    end

    def start(options={:params => ["-d"]})
      params = (options || {}).delete(:params) || []
      MiniLXC.start(name, params)
    end

    def stop(options={})
      params = (options || {}).delete(:params) || []
      MiniLXC.stop(name, params)
    end

    def destroy(options={:params => ["-f"]})
      params = (options || {}).delete(:params) || []
      MiniLXC.destroy(name, params)
    end

    def exist?
      MiniLXC.ls(["-1"]) do |pid, status, output|
        output.split("\n").compact.map(&:strip).include?(name)
      end
    end

    def state(name)
      MiniLXC.info(name, ["-s"]) do |pid, status, output|
        raise "Could not read state of container #{name}. Does it exist? Output: #{output}" unless status.success?
        YAML.load(output)["State"]
      end
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
