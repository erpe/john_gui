require 'digest'
require 'digest/md5'
require 'digest/sha1'
require 'tempfile'
require 'johngui/error'

module JohnGUI
  
  
  class RandomString
    
   # returns random string of length 'num' - default 8 chars
   #
   def self.make(num=8)
      a = [("a".."z").to_a,("A".."Z").to_a,(0..9).to_a].flatten
      r = ""
      num.times { r << a[rand(a.length - 1)].to_s }
      r
   end 
  end

  class PasswordFile
    
    attr_reader :file
    attr_reader :name
    
    def initialize(filepath=nil)
      
      if filepath.nil?
        @file = Tempfile.new("johnGUI-")
      else
        if File.exist?(filepath)
          @file = File.open(filepath, "a+")
        else 
          # TODO think about not throwing exception but creating that file...
          raise PasswordFileException.new("password file does not exist: #{filepath}")
        end
      end
      
    end
    
    def path
      @file.path
    end
    
    def add_entry(user, password, type)
      ret = nil
      case type
        when 'md5'
          ret = Digest::MD5.hexdigest(password)
        when 'sha1'
          ret = Digest::SHA1.hexdigest(password)
        when 'sha2'
          ret = Digest::SHA2.hexdigest(password)
        else
          raise CryptError.new("wrong or empty input as phrase")
      end
      if @file.closed?
        @file = File.open(@file.path,'a+')
      end
      @file.puts("#{user}:".concat(ret))
      @file.flush
      @file.rewind
      @file.close
      ret
    end
    
    def finish
      @file.close unless @file.closed?
      File.unlink(@file) if @file.kind_of?(Tempfile)
    end
    
  end
  
end



if __FILE__ == $0
  # TODO Generated stub
end