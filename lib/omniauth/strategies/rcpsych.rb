#require 'omniauth-oauth'
require 'omniauth'
require 'multi_json'
require 'savon'

module OmniAuth
  module Strategies
    class RCPsych 
      include OmniAuth::Strategy

        args [:endpoint, :sptoken]

        option :name, 'rcpsych'
        option :fields, [:conceptid,:rcpencryption,:secret]
        
        uid { options.concept_id }
        
        info do 
          { 'name' => "Unknown" }
        end
        
        extra do 
          { 'raw_info' => {} }
        end
        
        def request_phase
          redirect "#{options.endpoint}/sp3rd.aspx?SPToken=#{options.sptoken}"
        end

        def callback_phase
                    
          access_token = { rcpencryption: session[:rcpencryption] }

          raise "Invalid RCPEncryption Token" if access_token[:rcpencryption].nil?

          secret = session[:secret] = Time.now.to_f.to_s

          client_wsdl = "#{options.endpoint}/plugins/crosssiteauth/rcpcrosssiteauthprovider.asmx?wsdl"

          client = Savon.client(wsdl: client_wsdl)
          
          message = {}
          message["returnMessage"] = secret
          message["encryptedUserInfo"] = access_token[:rcpencryption]
          
          response = client.call(:retrieve_person_id, message: message )

          raise response.soap_fault if response.soap_fault?
          raise response.http_error if response.http_error?
          
          response_hash = response.to_hash
          
          return_message = response_hash[:retrieve_person_id_response][:return_message]
          
          if return_message == secret
            concept_id = response_hash[:retrieve_person_id_response][:retrieve_person_id_result]
            raise "No PersonID [#{response.inspect}]" if concept_id.nil?
            options.concept_id = concept_id
          else 
            return_message.slice!(secret)
            raise "Invalid return_message: #{return_message}"
          end
          
          super
        end
  
    end
  end
end

OmniAuth.config.add_camelization('rcpsych', 'RCPsych')
