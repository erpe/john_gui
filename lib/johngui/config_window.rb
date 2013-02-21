module JohnGUI
  
  class ConfigWindow < FXDialogBox
    
    include Config
    
    attr_accessor :pathField
    
    def initialize(parent,debug)
      @debug = parent
      super(parent, "Preferences", :width => 400) 
      setup_layout
    end
    
    def setup_layout
      packer = FXPacker.new(self, :opts => LAYOUT_FILL_X)
      
      FXVerticalFrame.new(packer, :opts => LAYOUT_FILL_X) do |vframe|
        FXLabel.new(vframe, "First things first - do the config:", :opts => FRAME_GROOVE|LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
        FXVerticalFrame.new(vframe, :opts => LAYOUT_FILL|FRAME_SUNKEN) do |frame|
          FXLabel.new(frame, "Path to john-binary (e.g. /john/run/john )", :opts =>  LAYOUT_SIDE_LEFT)
          FXHorizontalFrame.new(frame, :opts => LAYOUT_FILL) do |hframe|
            @pathField = FXTextField.new(hframe,35)
            FXButton.new(hframe,'select &path',:opts => BUTTON_NORMAL|LAYOUT_LEFT ) do |button|
              button.connect(SEL_COMMAND) do |sender, sel, data| 
                @pathField.text = onFileSelect(sender,sel,data)
              end
            end
          end
        end
      end
      
      FXHorizontalFrame.new(packer, :opts => LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X) do |frame|
        FXButton.new(frame, " &cancel ", :opts => BUTTON_NORMAL|LAYOUT_LEFT  ) do |button|
          button.connect(SEL_COMMAND, method(:onCancel))   
        end
        FXButton.new(frame, " &save ", :opts => BUTTON_NORMAL|LAYOUT_RIGHT) do |button|
          button.connect(SEL_COMMAND, method(:onSave))   
        end
      end
      @statusBar = FXStatusBar.new(self, :opts => LAYOUT_FILL_X|LAYOUT_BOTTOM)       
    end
    
    def onFileSelect(sender,sel,data)
      # is john installed in path?
      path = nil
      if File.exist?(`which john`.chop)
        path = File.dirname(`which john`.chop)
      else
        path = Etc.getpwuid.dir
      end
      result = FXFileDialog.getOpenFilename(self, "select john-binaray", path )   
      return result
    end
    
    def onSave(sender,sel,data)
      puts "save called " if @debug
      msg = ""
      unless File.exist?(@pathField.text) && File.executable?(@pathField.text)
        msg = "error: not existent #{@pathField.text} or john not executable"    
        puts msg if @debug
        @statusBar.statusLine.normalText = msg
        return
      end
      msg =  "#{@pathField.text} will be written to " << CONFIG_FILE
      puts msg if @debug
      cfgHash = Hash.new
      cfgHash[:johnGUIversion] = VERSION
      cfgHash[:john_binary] = @pathField.text
      puts "dumping YAML" if @debug
      YAML::dump(cfgHash, File.open(CONFIG_FILE,"w+"))
      self.handle(sender, MKUINT(ID_ACCEPT, SEL_COMMAND), nil) 
    end
    
    def onCancel(sender, sel, data)
      puts "cancel called" if @debug
      self.handle(sender, MKUINT(ID_CANCEL, SEL_COMMAND), nil)
    end
    
  end
  
end

if __FILE__ == $0
  # TODO Generated stub
end