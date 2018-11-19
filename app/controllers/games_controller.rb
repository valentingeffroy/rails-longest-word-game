require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = ("a".."z").to_a.sample(5)
    @start_time = Time.now
  end

  def score
    attempt = params[:answer]
    grid = params[:letters]
    time = Time.now - params[:time].to_i
    score_and_message(attempt, grid, time)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        @result = [score, "well done"]
      else
        @result = [0, "not an english word"]
      end
    else
      @result = [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
end
