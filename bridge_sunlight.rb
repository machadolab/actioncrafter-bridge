require 'yaml'
require 'pusher-client'
require 'dino'
require './helpers'

config = YAML.load(File.read("config.yml"))

board = Dino::Board.new(Dino::TxRx::Serial.new)

photo_cell = Dino::Components::Sensor.new(pin: config['photocell_pin'], board: board)

options = {:secret => config['pusher_secret']}
socket = PusherClient::Socket.new(config['pusher_apikey'], options)

channel = socket.subscribe('private-'+config['pusher_channel'])


#### Put event bindings under here ####


## Arduino events ##

start_time = Time.now

photo_cell_timer = start_time
light_level_prev = 0
level_change_filter = 5


photo_cell.listen do |data|
#  puts "Got data #{data}"

  now = Time.now
  if photo_cell_timer + 0.1 < now

    light_level = scale_value(data, 200, 800, 180, 60)

    if light_level <= (light_level_prev-level_change_filter) || light_level >= (light_level_prev+level_change_filter)

      # we start to get dino events before pusher subscribes to channel
      # so check subscription is active before sending
      if channel.subscribed
        puts "Setting light level to #{light_level}"
        socket.send_channel_event(channel.name,
                                  'client-mc_cmd',
                                  cmd: 'time', args: "set #{light_level}00")

        light_level_prev = light_level
      end

    end

    photo_cell_timer = now
  end
end



socket.connect(false)
