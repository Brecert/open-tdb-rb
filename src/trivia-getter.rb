require "http"
require 'json'

module OpenTDB
	class Getter
	  attr_accessor :token
	  attr_accessor :api_base

  	RES = {
		  SUCCESS: {CODE: 0, MESSAGE:"Returned results successfully."},
		  NO_RESULTS: {CODE: 1, MESSAGE:"Could not return results. The API doesn't have enough questions for your query. (Ex. Asking for 50 Questions in a Category that only has 20.)"},
		  INVALID_PARAMETER: {CODE: 2, MESSAGE:"Contains an invalid parameter. Arguements passed in aren't valid. (Ex. Amount = Five)"},
		  TOKEN_NOT_FOUND: {CODE: 3, MESSAGE:"Session Token does not exist."},
		  TOKEN_EMPTY: {CODE: 4, MESSAGE:"Session Token has returned all possible questions for the specified query. Resetting the Token is necessary."},
		  UNKNOWN_ERROR: {CODE: -1, MESSAGE:"An unknown response_code was given by the api"}
		}.freeze

	  def initialize()
	  	api_base = "https://opentdb.com"
	  	@http = HTTP.headers({
				'User-Agent'=> 'ruby-opentdb-api ',
				'Access-Control-Allow-Origin'=> '*',
				'Cache-Control'=> 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
				'Content-Type'=> 'application/json'
	  	}).persistent api_base
			@token = nil
	  end

	  def get_api(path, params = {})
	  	@http.get(path, :params => params).parse
	  end

	  def get_token
	  	@token = self.get_api('/api_token.php', command: "request")["token"]
	  end

	  def reset_token
	  	self.get_api('/api_token.php',command: 'reset', token: @token)
	  end

	  # QUESTION OPTIONS
	  # :amount[1-50], :catagory[https://opentdb.com/api_category.php], :difficulty[easy, medium, hard], :type[multiple, boolean], :encoding[base64, url3986], token[token]
	  def get_questions(options = {amount: 1})
	  	if @token != nil and options["token"] != nil
	  		options["token"] = @token
	  	end
	  	return self.get_api('/api.php', options)
	  end

	  def handle_response_code(code)
	  	if code != 0
				RES.each do |type|
					if code == type[:CODE]
						raise type[:MESSAGE]
					end
				end
			end
	  end
	end
end

# tdb = OpenTDB.new()
# # puts tdb.get_api('/api.php', amount: 1)
# # p tdb.get_token
# # p tdb.reset_token
# p tdb.get_questions
