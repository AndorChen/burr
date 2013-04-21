# Much of these code stole from bundler.

module Burr
  class UI

    attr_accessor :shell

    def initialize
      Thor::Base.shell = Thor::Shell::Basic if !STDOUT.tty?
      @shell = Thor::Base.shell.new
    end

    def info(msg, newline = nil)
      tell_me(msg, nil, newline)
    end

    def confirm(msg, newline = nil)
      tell_me(msg, :green, newline)
    end

    def warn(msg, newline = nil)
      tell_me(msg, :yellow, newline)
    end

    def error(msg, newline = nil)
      tell_me(msg, :red, newline)
    end

    def debug(msg, newline = nil)
      tell_me(msg, nil, newline) if debug?
    end

    def trace(e, newline = nil)
      msg = ["#{e.class}: #{e.message}", *e.backtrace].join("\n")
      tell_me(msg, nil, newline)
    end

    private

    # valimism
    def tell_me(msg, color = nil, newline = nil)
      newline.nil? ? @shell.say(msg, color) : @shell.say(msg, color, newline)
    end

  end
end
