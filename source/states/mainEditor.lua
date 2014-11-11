local mainEditor = {}

mainEditor.cameraPosition = Vector(0,0)
mainEditor.mousePosition = Vector(0,0)
mainEditor.mousePositionSnap = Vector(0,0)
mainEditor.snapMode = 32
mainEditor.gridMode = 64

function mainEditor:init()

end

function mainEditor:update(dt)
	-- camera movement
	local dCamPos = Vector(0,0)
	if love.keyboard.isDown('up') then dCamPos = dCamPos + Vector(0,-1) end
	if love.keyboard.isDown('down') then dCamPos = dCamPos + Vector(0,1) end
	if love.keyboard.isDown('left') then dCamPos = dCamPos + Vector(-1,0) end
	if love.keyboard.isDown('right') then dCamPos = dCamPos + Vector(1,0) end
	self.cameraPosition = self.cameraPosition + dCamPos*CAMERA_SPEED

	-- mouse position
	self.mousePosition = Vector(love.mouse.getPosition()) + self.cameraPosition
	self.mousePositionSnap = Vector(roundTo(self.mousePosition.x,self.snapMode,'nearest'),roundTo(self.mousePosition.y,self.snapMode,'nearest'))
end

function mainEditor:draw()
	local gridStart = self.cameraPosition - Vector(self.cameraPosition.x%self.gridMode,self.cameraPosition.y%self.gridMode)

	-- non ui drawing
	-- draw grid
	love.graphics.translate(-self.cameraPosition.x, -self.cameraPosition.y)
	local xTileNum = love.window.getWidth()/self.gridMode
	local yTileNum = love.window.getHeight()/self.gridMode
	local sprite
	if (self.gridMode == 32) then
		sprite = spr_grid32
	elseif (self.gridMode == 64) then
		sprite = spr_grid64
	else
		error('invalid gridMode')
	end
	for i=0, xTileNum do
		for j=0, yTileNum do
			love.graphics.draw(sprite, gridStart.x + self.gridMode*i, gridStart.y + self.gridMode*j)
		end
	end

	-- ui drawing
	love.graphics.translate(self.cameraPosition.x, self.cameraPosition.y)
	-- drawing ui text
	local printString = "camera position: " .. tostring(self.cameraPosition)
	printString = printString .. "\nmousePosition: " .. tostring(self.mousePosition)
	printString = printString .. "\nmouseSnap Position: " .. tostring(self.mousePositionSnap)
	love.graphics.setColor(0,0,0)
	love.graphics.print(printString, 16, 16)
	love.graphics.setColor(255,255,255)
end

state:add("editor", mainEditor)