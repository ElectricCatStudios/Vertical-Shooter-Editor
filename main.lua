-- dependencies
require "./source/lib/class"				-- class
require './source/lib/util'				-- util functions
Vector = require "./source/lib/vector"		-- vector

-- classes
require "./source/classes/StateManager"		-- StateManager

-- states
state = StateManager:new()					-- init state system
require"./source/states/mainEditor"

-- sprites
spr_grid32 = love.graphics.newImage("/resources/grid32.png")		-- playerShip1
spr_grid64 = love.graphics.newImage("/resources/grid64.png")		-- enemyShip1

-- constants
CAMERA_SPEED = 5
PROGRESSION_SPEED = 10

function love.load()
	state:set("editor")
	love.graphics.setBackgroundColor(180,180,180)
end

function love.update(dt)
	state:update(dt)
end

function love.draw()
	state:draw()
end

function love.keypressed(key,isrepeat)
	state:keypressed(key)
end