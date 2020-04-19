function _init()
	local n = 100
	make_world()
	make_hall()
	make_agents(n)
	foreach(agents, make_home)
end

function _update()
	if time_cycle <= 0 then
		in_cycle = false
	end
	if in_cycle then
		foreach(agents, act)
	else
		user_input()
	end
	if time_cycle > 0 then
		time_cycle -= 1
	end
end

function _draw()
	cls(1)
	rectfill(0, 101, 127, 127, 0)
	if not in_cycle then
		rect(0, 101, 127, 127, 6)
	end
	foreach(agents, draw_home)
	foreach(agents, draw_agent)
	draw_hall()
	draw_endturn()
	draw_cycle()
	draw_ap()
	draw_mouse()
	--print("CPU: " .. stat(1), 0, 0, 7)
	--print("MEM: " .. stat(0), 0, 6, 7)
end