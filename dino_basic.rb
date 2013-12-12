require 'dino'

config = YAML.load(File.read("config.yml"))

board = Dino::Board.new(Dino::TxRx::Serial.new)
led = Dino::Components::Led.new(pin: config['led_pin'], board: board)
button = Dino::Components::Button.new(pin: config['button_pin'], board: board)


button.down do
  puts 'button down'
end

button.up do
  puts "button up"
end



[:on, :off].cycle do |s|
  led.send(s)
  sleep 0.5
end

