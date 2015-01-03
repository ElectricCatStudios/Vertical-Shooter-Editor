-- TODO: Fix export buttor 
-- TODO: Handle file io more elegantly, the program currently keeps control over output file the whole time it
-- is running

-- dependencies
require "./source/lib/yaci"						-- class
loveframes = require("source.lib.loveframes")	-- loveframes
Vector = require "./source/lib/vector"			-- vector
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
	if (button == 'l') then
		if ((window.mode == "place enemy") and (x < window.mainAreaSize.x) and (y > window.toolbarHeight)) then
			enemyPlaced(world:getMouseWorldPositionSnapped(window.snap))
			if not (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
				window.mode = 'default'
			end
		end
	elseif (button == 'r') then
		window.mode = 'default'
	end
	loveframes.mousepressed(x, y, button)
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
		if love.keyboard.isDown('up') then dCamPos = dCamPos + Vector(0,-1) end
		if love.keyboard.isDown('down') then dCamPos = dCamPos + Vector(0,1) end
		if love.keyboard.isDown('left') then dCamPos = dCamPos + Vector(-1,0) end
		if love.keyboard.isDown('right') then dCamPos = dCamPos + Vector(1,0) end
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

	local coords = {}
	coords[1] = tostring(pos.x) .. ", " .. tostring(pos.y)
	coords[2] = tostring(pos.x) .. ", " .. tostring(pos.y + 1000)

	local lines = {}

	lines[1] = "Fighter1, 3, 3\n"
	lines[2] = "\tstart, 1\n"
	lines[3] = "\t\t" .. coords[1] .. "\n"
	lines[4] = "\tlinear, 1, 6\n"
	lines[5] = "\t\t" .. coords[2] .. "\n"
	lines[6] = "\tend, 0\n"

	table.insert(world.enemies, enemy)
	enemy.path = ""
	for i, v in pairs(lines) do
		enemy.path = enemy.path .. v
	end
end