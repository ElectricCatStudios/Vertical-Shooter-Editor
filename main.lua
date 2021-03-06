-- TODO: Fix export buttor 
-- TODO: Handle file io more elegantly, the program currently keeps control over output file the whole time it
-- TODO: switch game coordinate system
-- is running

-- dependencies
require "./source/lib/yaci"						-- class
loveframes = require("source.lib.loveframes")	-- loveframes
Vector = require "./source/lib/vector"			-- vector

Vector.up = Vector(0, 1)
Vector.down = Vector(0, -1)
Vector.left = Vector(-1, 0)
Vector.right = Vector(1, 0)

require './source/lib/util'						-- util functions
require './source/lib/PriorityQueue'
require "./source/loadSprites"
require "/source/Enemy"

require "./source/window"
require "./source/world"

-- sprites
spr_grid32 = love.graphics.newImage("/resources/grid32.png")		-- playerShip1
spr_grid64 = love.graphics.newImage("/resources/grid64.png")		-- enemyShip1

-------------------------------------------
-- INIT AND MAIN LOOP
-------------------------------------------

function love.load(arg)

	output = io.open("./levels/output.lvl", "w")
	love.graphics.setBackgroundColor(180,180,180)
	window:initUI()
end

function love.update(dt)
	loveframes.update(dt)
	cameraMovement(dt)
end

function love.draw()
	world:draw()
	window:draw()
end


-------------------------------------------
-- INPUT
-------------------------------------------
function love.keypressed(key, unicode)
	if (key == 'g') then
		if (world.gridMode == 32) then
			world.gridMode = 64
		else
			world.gridMode = 32
		end
	end

	if (key == 'escape') then
		love.event.quit()
	end

	loveframes.keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	loveframes.keyreleased(key)
end

function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
	window:mousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function love.textinput(text)
	loveframes.textinput(text)
end

------------------------------------------
-- OTHER
------------------------------------------
function love.resize(w, h)
	window:resize(w,h)
end

function cameraMovement(dt)
	local dCamPos = Vector(0,0)		-- the position delta

	if (not (window.cameraFieldx:GetFocus() or window.cameraFieldy:GetFocus())) then
		if love.keyboard.isDown('up') then dCamPos = dCamPos + Vector.up end
		if love.keyboard.isDown('down') then dCamPos = dCamPos + Vector.down end
		if love.keyboard.isDown('left') then dCamPos = dCamPos + Vector.left end
		if love.keyboard.isDown('right') then dCamPos = dCamPos + Vector.right end
	end

	world.cameraPosition = world.cameraPosition + dCamPos*world.scrollSpeed * dt
	--round values to nearest integer so there isn't any nasty aliasing of the grid
	world.cameraPosition.x = roundTo(world.cameraPosition.x, 1, 'nearest')
	world.cameraPosition.y = roundTo(world.cameraPosition.y, 1, 'nearest')
end

function enemyButtonPressed(self, mouseX, mouseY)
	if (window.mode == "default") then
		window.mode = "place enemy"
		window.enemyIndex = self.id
	end
end

function enemyPlaced(pos)
	-- print("placing enemy #" .. window.enemyIndex .. ' at pos: ' .. tostring(pos))
	local enemy =  Enemy:new(enemyTypeArray[window.enemyIndex], pos, spritesArray[window.enemyIndex])
	table.insert(world.enemies, enemy)
end