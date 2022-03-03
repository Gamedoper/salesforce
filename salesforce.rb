require "httparty"
require 'uri'

# * 
USERNAME = ''
PASSWORD = ''
CLIENT_ID = ''
CLIENT_SECRET = ''
API_VERSION = ''
SECURITY_TOKEN = ''
ACCESS_TOKEN = ''
INSTANCE_URL = ''
SANDBOX_BASE_URL = ''

URL = "#{BASE_URL}/oauth2/token"

class SalesForceApi
	include HTTParty


    def initialize

        data = {
			grant_type: 'password',
			client_id: CLIENT_ID,
			client_secret: CLIENT_SECRET,
			username: USERNAME,
			password: PASSWORD
        }


        response = self.class.post(URL,
          body: URI.encode_www_form(data),
          headers: {
            'Content-Type' => 'application/x-www-form-urlencoded',
          }
        )

        response_body = JSON.parse(response.body)

		raise response_body["error_description"] if response_body["error"]

		@access_token = response_body["access_token"]
		@instance_url = response_body["instance_url"]
		@issued_at = response_body["issued_at"]
		@headers = { Authorization: "Bearer #{@access_token}" }
	end

	def details
		{
			access_token: @access_token,
			instance_url: @instance_url,
			issued_at: @issued_at,
			headers: @headers
		}
	end


	def accounts
		query = {
			q: 'SELECT name Id from Account'
		}

		url = @instance_url + '/services/data/v53.0/query?q=SELECT+name,+Id+from+Opportunity'

		response = self.class.get(
			url,
			:headers => @headers,
		)

		if response.parsed_response.is_a? Array
			resp = response.parsed_response[0]
			raise resp["message"] unless resp["errorCode"].empty?
		end

		{
			total: response.parsed_response["totalSize"],
			records: response.parsed_response["records"]
		}
	end

	
	
end
