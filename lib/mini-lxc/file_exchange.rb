class MiniLXC
  module FileExchange

    def copy_from_host_to_container(name, source_path_on_host, target_path_on_container)
      log "[LXC] COPY TO CONTAINER #{name}: #{source_path_on_host} => #{target_path_on_container}"
      attach(name, Shellwords.join(["mkdir", "-p", File.dirname(target_path_on_container)]), nil)
      stream_from_host_to_container(name, File.open(source_path_on_host), target_path_on_container)
    end

    def read_file_from_container(name, path_on_container)
      log "[LXC] READ FILE IN CONTAINER #{name}: #{path_on_container}"
      stream_file_from_container(name, path_on_container, nil)
    end

    def stream_from_host_to_container(name, ios, target_path_on_container, &block)
      log "[LXC] STREAM TO CONTAINER #{name}: #{ios.inspect} => #{target_path_on_container}"
      attach(name, Shellwords.join(["/bin/sh", "-c", "/bin/cat > " + Shellwords.escape(target_path_on_container)]), nil, :in => ios, &block)
    end

    def stream_file_from_container(name, path_on_container, ios, &block)
      log "[LXC] STREAM FILE IN CONTAINER #{name}: #{path_on_container} => #{ios.inspect}"
      attach(name, Shellwords.join(["/bin/cat", path_on_container]), nil, :out => ios, &block)
    end

  end
end
