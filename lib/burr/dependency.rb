module Burr
  module Dependency

    # Checks if PrinceXML installed.
    #
    # Returns true if installed, otherwise false.
    def self.prince_installed?
      installed? 'prince'
    end

    # Checks if Dependent libx installed.
    #
    # Returns true if installed, otherwise false.
    def installed?(cmd)
      return true if which(cmd)
      false
    end

    # Finds the executable.
    def which(cmd)
      system "which #{cmd} > /dev/null 2>&1"
    end
  end
end
