require "yaml"

class MiniLXC
  # This class represents the high-level API, which provides some abstractions and conveniences for container
  # creation and management. It wraps calls to the static methods on MiniLXC, so everything that an instance
  # does can be done using the MiniLXC api alone if more fine-tuned control is needed
  class Container

    attr_reader :name, :api

    class << self
      def create_unprivileged(name, template_spec={:distro => "ubuntu", :release => "trusty"}, options={})
        params = (options || {}).delete(:params) || []
        api = (options || {}).delete(:client) || MiniLXC.new

        pid, status, output = api.create_unprivileged(name, template_spec, params, options)
        raise "Failed to create container #{name} (exited with status #{status.to_i}: #{output}" unless status.success?
        self.new(name, api)
      end

      def create_from_base_container(name, base_container, options={})
        params = (options || {}).delete(:params)
        api = (options || {}).delete(:client) || MiniLXC.new

        pid, status, output = if api.lxc_v1?
          params ||= ["-s", "-B", "overlayfs"]
          api.clone(name, base_container, params, options)
        else
          params ||= ["-s", "-B", "overlay"]
          api.copy(name, base_container, params, options)
        end

        raise "Failed to create container #{name} (exited with status #{status.to_i}: #{output}" unless status.success?
        self.new(name, api)
      end

      def ephemeral(name, base_container, options={})
        params = (options || {}).delete(:params)
        api = (options || {}).delete(:client) || MiniLXC.new

        pid, status, output = if api.lxc_v1?
          params ||= ["-d", "-U", "overlayfs"]
          api.start_ephemeral(name, base_container, params, options)
        else
          params = (["-e"] + (params || ["-s", "-d", "-B", "overlay"])).uniq
          api.copy(name, base_container, params, options)
        end

        raise "Failed to create container #{name} (exited with status #{status.to_i}: #{output}" unless status.success?
        self.new(name, api)
      end
    end

    def initialize(name, api=MiniLXC.new)
      @name = name
      @api = api
    end

    def attach(command, options={})
      params = (options || {}).delete(:params) || []
      api.attach(name, command, params, options)
    end

    def start(options={:params => ["-d"]})
      params = (options || {}).delete(:params) || []
      api.start(name, params)
    end

    def stop(options={})
      params = (options || {}).delete(:params) || []
      api.stop(name, params)
    end

    def destroy(options={:params => ["-f"]})
      params = (options || {}).delete(:params) || []
      api.destroy(name, params)
    end

    def exist?
      api.ls(["-1"]) do |pid, status, output|
        output.split("\n").compact.map(&:strip).include?(name)
      end
    end

    def state
      api.info(name, ["-s"]) do |pid, status, output|
        raise "Could not read state of container #{name}. Does it exist? Output: #{output}" unless status.success?
        YAML.load(output)["State"]
      end
    end

    def running?
      # Alternatively, we could parse `lxc-info -n NAME` output, but `lxc-ls`
      # can be handled in a simpler way since it won't fail if the container
      # doesn't exist.
      api.ls(["--running", "-1"]) do |pid, status, output|
        output.split("\n").compact.map(&:strip).include?(name)
      end
    end

    def copy_file_from_host(path_on_host, path_on_container)
      api.copy_file_to_container(name, path_on_host, path_on_container)
    end

    def copy_file_to_host(path_on_container, path_on_host)
      api.copy_file_from_container(name, path_on_container, path_on_host)
    end

    def read_file_on_container(path_on_container, stdout=nil)
      api.read_file_on_container(name, path_on_container, stdout)
    end

    def tar_to_host(path_on_container, tarball_on_host)
      api.tar_from_container(name, path_on_container, tarball_on_host)
    end

    def untar_from_host(tarball_on_host, path_on_container)
      api.untar_to_container(name, tarball_on_host, path_on_container)
    end

  end

end
