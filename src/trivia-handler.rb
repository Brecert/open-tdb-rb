require_relative './trivia-getter.rb'
module OpenTDB
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

    def question()
      @json['question']
    end

    def answers()
      self.answer_join()
    end    

    def answer(answer = 0)
      self.answer_join()[answer]
    end

    def correct_answer()
      @json['correct_answer']
    end

    def incorrect_answers()
      

    def answer_join()
      qs = Array.new()
      if self.type === 'boolean'
        qs.insert(0, @json['correct_answer'])
        qs.concat(@json['incorrect_answers'])
        qs.sort! { |x,y| x <=> y } # Reverse. (True, False) instead of (False, True)
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
  end

  class Handler
    def initialize(json)
      @json = json
    end

    def questions()
      @json['results']
    end

    def question(num = 0)
      Question.new(@json['results'][num])
    end
  end
end

# class OpenTDB
#   def initialize(json)
#     @json = json
#     @encoding = 'default'
#   end
# end

tdb = OpenTDB::Getter.new()
# puts tdb.get_api('/api.php', amount: 1)
# p tdb.get_token
# p tdb.reset_token
p tdb.get_questions