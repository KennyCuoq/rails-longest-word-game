require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @start_time = Time.now
    @letters = generate_grid(9)
  end

  def score
    # binding.pry
    # raise
    @grid = params[:grid]

    # @time_taken = @start_time - Time.now
    # binding.pry

    @answer = params[:answer]
    @time_taken = Time.parse(params[:start_time]) - Time.now
    @final_score = score_and_message(@answer, @grid, @time_taken)
  end

  private

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
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
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
end
end
