require "minitest/autorun"
require "minitest/pride"
require "minitest/hell"

$: << File.expand_path("../lib", File.dirname(__FILE__))

require "mini-lxc"

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
    Proc.new do |command, options|
      (@commands ||= []) << command
      [pid, FakeStatus.new(status, pid), output]
    end
  end

  def stub_spawn(instance, pid, status, output, &block)
    instance.stub :spawn_with_io, record_and_return(pid, status, output) do
      yield
    end
  end
end
