require "minitest/autorun"
require "minitest/pride"
require "minitest/hell"

$: << File.expand_path("../lib", File.dirname(__FILE__))

require "lxc"

LXC.use_logger(nil) # be quiet

module FakeExec

  class FakeStatus # a good-enough implementation of Process::Status
    def initialize(code, pid)
      @code = code
      @pid = pid
    end

    def exited?
      !@code.nil?
    end

    def exitstatus
      @code
    end

    def success?
      @code == 0
    end

    def pid
      @pid
    end
  end

  def record_and_return(pid, status, output)
    Proc.new do |command|
      (@commands ||= []) << command
      [pid, FakeStatus.new(status, pid), output]
    end
  end

  def stub_spawn(pid, status, output, &block)
    LXC.stub :__run_in_subprocess, record_and_return(pid, status, output) do
      block.call
    end
  end
end
