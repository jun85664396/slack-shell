$LOAD_PATH << File.join('lib')
require 'readline'
require "net/https"
require "faye/websocket"
require "eventmachine"
require 'dotenv'
require "slack"
require "app"
require "json"

Dotenv.load

App.new
