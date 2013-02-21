require 'johngui/error'
require 'johngui/john'


module JohnGUI
  
  
  class JGSession
    
    attr_reader :type
    attr_reader :passwd
    attr_reader :wordlist
    attr_reader :session_name
    
    def initialize(session_name, hash)
      @type =  hash.has_key?(:type) ? hash[:type] : 'raw-MD5'
      @passwd = hash.has_key?(:passwd) ? hash[:passwd] : (raise PasswordFileException.new("missing passwd argument...") )
      @wordlist = hash.has_key?(:wordlist) ? hash[:wordlist] : nil
      @session_name = session_name  
    end
    
    def execute_john
      ret = [2]
      @j = John.new
      @j.add_arguments(setup_arguments)
      data = @j.exec
      
      if data.kind_of?(Array)
        # if data length is gt than 1 its positive/cracked
        if data.length > 1
          ret[1] = data[-1].split(" ")[0]
          ret[0] = data[-1].split(" ")[1].gsub("(","").gsub(")","")
        else # else its an error like 'ho hashed loaded'
          raise NoHashError.new("Error: #{data[0].inspect}")
        end
      end
      puts data.inspect
      ret
    end
    
    def cancel_john
      @j.cancel if @j
    end
    
    private
    
    def forward_to_passwordfile
      
    end
    
    def setup_arguments
      args = []
      _format_arg = nil
      case self.type
        when 'md5'
          _format_arg = 'raw-MD5'
        when 'sha1'
          _format_arg = 'raw-sha1'
        when 'sha2'
          _format_arg = 'raw-sha2'
      end
      args.push("--wordlist=#{@wordlist}") if @wordlist && File.exist?(@wordlist)
      args.push("--session=#{@session_name}") if @session_name
      args.push("--format=#{_format_arg}")
      args.push("#{@passwd}") 
    end
    
    
    
  end
  
end