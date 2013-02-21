module JohnGUI
  # not working yet...
  # so not called from anywhere
  #
  class JohnGUISplashWindow < FXSplashWindow
    def initialize(app)
      icon = nil
      File.open(File.join("..","icons", "versio.tif"), "rb") do |f|
        if File.exists?(f)
          icon = FXIcon.new(app,nil, 300,300)
          icon.loadPixels(f)
        else
          raise "no such path: #{f.inspect}"
        end
      end
      super(app,icon)
    end
  end
end

if __FILE__ == $0
  # TODO Generated stub
end