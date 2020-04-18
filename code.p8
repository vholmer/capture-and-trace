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

local floor = flr

local priorityqueue = {}
priorityqueue.__index = priorityqueue

setmetatable(
	priorityqueue,
	{
		__call = function (self)
			setmetatable({}, self)
			self:initialize()
			return self
		end
	}
)


function priorityqueue:initialize()
		--[[  initialization.
		example:
				priorityqueue = require("priority_queue")
				pq = priorityqueue()
		]]--
	self.heap = {}
	self.current_size = 0
end

function priorityqueue:empty()
	return self.current_size == 0
end

function priorityqueue:size()
	return self.current_size
end

function priorityqueue:swim()
		-- swim up on the tree and fix the order heap property.
	local heap = self.heap
	local floor = floor
	local i = self.current_size

	while floor(i / 2) > 0 do
		local half = floor(i / 2)
		if heap[i][2] < heap[half][2] then
			heap[i], heap[half] = heap[half], heap[i]
		end
		i = half
	end
end

function priorityqueue:put(v, p)
	--[[ put an item on the queue.
	args:
			v: the item to be stored
			p(number): the priority of the item
	]]--
	--

	self.heap[self.current_size + 1] = {v, p}
	self.current_size = self.current_size + 1
	self:swim()
end

function priorityqueue:sink()
		-- sink down on the tree and fix the order heap property.
	local size = self.current_size
	local heap = self.heap
	local i = 1

	while (i * 2) <= size do
		local mc = self:min_child(i)
		if heap[i][2] > heap[mc][2] then
			heap[i], heap[mc] = heap[mc], heap[i]
		end
		i = mc
	end
end

function priorityqueue:min_child(i)
	if (i * 2) + 1 > self.current_size then
		return i * 2
	else
		if self.heap[i * 2][2] < self.heap[i * 2 + 1][2] then
			return i * 2
		else
			return i * 2 + 1
		end
	end
end

function priorityqueue:pop()
	-- remove and return the top priority item
	local heap = self.heap
	local retval = heap[1][1]
	heap[1] = heap[self.current_size]
	heap[self.current_size] = nil
	self.current_size = self.current_size - 1
	self:sink()
	return retval
end

width=128
function get_id(pos)
	return pos.y*width+pos.x
end

function get_pos(id)
	local pos ={}
	pos.y = flr(id / width)
	pos.x = id % width
	return pos
end

function get_neighbours(pos)
	neighs = {}
	counter = 0
	for x=-1,1 do
		for y=-1,1 do
			if not (x == 0 and y == 0) then
				newx,newy=pos.x+x,pos.y+y
				if newx >= 0 and newx < width and newy >= 0 and newy < width then
					neigh = {}
					neigh.x = newx
					neigh.y = newy
					neighs[counter] = neigh
					counter += 1
				end
			end
		end
	end
	return neighs
end

function get_default(tbl, i, def)
	val = tbl[i]
	if val == nil then
		return def
	else
		return val
	end
end

function func_h(a,b)
	return (a.x-b.x)^2 + (a.y-b.y)^2
end

function reverse(t)
	local n = #t
	local i = 1
	while i < n do
		t[i],t[n] = t[n],t[i]
		i = i + 1
		n = n - 1
	end
end

function reconstruct_path(curr, came_from)
	total_path = {}
	counter = 1
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

-- Example usage of a_star
-- start, goal= create_pos(68,124), create_pos(0, 0)
-- path = a_star(start, goal) -- path is is 1-index
-- path[1].x is the next x-value in the agents path etc.
-- path[1].y is the next y-value in the agents path etc.
-- for i,p in pairs(path) do
-- 	print(p.x..':'..p.y)
-- end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
