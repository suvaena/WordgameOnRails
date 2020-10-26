class GameController < ApplicationController
    
  def store_game_in_session
    session[:game] = @game.to_yaml
  end  
    
  def get_game_from_session
    if !session[:game].blank? 
      @game = YAML.load(session[:game])
    else
      @game = WordGame.new('', 0)
    end
  end
    
  before_action :get_game_from_session
  after_action :store_game_in_session
    
  def win
      if @game.word_with_guesses != @game.word
          redirect_to game_show_path
      end
  end

  def lose
      if @game.wrong_guesses.length < @game.availguesses.to_i
          redirect_to game_show_path
      end
  end

  def show
  end

  def new
  end

  def create
      word = params[:word] || WordGame.get_random_word
      num = params[:availguesses].to_s[0]
      if num.match? /\A[a-zA-Z'-]*\z/
          flash[:message] = "You must enter a number zero or larger!"
          redirect_to game_new_path
      else
          num = params[:availguesses].to_i
          if num<0 || num==nil
              flash[:message] = "You must enter a number zero or larger!"
              redirect_to game_new_path
          else
              @game = WordGame.new(word, num)
              redirect_to game_show_path
          end
      end
  end

  def guess
    letter = params[:guess].to_s[0]
    
    if @game.guess_illegal_argument? letter
        flash[:message] = "Invalid guess."
    elsif ! @game.guess letter # enter the guess here
        flash[:message] = "You have already used that letter."
    end
    
    if @game.check_win_or_lose == :win
        redirect_to game_win_path
    elsif @game.check_win_or_lose == :lose
        redirect_to game_lose_path
    else    
        redirect_to game_show_path
    end
  end
   
end