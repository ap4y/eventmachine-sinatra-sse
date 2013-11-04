require 'action_dispatch'

class RailsCookieMiddleware < Sinatra::Base
  def initialize(app, options)
    @app = app
    @key = options[:key]
    @secret = options[:secret]

    parent_key_generator = ActiveSupport::KeyGenerator.new(@secret, iterations: 1000)
    key_generator = ActiveSupport::CachingKeyGenerator.new(parent_key_generator)

    @parent_jar = ActionDispatch::Cookies::CookieJar.new(key_generator, nil, false)

    @cookie_jar = ActionDispatch::Cookies::EncryptedCookieJar.new(@parent_jar, key_generator, {
      encrypted_cookie_salt:         'encrypted cookie',
      encrypted_signed_cookie_salt:  'signed encrypted cookie'
    })
  end

  def call(env)
    cookie = CGI::Cookie::parse(env['HTTP_COOKIE'])
    if cookie[@key]
      session_cookie = { @key => cookie[@key].first }
      @parent_jar.update(session_cookie)
      env[@key] = @cookie_jar[@key]
    end

    @app.call(env)
  end
end

