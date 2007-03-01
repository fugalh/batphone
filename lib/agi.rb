require 'logger'
# Asterisk Gateway Interface
# 
# Synopsis:
#   a = AGI.new
#   a.answer
#   r = a.get_data('tt-monkeys')
#   digits = r.result
class AGI
  def initialize(io_in=STDIN, io_out=STDOUT)
    @io_in = io_in
    @io_out = io_out

    # read vars
    @env = {}
    while (line = @io_in.readline.strip) != ''
      k,v = line.split(':')
      k.strip! if k
      v.strip! if v
      k = $1 if k =~ /^agi_(.*)$/
      @env[k] = v
    end

    @log = Logger.new(STDERR)
  end
  # Logger object, defaults to Logger.new(STDERR)
  attr_accessor :log

  # A Hash with the initial environment. Leave off the agi_ prefix
  attr_accessor :env
  alias :environment :env

  # Environment access shortcut. Use strings or symbols as keys.
  def [](key)
    @env[key.to_s]
  end

  # Send the given command and arguments. Converts nil and '' in args to literal empty quotes
  def send(cmd, *args)
    args.map! {|a| (a.nil? or a == '') ? '""' : a}
    msg = [cmd, *args].join(' ')
    @log.debug ">> "+msg
    @io_out.puts msg
    @io_out.flush # I'm not sure if this is necessary, but just in case
    Response.new(@io_in.readline)
  end

  # Shortcut for send. e.g. a.say_time(Time.now.to_i,nil) is the same as
  # a.send("SAY TIME",Time.now.to_i,'""')
  def method_missing(symbol, *args)
    cmd = symbol.to_s.upcase.tr('_',' ')
    send(cmd, *args)
  end

  # The answer to every send is one of these.
  class Response
    # Raw response string
    attr_accessor :raw
    # The return code, usually (almost always) 200
    attr_accessor :code
    # The result value
    attr_accessor :result
    # The note in parentheses (if any), stripped of parentheses
    attr_accessor :parenthetical
    alias :note :parenthetical
    # The endpos value (if any)
    attr_accessor :endpos

    # raw:: A string of the form "200 result=0 [(foo)] [endpos=1234]"
    #
    # The variables are populated as you would think. The parenthetical note is
    # stripped of its parentheses.
    #
    # Don't forget that result is often an ASCII value rather than an integer
    # value. In that case you should test against ?d where d is a digit.
    def initialize(raw)
      @raw = raw
      @raw =~ /^(\d+)\s+result=(-?\d+)(?:\s+\((.*)\))?(?:\s+endpos=(-?\d+))?/
      @code = ($1 and $1.to_i)
      @result = ($2 and $2.to_i)
      @parenthetical = $3
      @endpos = ($4 and $4.to_i)
    end
  end
end
