#!/usr/bin/env ruby

module Oxidized
  require 'oxidized'
  class Fetch
    attr_reader :model

    class ScriptError   < OxidizedError; end
    class NoNode        < ScriptError;   end
    class InvalidOption < ScriptError;   end
    class NoConnection  < ScriptError
      attr_accessor :node_error
    end

    private

    # @param [Hash] opts options for Oxidized::Fetch
    # @option opts [String]  :host      hostname or ip address for Oxidized::Node
    # @option opts [String]  :model     node model (ios, junos etc) if defined, nodes are not loaded from source
    # @option opts [Fixnum]  :timeout   oxidized timeout
    # @option opts [String]  :username  username for login
    # @option opts [String]  :password password for login
    # @option opts [String]  :enable    enable password to use
    # @option opts [String]  :community community to use for discovery
    # @option opts [String]  :protocols protocols to use to connect, default "ssh ,telnet"
    # @option opts [boolean] :verbose   extra output, e.g. show command given in output
    # @yieldreturn [self] if called in block, returns self and disconnects session after exiting block
    # @return [void]
    def initialize opts, &block
      group       = opts.delete :group
      host        = opts.delete :host
      model       = opts.delete :model
      timeout     = opts.delete :timeout
      username    = opts.delete :username
      password    = opts.delete :password
      enable      = opts.delete :enable
      community   = opts.delete :community
      @verbose    = opts.delete :verbose
      CFG.input.default = opts.delete :protocols if opts[:protocols]
      raise InvalidOption, "#{opts} not recognized" unless opts.empty?

      @@oxi ||= false
      if not @@oxi
        Oxidized.mgr = Manager.new
        Oxidized.Hooks = HookManager.from_config CFG
        @@oxi = true
      end

      @node = if model
        Node.new(:name=>host, :model=>model)
      else
        Nodes.new(:node=>host).first
      end
      if not @node
        begin
          require 'corona'
          community ||= Corona::CFG.community
        rescue LoadError
          raise NoNode, 'node not found'
        end
        node = Corona.poll :host=>host, :community=>community
        raise NoNode, 'node not found' unless node
        @node = Node.new :name=>host, :model=>node[:model]
      end
      @node.group[:group] = group if group
      @node.auth[:username] = username if username
      @node.auth[:password] = password if password
      CFG.vars.enable = enable if enable
      CFG.timeout = timeout if timeout

      status, config = @node.run
      if status == :success
        Oxidized.Hooks.handle :node_success, :node => @node
        msg = "update #{@node.name}"
        msg += " from #{@node.from}" if @node.from
        msg += " with message '#{@node.msg}'" if @node.msg
        if @node.output.new.store @node.name, config, :msg => msg, :user => @node.user, :group => @node.group
          Oxidized.Hooks.handle :post_store, :node => @node
          STDERR.write "Configuration updated for #{@node.group}/#{@node.name}\n" if @verbose
          exit 1
        end
        STDERR.write "Configuration NOT updated for #{@node.group}/#{@node.name}\n" if @verbose
        exit 0
      else
        Oxidized.Hooks.handle :node_fail, :node => @node
        STDERR.write "An unexpected error occurred\n" if @verbose
        exit -1
      end
    end
  end
end
