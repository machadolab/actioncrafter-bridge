require 'yaml'
require 'pusher-client'
require 'dino'

config = YAML.load(File.read("config.yml"))

board = Dino::Board.new(Dino::TxRx::Serial.new)
led = Dino::Components::Led.new(pin: config['led_pin'], board: board)
button = Dino::Components::Button.new(pin: config['button_pin'], board: board)

options = {:secret => config['pusher_secret']}
socket = PusherClient::Socket.new(config['pusher_apikey'], options)

channel = socket.subscribe('private-'+config['pusher_channel'])


#### Put event bindings under here ####


## Pusher events ##

channel.bind('client-led') do |data|
  args = JSON.parse(data)
  led.send(args['state'].to_sym)
  puts "Setting led to state " + args['state']
end



## Arduino events ##
button.up do
  socket.send_channel_event(channel.name,
                            'client-mc_cmd',
                            cmd: 'rsc', args: 'front_door')
  puts "button pushed"
end



socket.connect(false)



