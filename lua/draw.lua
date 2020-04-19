function draw_ap()
	ap_top_left_x = 46
	ap_top_left_y = 111
	ap_bot_right_x = ap_top_left_x + 33
	ap_bot_right_y = ap_top_left_y + 6

	if in_cycle then
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
	cycle_top_right_y = 105
	cycle_bot_left_x = cycle_top_right_x - 32
	cycle_bot_left_y = cycle_top_right_y + 6

	if in_cycle then
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
	end_turn_bot_right_y = 123 -- 109
	end_turn_bot_right_x = 124 -- 34
	end_turn_top_left_x = end_turn_bot_right_x - 32
	end_turn_top_left_y = end_turn_bot_right_y - 6

	if et_mouse_over then
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