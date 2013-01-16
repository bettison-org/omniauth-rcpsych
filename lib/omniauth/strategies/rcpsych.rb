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
        
        uid {
          access_token["conceptid"]
        }
        
        info do 
          nil
        end
        
        extra do 
          { 'raw_info' => nil }
        end
        
        def request_phase
          redirect "http://www.webtest.rcpsych.ac.uk/RCP60/sp3rd.aspx?SPToken=#{options.sptoken}"
        end

        def callback_phase
          
          access_token = { rcpencrpytion: session[:rcpencryption] }
          session.delete :rcpencryption

          raise "Invalid RCPEncryption Token" if access_token[:rcpencryption].nil?

            client_endpoint = 'http://www.webtest.rcpsych.ac.uk/RCP60/plugins/crosssiteauth/rcpcrosssiteauthprovider.asmx'
            client_namespace = 'http://tempuri.org/'
  
            call_xml = '<?xml version="1.0" encoding="utf-8"?>
                          <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                            <soap:Body>
                              <RetrievePersonID xmlns="http://tempuri.org/">
                                <returnMessage>string</returnMessage>
                                <encryptedUserInfo>' + access_token[:rcpencryption] + '</encryptedUserInfo>
                              </RetrievePersonID>
                            </soap:Body>
                          </soap:Envelope>'
  
            client_headers = {"Content-Length" => call_xml.length, "SOAPAction" => '"http://tempuri.org/RetrievePersonID"'}
            
            client = Savon.client(endpoint: client_endpoint, namespace: client_namespace, headers: client_headers)       
            response = client.call("RetrievePersonID", xml: call_xml)
  
            raise response.soap_fault if response.soap_fault?
            raise response.http_error if response.http_error?
            
            conceptid = xml.xpath('//retrieve_person_id_response/retrieve_person_id_result').inner_text
            
            accesss_token[:conceptid] = conceptid unless conceptid.nil?

        end
  
    end
  end
end

OmniAuth.config.add_camelization('rcpsych', 'RCPsych')
