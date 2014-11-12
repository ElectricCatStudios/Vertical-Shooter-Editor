-- dependencies
require "./source/lib/class"					-- class
require './source/lib/util'						-- util functions
loveframes = require("source.lib.loveframes")	-- loveframes
Vector = require "./source/lib/vector"			-- vector
-- sprites
spr_grid32 = love.graphics.newImage("/resources/grid32.png")		-- playerShip1
spr_grid64 = love.graphics.newImage("/resources/grid64.png")		-- enemyShip1

-- constants
CAMERA_SPEED = 250
PROGRESSION_SPEED = 10
TOOLPANE_WIDTH = 250
TOOLBAR_HEIGHT = 32

-- globals
cameraPosition = Vector(0,0)
mousePosition = Vector(0,0)
mousePositionSnap = Vector(0,0)
snapMode = 32
gridMode = 64

function love.load()
	-- toolpane
	toolpane = loveframes.Create("panel")
	toolpane.update = function(object, dt)
		toolpane:SetSize(TOOLPANE_WIDTH, love.window.getHeight() - TOOLBAR_HEIGHT - 1)
		toolpane:SetPos(love.window.getWidth() - TOOLPANE_WIDTH, TOOLBAR_HEIGHT + 1)
	end
	toolpane:update(0)

	-- toolbar
	toolbar = loveframes.Create("panel")
	toolbar.update = function(object, dt)
		toolbar:SetSize(love.window.getWidth(), TOOLBAR_HEIGHT)
	end
	toolbar:update(0)

	-- cameraField
	-- x
	cameraFieldx = loveframes.Create("textinput")
	cameraFieldx:SetWidth(50)
	cameraFieldx:CenterWithinArea(46, 0, 96, TOOLBAR_HEIGHT)
	cameraFieldx:SetFont(love.graphics.newFont(12))
	cameraFieldx:SetEditable(true)
	cameraFieldx:SetText(tostring(cameraPosition.x))
	-- y
	cameraFieldy = loveframes.Create("textinput")
	cameraFieldy:SetWidth(50)
	cameraFieldy:CenterWithinArea(142, 0, 192, TOOLBAR_HEIGHT)
	cameraFieldy:SetFont(love.graphics.newFont(12))
	cameraFieldy:SetEditable(true)
	cameraFieldy:SetText(tostring(cameraPosition.y))

	love.graphics.setBackgroundColor(180,180,180)
end

function love.update(dt)
	-- camera movement
	local dCamPos = Vector(0,0)
	if love.keyboard.isDown('up') then dCamPos = dCamPos + Vector(0,-1) end
	if love.keyboard.isDown('down') then dCamPos = dCamPos + Vector(0,1) end
	if love.keyboard.isDown('left') then dCamPos = dCamPos + Vector(-1,0) end
	if love.keyboard.isDown('right') then dCamPos = dCamPos + Vector(1,0) end
	cameraPosition = cameraPosition + dCamPos*CAMERA_SPEED * dt
	cameraPosition.x = roundTo(cameraPosition.x, 1, 'nearest')
	cameraPosition.y = roundTo(cameraPosition.y, 1, 'nearest')

	-- mouse position
	mousePosition = Vector(love.mouse.getPosition()) + cameraPosition
	mousePositionSnap = Vector(roundTo(mousePosition.x,snapMode,'nearest'),roundTo(mousePosition.y,snapMode,'nearest'))

	loveframes.update(dt)
end

function love.draw()
	local gridStart = cameraPosition - Vector(cameraPosition.x%gridMode,cameraPosition.y%gridMode)

	-- non ui drawing
	-- draw grid
	love.graphics.translate(-cameraPosition.x, -cameraPosition.y)
	local xTileNum = love.window.getWidth()/gridMode + 1
	local yTileNum = love.window.getHeight()/gridMode + 1
	local sprite
	if (gridMode == 32) then
		sprite = spr_grid32
	elseif (gridMode == 64) then
		sprite = spr_grid64
	else
		error('invalid gridMode')
	end
	for i=0, xTileNum do
		for j=0, yTileNum do
			love.graphics.draw(sprite, gridStart.x + gridMode*i, gridStart.y + gridMode*j)
		end
	end

	-- ui drawing
	love.graphics.translate(cameraPosition.x, cameraPosition.y)
	loveframes.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.print('Camera x:', 4, TOOLBAR_HEIGHT/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.print('Camera y:', 4 + 46 + 100, TOOLBAR_HEIGHT/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.setColor(255,255,255)
end

function love.keypressed(key, unicode)
	if (key == 'g') then
		if (gridMode == 32) then
			gridMode = 64
		else
			gridMode = 32
		end
	end
	loveframes.keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	loveframes.keyreleased(key)
end

function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function love.textinput(text)
	loveframes.textinput(text)
end