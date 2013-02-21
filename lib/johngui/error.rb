module JohnGUI
  # thrown if config-file does not exist
  #
  class ConfigException < Exception
    def initialize(args)
      super(args)
    end
  end
  
  # thrown if there is something wrong with the passwordfile
  #
  class PasswordFileException < Exception
    def initialize(args)
      super(args)
    end
  end
  
  # thrown if there is something wrong with the wordlist to be used...
  #
  class WordlistException < Exception
    def initialize(args)
      super(args)
    end
  end
  
  # thrown if something is wrong with creating the crypto-hash
  #
  class CryptError < Exception
    def initialize(args)
      super(args)
    end
  end
  
  # thrown if john can not find any hashes to be used.
  #
  class NoHashError < Exception
    def initialize(args)
      super(args)
    end
  end
  
end