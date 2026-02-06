module CLI
  module Inputs
    # waits for simple string input; returns value stripped of leading/trailing whitespace
    def get_input(prompt)
      puts prompt
      response = nil
      until response && response.strip.length > 0
        response = gets.chomp
      end
      response.strip
    end

    # TODO: Invalid input handling?
    # waits for a user to select an option from a list
    def select_option(prompt, options)
      puts prompt
      options.each_with_index do |option, index|
        puts "  #{index + 1}. #{option.inspect}"
      end
      puts "Enter your choice: "
      choice = gets.chomp.to_i
      options[choice - 1]
    end

    # TODO: Invalid input handling?
    # TODO: Explicit no handling?
    # waits for a user to select yes or no
    def yes_no_input(prompt)
      answer = get_input("#{prompt} (y/n)")
      answer.downcase == "y" || answer.downcase == "yes"
    end
  end
end
