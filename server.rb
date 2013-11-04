require 'thin'
require 'eventmachine'

require './pub_sub'
require './app'

pub_sub = PubSub.new('channel_1')
EM.run do
  EM.add_periodic_timer(1) do
    pub_sub.publish("foo#{rand(10)}")
  end

  Thin::Server.start(App, '0.0.0.0', 4567)

  Signal.trap("INT")  { EM.stop }
  Signal.trap("TERM") { EM.stop }
end
