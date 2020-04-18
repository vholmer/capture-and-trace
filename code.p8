pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
poke(0x5F2D, 1) -- mouse support
size = 128
matrix = {}
agents = {}
hall = {}
dist = 1 -- distance between agents
min_x = 0 + dist
min_y = 0 + dist
max_x = size - dist
max_y = 100
change_dir_chance = 0.1 -- percent
hit_distance = 3
home_size = 4
home_radius = home_size \ 2

function _init()
	local n = 100
	make_world()
	make_hall()
	make_agents(n)
	foreach(agents, make_home)
end

function _update()
	foreach(agents, act)
	user_input()
end

function _draw()
	cls(1)
	foreach(agents, draw_home)
	foreach(agents, draw_agent)
	draw_hall()
	draw_mouse()
	--print("CPU: " .. stat(1), 0, 0, 7)
	--print("MEM: " .. stat(0), 0, 6, 7)
end

function draw_hall()
	rect(
		hall.top_left_x, hall.top_left_y,
		hall.top_left_x + hall.width,
		hall.top_left_y + hall.height,
		7
	)
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
		matrix[i][top_left_y] = "home"
		matrix[i][bot_right_y] = "home"
	end
	for i = top_left_y, bot_right_y do
		matrix[top_left_x][i] = "home"
		matrix[bot_right_x][i] = "home"
	end
end

function draw_home(agent)
	local top_left_x = agent.home_x - home_radius
	local top_left_y = agent.home_y - home_radius
	local bot_right_x = agent.home_x + home_radius
	local bot_right_y = agent.home_y + home_radius

	rect(top_left_x, top_left_y, bot_right_x, bot_right_y, 13)
end

function draw_mouse()
	local mouse_x = stat(32)
	local mouse_y = stat(33)

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
	local mouse_x = stat(32)
	local mouse_y = stat(33)
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
			matrix[agent.x][agent.y] = "agent"
			add(agents, agent)
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
			if matrix[i][j] == "agent" or matrix[i][j] == "hall" then
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
	pset(a.x, a.y, 8)
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

function agent_move(agent)
	if 		agent.prev_dx == nil
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

function get_id(pos)
	return pos.y*size+pos.x
end

function create_pos(x,y)
	pos = {}
	pos.x = x
	pos.y = y
	return pos
end

function get_pos(id)
	local pos ={}
	pos.y = flr(id / size)
	pos.x = id % size
	return pos
end

function reverse(tbl)
	for i=1, flr(#tbl / 2) do
	tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
	end
end

	-- Get the surrounding
function get_neighbours(pos)
	neighs = {}
	counter = 0
	for x=-1,1 do
	for y=-1,1 do
		if not (x == 0 and y == 0) then
		newx,newy=pos.x+x,pos.y+y
		if newx >= min_x and newx < max_x and newy >= min_y and newy < max_y then
			neigh = create_pos(newx,newy)
			neighs[counter] = neigh
			counter += 1
		end
		end
	end
	end
	return neighs
end

	-- Get the value from a table, or a default value
function get_default(tbl, i, def)
	val = tbl[i]
	if val == nil then
	return def
	else
	return val
	end
end

function func_h(a,b)
	--return abs(a.x-b.x)+abs(a.y-b.y)
	return (a.x-b.x)^2 + (a.y-b.y)^2
end

function reconstruct_path(curr, came_from)
	total_path = {}
	counter = 0
	while came_from[get_id(curr)] ~= nil do
	total_path[counter] = curr
	curr = came_from[get_id(curr)]
	counter += 1
	end

	reverse(total_path)
	return total_path
end


function create_pos(x,y)
	pos = {}
	pos.x=x
	pos.y=y
	return pos
end 

function pos_eq(a,b)
	return a.x == b.x and a.y == b.y
end


function a_star(start, goal)
	open_set_q = priorityqueue()
	open_set_tb = {}

	came_from = {}
	g_scores = {}
	f_scores = {}

	g_scores[get_id(start)] = 0

	while not open_set_q:empty() or curr == nil do
	  if curr == nil then
        curr = start
    else
        curr = get_pos(open_set_q:pop())
        open_set_tb[get_id(curr)] = nil
    end

    curr_id = get_id(curr)

    if pos_eq(curr, goal) then
        return reconstruct_path(goal, came_from)
    end
    ns = get_neighbours(curr)
    for i, n in pairs(ns) do
      n_id = get_id(n)

      tent_score = get_default(g_scores, curr_id, (1/0)) + func_h(curr, n)
      if tent_score < get_default(g_scores, n_id, (1/0)) then
        came_from[n_id] = curr
        g_scores[n_id] = tent_score
        f_score = tent_score + func_h(n, goal)
        f_scores[n_id] = f_score

        if open_set_tb[n_id] == nil then
            open_set_q:put(n_id, f_score)
            open_set_tb[n_id] = n
        end
      end
    end
  end
 end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
