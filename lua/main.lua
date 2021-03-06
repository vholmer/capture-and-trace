function _init()
	local n = 50
	if stat(6) == "retry" then
		in_menu = false
	else
		in_cycle = false
		buttons_disabled = true
	end
	make_world()
	make_hall()
	make_agents(n)
	if in_menu then
    	music(21)
    else
    	music(1)
    end
end

function _update()
	if time_cycle <= 0 then
		if in_cycle then
			if max_ap < ap_limit then
				max_ap += 5
			end
			if cycle_count < 99 then
				cycle_count += 1
			else
				cycle_count = 99
			end
			in_cycle = false
			reset_ap = true
		end
	end
	if in_cycle then
		capturing = false
		foreach(agents, act)
	else
		if reset_ap == nil or reset_ap then
			curr_ap = max_ap
			reset_ap = false
		end
		user_input()
	end
	if time_cycle > 0 and in_cycle then
		time_cycle -= 1
	end
	foreach(particles, particle_act)
	foreach(exp_circles, circle_act)
	game_over, old_game_over_state = is_game_over(), game_over
	victory, old_victory_state = is_victory(), victory
	if game_over or victory or in_menu then
		if not old_game_over_state and game_over then
			sfx(22)
			music(-1)
		end
		if not old_victory_state and victory then
			sfx(23)
			music(-1)
		end
		capturing = false
		tracing = false
		buttons_disabled = true
		in_cycle = false
	end
end

function _draw()
	if in_menu then
		cls(0)
		draw_menu()
		draw_mouse()
	else
		cls(1)
		rectfill(0, 101, 127, 127, 0)
		if not in_cycle then
			rect(0, 101, 127, 127, 6)
		end
		foreach(agents, draw_home)
		draw_trace_lines()
		foreach(agents, draw_agent)
		draw_hall()
		draw_exp_circles()
		draw_particles()
		draw_endturn()
		draw_cycle()
		draw_ap()
		draw_actions()
		if game_over then
			draw_game_over()
		elseif victory then
			draw_victory()
		end
		draw_capture()
		draw_trace()
		draw_mouse()
		--print("CPU: " .. stat(1), 0, 0, 7)
		--print("MEM: " .. stat(0), 0, 6, 7)
	end
end
