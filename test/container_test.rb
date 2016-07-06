require File.expand_path("test_helper", File.dirname(__FILE__))

class ContainerTest < Minitest::Test

  include FakeExec

  def setup
    @commands = []
    @container = LXC::Container.new("test-container", "original-container")
  end

  def test_running
    stub_spawn(2, 0, "original-container\n") do
      assert !@container.running?
    end

    stub_spawn(2, 0, "original-container\ntest-container\nfoo-container\n") do
      assert @container.running?
    end
  end

  def test_reify_clones_container_from_base_container
    stub_spawn(2, 0, "ok") do
      @container.reify
    end
    assert_equal ["lxc-clone -o original-container -n test-container -s --backingstore=overlayfs"], @commands
  end

end
