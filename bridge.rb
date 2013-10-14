require 'dino'
require 'json'
require 'faye/websocket'
require 'eventmachine'
require './helpers'


ACTIONCRAFTER_URL = 'ws://ws.actioncrafter.com:8080?key=121212'
OUR_CHANNEL_NAME = 'arduino'

ws = nil

start_time = Time.now

board = Dino::Board.new(Dino::TxRx.new)
led1 = Dino::Components::Led.new(pin: 13, board: board)
led2 = Dino::Components::Led.new(pin: 12, board: board)

button1 = Dino::Components::Button.new(pin: 2, board: board)
button2 = Dino::Components::Button.new(pin: 3, board: board)

photo_cell = Dino::Components::Sensor.new(pin: 0, board: board)

photo_cell_timer = start_time
light_level_prev = 0
level_change_filter = 5
#

photo_cell.listen do |data|
  now = Time.now
  if photo_cell_timer + 0.1 < now

    light_level = scale_value(data, 200, 800, 180, 60)

    if light_level <= (light_level_prev-level_change_filter) || light_level >= (light_level_prev+level_change_filter)

      puts "Setting light level to #{light_level}"
      ws.send("action minecraft name=time&args=set+#{light_level}00")

      light_level_prev = light_level
    end

    photo_cell_timer = now
  end
end


button1.up do
  puts "button1 up"

  ws.send("action minecraft name=rsc&args=front_door")
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

