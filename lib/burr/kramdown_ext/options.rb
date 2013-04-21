module Kramdown
  module Options

    # Parse the given value +data+ as if it was a value for the option +name+ and return the parsed
    # value with the correct type.
    #
    # If +data+ already has the correct type, it is just returned. Otherwise it is converted to a
    # String and then to the correct type.
    def self.parse(name, data)
      raise ArgumentError, "No option named #{name} defined" if !@options.has_key?(name)
      if !(@options[name].type === data)
        data = data.to_s
        data = if @options[name].type == String
                 data
               elsif @options[name].type == Integer
                 Integer(data) rescue raise Kramdown::Error, "Invalid integer value for option '#{name}': '#{data}'"
               elsif @options[name].type == Float
                 Float(data) rescue raise Kramdown::Error, "Invalid float value for option '#{name}': '#{data}'"
               elsif @options[name].type == Symbol
                 data.strip!
                 data = data[1..-1] if data[0] == ?:
                 (data.empty? || data == 'nil' ? nil : data.to_sym)
               elsif @options[name].type == Boolean
                 data.downcase.strip != 'false' && !data.empty?
               else
                 data
               end
      end
      data = @options[name].validator[data] if @options[name].validator
      data
    end

    define(:register, Object, nil, 'Pass in another object.') do |r|
      r
    end

  end
end
