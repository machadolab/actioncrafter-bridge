require 'dino'
require 'json'
require 'faye/websocket'
require 'eventmachine'
require './helpers'


ACTIONCRAFTER_URL = 'ws://ws.actioncrafter.com:8080?key=121212'
OUR_CHANNEL_NAME = 'arduino'

ws = nil


board = Dino::Board.new(Dino::TxRx.new)
led1 = Dino::Components::Led.new(pin: 13, board: board)

button1 = Dino::Components::Button.new(pin: 2, board: board)

button1.up do
  puts "button1 up"

  ws.send("action minecraft name=rsc&args=on+front_door")
end

button1.down do
  puts "button1 down"

  ws.send("action minecraft name=rsc&args=off+front_door")
end


led1_state = false

EM.run do
  ws = Faye::WebSocket::Client.new(ACTIONCRAFTER_URL)

  ws.on :open do |event|
    puts "Websocket to actioncrafter is open"
    ws.send("subscribe "+OUR_CHANNEL_NAME)
  end


  ws.on :message do |msg|

    puts "Got message #{msg.data}"

    begin

      event = JSON.parse(msg.data)

      if event['name'] == 'light_on'
        led1.send(:on)
        led1_state = true
      end

      if event['name'] == 'light_off'
        led1.send(:off)
        led1_state = false
      end

      if event['name'] == 'light_toggle'
        if led1_state
          led1.send(:off)
          led1_state = false
        else
          led1.send(:on)
          led1_state = true
        end
      end

    rescue Exception => e
      puts "Exception while processing message #{msg}"
    end


  end


  ws.on :close do |event|
    puts "Websocket closed: #{event.code} - #{event.reason}"
    ws = nil
  end
end

