local mainEditor = {}

mainEditor.cameraPosition = Vector(0,0)
mainEditor.mousePosition = Vector(0,0)
mainEditor.mousePositionSnap = Vector(0,0)
mainEditor.snapMode = 32

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
	self.mousePositionSnap = Vector(roundTo(self.mousePosition.x,32,'nearest'),roundTo(self.mousePosition.y,32,'nearest'))
end

function mainEditor:draw()
	local gridStart = self.cameraPosition - Vector(self.cameraPosition.x%32,self.cameraPosition.y%32)
	-- non ui drawing
	-- draw grid
	love.graphics.translate(-self.cameraPosition.x, -self.cameraPosition.y)
	local xTileNum = love.window.getWidth()/self.snapMode
	local yTileNum = love.window.getHeight()/self.snapMode
	print(xTileNum)
	for i=0, xTileNum do
		for j=0, yTileNum do
			love.graphics.draw(spr_grid32, gridStart.x + 32*i, gridStart.y + 32*j)
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