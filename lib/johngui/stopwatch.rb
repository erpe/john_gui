require 'singleton'

module JohnGUI
  
  class Stopwatch
    
    include Singleton
    
    attr_reader :start_time
    attr_reader :stop_time
    
    def initialize
      @start_time = nil
      @stop_time = nil
    end
    
    def start
      @start_time = Time.now
      @stop_time = nil
      @start_time
    end
    
    def stop(reset=false)
      @stop_time = Time.now
      t = runtime
      @start_time = nil if reset
      t
    end
    
    def reset
      @start_time = nil
      @stop_time = nil
    end
    
    def time
      Time.now
    end
    
    def runtime
      b = Time.now
      t = @stop_time || b
      t - ( @start_time || b )
    end
    
  end
  
end

if __FILE__ == $0
  # TODO Generated stub
end