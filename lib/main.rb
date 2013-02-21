require 'rubygems'
gem 'fxruby'
require 'fox16'
require 'etc'
require 'yaml'

include Fox

# direkter aufruf mit ruby?
#
if __FILE__ == $0
  
  require 'johngui/error'
  require 'johngui/config'
  require 'johngui/config_window'
  require 'johngui/splash_window'
  require 'johngui/stopwatch'
  require 'johngui/john'
  require 'johngui/crypter'
  require 'johngui/main_window'
  require 'johngui/jg_session'
  
  include JohnGUI
  
  FXApp.new do |app|
    #JohnGUISplashWindow.new(app)
    debug = true
    MainWindow.new(app,debug)
    app.create
    app.run 
  end 
end