require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'haml'
require 'sass'
require 'coffee-script'
require 'app.rb'

run Sinatra::Application
