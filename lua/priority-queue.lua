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