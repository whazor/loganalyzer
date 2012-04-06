require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'haml'
require 'sass'
require 'coffee-script'

set :public_folder, File.dirname(__FILE__) + '/static'

get '/' do
  haml :'haml/index'
end

get '/css/style.css' do
  sass :'sass/style'
end

get '/js/application.js' do
  coffee :'coffeescript/application'
end
