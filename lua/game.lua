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
			time_cycle = 100
		end
	end
end



function check_empty(x, y, a)
	local top_left_x = 0
	local top_left_y = 0
	local bot_right_x = 0
	local bot_right_y = 0

	if a == nil then
		top_left_x = x - dist -  (home_radius + 3)
		top_left_y = y - dist -  (home_radius + 3)
		bot_right_x = x + dist + (home_radius + 3)
		bot_right_y = y + dist + (home_radius + 3)
	else
		top_left_x = x - dist
		top_left_y = y - dist
		bot_right_x = x + dist
		bot_right_y = y + dist
	end

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
	agent_move(a)
end

function sign(x)
	if x < 0 then return -1 elseif x == 0 then return 0 else return 1 end
end

function move_dir(target, goal)
	return (target - goal)
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
	agent.hunger -= 1

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
			matrix[agent.x][agent.y] = "agent"
			break
		else
			attempt += 1
			dx, dy = get_delta(agent.x, agent.y)
		end
	end
end
