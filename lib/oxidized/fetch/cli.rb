module Oxidized
  require_relative 'fetch'
  require 'slop'
  class Fetch
    class CLI
      class CLIError < ScriptError; end
      class NothingToDo < ScriptError; end

      def run
        connect
      end

      private

      def initialize
        @args, @opts = opts_parse
	Config.load(@opts)
        Oxidized.setup_logger
        Oxidized.config.debug = true if @opts[:debug]
        @host = @args.shift
        @oxf  = nil
        raise NothingToDo, 'no host given' if not @host
      end

      def opts_parse
        slop = Slop.new(:help=>true)
        slop.banner 'Usage: oxf [options] hostname'
        slop.on 'g=', '--group',     'host group'
        slop.on 'm=', '--model',     'host model (ios, junos, etc), otherwise discovered from Oxidized source'
        slop.on 'u=', '--username',  'username to use'
        slop.on 'p=', '--password',  'password to use'
        slop.on 't=', '--timeout',   'timeout value to use'
        slop.on 'e=', '--enable',    'enable password to use'
        slop.on 'c=', '--community', 'snmp community to use for discovery'
        slop.on       '--protocols=','protocols to use, default "ssh, telnet"'
        slop.on 'v',  '--verbose',   'verbose output, e.g. show commands sent'
        slop.on 'd',  '--debug',     'turn on debugging'
        slop.on :terse, 'display clean output'
        slop.parse
        [slop.parse!, slop]
      end

      def connect
        opts = {}
        opts[:host]     = @host
        [:group, :model, :username, :password, :timeout, :enable, :verbose, :community, :protocols].each do |key|
          opts[key] = @opts[key] if @opts[key]
        end
        @oxf = Fetch.new opts
      end
    end
  end
end
