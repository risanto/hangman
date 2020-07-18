class Hangman
    attr_accessor :guess_word_string, :guess_word, :ended, :incorrect_guesses, :incorrect_guesses_limit, :won, :previous_correct_guesses, :previous_incorrect_guesses, :save_dir

    def initialize(incorrect_guesses_limit)
        @guess_word_string
        @guess_word = []
        @previous_correct_guesses = []
        @previous_incorrect_guesses = []
        generate_word

        @incorrect_guesses = 0
        @incorrect_guesses_limit = incorrect_guesses_limit
        @won = false

        @save_dir = ''
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
                @previous_correct_guesses << letter
            end
        end
        
        if !correct_guess
            @incorrect_guesses += 1
            @previous_incorrect_guesses << letter
        end
    end

    def show_word
        result = []
    
        @guess_word.each do |arr|
            arr[1] == false ? result << '_' : result << arr[0]
        end
    
        result.join(' ')
    end
end


def center_and_display(string, newlines=1)
    puts "\n" * newlines + string.lines.map { |line| line.strip.center(50) }.join("\n")
end

def left_and_display(string, newlines=1)
    puts "\n" * newlines + string.lines.map { |line| line.strip }.join("\n")
end

game_initialized = false

while !game_initialized do
    center_and_display(
"   ======================================================
        Type 'NEW' if you want to start a new game

        Type 'LOAD' if you want to continue from a saved game
======================================================
    ")

    input = gets.chomp.upcase

    if input == 'NEW'
        game = Hangman.new(5)
        game_initialized = true
        break
    elsif input == 'LOAD'
        save_files = Dir["saves/*"]
        correct_input = false

        if save_files.length < 1
            center_and_display("
                No save files found!")
            next
        end

        while !correct_input do
            left_and_display("
                ================================================================
                Which one do you want to load?  
                
                #{
                    save_files.map.with_index { |file, idx| "#{idx + 1}. #{file}"}.join("\n")
                }

                (Input a number or type 'BACK' to go back to the previous menu)
                ================================================================
            ")

            input = gets.chomp.upcase
            picked_save_file = save_files[input.to_i - 1]

            if input == 'BACK'
                break
            elsif picked_save_file != nil
                game = Marshal.load(File.read("#{picked_save_file}"))
                game_initialized = true
                break
            else
                left_and_display("
                    File not found!")
                next
            end
        end
    else
        center_and_display("
            No such command!")
    end
end

while game.still_going? do

    center_and_display("
        ==================================================
        Incorrect guesses: #{game.previous_incorrect_guesses.join(', ')} (#{game.incorrect_guesses}/#{game.incorrect_guesses_limit})

        #{game.show_word}

        Please input a letter
        
        or type 'SAVE' if you want to save your progress
        ==================================================
    ")

    input = gets.chomp.upcase

    # SAVING THE GAME

    if input == 'SAVE'
        Dir.mkdir("saves") unless Dir.exists? "saves"

        save_files = Dir["saves/*"]

        game.save_dir.length > 1 ? (
            file_name = game.save_dir
        ) : (
            file_name = "saves/#{save_files.length + 1}.dump"
            game.save_dir = file_name
        )

        File.open(file_name, 'wb') { |f| f.write(Marshal.dump(game)) }

        center_and_display("
            Game saved to #{file_name}!")

        next

    # GUESS VALIDATION

    elsif input.length > 1 
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
    elsif (game.previous_correct_guesses + game.previous_incorrect_guesses).include? input
        center_and_display("
            You've already inputted the letter! Pick another one.")
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
    ", 10
) if !game.won
