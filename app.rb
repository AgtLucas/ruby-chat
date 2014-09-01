require 'thin'
require 'sinatra/base'
require 'em-websocket'

EventMachine.run do
  puts "This is process #{Process.pid}"
  class App < Sinatra::Application
    get '/' do
      erb :index
    end
  end

  @clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '6010') do |ws|
    ws.onopen do |handshake|
      @clients << ws
      ws.send "Connected to #{handshake.path}."
    end

    ws.onclose do
      ws.send "Closed!"
      @clients.exit ws
    end

    ws.onmessage do |msg|
      puts "Received Message: #{msg}"
      @clients.each do |socket|
        socket.send msg
      end
    end
  end

  App.run! :port => 6016
end