# mini-lxc
Minimalistic Ruby API for LXC

*mini-lxc* is a simple, minimal Ruby library that uses the LXC command-line API rather than the C library bindings to create, control, and destroy LXC containers. Using the command-line API ensures that anything *mini-lxc* does is manually reproducable, and that it works across different rubies (e.g. MRI, JRuby, etc).
