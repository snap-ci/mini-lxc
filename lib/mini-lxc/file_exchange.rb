class MiniLXC
  module FileExchange

    def copy_file_to_container(name, path_on_host, path_on_container, &block)
      log "[LXC] COPY FILE TO CONTAINER #{name}: #{path_on_host} => #{path_on_container}"
      command = Shellwords.join(["/bin/sh", "-c", "/bin/cat > " + Shellwords.escape(path_on_container)])

      stream_stdin_to_container(name, command, File.open(path_on_host, "rb"), &block)
    end

    def copy_file_from_container(name, path_on_container, path_on_host, &block)
      log "[LXC] COPY FILE FROM CONTAINER #{name}: #{path_on_container} => #{path_on_host}"
      command = Shellwords.join(["/bin/cat", path_on_container])

      stream_stdout_from_container(name, command, File.open(path_on_host, "wb"), &block)
    end

    def tar_from_container(name, path_on_container, tarball_on_host, &block)
      log "[LXC] CREATING TARBALL FROM CONTAINER #{name}: #{path_on_container} => #{tarball_on_host}"
      command = Shellwords.join(["tar", "zcpf", "-", "-C", path_on_container, "."])

      stream_stdout_from_container(name, command, File.open(tarball_on_host, "wb"), &block)
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
