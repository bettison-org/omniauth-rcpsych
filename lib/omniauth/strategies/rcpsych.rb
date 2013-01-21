#require 'omniauth-oauth'
require 'omniauth'
require 'multi_json'
require 'savon'

module OmniAuth
  module Strategies
    class RCPsych 
      include OmniAuth::Strategy

        args [:sptoken]

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
          redirect "http://www.webtest.rcpsych.ac.uk/RCP60/sp3rd.aspx?SPToken=#{options.sptoken}"
        end

        def callback_phase
                    
          access_token = { rcpencryption: session[:rcpencryption] }

          raise "Invalid RCPEncryption Token" if access_token[:rcpencryption].nil?

          secret = session[:secret] = Time.now.to_f.to_s
          
          client_endpoint = 'http://www.webtest.rcpsych.ac.uk/RCP60/plugins/crosssiteauth/rcpcrosssiteauthprovider.asmx'
          client_namespace = 'http://tempuri.org/'

          call_xml = '<?xml version="1.0" encoding="utf-8"?>
                        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                          <soap:Body>
                            <RetrievePersonID xmlns="http://tempuri.org/">
                              <returnMessage>' + secret + '</returnMessage>
                              <encryptedUserInfo>' + access_token[:rcpencryption] + '</encryptedUserInfo>
                            </RetrievePersonID>
                          </soap:Body>
                        </soap:Envelope>'

          client_headers = {"Content-Length" => call_xml.length, "SOAPAction" => '"http://tempuri.org/RetrievePersonID"'}
          
          client = Savon.client(endpoint: client_endpoint, namespace: client_namespace, headers: client_headers)       
          response = client.call("RetrievePersonID", xml: call_xml)

          raise response.soap_fault if response.soap_fault?
          raise response.http_error if response.http_error?
          
          response_hash = response.to_hash
          
          return_message = response_hash[:retrieve_person_id_response][:return_message]
          
          if return_message == secret
            concept_id = response_hash[:retrieve_person_id_response][:retrieve_person_id_result]
            raise "No PersonID" if concept_id.nil?
            options.concept_id = concept_id
          else 
            message.slice!(secret)
            raise message
          end
          
          super
        end
  
    end
  end
end

OmniAuth.config.add_camelization('rcpsych', 'RCPsych')
