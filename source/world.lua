world = {}

world.background = love.graphics.newImage("/resources/background.png")
world.width = world.background:getWidth()
world.height = world.background:getHeight()
world.enemies = {}
world.cameraPosition = -window.centerOffset
world.gridMode = 64
world.scrollSpeed = 250

function world:draw()
	love.graphics.translate(-world.cameraPosition.x, -world.cameraPosition.y)

	love.graphics.draw(self.background, 0, -self.height)
	self:drawGrid()
	for index, enemy in pairs(world.enemies) do
		enemy:draw()
	end
	-- TODO: maybe move this
	-- enemy placement
	if (window.mode == 'place enemy') then
		love.graphics.draw(spritesArray[window.enemyIndex], self:getMouseWorldPositionSnapped(window.snap).x, -world:getMouseWorldPositionSnapped(window.snap).y, 0, 1, 1, spritesArray[window.enemyIndex]:getWidth()/2, spritesArray[window.enemyIndex]:getHeight()/2)
	end

	love.graphics.origin()
end

function world:drawGrid()
	local gridStart = world.cameraPosition - Vector(world.cameraPosition.x%self.gridMode, world.cameraPosition.y%self.gridMode)
	local xTileNum = love.window.getWidth()/self.gridMode + 1 			-- the number of columns
	local yTileNum = love.window.getHeight()/self.gridMode + 1 			-- the number of rows
	local sprite 		-- the sprite to be tiled

	-- do not draw grid out of bounds
	gridStart.x = math.max(gridStart.x, 0)
	gridStart.y = math.max(gridStart.y, -world.height)

	-- choose which sprite to use
	if (self.gridMode == 32) then
		sprite = spr_grid32
	elseif (self.gridMode == 64) then
		sprite = spr_grid64
	else
		error('invalid self.gridMode')
	end
	for i=0, xTileNum do
		local x = gridStart.x+self.gridMode*i
		local y
		-- only tile within map bounds
		if (x >= world.width) then break end
		for j=0, yTileNum do
			y = gridStart.y+self.gridMode*j
			-- only tile within map bounds
			if (y>=0) then break end
			love.graphics.draw(sprite, gridStart.x + self.gridMode*i, gridStart.y + self.gridMode*j)
		end
	end
end

function world:getMouseWorldPosition()
	local result = Vector(love.mouse.getPosition()) + world.cameraPosition
	result.y = -result.y
	return result
end

function world:getMouseWorldPositionSnapped(snapX, snapY)
	snapY = snapY or snapX
	local result = self:getMouseWorldPosition()
	return Vector(roundTo(result.x, snapX, 'nearest'), roundTo(result.y, snapY, 'nearest'))
end

function aabbEnemySelect()

end

function world:worldToWindowSpace(worldSpaceCoord)
	assert(worldSpaceCoord.x and worldSpaceCoord.y and self)

	local windowSpaceCoord = worldSpaceCoord - self.cameraPosition
	return windowSpaceCoord
end

function windowToWorldSpace(windowSpaceCoord)
	assert(windowSpaceCoord.x and windowSpaceCoord.y and self)

	local worldSpaceCoord = self.cameraPosition + windowSpaceCoord
	return worldSpaceCoord
end

function worldToWindowSpace(worldX, worldY)
	assert(worldX and worldY and self)

	local windowX = worldX - self.cameraPosition.x
	local windowY = worldY - self.cameraPosition.y

	return windowSpaceCoord
end

function windowToWorldSpace(windowX, windowY)
	assert(windowX and windowY and self)

	local worldX = self.cameraPosition.x + windowX
	local worldY = self.cameraPosition.y + windowY

	return windowSpaceCoord
end