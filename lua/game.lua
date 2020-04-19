function user_input()
	local mouse_x = stat(32)
	local mouse_y = stat(33)

	if 		mouse_x >= end_turn_top_left_x
		and mouse_x <= end_turn_bot_right_x
		and mouse_y >= end_turn_top_left_y
		and mouse_y <= end_turn_bot_right_y
	then
		et_mouse_over = true
	else
		et_mouse_over = false
	end
	
	if stat(34) == 1 then
		if 		mouse_x >= end_turn_top_left_x
			and mouse_x <= end_turn_bot_right_x
			and mouse_y >= end_turn_top_left_y
			and mouse_y <= end_turn_bot_right_y
		then
			et_mouse_over = false
			in_cycle = true
			if cycle_count < 99 then
				cycle_count += 1
			else
				cycle_count = 99
			end
			time_cycle = 100
		end
	end
end


function check_empty(x,y,a)
	if x <= min_x or x >= max_x then return false end
	if y <= min_y or y >= max_y then return false end
	return matrix[x][y] == "empty"
end

function valid_home_pos(x, y, a)
	local top_left_x = 0
	local top_left_y = 0
	local bot_right_x = 0
	local bot_right_y = 0

	top_left_x = x - dist -  (home_radius + 3)
	top_left_y = y - dist -  (home_radius + 3)
	bot_right_x = x + dist + (home_radius + 3)
	bot_right_y = y + dist + (home_radius + 3)

	if top_left_x <= min_x then return false end
	if top_left_y <= min_y then return false end
	if bot_right_x >= max_x then return false end
	if bot_right_y >= max_y then return false end

	for i = top_left_x, bot_right_x do
		for j = top_left_y, bot_right_y do
			if matrix[i][j] == "agent" or matrix[i][j] == "hall" or matrix[i][j] == "home" then
				if a ~= nil and i == a.x and j == a.y then
					goto continue_check_empty
				else
					return false
				end
			end
		end
		::continue_check_empty::
	end

	return true
end

function get_delta(x, y)
	dirs = {-1, 0, 1}

	local dx, dy = 0, 0

	chosen_dir = dirs[flr(rnd(3)) + 1]
	if x - dist <= min_x then dx = 1
	elseif x + dist >= max_x then dx = -1
	else dx = chosen_dir
	end

	chosen_dir = dirs[flr(rnd(3)) + 1]
	if y - dist <= min_y then dy = 1
	elseif y + dist >= max_y then dy = -1
	else dy = chosen_dir
	end

	return dx, dy
end

function act(a)
	agent_snatch(a)
	agent_move(a)
end

function sign(x)
	if x < 0 then return -1 elseif x == 0 then return 0 else return 1 end
end

function move_dir(target, goal)
	return (target - goal)
end

function get_nearby_snatcher(agent)
	local result, coords

	top_left_x = agent.x - snatch_radius
	top_left_y = agent.y - snatch_radius
	bot_right_x = agent.x + snatch_radius
	bot_right_y = agent.y + snatch_radius

	if top_left_x < min_x then top_left_x = min_x end
	if top_left_y < min_y then top_left_y = min_y end
	if bot_right_x > max_x then bot_right_x = max_x end
	if bot_right_y > max_y then bot_right_y = max_y end

	for i = top_left_x, bot_right_x do
		for j = top_left_y, bot_right_y do
			if 		matrix[i][j] == "snatcher"
				and agent.x ~= i
				and agent.y ~= j
			then
				coords = {i, j}
				break
			end
		end
		if coords ~= nil then break end
	end

	if coords ~= nil then
		for agent in all(agents) do
			if 		agent.x == coords[1]
				and agent.y == coords[2]
			then
				result = agent
				break
			end
		end
	end

	return result
end

function agent_snatch(agent)
	result = get_nearby_snatcher(agent)
	if result ~= nil then
		if snatch_chance > rnd(0.1) then
			agent.snatcher = true
			-- prevent snatched agent from going home
			agent.hunger = 100
			agent.going_home = false
		end
	end
end

function agent_move(agent)
	if agent.hunger < 0 or agent.going_home then
		agent.going_home = true

		if agent.x == agent.home_x and agent.y == agent.home_y then
			agent.going_home = false
			agent.hunger = flr(rnd(400)) + 100
		else
			xdir = move_dir(agent.home_x, agent.x)
			ydir = move_dir(agent.home_y, agent.y)
			if xdir ~= 0 then
				agent.x += sign(xdir)
			else
				agent.y += sign(ydir)
			end
		end
		return
	end

	if not agent.snatcher then
		agent.hunger -= 1
	end
		
	if 	agent.prev_dx == nil
		or 	agent.prev_dy == nil
		or 	change_dir_chance > rnd(1)
	then
		dx, dy = get_delta(agent.x, agent.y)
	else
		dx = agent.prev_dx
		dy = agent.prev_dy
	end

	local empty_coord = false
	local attempt = 0
	local num_retries = 10
	while not empty_coord and attempt < num_retries do
		empty_coord = check_empty(agent.x + dx, agent.y + dy, agent)
		if empty_coord then
			matrix[agent.x][agent.y] = "empty"
			agent.x += dx
			agent.y += dy
			agent.prev_dx = dx
			agent.prev_dy = dy
			if agent.snatcher then
				matrix[agent.x][agent.y] = "snatcher"
			else
				matrix[agent.x][agent.y] = "agent"
			end
			break
		else
			attempt += 1
			dx, dy = get_delta(agent.x, agent.y)
		end
	end
end
