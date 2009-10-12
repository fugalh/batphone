require 'agi'
require 'eventmachine'

class FastAGIProtocol < EventMachine::Protocols::LineAndTextProtocol
  include AGIMixin

  def initialize
    super
    @agi_mode = :environment
    @defer_queue = []
  end

  def receive_line(line)
    begin
      if @agi_mode == :environment
        if not parse_env line
          @agi_mode = :commands
          agi_post_init if respond_to? :agi_post_init
        end
      else # @agi_mode == :commands
        d = @defer_queue.shift
        throw 'Received unexpected message: #{line.inspect}' if d.nil?
        @log.debug "<< "+line if not @log.nil?
        d.succeed Response.new(line)
      end
    rescue Exception => e
      @log.error e.inspect if not @log.nil?
    end
  end

  # Send a command, and return a Deferrable for the Response object.
  def send(cmd, *args)
    msg = build_msg(cmd, *args)
    @log.debug ">> "+msg if not @log.nil?
    send_data msg

    # Queue the defer. The AGI protocol may be synchronous, but that
    # doesn't stop us from issueing more commands and expecting the
    # responses in order.
    d = EM::DefaultDeferrable.new
    @defer_queue << d
    d
  end
end
