# mini-lxc
Minimalistic Ruby API for LXC

*mini-lxc* is a simple, minimal Ruby library that uses the LXC command-line API rather than the C library bindings to create, control, and destroy LXC containers. Using the command-line API ensures that anything *mini-lxc* does is manually reproducible, and that it works across different rubies (e.g. MRI, JRuby, etc).

## mini-lxc supports both LXC 1 and LXC 2

*mini-lxc* implements common container manipulation operations (creating & destroying containers, executing commands in containers, etc). *mini-lxc* was intended to manage **unprivileged containers**, and thus, does not support privileged containers.

## LXC 2 caveats and LXD
*mini-lxc* _**does not yet support container management through the LXD client command,**_ `lxc`; *mini-lxc* uses the `lxc-*` client commands. While this is the default setup on Fedora, one must install the `lxc` transitional package for Ubuntu 16.04. This can be achieved by running:

```
sudo apt-get install -y lxc2 lxc
```

## Usage

*mini-lxc* provides both a low-level API (`MiniLXC`) and a high-level API (`MiniLXC::Container`), as well as convenience methods to move data (i.e. text and file streams) between host and container.

### Low-level API: MiniLXC

The low-level API more or less maps to the individual lxc-* commands. The methods provide nice wrappers for the commands, providing sensible default parameters and easy access to input and output streams, return status, etc. If there are any commands that haven't been implemented, don't hesitate to send a [pull request](https://github.com/snap-ci/mini-lxc/pulls). Alternatively, one can always drop down to use the internal `MiniLXC#exec()` method.

Example:

```ruby
# api client instance
lxc = MiniLXC.new

# create a container from a standard template
lxc.create_unprivileged("mycontainer", dist: "ubuntu", release: "xenial")

# all of the low-level API methods return pid, exit_status, and command output (stdout merged with stderr).
# command parameters can be overridden with a parameter array, which is usually the argument after the container name (except in attach() where it is the 3rd argument)
pid, status, output = lxc.start("mycontainer")

raise "Container failed to start: #{output}" unless status.success?

# execute command in container
lxc.attach("mycontainer", "ps -eo pid,command | grep -vF ps")

# passing a block to any low-level API method returns the result of the block
env_vars = lxc.attach("mycontainer", "env") do |pid, status, output|
  output.split("\n").inject({}) do |memo, line|
    name, val = line.trim.split("=")
    memo[name.to_sym] = val
    memo
  end
end

# pass in an IO-like object for STDOUT and/or STDIN for any API method by providing the :in and :out options.
# really, the IO-like object only needs to respond to `<<`
File.open("packages.txt", "w") do |file|
  lxc.attach("mycontainer", "dpkg -l", ["--clear-env"], out: file)
end

lxc.stop("mycontainer", ["-k"])

lxc.destroy("mycontainer", ["-f"])
```

### High-level API: MiniLXC::Container
