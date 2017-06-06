require 'yaml'

def reset(game_data)
	game_data[:game_no] = 0
	game_data[:last_game] = Time.now
	game_data[:add_lvl] = 0
	game_data[:sub_lvl] = 0
	game_data[:times_lvl] = 0
	game_data[:div_lvl] = 0
	game_data[:add_xp] = 0
	game_data[:sub_xp] = 0
	game_data[:times_xp] = 0
	game_data[:div_xp] = 0
	game_data[:avg_add] = nil
	game_data[:avg_sub] = nil
	game_data[:avg_times] = nil
	game_data[:avg_div] = nil
	
end

def save_data(tmp)
	serialized_game_data = YAML::dump(tmp)
	file = File.open("data.yaml", "w")
	file.write(serialized_game_data)
	file.close
end

def loaded_data()
	serialized_game_data = File.read("data.yaml")
	File.close("data.yaml")
	return YAML::load(serialized_game_data)
end

def calculate(a, b, token)
	case token
	when "+"
		a+b
	when "-"
		a-b
	when "*"
		a*b
	when "/"
		a/b
	else
		0
	end
end

# to implement, gives random operation depending on the game data
def random_item(game_data)
	item = { a: number, b: number, token: "+-*/"}
end

# to implement, gives user points depending on how well they did
def win(item, time)
	
end

# to implement
def lose(item)
	
end

def u_interaction
	item = random_item(game_data)
	answer = calculate(item[:a], item[:b], item[:token])
	"What is #{item[:a]} #{item[:token]} #{item[:b]}?"
	t1 = Time.now
	user_answer = gets.chomp.to_f
	t2 = Time.now
	response_time = t2 - t1
	if user_answer == answer
		puts "Right! (#{response_time}s)"
		win(item, response_time)
	else
		puts "Nope..."
		lose(item)
	end
end

def take_test(game_data)
	count = 0
	while (count < 20) do
		u_interaction
		count+=1
	end
	game_data[:game_no] += 1
	save_data(tmp)
end

tmp = {}
# check if there is previous saved data
if File.file?('data.yaml')
	tmp = loaded_data()
	puts "Welcome back for test number #{tmp[:game_no] + 1}, last game : #{tmp[:last_game]}"
	take_test(tmp)
else
	reset(tmp)
	puts "Welcome to your first test"
	take_test(tmp)
end