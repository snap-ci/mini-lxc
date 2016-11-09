require File.expand_path("test_helper", File.dirname(__FILE__))

class MiniLXCTest < Minitest::Test
  parallelize_me!

  include FakeExec

  def setup
    @commands = []
    @api = MiniLXC.new
  end

  def test_build_command_injects_options_into_base_command
    assert_equal "lxc-info -n test-container -q -o lxc.log", @api.build_command(["lxc-info", "-n", "test-container"], ["-q", ["-o", "lxc.log"]]).join(" ")
  end

  def test_build_command_allows_repeated_options
    assert_equal "lxc-attach -n test-container -v FOO=BAR -v BAZ=QUU", @api.build_command(["lxc-attach", "-n", "test-container"], ["-v", "FOO=BAR", "-v", "BAZ=QUU"]).join(" ")
  end

  def test_build_command_knows_when_to_terminate_options
    assert_equal "lxc-attach --clear-env -q --name=test-container -l DEBUG -- uname -a", @api.build_command(["lxc-attach", "--", "uname -a"], ["--clear-env", "-q", "--name=test-container", "-l", "DEBUG"]).join(" ")
  end

  def test_exec_can_take_a_block
    stub_spawn(@api, 2, 0, "hello world\n") do
      result = @api.exec("echo 'hello world'") do |pid, status, output|
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
    stub_spawn(@api, 5, 1, "nope!") do
      pid, status, output = @api.exec("cat /dev/null")

      assert_equal 5, pid
      assert_equal 1, status.exitstatus
      assert_equal "nope!", output
    end
  end

  def test_version_detection
    stub_spawn(@api, 2, 0, "1.0.8") do
      assert_equal "1.0.8", @api.lxc_version.to_s
      assert @api.lxc_v1?
      refute @api.lxc_v2?
    end

    stub_spawn(@api, 2, 0, "2.0.3") do
      assert_equal "2.0.3", @api.lxc_version.to_s
      refute @api.lxc_v1?
      assert @api.lxc_v2?
    end
  end

  def test_create_unprivileged
    stub_spawn(@api, 2, 0, "something") do
      # accepts short opts
      @api.create_unprivileged("new-container", {:d => "ubuntu", :r => "trusty", :a => "amd64"})

      # accepts GNU longopts too
      @api.create_unprivileged("new-container", {:dist => "centos", :r => 7, :arch => "amd64"}, [], :out => StringIO.new(""))

      # defaults to --arch amd64
      @api.create_unprivileged("new-container", {:dist => "debian", :release => "wheezy"}, [], :out => StringIO.new(""))

      # accepts params for command which are kept separate from template options
      @api.create_unprivileged("new-container", {:d => "ubuntu", :r => "precise", :a => "amd64"}, %w(-f new-lxc.config -B zfs))
    end

    expected = [
      "lxc-create -n new-container -t download -- -d ubuntu -r trusty -a amd64",
      "lxc-create -n new-container -t download -- --dist centos -r 7 --arch amd64",
      "lxc-create -n new-container -t download -- --dist debian --release wheezy --arch amd64",
      "lxc-create -n new-container -t download -f new-lxc.config -B zfs -- -d ubuntu -r precise -a amd64"
    ]
    assert_equal expected, @commands
  end

  def test_start_ephemeral
    stub_spawn(@api, 2, 0, "something") do
      @api.start_ephemeral("test", "original-container")
      @api.start_ephemeral("test", "original-container", ["-d", "--bdir=/mnt/foodisk"])
    end

    assert_equal ["lxc-start-ephemeral -n test -o original-container -d", "lxc-start-ephemeral -n test -o original-container -d --bdir=/mnt/foodisk"], @commands
  end

  def test_clone
    stub_spawn(@api, 2, 0, "something") do
      @api.clone("test", "original-container")
      @api.clone("test", "original-container", ["-M", ["-P", "/opt/lxc"]])
    end

    assert_equal ["lxc-clone -n test -o original-container -s --backingstore=overlayfs", "lxc-clone -n test -o original-container -M -P /opt/lxc"], @commands
  end

  def test_start
    stub_spawn(@api, 2, 0, "something") do
      @api.start("test")
      @api.start("test", ["-d", ["-v", "RBENV_DEBUG=true"], ["-v", "BUNDLER_PATH=/opt/local/bundle"]])
    end

    assert_equal ["lxc-start -n test -d", "lxc-start -n test -d -v RBENV_DEBUG=true -v BUNDLER_PATH=/opt/local/bundle"], @commands
  end

  def test_stop
    stub_spawn(@api, 2, 0, "something") do
      @api.stop("test")
      @api.stop("test", ["-r"])
    end

    assert_equal ["lxc-stop -n test", "lxc-stop -n test -r"], @commands
  end

  def test_destroy
    stub_spawn(@api, 2, 0, "something") do
      @api.destroy("test")
      @api.destroy("test", ["-f"])
    end

    assert_equal ["lxc-destroy -n test", "lxc-destroy -n test -f"], @commands
  end

  def test_ls
    stub_spawn(@api, 2, 0, "something") do
      @api.ls
      @api.ls(["--running", "-1"])
    end

    assert_equal ["lxc-ls --active", "lxc-ls --running -1"], @commands
  end

  def test_attach
    stub_spawn(@api, 2, 0, "something") do
      @api.attach("test", "uname -r")
      @api.attach("test", "uname -r", ["-o", "lxc.log", "--logpriority=DEBUG"])
    end

    assert_equal ["lxc-attach -n test --clear-env -o /dev/stdout -- uname -r", "lxc-attach -n test -o lxc.log --logpriority=DEBUG -- uname -r"], @commands
  end

  def test_config
    stub_spawn(@api, 2, 0, "something") do
      @api.config("lxc.lxcpath")
    end

    assert_equal ["lxc-config lxc.lxcpath"], @commands
  end

end
