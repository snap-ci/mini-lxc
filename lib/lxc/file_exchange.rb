class LXC
  module FileExchange
    # may refactor copy file and read file to use streams so we can deal with large files
    def copy_from_host_to_container(name, source_path_on_host, target_path_on_container)
      info "[LXC] COPY TO CONTAINER #{name}: #{source_path_on_host} => #{target_path_on_container}"
      exec "lxc-attach -n #{name} -- mkdir -p #{Shellwords.escape(File.dirname(target_path_on_container))}"
      exec "cat #{Shellwords.escape(source_path_on_host)} | lxc-attach -n #{name} -- /bin/sh -c #{Shellwords.escape("/bin/cat > " + Shellwords.escape(target_path_on_container))}"
    end

    def read_file_from_container(name, path_on_container)
      info "[LXC] READ FILE IN CONTAINER #{name}: #{path_on_container}"
      exec "lxc-attach -n #{name} -- /bin/cat #{Shellwords.escape path_on_container}"
    end
  end
end
