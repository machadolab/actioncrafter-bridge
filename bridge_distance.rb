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
led2 = Dino::Components::Led.new(pin: 12, board: board)

button1 = Dino::Components::Button.new(pin: 2, board: board)
button2 = Dino::Components::Button.new(pin: 3, board: board)


distance = Dino::Components::HCSR04.new(pin: 9, board: board)


Thread.new do
  door_open = false

  loop do
    begin
      distance.read do |value|
        d =  value.to_i / 29 / 2

        puts "Distance is #{d}"

          if d > 0 && d < 60 && !door_open
            ws.send("action minecraft name=rsc&args=on+side_door")
            puts "Opened side_door"
            door_open = true
          elsif (d < 0 || d > 40) && door_open
            ws.send("action minecraft name=rsc&args=off+side_door")
            puts "Closed side_door"
            door_open = false
          end


      end
    rescue Exception => e
      puts "Got thread exception #{e}"
    end
    sleep(0.5)
  end
end


button1.down do
  puts "button1 down"
  ws.send("action minecraft name=rsc&args=off+front_door")
end


button1.up do
  puts "button1 up"

  ws.send("action minecraft name=rsc&args=on+front_door")
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

