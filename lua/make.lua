function make_world()
	for i = 0, size do
		matrix[i] = {}
		for j = 0, size do
			matrix[i][j] = "empty"
		end
	end
end

function make_agents(n)
	for i = 1, n do
		local agent = {}
		local attempt = 0
		local num_retries = 10
		local empty_coord = false
		local rand_x = -1
		local rand_y = -1
		while not empty_coord and attempt < num_retries do
			rand_x = flr(rnd(max_x - min_x)) + min_x
			rand_y = flr(rnd(max_y - min_y)) + min_y
			empty_coord = check_empty(rand_x, rand_y, nil)
			attempt += 1
		end
		if attempt < num_retries then
			agent.x = rand_x
			agent.y = rand_y
			agent.home_x = rand_x
			agent.home_y = rand_y
			agent.home_opn_indx = 1 + flr(rnd(3))
			matrix[agent.x][agent.y] = "agent"
			agent.hunger = flr(rnd(400)) + 100
			add(agents, agent)
		end
	end
end

function make_hall()
	hall.top_left_x = flr(rnd(64)) + 16
	hall.top_left_y = flr(rnd(50)) + 8

	if 0.5 > rnd(1) then
		hall.width = 30
		hall.height = 10
	else
		hall.width = 10
		hall.height = 30
	end

	for i = hall.top_left_x, hall.top_left_x + hall.width do
		for j = hall.top_left_y, hall.top_left_y + hall.height do
			matrix[i][j] = "hall"
		end
	end
end

function make_home(agent)
	local top_left_x = agent.home_x - home_radius
	local top_left_y = agent.home_y - home_radius
	local bot_right_x = agent.home_x + home_radius
	local bot_right_y = agent.home_y + home_radius


	for i = top_left_x, bot_right_x do
		if agent.home_opn_indx ~= 0 then
			matrix[i][top_left_y] = "home"
		end
		if agent.home_opn_indx ~=2 then
			matrix[i][bot_right_y] = "home"
		end
	end
	for i = top_left_y, bot_right_y do
		if agent.home_opn_indx ~= 1 then
			matrix[top_left_x][i] = "home"
		end
		if agent.home_opn_indx ~= 3 then
			matrix[bot_right_x][i] = "home"
		end
	end
end
