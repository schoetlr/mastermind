class Code
  
  PEGS = {"R" => "Red", "G" => "Green", "B" => "Blue", "Y" => "Yellow", "O" => "Orange", "P" => "Purple"}
  PEG_KEYS = PEGS.keys

  def self.random
    pegs = Array.new(4){PEG_KEYS.sample}
    Code.new(pegs)
  end

  def self.parse(code)
  	pegs = code.split("").map(&:upcase)
  	raise "invalid color" if pegs.any? {|peg| PEG_KEYS.include?(peg) == false }
  	Code.new(pegs)
  end

  attr_reader :pegs
  def initialize(pegs)
  	@pegs = pegs
  end

  def [](peg_idx)
    pegs[peg_idx]
  end

  def exact_matches(other_code)
  	matches = 0
  	pegs.each_index { |i| matches += 1 if pegs[i] == other_code[i] }
  	matches
  end

  def near_matches(other_code)
  	matches = 0
  	max_usage = Hash.new(0)
  	usage = Hash.new(0)
  	other_code.pegs.each { |peg| max_usage[peg] += 1 }
  	other_code.pegs.each_with_index { |peg, i| max_usage[peg] -= 1 if other_code[i] == pegs[i] }
    pegs.each_with_index do |peg, i|
      if usage[peg] < max_usage[peg] && pegs[i] != other_code[i]
        matches += 1 
      end
      usage[peg] += 1
    end
    matches
  end

  def ==(other_code)
  	if other_code.is_a?(Code) && pegs == other_code.pegs
  	  true
  	else 
  	  false
  	end
  end

end

class Game
  attr_reader :secret_code, :guesses

  def initialize(code = Code.random)
  	@secret_code = code
  	@guesses = 0 
  end

  def get_guess
  	puts "Guess any of the following #{Code::PEG_KEYS} with no spaces or punctuation"
    Code.parse($stdin.gets.chomp)
  end

  def display_matches(code)
    puts "there are #{secret_code.exact_matches(code)} exact matches and
    #{secret_code.near_matches(code)} near matches"
  end

  def play
  	guess = get_guess
  	display_matches(guess)
  	@guesses += 1
    until guesses == 10 || secret_code == guess
      guess = get_guess
      display_matches(guess)
      @guesses += 1
    end

    if secret_code == guess
      puts "You won with #{guesses} guesses"
    else
      puts "You used up all your guesses and lost"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new.play
end
