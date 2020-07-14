# When a new game is started, the script should load in the dictionary (5desk.txt) and randomly select a word between 5 and 12 characters long for the secret word.

dictionary = File.open("5desk.txt")
dictionary_data = dictionary.readlines.map(&:chomp)

selected_words = dictionary_data.select { |str| str.length >= 5 && str.length <= 12 }

random_word = selected_words.shuffle[0]

# Do display some sort of count so the player knows how many more incorrect guesses he/she has before the game ends. You should also display which correct letters have already been chosen (and their position in the word, e.g. _ r o g r a _ _ i n g) and which incorrect letters have already been chosen.

game_ended = false
incorrect = 0

guess_word = Hash[random_word.split('').map { |ltr|[ltr.upcase, guessed: false] } ]

def display(word)
    result = []

    word.each do |k, v|
        v[:guessed] == false ? result << '_' : result << k
    end

    result.join(' ')
end

# pp display(guess_word)

while !game_ended do
    puts "
        Incorrect guesses: #{incorrect}/5

        #{display(guess_word)}

        What's your next letter?
    "

    input = gets.chomp
end
