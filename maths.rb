require 'yaml'

def reset(game_data)
	game_data[:game_no] = 0
	game_data[:last_game] = Time.now
	game_data[:add_lvl] = 1
	game_data[:sub_lvl] = 1
	game_data[:times_lvl] = 1
	game_data[:div_lvl] = 1
	game_data[:add_xp] = 0
	game_data[:sub_xp] = 0
	game_data[:times_xp] = 0
	game_data[:div_xp] = 0
	game_data[:avg_add] = 0
	game_data[:avg_sub] = 0
	game_data[:avg_times] = 0
	game_data[:avg_div] = 0
	game_data[:avg_lvl] = 1
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
		if b == 0
			a
		else
			a/b
		end
	else
		0
	end
end

def divisors(n)
	d = []
	(1...n).each do |k|
		d.push(k) if n%k == 0
	end
	return d
end

def random_item(game_data)

	# let l be the level a certain skill is at, s the average level, and p the probability of getting a given token : p = 1/2 - l/4s
	a = game_data[:add_lvl]
	b = game_data[:sub_lvl]
	c = game_data[:times_lvl]
	d = game_data[:div_lvl]
	s = ((a + b + c + d)/4).to_f
	game_data[:avg_lvl] = s

	pa = (100*(0.5 - a/(4*s))).floor
	pb = (100*(0.5 - b/(4*s))).ceil
	pc = (100*(0.5 - c/(4*s))).ceil
	pd = (100*(0.5 - d/(4*s))).floor

	prob_array = Array.new(100)

	(0...pa).each do |i|
		prob_array[i] = "+"
	end

	(pa...(pa + pb)).each do |i|
		prob_array[i] = "-"
	end

	(pb...(pa + pb + pc)).each do |i|
		prob_array[i] = "*"
	end

	(pc...100).each do |i|
		prob_array[i] = "/"
	end

	r = rand(0...100)
	token = prob_array[r]

	case token
	when "+"
		m = (rand*1000*10**a).to_i
		n = rand(m).to_i
	when "-"
		m = (rand*1000*10**b).to_i
		n = rand(m).to_i
	when "*"
		m = (rand*10**(c+1)).to_i
		n = rand(m).to_i
	when "/"
		m = (1+rand*10**(d+1)).to_i
		h = divisors(m)
		p h.inspect
		n = h.sample.to_i
	end

	item = { a: m, b: n, token: token}
	return item
end

def check_lvl(data)
	if data[:add_xp]>10**data[:add_lvl]
		data[:add_xp]%=10**data[:add_lvl]
		data[:add_lvl]+=1
	elsif data[:sub_xp]>10**data[:sub_lvl]
		data[:sub_xp]%=10**data[:sub_lvl]
		data[:sub_lvl]+=1
	elsif data[:times_xp]>10**data[:times_lvl]
		data[:times_xp]%=10**data[:times_lvl]
		data[:times_lvl]+=1
	elsif data[:div_xp]>10**data[:div_lvl]
		data[:div_xp]%=10**data[:div_lvl]
		data[:div_lvl]+=1
	elsif data[:add_xp]<0
		data[:add_xp] += 10**(data[:add_lvl]-1) 
		data[:add_lvl] -= 1
	elsif data[:sub_xp]<0
		data[:sub_xp] += 10**(data[:add_lvl]-1) 
		data[:sub_lvl] -= 1
	elsif data[:times_xp]<0
		data[:times_xp] += 10**(data[:add_lvl]-1) 
		data[:times_lvl] -= 1
	elsif data[:div_xp]<0
		data[:div_xp] += 10**(data[:add_lvl]-1) 
		data[:div_lvl] -= 1
	end

	if data[:add_lvl] < 1
		data[:add_lvl] = 1
		data[:add_xp] = 0
	elsif data[:sub_lvl] < 1
		data[:sub_lvl] = 1
		data[:sub_xp] = 0
	elsif data[:times_lvl] < 1
		data[:times_lvl] = 1
		data[:times_xp] = 0
	elsif data[:div_lvl] < 1
		data[:div_lvl] = 1
		data[:div_xp] = 0
	end
end

def win(item, time, data)
	points = 1
	if item[:token] == "/"
		points = 10 if time<=15-data[:div_lvl]
		points = 5 if time<=30-data[:div_lvl]
		points = 2 if time<=45-data[:div_lvl]
	else
		points = 15 if time<=5
		points = 10 if time<=10
		points = 5 if time<=15
		points = 2 if time<=20
	end

	case item[:token]
	when "+"
		data[:add_xp] += points
	when "-"
		data[:sub_xp] += points
	when "*"
		data[:times_xp] += points
	when "/"
		data[:div_xp] += points
	end
	check_lvl(data)
end

def lose(item, data)
	case item[:token]
	when "+"
		data[:add_xp] -= 2*data[:add_lvl]
	when "-"
		data[:sub_xp] -= 2*data[:sub_lvl]
	when "*"
		data[:times_xp] -= 2*data[:times_lvl]
	when "/"
		data[:div_xp] -= 2*data[:div_lvl]
	end
	check_lvl(data)
end

def update_avg(item, data, time)
	case item[:token]
	when "+"
		data[:avg_add] += time
		data[:avg_add] /= 2
	when "-"
		data[:avg_sub] += time
		data[:avg_sub] /= 2
	when "*"
		data[:avg_times] += time
		data[:avg_times] /= 2
	when "/"
		data[:avg_div] += time
		data[:avg_div] /= 2
	end
end

def u_interaction(game_data)

	item = random_item(game_data)
	answer = calculate(item[:a], item[:b], item[:token])

	puts "What is #{item[:a]} #{item[:token]} #{item[:b]}?"
	t1 = Time.now
	user_answer = gets.chomp.to_f
	t2 = Time.now
	response_time = t2 - t1
	update_avg(item, game_data, response_time)

	if user_answer == answer
		puts "Right! (#{response_time}s)"
		win(item, response_time, game_data)
		return 1
	else
		puts "Nope... the right answer was #{answer}"
		lose(item, game_data)
		return 0
	end

end

def take_test(game_data)

	i = 0
	count = 0

	while (i < 20) do
		count += u_interaction(game_data)
		i+=1
	end
	game_data[:game_no] += 1
	puts "Test is over, you scored #{count}/20"
	puts "Take a look at the stats : " + game_data.inspect
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