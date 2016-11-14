class MiniLXC
  module Interaction
    def spawn_with_io(command, options)
      output = options.delete(:out) || ""
      input = options.delete(:in)

      ro, wo = IO.pipe

      spawn_opts = {2 => 1, :out => wo}

      unless input.nil?
        ri, wi = IO.pipe(Encoding::ASCII_8BIT)
        spawn_opts.update(:in => ri)
      end

      pid = Process.spawn({}, command, spawn_opts)
      wo.close

      unless input.nil?
        ri.close
        wi.binmode

        chunksize = options.delete(:in_chunk) || 16 * 1024 * 1024
        while (chunk = input.read(chunksize))
          wi.write(chunk)
        end
        wi.close
      end

      buffer_size = options.delete(:out_chunk) || 16 * 1024
      while buffer = ro.read(buffer_size)
        output << buffer unless buffer.chomp.empty?
      end
      ro.close

      _, status = Process.waitpid2(pid)

      [pid, status, output]
    end
    private :spawn_with_io

    def exec(command, options={:out => ""}, &block)
      command = command.join(" ") if command.is_a?(Array)

      log "[LXC] execute: #{command.inspect}"
      pid, status, output = spawn_with_io(command, options)
      log "[LXC] completed with status #{status.inspect}: #{command.inspect}"

      if block_given?
        block.call(pid, status, output)
      else
        [pid, status, output]
      end
    end

    def build_command(base_command, options=[])
      return base_command unless options && options.size > 0

      terminal = []
      if (boundary = base_command.index("--")) # some commands mark end of options with "--"
        reverse = boundary - base_command.size
        terminal = base_command.slice!(reverse, reverse.abs)
      end

      base_command += options.flatten
      base_command += terminal unless terminal.empty?

      base_command
    end

  end
end
