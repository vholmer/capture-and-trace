pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
poke(0x5F2D, 1) -- mouse support
size = 128
matrix = {}
agents = {}
dist = 2 -- distance between agents
min_x = 0 + dist
min_y = 0 + dist
max_x = size - dist
max_y = size - dist
change_dir_chance = 0.1 -- percent
hit_distance = 3

function _init()
	n = 12
	make_world()
	make_agents(n)
end

function _update()
	foreach(agents, act)
	user_input()
end

function _draw()
	cls(1)
	foreach(agents, draw_agent)
	draw_mouse()
	--print("CPU: " .. stat(1), 0, 0, 7)
	--print("MEM: " .. stat(0), 0, 6, 7)
end

function draw_mouse()
	mouse_x = stat(32)
	mouse_y = stat(33)

	pset(mouse_x - 1, mouse_y - 1, 7)
	pset(mouse_x - 1, mouse_y + 1, 7)
	pset(mouse_x + 1, mouse_y - 1, 7)
	pset(mouse_x + 1, mouse_y + 1, 7)
	pset(mouse_x - 2, mouse_y - 2, 7)
	pset(mouse_x - 2, mouse_y + 2, 7)
	pset(mouse_x + 2, mouse_y - 2, 7)
	pset(mouse_x + 2, mouse_y + 2, 7)

	if stat(34) == 1 then
		pset(mouse_x, mouse_y, 7)
	end
end

function user_input()
	mouse_x = stat(32)
	mouse_y = stat(33)
	--if stat(34) == 1 then
	--	for i = 0, hit_distance do
	--		for j = 0, hit_distance do
	--			if matrix[mouse_x-i][mouse_y-j] == 1 then
	--				hit = true
	--				goto hit_break
	--			end
	--		end
	--	end
	--	::hit_break::
	--	if hit then
	--		for agent in all(agents) do
	--			if 		abs(agent.x - mouse_x) <= hit_distance
	--				and abs(agent.y - mouse_y) <= hit_distance
	--			then
	--				del(agents, agent)
	--				matrix[agent.x][agent.y] = 0
	--				break
	--			end
	--		end
	--	end
	--end
end

function make_world()
	for i = 0, size do
		matrix[i] = {}
		for j = 0, size do
			matrix[i][j] = 0
		end
	end
end

function make_agents(n)
	for i = 1, n do
		agent = {}
		attempt = 0
		num_retries = 10
		empty_coord = false
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
			agent.time_to_move = 0
			matrix[agent.x][agent.y] = 1
			add(agents, agent)
		end
	end
end

function check_empty(x, y, a)
	local top_left_x = x - dist
	local top_left_y = y - dist
	local bot_right_x = x + dist
	local bot_right_y = y + dist

	if top_left_x <= min_x then return false end
	if top_left_y <= min_y then return false end
	if bot_right_x >= max_x then return false end
	if bot_right_y >= max_y then return false end

	for i = top_left_x, bot_right_x do
		for j = top_left_y, bot_right_y do
			if matrix[i][j] == 1 then
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

function draw_agent(a)
	pset(a.x - 1, a.y, 8)
	pset(a.x, a.y, 8)
	pset(a.x + 1, a.y, 8)
	pset(a.x, a.y - 1, 8)
	pset(a.x, a.y + 1, 8)
	--spr(1, a.x, a.y)
end

function get_delta(x, y)
	dirs = {-1, 0, 1}

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
	foreach(agents, agent_move)
	--for agent in all(agents) do
	--	agent_move(agent)
	--end
end

function agent_move(agent)
	if agent.time_to_move == 0 then
		if 		agent.prev_dx == nil
			or 	agent.prev_dy == nil
			or 	change_dir_chance > rnd(1)
		then
			dx, dy = get_delta(agent.x, agent.y)
		else
			dx = agent.prev_dx
			dy = agent.prev_dy
		end

		empty_coord = false
		attempt = 0
		num_retries = 10
		while not empty_coord and attempt < num_retries do
			empty_coord = check_empty(agent.x + dx, agent.y + dy, agent)
			if empty_coord then
				matrix[agent.x][agent.y] = 0
				agent.x += dx
				agent.y += dy
				agent.prev_dx = dx
				agent.prev_dy = dy

				matrix[agent.x][agent.y] = 1
				break
			else
				attempt += 1
				dx, dy = get_delta(agent.x, agent.y)
			end
		end
		agent.time_to_move = flr(rnd(#agents)) + #agents \ 2
	else
		agent.time_to_move -= 1
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
