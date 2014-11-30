Enemy = class:new()

function Enemy:init(type, position, sprite)
	self.type = type
	self.position = position
	self.sprite = sprite
	self.offset = Vector(sprite:getWidth(), sprite:getHeight())/2
end

function Enemy:draw()
	love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, 1, 1,self.offset.x, self.offset.y)
end