require 'agi'
require 'eventmachine'

class FastAGIProtocol < EventMachine::Protocols::LineAndTextProtocol
  include AGIMixin

  def initialize
    super
    @agi_mode = :environment
  end

  def receive_line(line)
    begin
      if @agi_mode == :environment
        if not parse_env line
          @agi_mode = :commands
          agi_post_init if respond_to? :agi_post_init
        end
      else # @agi_mode == :commands
        # FIXME: handle response
      end
    rescue Exception => e
      @log.error e.inspect if not @log.nil?
    end
  end
end
