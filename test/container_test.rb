require File.expand_path("test_helper", File.dirname(__FILE__))

class ContainerTest < Minitest::Test
  parallelize_me!

  include FakeExec

  def setup
    @commands = []
    @container = MiniLXC::Container.new("test-container")
  end

  def test_running
    stub_spawn(@container.api, 2, 0, "original-container\n") do
      assert !@container.running?
    end

    stub_spawn(@container.api, 2, 0, "original-container\ntest-container\nfoo-container\n") do
      assert @container.running?
    end
  end

  def test_exist
    stub_spawn(@container.api, 2, 0, "original-container\n") do
      assert !@container.exist?
    end

    stub_spawn(@container.api, 2, 0, "original-container\ntest-container\nfoo-container\n") do
      assert @container.exist?
    end
  end

  def test_create_unprivileged
    api = MiniLXC.new
    stub_spawn(api, 2, 0, "ok") do
      @container = MiniLXC::Container.create_unprivileged("test-ubuntu", {:dist => "ubuntu", :release => "xenial"}, :params => %w(-B overlay), :client => api)
    end

    assert_equal ["lxc-create -n test-ubuntu -t download -B overlay -- --dist ubuntu --release xenial --arch amd64"], @commands
    assert_equal "test-ubuntu", @container.name
  end

  def test_create_from_base_container
    api = MiniLXC.new
    stub_spawn(api, 2, 0, "ok") do
      api.stub :lxc_version, Gem::Version.new("1.0.8") do
        @container = MiniLXC::Container.create_from_base_container("lxc-1-container", "original-container", :client => api)
        assert_equal "lxc-1-container", @container.name
      end

      api.stub :lxc_version, Gem::Version.new("2.0.3") do
        @container = MiniLXC::Container.create_from_base_container("lxc-2-container", "original-container", :client => api)
        assert_equal "lxc-2-container", @container.name
      end
    end

    assert_equal ["lxc-clone -n lxc-1-container -o original-container -s -B overlayfs", "lxc-copy -n original-container -N lxc-2-container -s -B overlay"], @commands
  end

  def test_ephemeral
    api = MiniLXC.new
    stub_spawn(api, 2, 0, "ok") do
      api.stub :lxc_version, Gem::Version.new("1.0.8") do
        @container = MiniLXC::Container.ephemeral("lxc-1-container", "original-container", :client => api)
        assert_equal "lxc-1-container", @container.name
      end

      api.stub :lxc_version, Gem::Version.new("2.0.3") do
        @container = MiniLXC::Container.ephemeral("lxc-2-container", "original-container", :client => api)
        assert_equal "lxc-2-container", @container.name
      end
    end

    assert_equal ["lxc-start-ephemeral -n lxc-1-container -o original-container -d -U overlayfs", "lxc-copy -n original-container -N lxc-2-container -e -s -d -B overlay"], @commands
  end

end
