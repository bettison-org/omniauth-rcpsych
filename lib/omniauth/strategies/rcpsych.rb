#require 'omniauth-oauth'
require 'omniauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class RCPsych 
      include OmniAuth::Strategy

        args [:sptoken]

        option :name, 'rcpsych'
        
        uid {
          '12345'
        }
        
        info do 
          {
          :first_name => 'hello',
          :last_name => 'world'          
          }
        end
        
        extra do 
          { 'raw_info' => raw_info }
        end
        
        def request_phase
          redirect "http://www.webtest.rcpsych.ac.uk/RCP60/sp3rd.aspx?SPToken=#{options.sptoken}"
        end

        def callback_phase
          raise access_token.inspect
        end
  
    end
  end
end
OmniAuth.config.add_camelization('rcpsych', 'RCPsych')
