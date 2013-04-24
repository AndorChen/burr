module Burr
  module Dependency

    # Checks if PrinceXML installed.
    #
    # Returns true if installed, otherwise false.
    def self.prince_installed?
      installed? 'prince'
    end

    def self.kindlegen_installed?
      installed? 'kindlegen'
    end

    # Checks if Dependent libx installed.
    #
    # Returns true if installed, otherwise false.
    def self.installed?(cmd)
      return true if which(cmd)
      false
    end

    # Finds the executable.
    def self.which(cmd)
      system "which #{cmd} > /dev/null 2>&1"
    end
  end
end
