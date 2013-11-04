require 'sinatra/base'

require './rails_cookie_middleware'
require './pub_sub'

class App < Sinatra::Base
  disable :run

  use RailsCookieMiddleware, key: '_devise_example_session',
    secret: 'e5df37d3c04900f9e4cb0e2cfe6dd0d45aeadaffaa1412b87b4f72a4b82eb7f3e533770770ba950a52e8df2e40ca52fe6c7df3875b78b6e493a64acc00f51b55'

  get '/stream/test' do
    erb :index
  end

  get '/stream/:channel' do
    return unless env['_devise_example_session']['warden.user.user.key']

    channel = params[:channel]
    pub_sub = PubSub.new(channel)

    content_type 'text/event-stream'
    response.header['X-Accel-Buffering'] = 'no'

    stream :keep_open do |out|
      pub_sub.subscribe do |message|
        if out.closed?
          pub_sub.unsubscribe
          next
        end

        out << "event: #{channel}\n\n"
        out << "data: #{message}\n\n"
      end
    end
  end
end
