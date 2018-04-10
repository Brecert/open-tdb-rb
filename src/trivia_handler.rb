require 'json'
require 'nokogiri'

class Question
  def initialize(json)
    @json = json
    @encoding = 'default'
  end

  def category()
    return @json['category']
  end

  def type()
    return @json['type']
  end

  def difficulty()
    return @json['difficulty']
  end

  def question(parse = true)
    return self.parser(@json['question'], parse)
  end
  def answers(parse = true)
    return self.answer_join(parse)
  end

  def answer(answer = 0, parse = true)
    self.answer_join(parse)[answer]
  end

  def correct_answer(parse = true)
    return self.parser(@json['correct_answer'], parse)
  end

  def incorrect_answers(parse = true)
    # browsers.include?('Konqueror')
    if self.type() === 'multiple'
      return self.parser(@json['incorrect_answers'], parse)
    elsif type() === 'boolean'
      return self.parser(@json['incorrect_answers'][1], parse)
    else
      # TODD: Proper error handling! 
      puts 'QUESTION TYPE MUST BE A BOOLEAN'
      return
    end
  end

  def correct?(string)
    if string === self.correct_answer()
      return true
    else
      return false
    end
  end

  def incorrect?(string)
    # TODO: Use incorrect_answers() method!
    @json['incorrect_answers'].include?(string)
  # @json['incorrect_answers'].each do |answer|
  #     if string === answer
  #       return true
  #     end 
  #   end
  #   return false
  # end
  end

  # private

  def answer_join(parse = true)
    qs = Array.new()

    if self.type === 'boolean'
      qs.insert(0, @json['correct_answer'])
      qs.concat(@json['incorrect_answers'])
      qs.sort! { |x,y| y <=> x } # Reverse. (True, False) instead of (False, True)
      return qs
    end

    qs.insert(0, @json['correct_answer'])
    # puts "ca> #{qs}"
    qs.concat(@json['incorrect_answers'])
    # puts "ia> #{qs}"
    qs.flatten!
    qs.shuffle!(random: Random.new(@json['correct_answer'].length))
    return qs
  end

  def parser(json_hash, on = true)
    if on === true
      if @encoding === 'default'
        return Nokogiri::HTML.parse( json_hash ).text
      else
        puts 'Unknown Encoding, cannot parse text, wip sorry.'
      end
    else
      return json_hash
    end
  end
end

class QuestionHandler
  def initialize(json)
    @json = json
  end

  def questions()
    return @json['results']
  end

  def question(num = 0)
    return Question.new(@json['results'][num])
  end
end

# json = File.read('response.json')

# # puts json

# qh = QuestionHandler.new(json)
# puts qh.question(0).is_incorrect('Nucleus')










