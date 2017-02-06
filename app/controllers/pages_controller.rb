class PagesController < ApplicationController
 def game
   @grid = generate_grid(9)
   @start_time = Time.now
 end

 def generate_grid(grid_size)
   Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
 end



 def included?(guess, grid)
   guess.split("").all? { |letter| guess.count(letter) <= grid.count(letter) }
 end

 def compute_score(attempt, time_taken)
   (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
 end

 def run_game(attempt, grid, start_time, end_time)
   result = { time: end_time - start_time }

   result[:translation] = get_translation(attempt)
   result[:score], result[:message] = score_and_message(
     attempt, result[:translation], grid, result[:time])

   result
 end

 def score_and_message(attempt, translation, grid, time)
   if included?(attempt.upcase, grid)
     if translation
       score = compute_score(attempt, time)
       [score, "well done"]
     else
       [0, "not an english word"]
     end
   else
     [0, "not in the grid"]
   end
 end


 def get_translation(word)
  begin
    response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=3047e8dd-e79e-4065-8261-47f7c2fb3d59&input=#{word}")
    json = JSON.parse(response.read.to_s)
    if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
      json['outputs'][0]['output']
    end
  rescue
    if File.read('/usr/share/dict/words').split("\n").include? word.upcase
      word
    else
      nil
    end
  end
end


def score
 @word = params[:query]
 @grid = params[:grid]
 @start_time = Time.parse(params[:start])
 @end_time =Time.now
 @score = run_game(@word, @grid, @start_time, @end_time)
end

end
