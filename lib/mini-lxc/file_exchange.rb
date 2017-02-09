class MiniLXC
  module FileExchange

    def copy_file_to_container(name, host_file, container_file, &block)
      log "[LXC] COPY FILE TO CONTAINER #{name}: #{host_file} => #{container_file}"
      command = Shellwords.join(["/bin/sh", "-c", "/bin/cat > " + Shellwords.escape(container_file)])

      stream_stdin_to_container(name, command, File.open(host_file, "rb"), &block)
    end

    def copy_file_from_container(name, container_file, host_file, &block)
      log "[LXC] COPY FILE FROM CONTAINER #{name}: #{container_file} => #{host_file}"
      command = Shellwords.join(["/bin/cat", container_file])

      stream_stdout_from_container(name, command, File.open(host_file, "wb")) do |pid, status, ios|
        ios.close
        yield pid, status, ios if block_given?
      end
    end

    def tar_from_container(name, path_on_container, tarball_on_host, &block)
      log "[LXC] CREATING TARBALL FROM CONTAINER #{name}: #{path_on_container} => #{tarball_on_host}"
      command = Shellwords.join(["tar", "zcpf", "-", "-C", path_on_container, "."])

      stream_stdout_from_container(name, command, File.open(tarball_on_host, "wb")) do |pid, status, ios|
        ios.close
        yield pid, status, ios if block_given?
      end
    end

    def untar_to_container(name, tarball_on_host, path_on_container, &block)
      log "[LXC] EXPLODING TARBALL TO CONTAINER #{name}: #{tarball_on_host} => #{path_on_container}"
      command = Shellwords.join(["tar", "zxpf", "-", "-C", path_on_container])

      stream_stdin_to_container(name, command, File.open(tarball_on_host, "rb"), &block)
    end

    def stream_stdin_to_container(name, command, ios, &block)
      attach(name, command, nil, :in => ios, &block)
    end

    def stream_stdout_from_container(name, command, ios, &block)
      attach(name, command, nil, :out => ios, &block)
    end

  end
end
