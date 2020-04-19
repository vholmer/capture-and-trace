function draw_ap()
	ap_top_left_x = 46
	ap_top_left_y = 112
	ap_bot_right_x = ap_top_left_x + 33
	ap_bot_right_y = ap_top_left_y + 6

	if game_over then
		color = 8
	elseif in_cycle then
		color = 8
	else
		color = 6
	end

	rectfill(
		ap_top_left_x,
		ap_top_left_y,
		ap_bot_right_x,
		ap_bot_right_y,
		color
	)

	print(
		"ap: " .. curr_ap .. "/" .. max_ap,
		ap_top_left_x + 1,
		ap_top_left_y + 1,
		0
	)
end

function draw_cycle()
	cycle_top_right_x = 124
	cycle_top_right_y = 106
	cycle_bot_left_x = cycle_top_right_x - 32
	cycle_bot_left_y = cycle_top_right_y + 6

	if game_over then
		color = 8
	elseif in_cycle then
		color = 8
	else
		color = 6
	end

	rectfill(
		cycle_top_right_x,
		cycle_top_right_y,
		cycle_bot_left_x,
		cycle_bot_left_y,
		color
	)

	print(
		"Cycle:" .. cycle_count,
		cycle_top_right_x - 31,
		cycle_top_right_y + 1,
		0
	)
end

function draw_endturn()
	end_turn_bot_right_y = 122
	end_turn_bot_right_x = 124
	end_turn_top_left_x = end_turn_bot_right_x - 32
	end_turn_top_left_y = end_turn_bot_right_y - 6

	if game_over then
		color = 8
	elseif et_mouse_over and not buttons_disabled then
		color = 3
	elseif in_cycle then
		color = 8
	else
		color = 6
	end

	rectfill(
		end_turn_top_left_x,
		end_turn_top_left_y,
		end_turn_bot_right_x,
		end_turn_bot_right_y,
		color
	)

	rect(
		end_turn_top_left_x - 1,
		end_turn_top_left_y - 1,
		end_turn_bot_right_x + 1,
		end_turn_bot_right_y + 1,
		5
	)

	print(
		"End turn",
		end_turn_top_left_x + 1,
		end_turn_top_left_y + 1,
		0
	)
end

function draw_hall()
	rect(
		hall.top_left_x, hall.top_left_y,
		hall.top_left_x + hall.width,
		hall.top_left_y + hall.height,
		7
	)
end

home_cnt = 0
function draw_home(agent)
	local top_left_x = agent.home_x - home_radius
	local top_left_y = agent.home_y - home_radius
	local bot_right_x = agent.home_x + home_radius
	local bot_right_y = agent.home_y + home_radius
	local opn_indx = agent.home_opn_indx

	-- if agent.going_home then
	-- 	rectfill(agent.home_x, agent.home_y, agent.home_x, agent.home_y, 10)
	-- end

	local debugging = false
	if debugging then home_cnt += 1 end

	if (not debugging) or flr(home_cnt / 120) % 2 == 0 then
		-- Top
		if opn_indx ~= 0 then
			line(top_left_x, top_left_y, bot_right_x, top_left_y, 13)
		end
		if opn_indx ~= 1 then
			-- Left
			line(top_left_x, top_left_y, top_left_x, bot_right_y, 13)
		end
		if opn_indx ~= 2 then
			--Bottom
			line(top_left_x, bot_right_y, bot_right_x, bot_right_y, 13)
		end
		if opn_indx ~= 3 then
			-- Right
			line(bot_right_x, top_left_y, bot_right_x, bot_right_y, 13)
		end
	else
		for x=0,127 do
			for y=0,127 do
				if matrix[x][y] == "home" then
					rectfill(x,y,x,y,0)
				end
			end
		end
	end
end

function draw_mouse()
	local mouse_x = stat(32)
	local mouse_y = stat(33)

	pset(mouse_x - 1, mouse_y - 1, 7)
	pset(mouse_x - 1, mouse_y + 1, 7)
	pset(mouse_x + 1, mouse_y - 1, 7)
	pset(mouse_x + 1, mouse_y + 1, 7)

	if stat(34) == 1 then
		pset(mouse_x, mouse_y, 7)
	end
end

function draw_agent(a)
	-- and false because debugging feature toggle
	if 		a.is_snatcher
		and true
	then
		pset(a.x, a.y, 9)
	else
		pset(a.x, a.y, 8)
	end
end

function draw_game_over()
	local color = 0
	local top_left_x = 32
	local top_left_y = 25
	local bot_right_x = 128 - 32
	local bot_right_y = 128 - 28 - 25

	rectfill(
		top_left_x,
		top_left_y,
		bot_right_x,
		bot_right_y,
		0
	)

	rect(
		top_left_x,
		top_left_y,
		bot_right_x,
		bot_right_y,
		6
	)

	print(
		"Game over",
		2 + top_left_x + 12,
		4 + top_left_y,
		7
	)

	print(
		"Try again?",
		2 + top_left_x + 10,
		2 + top_left_y + 12,
		7
	)

	go_yes_top_left_x = 2 + top_left_x + 10
	go_yes_top_left_y = 2 + top_left_y + 24
	go_yes_bot_right_x = 2 + top_left_x + 10 + 14
	go_yes_bot_right_y = 2 + top_left_y + 24 + 8

	if go_yes_mouse_over then
		color = 3
	else
		color = 6
	end

	rectfill(
		go_yes_top_left_x,
		go_yes_top_left_y,
		go_yes_bot_right_x,
		go_yes_bot_right_y,
		color
	)

	rect(
		go_yes_top_left_x,
		go_yes_top_left_y,
		go_yes_bot_right_x,
		go_yes_bot_right_y,
		5
	)

	print(
		"Yes",
		go_yes_top_left_x + 2,
		go_yes_top_left_y + 2,
		0
	)

	local width = 10
	local offset = 28
	go_no_top_left_x = go_yes_top_left_x + offset
	go_no_top_left_y = go_yes_top_left_y
	go_no_bot_right_x = go_yes_top_left_x + offset + width
	go_no_bot_right_y = go_yes_bot_right_y

	if go_no_mouse_over then
		color = 3
	else
		color = 6
	end

	rectfill(
		go_no_top_left_x,
		go_no_top_left_y,
		go_no_bot_right_x,
		go_no_bot_right_y,
		color
	)

	rect(
		go_no_top_left_x,
		go_no_top_left_y,
		go_no_bot_right_x,
		go_no_bot_right_y,
		5
	)

	print(
		"No",
		go_no_top_left_x + 2,
		go_no_top_left_y + 2,
		0
	)
end

function draw_actions()
	capture_top_left_x = 3
	capture_top_left_y = 105
	capture_bot_right_x = 33
	capture_bot_right_y = capture_top_left_y + 8

	if game_over then
		color = 8
	elseif capture_mouse_over and not buttons_disabled then
		color = 3
	elseif in_cycle then
		color = 8
	else
		color = 6
	end

	rectfill(
		capture_top_left_x,
		capture_top_left_y,
		capture_bot_right_x,
		capture_bot_right_y,
		color
	)

	rect(
		capture_top_left_x,
		capture_top_left_y,
		capture_bot_right_x,
		capture_bot_right_y,
		5
	)

	print(
		"Capture",
		capture_top_left_x + 2,
		capture_top_left_y + 2,
		0
	)

	trace_top_left_x = 3
	trace_top_left_y = 115
	trace_bot_right_x = 33
	trace_bot_right_y = trace_top_left_y + 8

	if game_over then
		color = 8
	elseif trace_mouse_over and not buttons_disabled then
		color = 3
	elseif in_cycle then
		color = 8
	else
		color = 6
	end

	rectfill(
		trace_top_left_x,
		trace_top_left_y,
		trace_bot_right_x,
		trace_bot_right_y,
		color
	)

	rect(
		trace_top_left_x,
		trace_top_left_y,
		trace_bot_right_x,
		trace_bot_right_y,
		5
	)

	print(
		"trace",
		trace_top_left_x + 6,
		trace_top_left_y + 2,
		0
	)	
end
