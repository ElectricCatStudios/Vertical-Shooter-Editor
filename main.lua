-- dependencies
require "./source/lib/class"					-- class
require './source/lib/util'						-- util functions
loveframes = require("source.lib.loveframes")	-- loveframes
Vector = require "./source/lib/vector"			-- vector


-- classes
require "./source/classes/StateManager"		-- StateManager

-- states
state = StateManager:new()					-- init state system
require"./source/states/mainEditor"

-- sprites
spr_grid32 = love.graphics.newImage("/resources/grid32.png")		-- playerShip1
spr_grid64 = love.graphics.newImage("/resources/grid64.png")		-- enemyShip1

-- constants
CAMERA_SPEED = 250
PROGRESSION_SPEED = 10
TOOLPANE_WIDTH = 250
TOOLBAR_HEIGHT = 32

function love.load()
	state:set("editor")
	love.graphics.setBackgroundColor(180,180,180)
end

function love.update(dt)
	state:update(dt)
	loveframes.update(dt)
end

function love.draw()
	state:draw()
end

function love.keypressed(key, unicode)
	state:keypressed(key)
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