require 'open3'
require 'johngui/error'
require 'johngui/config'

module JohnGUI
  
  class John
    
    def initialize()
      JohnGUI::Config.read_in_config
    end
    
    def add_arguments(array)
      @arguments = array
    end
    
    def binary
      JohnGUI.instance_variable_get('@john')
    end
    
#    def wordlist_crack(passwordfile,wordlist, type=nil)
#      type = type || 'md5'
#      @arguments = []
#      wordlist = nil
#      passwordfile = nil
#      if File.exist?(passwordfile)
#        passwordfile = passwordfile
#      else
#        raise PasswordFileException.new("no such passwordfile: #{passwordfile}")
#      end
#      
#      if File.exist?(wordlist)
#        wordlist = wordlist
#      else
#        raise WordlistException.new("no such wordlist: #{wordlist}")
#      end
#      
#      @arguments << "-wordlist=#{wordlist} #{passwordfile}"
#    end
    
    def passthrough(string)
      @arguments = string
    end
    
    def exec
      puts "running command: #{binary()} #{@arguments.join(' ')}"
      @process = IO.popen("#{binary()} #{@arguments.join(' ')}") do |io|
        loop  do
          data = io.readlines
          unless data.empty?
            puts "got data: #{data}"
            return data
          end
          sleep 5
        end
      end
    end
    
    def cancel
      `killall -9 john`
    end
    
  end
end


if __FILE__ == $0
  require 'config'
  include JohnGUI
  
  john = John.new
  puts john.binary
  puts JohnGUI.instance_variable_get('@john')
  
end