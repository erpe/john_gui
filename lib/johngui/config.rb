require 'yaml'
require 'etc'


module JohnGUI
  
  
  module Config
    CONFIG_NAME = ".johnGUI.yml"
    CONFIG_FILE = File.join(Etc.getpwuid.dir,CONFIG_NAME) 
    WORKDIR = File.join(Etc.getpwuid.dir, '.john')
    VERSION = "0.1"
    MD5 = 0
    SHA1 = 1
    SHA2 = 2
    
    def Config.read_in_config()
      Dir.mkdir(Config::WORKDIR) unless File.exist?(Config::WORKDIR)
      if File.exist?(CONFIG_FILE) 
        puts "config exists...#{CONFIG_FILE}" if @debug
        config = YAML::load_file(CONFIG_FILE)
        puts config.inspect if @debug
        if config[:johnGUIversion] == VERSION
          john = config[:john_binary]
          JohnGUI.instance_variable_set('@john',john )
          puts "read in config: #{john}" if @debug
          unless File.executable?(john)
            raise ConfigException.new('john is not executable')
          end
        else
          raise ConfigException.new('config-versions mismatch')
        end
      else
        raise ConfigException.new('no configfile exists')
      end
      
    end
    
  end
end