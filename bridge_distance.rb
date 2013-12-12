require 'yaml'
require 'pusher-client'
require 'dino'
require './helpers'



config = YAML.load(File.read("config.yml"))

board = Dino::Board.new(Dino::TxRx::Serial.new)

distance = Dino::Components::HCSR04.new(pin: config['ultrasonic_pin'], board: board)


options = {:secret => config['pusher_secret']}
socket = PusherClient::Socket.new(config['pusher_apikey'], options)

channel = socket.subscribe('private-'+config['pusher_channel'])

socket.connect(true) ## run async because sensor reading will keep main thread busy



door_open = false

loop do

  distance.read do |value|
    d =  value.to_i / 29 / 2 # speed of sound in cm/microsecond

    puts "Distance is #{d}"

    # we start to get dino events before pusher subscribes to channel
    # so check subscription is active before sending
    if channel.subscribed

      if d > 0 && d < 60 && !door_open
        socket.send_channel_event(channel.name,
                                  'client-mc_cmd',
                                  cmd: 'rsc', args: 'on front_door')
        puts "Opened front_door"
        door_open = true
      elsif (d < 0 || d > 40) && door_open
        socket.send_channel_event(channel.name,
                                  'client-mc_cmd',
                                  cmd: 'rsc', args: 'off front_door')

        puts "Closed front_door"
        door_open = false
      end

    end

  end

  sleep(0.5)
end


