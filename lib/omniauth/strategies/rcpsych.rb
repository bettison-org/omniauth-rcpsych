require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Rdio via OAuth and retrieve basic user information.
    # Usage:
    #    use OmniAuth::Strategies::Rdio, 'consumerkey', 'consumersecret'
    #
    class RCPsych < OmniAuth::Strategies::OAuth

def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
  opts = {
    :site               => "http://www.webtest.rcpsych.ac.uk/RCP60/sp3rd.aspx?Returnurl=[xyz]&SPTo ken=[pqrst]",
    :request_token_path => "/oauth/request_token",
    :access_token_path  => "/oauth/access_token",
    :authorize_url      => "https://www.rdio.com/oauth/authorize"
  }
  super(app, :rdio, consumer_key, consumer_secret, opts, options, &block)
end

    end
  end
end
