require File.expand_path("test_helper", File.dirname(__FILE__))

class MiniLXCTest < Minitest::Test

  include FakeExec

  def setup
    @commands = []
  end

  def test_build_command_injects_options_into_base_command
    assert_equal "lxc-info -n test-container -q -o lxc.log", MiniLXC.build_command(["lxc-info", "-n", "test-container"], ["-q", ["-o", "lxc.log"]]).join(" ")
  end

  def test_build_command_handles_gnu_options
    assert_equal "lxc-info -q --name=test-container", MiniLXC.build_command(["lxc-info"], ["-q", ["--name", "test-container"]]).join(" ")
  end

  def test_build_command_allows_repeated_options
    assert_equal "lxc-attach -n test-container -v FOO=BAR -v BAZ=QUU", MiniLXC.build_command(["lxc-attach", "-n", "test-container"], [["-v", "FOO=BAR"], ["-v", "BAZ=QUU"]]).join(" ")
  end

  def test_build_command_allows_repeated_options
    assert_equal "lxc-attach -n test-container -v FOO=BAR -v BAZ=QUU", MiniLXC.build_command(["lxc-attach", "-n", "test-container"], [["-v", "FOO=BAR"], ["-v", "BAZ=QUU"]]).join(" ")
  end

  def test_build_command_knows_when_to_terminate_options
    assert_equal "lxc-attach --clear-env -q --name=test-container -l DEBUG -- uname -a", MiniLXC.build_command(["lxc-attach", "--", "uname -a"], ["--clear-env", "-q", ["--name", "test-container"], ["-l", "DEBUG"]]).join(" ")
  end

  def test_exec_can_take_a_block
    stub_spawn(2, 0, "hello world\n") do
      result = MiniLXC.exec("echo 'hello world'") do |pid, status, output|
        assert_equal 2, pid, "should get pid as first argument"
        assert_equal 0, status.exitstatus, "should get status object as second argument"
        assert_equal "hello world\n", output, "should get output as third argument"
        output.strip.upcase.split(" ")
      end

      assert_equal ["echo 'hello world'"], @commands
      assert_equal ["HELLO", "WORLD"], result, "exec returns the result of the block"
    end
  end

  def test_exec_returns_pid_status_and_output
    stub_spawn(5, 1, "nope!") do
      pid, status, output = MiniLXC.exec("cat /dev/null")

      assert_equal 5, pid
      assert_equal 1, status.exitstatus
      assert_equal "nope!", output
    end
  end

  def test_start_ephemeral
    stub_spawn(2, 0, "something") do
      MiniLXC.start_ephemeral("original-container", "test")
      MiniLXC.start_ephemeral("original-container", "test", ["-d", ["--bdir", "/mnt/foodisk"]])
    end

    assert_equal ["lxc-start-ephemeral -o original-container -n test -d", "lxc-start-ephemeral -o original-container -n test -d --bdir=/mnt/foodisk"], @commands
  end

  def test_clone
    stub_spawn(2, 0, "something") do
      MiniLXC.clone("original-container", "test")
      MiniLXC.clone("original-container", "test", ["-M", ["-P", "/opt/lxc"]])
    end

    assert_equal ["lxc-clone -o original-container -n test -s --backingstore=overlayfs", "lxc-clone -o original-container -n test -M -P /opt/lxc"], @commands
  end

  def test_start
    stub_spawn(2, 0, "something") do
      MiniLXC.start("test")
      MiniLXC.start("test", ["-d", ["-v", "RBENV_DEBUG=true"], ["-v", "BUNDLER_PATH=/opt/local/bundle"]])
    end

    assert_equal ["lxc-start -n test -d", "lxc-start -n test -d -v RBENV_DEBUG=true -v BUNDLER_PATH=/opt/local/bundle"], @commands
  end

  def test_stop
    stub_spawn(2, 0, "something") do
      MiniLXC.stop("test")
      MiniLXC.stop("test", ["-r"])
    end

    assert_equal ["lxc-stop -n test", "lxc-stop -n test -r"], @commands
  end

  def test_destroy
    stub_spawn(2, 0, "something") do
      MiniLXC.destroy("test")
      MiniLXC.destroy("test", ["-f"])
    end

    assert_equal ["lxc-destroy -n test", "lxc-destroy -n test -f"], @commands
  end

  def test_ls
    stub_spawn(2, 0, "something") do
      MiniLXC.ls
      MiniLXC.ls(["--running", "-1"])
    end

    assert_equal ["lxc-ls --active", "lxc-ls --running -1"], @commands
  end

  def test_attach
    stub_spawn(2, 0, "something") do
      MiniLXC.attach("test", "uname -r")
      MiniLXC.attach("test", "uname -r", ["-o", "lxc.log"])
    end

    assert_equal ["lxc-attach -n test --clear-env -o /dev/stdout -l DEBUG -- uname -r", "lxc-attach -n test -o lxc.log -- uname -r"], @commands
  end

  def test_config
    stub_spawn(2, 0, "something") do
      MiniLXC.config("lxc.lxcpath")
    end

    assert_equal ["lxc-config lxc.lxcpath"], @commands
  end

end
