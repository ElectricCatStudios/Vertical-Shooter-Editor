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
	setupUI()
end

function love.update(dt)
	loveframes.update(dt)
	cameraMovement(dt)
end


------------------------------------------
-- DRAWING
------------------------------------------
function love.draw()
	world:draw()
	drawUI()
end

function drawUI()
	-- toolbar
	loveframes.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.print('Camera x:', 4, window.toolbarHeight/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.print('Camera y:', 4 + 46 + 100, window.toolbarHeight/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.print('     Snap:', 4 + 2*(46 + 100),  window.toolbarHeight/2 - love.graphics.getFont():getHeight()/2)


	local snapPos = world:getMouseWorldPositionSnapped(window.snap)
	snapPos.y = -snapPos.y
	local mouseString = tostring(snapPos)
	local _, _, p1, p2, p3 = mouseString:find('(%(%-?%d+)%.%d*(%,%-?%d+)%.%d*(%))')
	mouseString = p1 .. p2 .. p3
	love.graphics.print('Mouse: ' .. mouseString, love.window.getWidth() - 140, window.toolbarHeight/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.setColor(255,255,255)

	-- croshair
	local top, bottom, left, right =
		window.centerOffset+window.crosshairSize*Vector.UP, window.centerOffset+window.crosshairSize*Vector.DOWN, window.centerOffset+window.crosshairSize*Vector.LEFT, window.centerOffset+window.crosshairSize*Vector.RIGHT
	love.graphics.line(top.x, top.y, bottom.x, bottom.y)
	love.graphics.line(left.x, left.y, right.x, right.y)
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
-- UI
------------------------------------------
function setupToolPane()
	local toolpane 						-- the main pane on the right. A list of all ui elements
	local enemyCategory					-- the expandable categary that holds the enemy ui
	local pathCategory					-- the expandable category that holds path ui
	local enemyGrid						-- the grid of all the enemy buttons

	--toolpane
	toolpane = loveframes.Create("list")
	toolpane.resize = function(object)
		object:SetSize(window.toolpaneWidth, love.window.getHeight() - window.toolbarHeight - 1)
		object:SetPos(love.window.getWidth() - window.toolpaneWidth, window.toolbarHeight + 1)
	end
	toolpane:resize()
	toolpane:SetPadding(5)
	toolpane:SetSpacing(5)



	-- enemy Category
	enemyCategory = loveframes.Create("collapsiblecategory", toolpane)
	enemyCategory:SetText("Enemies")
	enemyCategory.Update = function(object, dt)
		child = object:GetObject()
		child:SetX((enemyCategory:GetWidth() - child:GetWidth())/2)
	end

	-- enemy grid
	local gridColumns = 6
	local gridRows = roundTo(#spritesArray/gridColumns, 1, 'up')
	enemyGrid = loveframes.Create("grid")
	enemyGrid:SetRows(gridRows)
	enemyGrid:SetColumns(gridColumns)
	enemyGrid:SetCellWidth(32)
	enemyGrid:SetCellHeight(32)
	enemyGrid:SetCellPadding(2)
	enemyGrid:SetItemAutoSize(true)
	enemyGrid:SetSize(enemyCategory:GetWidth()-4, 100)
	local id = 1
	for i=1, gridRows do
	    for n=1, gridColumns do
	        local button = loveframes.Create("imagebutton")
	        local tooltip = loveframes.Create("tooltip")
	        tooltip:SetObject(button)
	        tooltip:SetText(enemyTypeArray[id])
	        button:SetImage(spritesArray[id])
	        button:SetSize(15, 15)
	        button:SetText("")
	        enemyGrid:AddItem(button, i, n)
	        button.id = id
	        button.OnClick = enemyButtonPressed
	        id = id + 1
	        if (id > #spritesArray) then
	        	break
	        end
	    end
	end
	enemyCategory:SetObject(enemyGrid)


	-- path category
	pathCategory = loveframes.Create("collapsiblecategory", toolpane)
	pathCategory:SetText("Path Tools")

	-- toolbar
	toolbar = loveframes.Create("panel")
	toolbar.resize = function(object)
		toolbar:SetSize(love.window.getWidth(), window.toolbarHeight)
	end
	toolbar:resize()
end

function setupToolbar()
	local toolbar 			-- the main toolbar at the top

	-- cameraField
	local function onFocus(object)
		object:SetText("")
	end
	-- x field
	window.cameraFieldx = loveframes.Create("textinput")
	window.cameraFieldx:SetWidth(50)
	window.cameraFieldx:CenterWithinArea(46, 0, 96, window.toolbarHeight)
	window.cameraFieldx:SetFont(love.graphics.newFont(12))
	window.cameraFieldx:SetEditable(true)
	window.cameraFieldx:SetText(tostring(world.cameraPosition.x))
	window.cameraFieldx.OnFocusGained = onFocus
	window.cameraFieldx.OnEnter = function(object)
		world.cameraPosition.x = tonumber(object:GetText()) - window.centerOffset.x
	end
	window.cameraFieldx.Update = function(object, dt)
		if (not object:GetFocus()) then
			object:SetText(tostring(window.cameraCenterPos.x))
		end
	end
	-- y field
	window.cameraFieldy = loveframes.Create("textinput")
	window.cameraFieldy:SetWidth(50)
	window.cameraFieldy:CenterWithinArea(142, 0, 192, window.toolbarHeight)
	window.cameraFieldy:SetFont(love.graphics.newFont(12))
	window.cameraFieldy:SetEditable(true)
	window.cameraFieldy:SetText(tostring(world.cameraPosition.y))
	window.cameraFieldy.OnFocusGained = onFocus
	window.cameraFieldy.OnEnter = function(object)
		world.cameraPosition.y = -tonumber(object:GetText()) - window.centerOffset.y
	end
	window.cameraFieldy.Update = function(object, dt)
		if (not object:GetFocus()) then
			object:SetText(tostring(-window.cameraCenterPos.y))
		end
	end

	-- snap field
	local snapField = loveframes.Create("textinput")
	snapField:SetWidth(50)
	snapField:CenterWithinArea(142+96, 0, 192+96, window.toolbarHeight)
	snapField:SetFont(love.graphics.newFont(12))
	snapField:SetEditable(true)
	snapField:SetText(tostring(window.snap))
	snapField.OnFocusGained = onFocus
	snapField.OnEnter = function(object)
		window.snap = tonumber(object:GetText())
	end

	-- export button
	local exportButton = loveframes.Create('button', toolbar)
	exportButton:SetWidth(80)
	exportButton:SetText("Export Level")
	exportButton:CenterWithinArea(love.window.getWidth() - 256, 0, 128, window.toolbarHeight)
	exportButton.OnClick = function(object)
		for index,enemy in pairs(world.enemies) do
			output:write(enemy.path)
		end
	end
end

function setupUI()
	setupToolPane()
	setupToolbar()
end


------------------------------------------
-- OTHER
------------------------------------------
function love.resize(w, h)
	window.mainAreaSize = Vector(love.window.getWidth() - window.toolpaneWidth, love.window.getHeight() - window.toolbarHeight)
	window.centerOffset = window.mainAreaSize/2 + Vector.DOWN*window.toolbarHeight
	loveframes.resize(w, h)
	-- TODO: find a better solution that this
	-- round to nearest one for clean non aliased graphics
	world.cameraPosition.x = roundTo(world.cameraPosition.x, 1, 'nearest')
	world.cameraPosition.y = roundTo(world.cameraPosition.y, 1, 'nearest')
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