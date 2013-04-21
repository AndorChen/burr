module Burr

  # steal from jekyll: https://github.com/mojombo/jekyll/blob/master/lib/jekyll/plugin.rb
  class Plugin

    PRIORITIES = {
      :lowest  => -100,
      :low     => -10,
      :normal  => 0,
      :high    => 10,
      :highest => 100
    }

    VALIDS = [:before_parse, :after_parse, :before_decorate, :after_decorate]

    class << self

      # Install a hook so that subclasses are recorded. This method is only
      # ever called by Ruby itself.
      def inherited(base)
        subclasses << base
        subclasses.sort!
      end

      # The list of Classes that have been subclassed.
      #
      # @return An array of Class objects.
      def subclasses
        @subclasses ||= []
      end

      # Get or set the priority of this plugin. When called without an
      # argument it returns the priority. When an argument is given, it will
      # set the priority.
      #
      # @param [Symbol] priority The priority (default: nil). Valid options are:
      #                          :lowest, :low, :normal, :high, :highest
      # @return The Symbol priority.
      def priority(priority=nil)
        @priority ||= nil
        if priority && PRIORITIES.has_key?(priority)
          @priority = priority
        end
        @priority || :normal
      end

      # Spaceship is priority [higher -> lower]
      #
      # other - The class to be compared.
      #
      # Returns -1, 0, 1.
      def <=>(other)
        PRIORITIES[other.priority] <=> PRIORITIES[self.priority]
      end

    end

    attr_accessor :book

    # Initialize a new plugin. This should be overridden by the subclass.
    #
    # book - The book object.
    #
    # Returns a new instance.
    def initialize(book)
      @book = book
    end

  end
end
