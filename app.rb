require 'sinatra'
require 'sinatra/respond_to'
require 'tilt/erb'
require 'json'
require './organization'

Sinatra::Application.register Sinatra::RespondTo

get "/" do
  respond_to do |format|
    format.html {erb :index, :locals => {:org => nil, :err => nil}}
  end
end

post "/search" do
  name   = params[:name]
  locals = {:org => nil, :err => nil}
  begin
    locals[:org] = Organization.search(name)
  rescue Exception => e
    locals[:err] = e.message
  end
  respond_to do |format|
    format.html { erb :index, :locals => locals }
    format.json { (locals[:org] ? locals[:org] : {:err => locals[:err]}).method(:to_json).call }
    format.xml { locals[:org] ? locals[:org].to_xml : "<err>#{locals[:err]}</err>" }
  end
end
