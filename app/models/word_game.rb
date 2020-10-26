class WordGame

  # Author: Mark Smucker
  # Date: June 2020

  attr_reader :word, :guesses, :wrong_guesses
    
  def initialize(word, availguesses)
    @word = word.downcase
    @guesses = '' # stores all correct guesses
    @wrong_guesses = '' # stores all incorrect guesses
    @availguesses = availguesses
  end  
  
  # returns true if illegal argument for guess method
  # use this to check argument and avoid exception
  def guess_illegal_argument? letter
    letter == nil || letter.length != 1 || letter =~ /[^a-zA-Z]/
  end
  
  def availguesses
      return @availguesses
  end
    
  # user guesses this letter
  # return true if not guessed before
  # return false if guessed
  # @guesses is a string holding all unique guesses
  # WordGame is case insensitive, change all guesses to lowercase via downcase
  def guess letter
     if guess_illegal_argument? letter
         raise ArgumentError, 'letter must be a single character a-zA-Z'
     end
      
     letter = letter.downcase
     if @word.include? letter
        if ! @guesses.include? letter 
           @guesses << letter
           return true 
        else
           return false
        end
     else
        if ! @wrong_guesses.include? letter
            @wrong_guesses << letter
            return true
        else
            return false
        end
     end
  end
    
  def check_win_or_lose
      if @wrong_guesses.length >= @availguesses
         return :lose
      elsif word_with_guesses == @word 
         return :win
      else
         return :play
      end
  end
    
  def word_with_guesses
     if @guesses == ''
        return @word.gsub /./, '-'
     else
        return @word.gsub /[^#{@guesses}]/, '-'     
     end
  end

  # Get a word from remote "random word" service
  #     
  # You can test get_random_word by running $ bundle exec irb -I. -r app.rb
  # And then in the irb: irb(main):001:0> WordGame.get_random_word
  #  => "cooking"   <-- some random word
  def self.get_random_word
    require 'uri'
    require 'net/http'
    uri = URI('http://watchout4snakes.com/wo4snakes/Random/RandomWord')
    Net::HTTP.new('watchout4snakes.com').start { |http|
      return http.post(uri, "").body
    }
  end
end