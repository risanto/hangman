class Hangman
    attr_accessor :guess_word_string, :guess_word, :ended, :incorrect_guesses, :incorrect_guesses_limit, :won

    def initialize(incorrect_guesses_limit)
        @guess_word_string
        @guess_word = []
        generate_word

        @incorrect_guesses = 0
        @incorrect_guesses_limit = incorrect_guesses_limit
        @won = false
    end
    
    private

    def generate_word
        dictionary = File.open("5desk.txt")
        dictionary_data = dictionary.readlines.map(&:chomp)

        selected_words = dictionary_data.select { |str| str.length >= 5 && str.length <= 12 }
        
        @guess_word_string = selected_words.shuffle[0].upcase

        guess_word_string.each_char do |ltr|
            @guess_word << [ltr, false]
        end
    end

    public

    def still_going?
        @incorrect_guesses < @incorrect_guesses_limit ? true : false
    end

    def all_guessed?
        count = 0

        @guess_word.each do |arr|
            count += 1 if arr[1] == true
        end

        if count == @guess_word_string.length
            @won = true
            true
        else
            false
        end
    end

    def guess(letter)
        letter = letter.upcase
        correct_guess = false

        @guess_word.each do |arr|
            if letter == arr[0]
                correct_guess = true
                arr[1] = true
            end
        end

        @incorrect_guesses += 1 if !correct_guess
    end

    def show_word
        result = []
    
        @guess_word.each do |arr|
            arr[1] == false ? result << '_' : result << arr[0]
        end
    
        result.join(' ')
    end
end


def center_and_display(string)
    puts "\n" * 100 + string.lines.map { |line| line.strip.center(50) }.join("\n") + "\n" * 3
end

game = Hangman.new(5)

while game.still_going? do

    center_and_display("
        ========================
        Incorrect guesses: #{game.incorrect_guesses}/#{game.incorrect_guesses_limit}

        #{game.show_word}

        What's your next letter?
        ========================
    ")

    input = gets.chomp.upcase

    if input.length > 1 
        center_and_display("
            Please input only ONE letter!")
        next
    elsif input.length <= 0
        center_and_display("
            Input cannot be empty!")
        next
    elsif (input =~ /[[:alpha:]]/) == nil
        center_and_display("
            Please input a valid letter (a-z)!")
        next
    end

    game.guess(input)

    if game.all_guessed?
        center_and_display("
            ==========================
            Incorrect guesses: #{game.incorrect_guesses}/#{game.incorrect_guesses_limit}
    
            #{game.show_word}
    
            CONGRATS YOU WON THE GAME!
            ==========================
        ")
        break
    end
end

center_and_display("
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    No attempts left!

    The correct answer is #{game.guess_word_string.upcase}
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    "
) if !game.won
