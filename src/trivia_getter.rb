require 'rubygems'
require 'excon'
require 'json'

RES = {
  SUCCESS: {CODE: 0, MESSAGE:"Returned results successfully."},
  NO_RESULTS: {CODE: 1, MESSAGE:"Could not return results. The API doesn't have enough questions for your query. (Ex. Asking for 50 Questions in a Category that only has 20.)"},
  INVALID_PARAMETER: {CODE: 2, MESSAGE:"Contains an invalid parameter. Arguements passed in aren't valid. (Ex. Amount = Five)"},
  TOKEN_NOT_FOUND: {CODE: 3, MESSAGE:"Session Token does not exist."},
  TOKEN_EMPTY: {CODE: 4, MESSAGE:"Session Token has returned all possible questions for the specified query. Resetting the Token is necessary."},
  UNKNOWN_ERROR: {CODE: -1, MESSAGE:"An unknown response_code was given by the api"}
}

class OpenTDB
  attr_accessor :token

  def initialize(base = 'https://opentdb.com/')
    @base = Excon.new(base,  :headers => {    
    'User-Agent'=> 'ruby-opentdb-api',
    'Access-Control-Allow-Origin'=> '*',
    'Cache-Control'=> 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
    'Content-Type'=> 'application/json'})
    @token = nil
  end

  def get_api(path)
    response = @base.get(:path => path)
    json_body = JSON.parse(response.body)
    hsc = self.handle_response_code(json_body['response_code'])
    return json_body
  end

  def get_token()
    get_token = self.get_api('api_token.php?command=request')
    token = get_token['token']
    @token = token
    return token
  end

  def reset_token()
    reset_token = self.get_api("api_token.php?command=reset&token=#{@token}")
    return true
  end

  def get_questions(options = {})
    params = []
    base_url = 'api.php'

    if options.has_key?(:amount)
      params.push("amount=#{URI.encode_www_form_component(options[:amount])}")
    else
      params.push("amount=1")
    end

    if options.has_key?(:category)
      params.push("category=#{URI.encode_www_form_component(options[:category])}")
    end 

    if options.has_key?(:difficulty)
      params.push("difficulty=#{URI.encode_www_form_component(options[:difficulty])}")
    end 

    if options.has_key?(:type)
      params.push("type=#{URI.encode_www_form_component(options[:type])}")
    end 


    if options.has_key?(:encoding)
      params.push("encoding=#{URI.encode_www_form_component(options[:encoding])}")
    end 

    if options.has_key?(:token)
      params.push("token=#{URI.encode_www_form_component(options[:token])}")
    elsif @token != nil
      params.push("token=#{@token}")
    else
      # TODO: Add proper error handling!
      puts 'Token cannot be nil! Please use get_token() to generate one!'
    end

    # TODO: Finish and add url request stuff.
    url ="#{base_url}?#{params.join('&')}"
    return self.get_api(url)
    puts url
  end
  # private

  def handle_response_code(code)
    if (code != 0)
      case code
      when RES[:NO_RESULTS][:CODE]
        return RES[:NO_RESULTS][:MESSAGE]

      when RES[:INVALID_PARAMETER][:CODE]
        return RES[:INVALID_PARAMETER][:MESSAGE]

      when RES[:TOKEN_NOT_FOUND][:CODE]
        return RES[:TOKEN_NOT_FOUND][:MESSAGE]

      when RES[:TOKEN_EMPTY][:CODE]
        return RES[:TOKEN_EMPTY][:MESSAGE]
      else
        return RES[:INVALID_PARAMETER][:MESSAGE]
    end
    else 
      return true
    end
  end
end

# otdb = OpenTDB.new
# puts otdb.get_questions()




