-- dependencies
require "./source/lib/class"					-- class
require './source/lib/util'						-- util functions
loveframes = require("source.lib.loveframes")	-- loveframes
Vector = require "./source/lib/vector"			-- vector

-- sprites
spr_grid32 = love.graphics.newImage("/resources/grid32.png")		-- playerShip1
spr_grid64 = love.graphics.newImage("/resources/grid64.png")		-- enemyShip1

-- constants
CAMERA_SPEED = 250			-- how fast the camera scrolls when user uses arrow keys
PROGRESSION_SPEED = 10 		-- how fast the level will move forwards
TOOLPANE_WIDTH = 250 		-- how wide the main tool pane is
TOOLBAR_HEIGHT = 32			-- how tall the main toolbare is
LEVEL_WIDTH = 64*10			-- the width of the level
LEVEL_HEIGHT = 64*10		-- how for forwards the level goes

-- globals
cameraPosition = Vector(0,0)		-- the position of the top left corner of the screen (global coords)
mousePosition = Vector(0,0)			-- the position of the mouse (global coords)
mousePositionSnap = Vector(0,0)		-- the position that snap to grid will snap to if the mouse is clicked (global coords)
snapMode = 32						-- what multiples the mouse will snap to
gridMode = 64						-- the size of the grid squares
ui = {}

function love.load()
	setupUI()
	love.graphics.setBackgroundColor(180,180,180)
end

function love.update(dt)
	loveframes.update(dt)
	setMousePosition()
	cameraMovement(dt)
end

function love.draw()
	drawGrid()
	drawUI()
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

function love.resize(w, h)
	loveframes.resize(w, h)
end


function drawGrid()
	local gridStart = cameraPosition - Vector(cameraPosition.x%gridMode,cameraPosition.y%gridMode)	-- the top left corner of the grid
	local xTileNum = love.window.getWidth()/gridMode + 1 			-- the number of columns
	local yTileNum = love.window.getHeight()/gridMode + 1 			-- the number of rows
	local sprite 		-- the sprite to be tiled											

	love.graphics.translate(-cameraPosition.x, -cameraPosition.y)
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

	love.graphics.translate(cameraPosition.x, cameraPosition.y)
end

function cameraMovement(dt)
	local dCamPos = Vector(0,0)		-- the position delta

	if love.keyboard.isDown('up') then dCamPos = dCamPos + Vector(0,-1) end
	if love.keyboard.isDown('down') then dCamPos = dCamPos + Vector(0,1) end
	if love.keyboard.isDown('left') then dCamPos = dCamPos + Vector(-1,0) end
	if love.keyboard.isDown('right') then dCamPos = dCamPos + Vector(1,0) end

	cameraPosition = cameraPosition + dCamPos*CAMERA_SPEED * dt
	--round values to nearest integer so there isn't any nasty aliasing of the grid
	cameraPosition.x = roundTo(cameraPosition.x, 1, 'nearest')
	cameraPosition.y = roundTo(cameraPosition.y, 1, 'nearest')
end

function setMousePosition()
	mousePosition = Vector(love.mouse.getPosition()) + cameraPosition
	mousePositionSnap = Vector(roundTo(mousePosition.x,snapMode,'nearest'),roundTo(mousePosition.y,snapMode,'nearest'))
end

function setupUI()
	-- toolpane
	local toolpane 						-- the main pane on the right. A list of all ui elements
	local enemyCategory					-- the expandable categary that holds the enemy grid
	local enemyGrid						-- the grid of all the enemy buttons
	-- toolbar
	local toolbar 						-- the main toolbar at the top
	local cameraFieldx, cameraFieldy 	-- the fields for the cameras position

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

	-- toolbar
	toolbar = loveframes.Create("panel")
	toolbar.resize = function(object)
		toolbar:SetSize(love.window.getWidth(), TOOLBAR_HEIGHT)
	end
	toolbar:resize()

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
		cameraPosition.x = tonumber(object:GetText())
	end
	cameraFieldx.Update = function(object, dt)
		if (not object:GetFocus()) then
			object:SetText(tostring(cameraPosition.x))
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
		cameraPosition.y = tonumber(object:GetText())
	end
	cameraFieldy.Update = function(object, dt)
		if (not object:GetFocus()) then
			object:SetText(tostring(cameraPosition.y))
		end
	end
end

function drawUI()
	loveframes.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.print('Camera x:', 4, TOOLBAR_HEIGHT/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.print('Camera y:', 4 + 46 + 100, TOOLBAR_HEIGHT/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.setColor(255,255,255)
end