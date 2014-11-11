StateManager = class:new()


function StateManager:init()
	self.list = {}
	self.paused = false
end

function StateManager:pause()
	self.paused = true
end


function StateManager:unpause()
	self.paused = false
end

function StateManager:pauseToggle()
	self.paused = (not self.paused)
end


function StateManager:add(index, state)
	if(state) then
		self.list[index] = state
	else
		error("Cannot add nil state", 2)
	end
end

function StateManager:set(index, ...)
	if (self.list[index]) then
		self.current = self.list[index]
		
		if (self.current.init) then
			self.current:init(...)
		end
	else
		error("The state " .. index .. " does not exist",2)
	end
end

function StateManager:update(dt)
	if self.current.update and not self.paused then
		self.current:update(dt)
	end
end

function StateManager:draw()
	if self.current.draw then
		self.current:draw()
	end
end

function StateManager:keypressed(key)
	if self.current.keypressed then
		self.current:keypressed(key)
	end
end

function StateManager:printStates()
	print("states are:")
	for i, v in pairs(self.list) do
		print(i)
	end
	print()
end