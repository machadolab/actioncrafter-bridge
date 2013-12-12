actioncrafter-bridge
====================


This project contains example ruby code that bridges a Minecraft server running the actioncrafter bukkit plugin
(http://dev.bukkit.org/bukkit-plugins/actioncrafter/) with an Arduino connected to a computer using the dino gem
(https://github.com/austinbv/dino).

Several of the example commands sent to the minecraft server assume the RedStoneTorch (http://dev.bukkit.org/bukkit-plugins/redstonecommand/)
bukkit plugin is installed. This plugin allows a server command to turn a redstone torch on/off or have it toggled.

Bridging between the Arduino and the Minecraft server is done via the Pusher (http://www.pusher.com) service, so you
will need a pusher account first.

All the examples use the config.yaml to configure your pusher key and secret, along with the various Arduino pin mappings.


Files:

* bridge_basic - Listens for a minecraft event to turn on an LED as well as watches an Arduino button to enable a redstone
                 torch.

                 Actioncrafter event name: led
                 Arguments: state - which should be either 'on', 'off' or 'toggle'
                 Example: /action led state=on


* bridge_distance - Watches an HC-SR04 Ultrasonic sensor (same as the Parallax Ping))) sensor) and if its close enough
                    to an object, it enables a redstone torch (for example, to open a door).


* bridge_sunlight - Watches a photocell analog sensor and maps the sensed light value and automatically updates
                    the Minecraft world's time to match


* dino_basic - Basic test that blinks a light and reads button state to make sure dino is functioning properly





Configuration:

The configuration is stored in a yaml formatted file called 'config.yaml'. The file is expected to be located in the same
directory as all the script files.

The following parameters are defined:

* pusher_apikey - (string) Your pusher API key
* pusher_secret - (string) Your pusher secret
* pusher_channel - (string) The name of your pusher channel *without* the leading "private-" prefix (the scripts add that
                            in automatically). Must match the channel configured in the actioncrafter bukkit plugin config.
* led_pin - (int) Arduino digital pin containing the LED
* button_pin - (int) Arduino digitial input pin the button is connected to
* photocell_pin - (int) Arduino analog pin the photocell is connected to
* ultrasonic_pin - (int) Arduino digital pin the ultrasonic sensor is connected to. It assumes you are using single pin
                         mode of the sensor, so if using a 4 pin sensor connect a 1.8k resistor between Trig and Echo pins.


