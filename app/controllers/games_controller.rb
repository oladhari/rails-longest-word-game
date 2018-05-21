require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = 10.times.map { ("A".."Z").to_a.sample }
    @start_time = Time.now
  end

  def score
    @word = params[:word]
    @start_time = params[:start_time]
    @end_time = Time.now
    @grid=params[:grid]
    @time = @end_time.to_i - @start_time.to_i
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    case JSON.parse(open(url).read)["found"]
      when true
        if word_included_grid(@word, @grid)
          # @score =  @time > 60.0 ? 0 : @word.size * (1.0 - @time / 60.0)
          @score = (@word["length"].to_f + (0.1 / @time.to_i).to_f).round(2)
          @message = "well done"
        else
          @score = 0
          @message = "the given word is not in the grid"
        end
      else
        @score = 0
        @message = "not an english word"
      end
    end
  end



  # TODO: runs the game and return detailed hash of result


def word_included_grid(word, grid)
  word_arry = word.upcase.split(//)
  word_hash = {}
  grid_hash = {}
  word_arry.each do |letter|
    word_hash[letter.to_s] = 0 unless word_hash.key?(letter)
    word_hash[letter.to_s] += 1
  end
  grid_arry = grid.split(//)
  grid_arry.each do |element|
    grid_hash[element.to_s] = 0 unless grid_hash.key?(element)
    grid_hash[element.to_s] += 1
  end
  all_present = true
  word_hash.each do |key, _value|
    all_present = false if grid_hash[key].nil? || word_hash[key].to_i > grid_hash[key].to_i
  end
  return all_present
end
