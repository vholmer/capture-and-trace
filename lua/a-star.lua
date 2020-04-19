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
				if not (x == 0 or y == 0) and
						newx >= 0 and newx < width and newy >= 0 and newy < width then
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
