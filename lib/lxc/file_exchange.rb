class LXC
  module FileExchange

    # may refactor copy file and read file to use streams so we can deal with large files
    def copy_from_host_to_container(name, source_path_on_host, target_path_on_container)
      info "[LXC] COPY TO CONTAINER #{name}: #{source_path_on_host} => #{target_path_on_container}"

      ensure_directory_exists_on_container = Shellwords.join(["lxc-attach", "-n", name, "--", "mkdir", "-p", File.dirname(target_path_on_container)])
      stream_data_to_container = [
        Shellwords.join(["cat", source_path_on_host]),
        Shellwords.join(["lxc-attach", "-n", name, "--", "/bin/sh", "-c", "/bin/cat > " + Shellwords.escape(target_path_on_container)])
      ].join(" | ")

      exec ensure_directory_exists_on_container
      exec stream_data_to_container
    end

    def read_file_from_container(name, path_on_container)
      info "[LXC] READ FILE IN CONTAINER #{name}: #{path_on_container}"
      exec Shellwords.join(["lxc-attach", "-n", name, "--", "/bin/cat", path_on_container])
    end

  end
end
