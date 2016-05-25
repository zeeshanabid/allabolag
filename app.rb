require 'sinatra'
require 'tilt/erb'
require './organization'

get "/" do
  erb :index, :locals => {:org => nil, :err => nil}
end

post "/search" do
  name   = params[:name]
  locals = {:org => nil, :err => nil}
  begin
    locals[:org] = Organization.search(name)
  rescue Exception => e
    locals[:err] = e.message
  end
  erb :index, :locals => locals
end
