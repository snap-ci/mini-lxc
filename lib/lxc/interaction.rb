class LXC
  module Interaction
    def __run_in_subprocess(command)
      output = ""

      r, w = IO.pipe
      pid = Process.spawn({}, command, 2=>1, :out => w)
      w.close

      buffer_size = 1024 * 2
      while buffer = r.read(buffer_size)
        output << buffer unless buffer.chomp.empty?
      end
      r.close

      _, status = Process.waitpid2(pid)

      [pid, status, output]
    end

    def exec(command, &block)
      command = command.join(" ") if command.is_a?(Array)

      info "[LXC] execute: #{command.inspect}"
      pid, status, output = __run_in_subprocess(command)
      info "[LXC] completed with status #{status.inspect}: #{command.inspect}"

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

      # options should be array, not hash because certain options are repeatable e.g. --bdir
      options.each do |opt|
        if opt.is_a?(Array)
          # build GNU-style options differently
          base_command << (opt.first.start_with?("--") ? opt.join("=") : opt.join(" "))
        else
          base_command << opt
        end
      end

      base_command += terminal unless terminal.empty?

      base_command
    end
  end
end
