Enemy = newclass("Enemy")

function Enemy:init(type, position, sprite)
	self.type = type
	self.position = position
	self.sprite = sprite
	self.offset = Vector(sprite:getWidth(), sprite:getHeight())/2
end

function Enemy:draw()
	love.graphics.draw(self.sprite, self.position.x, -self.position.y, 0, 1, 1,self.offset.x, self.offset.y)
end

function Enemy:serialize()
	local data = ""
	local startCoord, endCoord = self.position, self.position + Vector.UP*1000

	startCoord = tostring(startCoord.x) .. ", " .. tostring(-startCoord.y)
	endCoord = tostring(endCoord.x) .. ", " .. tostring(-endCoord.y)

	data = data .. "Fighter, 3, 3, 3\n"
	data = data .. "\tstart, 1\n"
	data = data .. "\t\t" .. startCoord .. "\n"
	data = data .. "\tlinear, 1, 6\n"
	data = data .. "\t\t" .. endCoord .. "\n"
	data = data .. "\tend, 0\n"

	return data
end