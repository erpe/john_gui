

module JohnGUI
  
  #require 'johngui/config'
  
  # the main window of the application
  #
  class MainWindow < FXMainWindow
    
    include Config
    
    attr_reader :john
    attr_reader :debug
    
    # initialize 
    #
    def initialize(app,debug)
      @debug = debug
      @app = super(app, "JohnGUI - Verbraucher-Sicher-Online", :width => 850) 
      @pipe = nil   
      puts "calling 'setup_layout'" if debug
      setup_layout
    end
    
    # stelle es dar
    #
    def create  
      super
      show(PLACEMENT_SCREEN)
      checkForExistingConfig
    end
    
    def addInputText(lines)
      @out_text.appendText(lines)
    end
    
    # Remove previous input (if any)
    def closePipe
      if @pipe
        getApp().removeInput(@pipe, INPUT_READ|INPUT_EXCEPT)
        @pipe = nil
      end
    end
    
    
    private
    
    def checkForExistingConfig
      
      if File.exist?(CONFIG_FILE) 
        puts "config exists...#{CONFIG_FILE}" if @debug
        config = YAML::load_file(CONFIG_FILE)
        puts config.inspect if @debug
        if config[:johnGUIversion] == VERSION
          # read-in config
          @john = config[:john_binary]
          Config.instance_variable_set('@john', @john)
          puts "read in config: #{john}" if @debug
          unless File.executable?(@john)
            config_window()
          end
        else
          config_window()
        end
      else
        config_window()
      end
    end
    
    def config_window
      @cfgWindow = ConfigWindow.new(getApp(),debug)
      @cfgWindow.pathField.text = @john
      @cfgWindow.execute
    end
    
    def setup_layout
      create_menue
      create_top_frame
      create_output_frame 
      create_status_bar
      create_action_button
    end
    
    def create_menue
      menu_bar = FXMenuBar.new(self, :opts => FRAME_GROOVE|LAYOUT_FILL_X)
      file_menu = FXMenuPane.new(self)
      
      FXMenuTitle.new(menu_bar,"&File",:popupMenu => file_menu)
      
      preferences_command = FXMenuCommand.new(file_menu,"&Preferences...")
      preferences_command.connect(SEL_COMMAND) do
        config_window()
      end
      
      FXMenuSeparator.new(file_menu)
      
      exit_command = FXMenuCommand.new(file_menu, "E&xit")
      exit_command.connect(SEL_COMMAND) do
        #FXApp::ID_QUIT,
        exit
      end
    end
    
    def create_top_frame
      
      # Headline 
      FXHorizontalFrame.new(self) do |top1_frame|
        FXVerticalFrame.new(top1_frame) do |logo_frame|
          FXImageFrame.new(top1_frame, grabLogoImage, :opts => FRAME_NONE)
        end
        FXVerticalFrame.new(top1_frame, :opts => LAYOUT_FILL_X) do |top_right_frame| 
          label_versio = FXLabel.new(top_right_frame, 'Passwort knacken!')
          versio_font = FXFont.new(app, "Geneva,250")
          versio_font.create
          label_versio.font = versio_font
        end
      end
      
      # Session / Password 
      FXHorizontalFrame.new(self,:opts => LAYOUT_FILL_X) do |input_frame|
        label_font = FXFont.new(app, "Geneva,120")
        label_font_smaller = FXFont.new(app, "Geneva,90")
        FXGroupBox.new(input_frame, 'Eingaben', :opts => FRAME_GROOVE|LAYOUT_FILL_X) do |input_group|
          #FXHorizontalFrame.new(input_group, :opts => LAYOUT_SIDE_TOP) do |session_frame|
          #  session_label = FXLabel.new(session_frame, 'Name:')
          #  session_label.font = label_font
          #  session_label.padLeft = 128
          #  @session_name = FXTextField.new(session_frame,35, :opts => TEXTFIELD_NORMAL)
          #end
          #@session_name = 
          FXHorizontalFrame.new(input_group, :opts => LAYOUT_SIDE_TOP) do |password_frame|
            password_label = FXLabel.new(password_frame, 'Passwort:')
            password_label.font = label_font
            password_label.padLeft = 100
            @passwordText = FXTextField.new(password_frame,35, :opts => TEXTFIELD_PASSWD|TEXTFIELD_NORMAL)
            @passwordText.font = label_font
            @passwordConfirmText = @passwordText
          end
          FXButton.new(input_group, "Knack das Passwort!", :opts => BUTTON_NORMAL|LAYOUT_CENTER_X) do |button|
            button.padLeft = 20
            button.padRight = 20
            button.padTop = 10
            button.padBottom = 10
            button.font = label_font
            button.connect(SEL_COMMAND) do |sender,sel,data| 
              if @passwordText.text == @passwordConfirmText.text
                puts "got a password - processing takes place... with: #{@passwordText.text}" if @debug
                @statusBar.statusLine.normalText = "Bearbeite den Crypto-Hash..."
                processPassword()
              else
                @passwordText.text = ""
                @passwordConfirmText.text = ""
                @statusBar.statusLine.normalText = "passwords mismatch..."
              end
            end
          end
        end
      end
      
      FXHorizontalFrame.new(self, :opts => LAYOUT_FILL_X) do |output_frame|
        label_font = FXFont.new(app, "Geneva,120,bold")
        out_font = FXFont.new(app, "Geneva,120")
        FXGroupBox.new(output_frame, 'Ausgaben', :opts => FRAME_GROOVE|LAYOUT_FILL_X) do |output_group|
          _start_passwd = 'Geknackt: '
          _start_hash = 'Verschlüsselt: '
          @hash_label = FXLabel.new(output_group, _start_hash)
          @passwd_resultat_label = FXLabel.new(output_group, _start_passwd)
          [@passwd_resultat_label].each do |x|
            x.font = label_font
            x.padLeft = 20
          end
          
          #@time_start_label = FXLabel.new(output_group, "Start: ")
          #@time_stop_label = FXLabel.new(output_group, "Stop: ")
          @time_run_label = FXLabel.new(output_group, "Dauer: ")
          [@time_run_label].each do |x|
            x.font = label_font
            x.padLeft = 20
          end
        end
      end
    end
    
    
    
    
    def create_output_frame
      
      FXHorizontalFrame.new(self, :opts => LAYOUT_FILL_X|FRAME_NORMAL) do |o_frame|
          FXLabel.new(o_frame, "Log:")
          @out_text = FXText.new(o_frame, :opts => TEXT_AUTOSCROLL)
          @out_text.visibleRows = 16
          @out_text.visibleColumns = 160
      end
    end 
    
    def create_status_bar
      @bottom_frame = FXHorizontalFrame.new(self, :opts => LAYOUT_FILL_X|LAYOUT_SIDE_BOTTOM)
      @statusBar = FXStatusBar.new(@bottom_frame, :opts => LAYOUT_FILL)
    end
    
    def create_action_button
      cancel_button = FXButton.new(@bottom_frame, "Cancel it...", :opts => BUTTON_NORMAL|LAYOUT_RIGHT )
      cancel_button.connect(SEL_COMMAND) do |sender, sel,data|
        time_passed = Stopwatch.instance.stop(true) 
        if time_passed
          @time_stop_label.text = "Stop: " + Stopwatch.instance.stop_time.to_s
          @statusBar.statusLine.normalText = "process cancelled - time passed: #{time_passed}"
        end
        onCancelButtonPressed()
      end
    end
    
    def onCancelButtonPressed()
      
      @passwd_resultat_label.text = 'Phrase: '
      @hash_label.text = 'Crypto-Hash: '
      @running = false
      @john_session.cancel_john if @john_session
      @time_start_label.text = "Start: "
      @time_stop_label.text = "Stop: "
      @time_run_label.text = "Dauer: "
      getApp().endWaitCursor
      nil
    end
    
    def processPassword()
      # TODO clean this:
      
      @session_name = RandomString.make
      @passwordText.text
      type = 'md5'
      #if @hash_choice.value == 0
      #  type = 'md5'
      #end
      #if @hash_choice.value == 1
      #  type = 'sha1'
      #end
      #if @hash_choice.value == 2
      #  type = 'sha2'
      #end
      puts "trying type: #{type}" if @debug
      puts "about to delegate...." if @debug
      p = PasswordFile.new()
      _hash = p.add_entry(@session_name, @passwordText.text, type)
      #@hash_label.text = type + ":" + _hash
      @hash_label.text = @hash_label.text + " " + _hash
      @john_session = JGSession.new(@session_name,{:type => type, :passwd => p.path })
      Stopwatch.instance.reset
      @time_start_label.text = "Start: " + Stopwatch.instance.start.to_s
      
      @running = true
      
      Thread.new do
        out = ['*']
        while @running
         (out.length > 40) ? (out = ['*']) : out.push('*')    
          @statusBar.statusLine.normalText = "running: #{out.join('')}"
          sleep 0.1
        end
      end
      
      sleep 0.5
      
      Thread.new do
        Dir.mkdir(Config::WORKDIR) unless File.exist?(Config::WORKDIR)  # TODO place this more adequate...
        Dir.chdir(Config::WORKDIR) do
          begin
            app = getApp()
            app.beginWaitCursor 
            ret = @john_session.execute_john()
            @running = false
            @time_stop_label.text = "Stop: " + Stopwatch.instance.time.to_s
            @time_run_label.text = "Dauer: " + Stopwatch.instance.stop.to_s
            @statusBar.statusLine.normalText = "I did it: #{ret[0]} - #{ret[1]}"
            
            @passwd_resultat_label.text = @passwd_resultat_label.text.concat(ret[1])
            #puts ret + "running: #{@running}"
            FXMessageBox.warning(app,MBOX_OK, "Passwort geknackt!", "        #{ret[1]}         ")
            app.endWaitCursor
          rescue NoHashError => e
            @statusBar.statusLine.normalText = e.to_s
            @running = false
            getApp().endWaitCursor
          end
        end
        
      end
      
      sleep 0.2
      
      Thread.new do
        create_output
      end
      
    end
    
    def create_output
      # Stop previous command
      closePipe
      @out_text.text = ""
      logfile = File.join(Config::WORKDIR, @session_name + ".log")
      puts "reading log: #{logfile}" if @debug
      @pipe = IO.popen("tail -f #{logfile}")
      
      # Register input callbacks and return
      getApp().addInput(@pipe, INPUT_READ) do
        data = @pipe.read_nonblock(256)
        if data && data.length > 0
          @out_text.appendText(data)
        else
          @out_text.appendText("no data in pipe ...")
          closePipe
        end
      end
    end
    
    def grabLogoImage
      File.open(File.join(File.dirname(__FILE__),"..","..","icons","versio_logo.png"), "rb") do |f|
        if File.exists?(f)
          FXPNGImage.new(getApp(), f.read, :opts => IMAGE_ALPHAGUESS|IMAGE_OPAQUE)
        else
          raise "no such path: #{f.inspect}"
        end
      end
    end
    
  end
  
end
# direkter aufruf mit ruby?
#
if __FILE__ == $0
  
  require 'johngui/error'
  require 'johngui/config'
  require 'johngui/config_window'
  require 'johngui/splash_window'
  require 'johngui/stopwatch'
  require 'johngui/john'
  require 'joingui/crypter'
  
  include JohnGUI
  
  FXApp.new do |app|
    #JohnGUISplashWindow.new(app)
    debug = true
    JohnGUIWindow.new(app,debug)
    app.create
    app.run 
  end 
end
