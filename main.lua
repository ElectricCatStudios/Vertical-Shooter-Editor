-- dependencies
require "./source/lib/class"					-- class
require './source/lib/util'						-- util functions
loveframes = require("source.lib.loveframes")	-- loveframes
Vector = require "./source/lib/vector"			-- vector
require "./source/loadSprites"

-- sprites
spr_grid32 = love.graphics.newImage("/resources/grid32.png")		-- playerShip1
spr_grid64 = love.graphics.newImage("/resources/grid64.png")		-- enemyShip1

-- constants
BACKGROUND = love.graphics.newImage("/resources/background.png")
CAMERA_SPEED = 250							-- how fast the camera scrolls when user uses arrow keys
PROGRESSION_SPEED = 10 						-- how fast the level will move forwards
TOOLPANE_WIDTH = 250 						-- how wide the main tool pane is
TOOLBAR_HEIGHT = 32							-- how tall the main toolbare is
LEVEL_WIDTH = BACKGROUND:getWidth()			-- the width of the level
LEVEL_HEIGHT = BACKGROUND:getHeight()		-- how for forwards the level goes
CROSSHAIR_SIZE = 32 						-- how big the center crosshair is
-- cardinal direction constants
Vector.UP = Vector(0,-1)
Vector.DOWN = Vector(0,1)
Vector.LEFT = Vector(-1,0)
Vector.RIGHT = Vector(1,0)

-- globals
cameraPosition = Vector(0,0)		-- the position of the top left corner of the screen (global coords)
mousePosition = Vector(0,0)			-- the position of the mouse (global coords)
mousePositionSnap = Vector(0,0)		-- the position that snap to grid will snap to if the mouse is clicked (global coords)
snapMode = 32						-- what multiples the mouse will snap to
gridMode = 64						-- the size of the grid squares
mainAreaSize = Vector(love.window.getWidth() - TOOLPANE_WIDTH, love.window.getHeight() - TOOLBAR_HEIGHT)		-- the size of the window area excluding the toolbar and toolpane
centerOffset = mainAreaSize/2 + Vector.DOWN*TOOLBAR_HEIGHT						-- the offset from the top right of the screen to the cerner of the main area (main area defined above)
cameraFieldx, cameraFieldy = nil, nil			-- the two gui fields that display the cameras position
mode = "default"								-- the current mode the ui interface is in
enemyIndex = nil								-- the current enemy type that is marked to be placed
cameraCenterPos = Vector(0,0)					-- the position in global coordinates that the center of the main area is at
enemyList = {}									-- a list of all the enemies that have been placed on the level

-------------------------------------------
-- INIT AND MAIN LOOP
-------------------------------------------

function love.load(arg)
	setupUI()
	loadBackground()
	love.graphics.setBackgroundColor(180,180,180)
	cameraPosition = -centerOffset
	setCamCenterPos()
end

function love.update(dt)
	loveframes.update(dt)
	setMousePosition()
	cameraMovement(dt)

	if (mode == 'place enemy') then

	end
end


------------------------------------------
-- DRAWING
------------------------------------------
function love.draw()
	drawTranslated()
	drawUI()
end

function drawTranslated()
	love.graphics.translate(-cameraPosition.x, -cameraPosition.y)

	love.graphics.draw(BACKGROUND, 0, -LEVEL_HEIGHT)

	local gridStart = cameraPosition - Vector(cameraPosition.x%gridMode,cameraPosition.y%gridMode)	-- the top left corner of the grid
	local xTileNum = love.window.getWidth()/gridMode + 1 			-- the number of columns
	local yTileNum = love.window.getHeight()/gridMode + 1 			-- the number of rows
	local sprite 		-- the sprite to be tiled											

	-- do not draw grid out of bounds
	gridStart.x = math.max(gridStart.x, 0)
	gridStart.y = math.max(gridStart.y, -LEVEL_HEIGHT)

	-- choose which sprite to use
	if (gridMode == 32) then
		sprite = spr_grid32
	elseif (gridMode == 64) then
		sprite = spr_grid64
	else
		error('invalid gridMode')
	end
	for i=0, xTileNum do
		local x = gridStart.x+gridMode*i
		local y
		-- only tile within map bounds
		if (x >= LEVEL_WIDTH) then break end
		for j=0, yTileNum do
			y = gridStart.y+gridMode*j
			-- only tile within map bounds
			if (y>=0) then break end
			love.graphics.draw(sprite, gridStart.x + gridMode*i, gridStart.y + gridMode*j)
		end
	end

	-- enemy placement
	if (mode == 'place enemy') then
		love.graphics.draw(spritesArray[enemyIndex], mousePositionSnap.x, mousePositionSnap.y, 0, 1, 1, spritesArray[enemyIndex]:getWidth()/2, spritesArray[enemyIndex]:getHeight()/2)
	end

	love.graphics.translate(cameraPosition.x, cameraPosition.y)
end

function drawUI()
	-- toolbar
	loveframes.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.print('Camera x:', 4, TOOLBAR_HEIGHT/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.print('Camera y:', 4 + 46 + 100, TOOLBAR_HEIGHT/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.print('     Snap:', 4 + 2*(46 + 100),  TOOLBAR_HEIGHT/2 - love.graphics.getFont():getHeight()/2)

	local snapPos = mousePositionSnap
	snapPos.y = -snapPos.y
	local mouseString = tostring(mousePositionSnap)
	local _, _, p1, p2, p3 = mouseString:find('(%(%-?%d+)%.%d*(%,%-?%d+)%.%d*(%))')
	mouseString = p1 .. p2 .. p3
	love.graphics.print('Mouse: ' .. mouseString, love.window.getWidth() - 140, TOOLBAR_HEIGHT/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.setColor(255,255,255)

	-- croshair
	local top, bottom, left, right = 
		centerOffset+CROSSHAIR_SIZE*Vector.UP, centerOffset+CROSSHAIR_SIZE*Vector.DOWN, centerOffset+CROSSHAIR_SIZE*Vector.LEFT, centerOffset+CROSSHAIR_SIZE*Vector.RIGHT
	love.graphics.line(top.x, top.y, bottom.x, bottom.y)
	love.graphics.line(left.x, left.y, right.x, right.y)
end


-------------------------------------------
-- INPUT
-------------------------------------------
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
	if (button == 'l') then
		if ((mode == "place enemy") and (x < mainAreaSize.x) and (y > TOOLBAR_HEIGHT)) then
			enemyPlaced(mousePositionSnap)
			if not (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
				mode = 'default'
			end
		end
	elseif (button == 'r') then
		mode = 'default'
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
		object:SetSize(TOOLPANE_WIDTH, love.window.getHeight() - TOOLBAR_HEIGHT - 1)
		object:SetPos(love.window.getWidth() - TOOLPANE_WIDTH, TOOLBAR_HEIGHT + 1)
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
	        tooltip:SetText(toolTipsArray[id])
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
		toolbar:SetSize(love.window.getWidth(), TOOLBAR_HEIGHT)
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
	cameraFieldx = loveframes.Create("textinput")
	cameraFieldx:SetWidth(50)
	cameraFieldx:CenterWithinArea(46, 0, 96, TOOLBAR_HEIGHT)
	cameraFieldx:SetFont(love.graphics.newFont(12))
	cameraFieldx:SetEditable(true)
	cameraFieldx:SetText(tostring(cameraPosition.x))
	cameraFieldx.OnFocusGained = onFocus
	cameraFieldx.OnEnter = function(object)
		cameraPosition.x = tonumber(object:GetText()) - centerOffset.x
	end
	cameraFieldx.Update = function(object, dt)
		if (not object:GetFocus()) then
			object:SetText(tostring(cameraCenterPos.x))
		end
	end
	-- y field
	cameraFieldy = loveframes.Create("textinput")
	cameraFieldy:SetWidth(50)
	cameraFieldy:CenterWithinArea(142, 0, 192, TOOLBAR_HEIGHT)
	cameraFieldy:SetFont(love.graphics.newFont(12))
	cameraFieldy:SetEditable(true)
	cameraFieldy:SetText(tostring(cameraPosition.y))
	cameraFieldy.OnFocusGained = onFocus
	cameraFieldy.OnEnter = function(object)
		cameraPosition.y = -tonumber(object:GetText()) - centerOffset.y
	end
	cameraFieldy.Update = function(object, dt)
		if (not object:GetFocus()) then
			object:SetText(tostring(-cameraCenterPos.y))
		end
	end

	-- snap field
	local snapField = loveframes.Create("textinput")
	snapField:SetWidth(50)
	snapField:CenterWithinArea(142+96, 0, 192+96, TOOLBAR_HEIGHT)
	snapField:SetFont(love.graphics.newFont(12))
	snapField:SetEditable(true)
	snapField:SetText(tostring(snapMode))
	snapField.OnFocusGained = onFocus
	snapField.OnEnter = function(object)
		snapMode = tonumber(object:GetText())
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
	mainAreaSize = Vector(love.window.getWidth() - TOOLPANE_WIDTH, love.window.getHeight() - TOOLBAR_HEIGHT)
	centerOffset = mainAreaSize/2 + Vector.DOWN*TOOLBAR_HEIGHT
	loveframes.resize(w, h)
	setCamCenterPos()
	-- round to nearest one for clean non aliased graphics
	cameraPosition.x = roundTo(cameraPosition.x, 1, 'nearest')
	cameraPosition.y = roundTo(cameraPosition.y, 1, 'nearest')
end

function cameraMovement(dt)
	local dCamPos = Vector(0,0)		-- the position delta

	if (not (cameraFieldx:GetFocus() or cameraFieldy:GetFocus())) then
		if love.keyboard.isDown('up') then dCamPos = dCamPos + Vector(0,-1) end
		if love.keyboard.isDown('down') then dCamPos = dCamPos + Vector(0,1) end
		if love.keyboard.isDown('left') then dCamPos = dCamPos + Vector(-1,0) end
		if love.keyboard.isDown('right') then dCamPos = dCamPos + Vector(1,0) end
	end

	cameraPosition = cameraPosition + dCamPos*CAMERA_SPEED * dt
	--round values to nearest integer so there isn't any nasty aliasing of the grid
	cameraPosition.x = roundTo(cameraPosition.x, 1, 'nearest')
	cameraPosition.y = roundTo(cameraPosition.y, 1, 'nearest')
	setCamCenterPos()
end

function setMousePosition()
	mousePosition = Vector(love.mouse.getPosition()) + cameraPosition
	mousePositionSnap = Vector(roundTo(mousePosition.x,snapMode,'nearest'),roundTo(mousePosition.y,snapMode,'nearest'))
end

function setCamCenterPos()
	cameraCenterPos = cameraPosition + centerOffset
	cameraCenterPos.x = roundTo(cameraCenterPos.x, 1, 'nearest')
	cameraCenterPos.y = roundTo(cameraCenterPos.y, 1, 'nearest')
end

function enemyButtonPressed(self, mouseX, mouseY)
	if (mode == "default") then
		mode = "place enemy"
		enemyIndex = self.id
	end
end	

function enemyPlaced(pos)
	print("placing enemy #" .. enemyIndex .. ' at pos: ' .. tostring(pos))
end

function loadBackground()

end