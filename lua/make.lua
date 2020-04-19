function make_world()
	for i = 0, size do
		matrix[i] = {}
		for j = 0, size do
			matrix[i][j] = "empty"
		end
	end
end

function make_agents(n)
	first_snatcher = true
	for i = 1, n do
		local agent = {}
		local empty_coord = false
		local rand_x = -1
		local rand_y = -1
		while not empty_coord do
			rand_x = flr(rnd(max_x - min_x)) + min_x
			rand_y = flr(rnd(max_y - min_y)) + min_y
			empty_coord = check_empty(rand_x, rand_y, nil)
		end
		agent.x = rand_x
		agent.y = rand_y
		agent.home_x = rand_x
		agent.home_y = rand_y
		agent.trace_depth = -1
		agent.is_captured = false
		agent.home_opn_indx = 1 + flr(rnd(3))
		matrix[agent.x][agent.y] = "agent"
		agent.hunger = flr(rnd(400)) + 100
		if first_snatcher then
			agent.is_snatcher = true
			agent.snatcher_zero = true
			matrix[agent.x][agent.y] = "snatcher"
		else
			agent.snatcher_zero = false
			agent.is_snatcher = false
			matrix[agent.x][agent.y] = "agent"
		end
		add(agents, agent)
		make_home(agent)
		first_snatcher = false
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

	hall.bot_right_x = hall.top_left_x + hall.width
	hall.bot_right_y = hall.top_left_y + hall.height

	for i = hall.top_left_x, hall.bot_right_x do
		matrix[i][hall.top_left_y] = "hall"
	end

	for i = hall.top_left_x, hall.bot_right_x do
		matrix[i][hall.bot_right_y] = "hall"
	end

	for i = hall.top_left_y, hall.bot_right_y do
		matrix[hall.top_left_x][i] = "hall"
	end

	for i = hall.top_left_y, hall.bot_right_y do
		matrix[hall.bot_right_x][i] = "hall"
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

function make_exp_circle(x, y, speed, max_r, col)
	local circle = {}
	circle.x = x
	circle.y = y
	circle.r = 0
	circle.max_r = max_r
	circle.speed = speed
	circle.col = col
	add(exp_circles, circle)
end

function make_particle_point(x, y, n, col)
	for i = 0, n do
		local particle = {}
		particle.x = x
		particle.y = y
		particle.col = col
		particle.floor_y = y + 2
		particle.life = flr(rnd(10)) + 5

		particle.dx = rnd(0.1) - 0.2
		particle.dy = rnd(0.1) * -1

		add(particles, particle)
	end
end

function make_particle_line(x1, y1, x2, y2, n, col1, col2, chance)
	local x, y, dx, dy, dx1, dy1, px, py, xe, ye

	dx = x2 - x1
	dy = y2 - y1

	dx1 = abs(dx)
	dy1 = abs(dy)

	px = 2 * dy1 - dx1
	py = 2 * dx1 - dy1

	if dy1 <= dx1 then
		if dx >= 0 then
			x = x1
			y = y1
			xe = x2
		else
			x = x2
			y = y2
			xe = x1
		end

		if chance > rnd(1) then
			if 0.5 > rnd(1) then
				make_particle_point(x, y, n, col1)
			else
				make_particle_point(x, y, n, col2)
			end
		end

		while x < xe do
			x += 1
			if px < 0 then
				px += 2 * dy1
			else
				if 		(dx < 0 and dy < 0)
					or 	(dx > 0 and dy > 0)
				then
					y += 1
				else
					y -= 1
				end
				px += 2 * (dy1 - dx1)
			end

			if chance > rnd(1) then
				if 0.5 > rnd(1) then
					make_particle_point(x, y, n, col1)
				else
					make_particle_point(x, y, n, col2)
				end
			end
		end
	else
		if dy >= 0 then
			x = x1
			y = y1
			ye = y2
		else
			x = x2
			y = y2
			ye = y1
		end

		if chance > rnd(1) then
			if 0.5 > rnd(1) then
				make_particle_point(x, y, n, col1)
			else
				make_particle_point(x, y, n, col2)
			end
		end

		while y < ye do
			y += 1
			if py <= 0 then
				py += 2 * dx1
			else
				if		(dx < 0 and dy < 0)
					or	(dx > 0 and dy > 0)
				then
					x += 1
				else
					x -= 1
				end

				py += 2 * (dx1 - dy1)
			end

			if chance > rnd(1) then
				if 0.5 > rnd(1) then
					make_particle_point(x, y, n, col1)
				else
					make_particle_point(x, y, n, col2)
				end
			end
		end
	end
end
