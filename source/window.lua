window = {}

window.toolpaneWidth = 250
window.toolbarHeight = 32
window.crosshairSize = 32
window.snap = 32
window.enemyIndex = nil
window.mode = "default"
window.cameraPosFieldX = nil
window.cameraPosFieldY = nil

window.mainAreaStart = Vector(0, window.toolbarHeight)
window.mainAreaSize = Vector(love.window.getWidth() - window.toolpaneWidth, love.window.getHeight() - window.toolbarHeight)
window.centerOffset = window.mainAreaSize/2 + Vector.DOWN*window.toolbarHeight
window.centerOffset.y = -window.centerOffset.y

function window:initUI()
	self:setupToolPane()
	self:setupToolbar()
end

function window:setupToolPane()
	local toolpane 						-- the main pane on the right. A list of all ui elements
	local enemyCategory					-- the expandable categary that holds the enemy ui
	local pathCategory					-- the expandable category that holds path ui
	local enemyGrid						-- the grid of all the enemy buttons

	--toolpane
	toolpane = loveframes.Create("list")
	toolpane.resize = function(object)
		object:SetSize(self.toolpaneWidth, love.window.getHeight() - self.toolbarHeight - 1)
		object:SetPos(love.window.getWidth() - self.toolpaneWidth, self.toolbarHeight + 1)
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
		toolbar:SetSize(love.window.getWidth(), self.toolbarHeight)
	end
	toolbar:resize()
end

function window:setupToolbar()
	local toolbar 			-- the main toolbar at the top

	-- cameraField
	local function onFocus(object)
		object:SetText("")
	end
	-- x field
	self.cameraPosFieldX = loveframes.Create("textinput")
	self.cameraPosFieldX:SetWidth(50)
	self.cameraPosFieldX:CenterWithinArea(46, 0, 96, self.toolbarHeight)
	self.cameraPosFieldX:SetFont(love.graphics.newFont(12))
	self.cameraPosFieldX:SetEditable(true)
	self.cameraPosFieldX:SetText(tostring(world.cameraPosition.x))
	self.cameraPosFieldX.OnFocusGained = onFocus
	self.cameraPosFieldX.OnEnter = function(object)
		world.cameraPosition.x = tonumber(object:GetText()) - self.centerOffset.x
	end
	-- y field
	self.cameraPosFieldY = loveframes.Create("textinput")
	self.cameraPosFieldY:SetWidth(50)
	self.cameraPosFieldY:CenterWithinArea(142, 0, 192, self.toolbarHeight)
	self.cameraPosFieldY:SetFont(love.graphics.newFont(12))
	self.cameraPosFieldY:SetEditable(true)
	self.cameraPosFieldY:SetText(tostring(world.cameraPosition.y))
	self.cameraPosFieldY.OnFocusGained = onFocus
	self.cameraPosFieldY.OnEnter = function(object)
		world.cameraPosition.y = -tonumber(object:GetText()) - self.centerOffset.y
	end

	-- snap field
	local snapField = loveframes.Create("textinput")
	snapField:SetWidth(50)
	snapField:CenterWithinArea(142+96, 0, 192+96, self.toolbarHeight)
	snapField:SetFont(love.graphics.newFont(12))
	snapField:SetEditable(true)
	snapField:SetText(tostring(self.snap))
	snapField.OnFocusGained = onFocus
	snapField.OnEnter = function(object)
		self.snap = tonumber(object:GetText())
	end

	-- export button`
	local exportButton = loveframes.Create('button', toolbar)
	exportButton:SetWidth(80)
	exportButton:SetText("Export Level")
	exportButton:CenterWithinArea(love.window.getWidth() - 256, 0, 128, self.toolbarHeight)
	exportButton.OnClick = function(object)
		for index,enemy in pairs(world.enemies) do
			output:write(enemy:serialize())
		end
	end
end

function window:getStageCenter()
	local center = world.cameraPosition + self.centerOffset
	center.x = roundTo(center.x, 1, 'nearest')
	center.y = roundTo(center.y, 1, 'nearest')
end

function window:draw()
	loveframes.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.print('Camera x:', 4, self.toolbarHeight/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.print('Camera y:', 4 + 46 + 100, self.toolbarHeight/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.print('     Snap:', 4 + 2*(46 + 100),  self.toolbarHeight/2 - love.graphics.getFont():getHeight()/2)


	local snapPos = world:getMouseWorldPositionSnapped(self.snap)
	snapPos.y = -snapPos.y
	local mouseString = tostring(snapPos)
	local _, _, p1, p2, p3 = mouseString:find('(%(%-?%d+)%.%d*(%,%-?%d+)%.%d*(%))')
	mouseString = p1 .. p2 .. p3
	love.graphics.print('Mouse: ' .. mouseString, love.window.getWidth() - 140, self.toolbarHeight/2 - love.graphics.getFont():getHeight()/2)
	love.graphics.setColor(255,255,255)

	-- croshair
	local top, bottom, left, right =
		self.centerOffset+self.crosshairSize*Vector.UP, self.centerOffset+self.crosshairSize*Vector.DOWN, self.centerOffset+self.crosshairSize*Vector.LEFT, self.centerOffset+self.crosshairSize*Vector.RIGHT
	love.graphics.line(top.x, top.y, bottom.x, bottom.y)
	love.graphics.line(left.x, left.y, right.x, right.y)
end

function window:resize()
	self.mainAreaSize = Vector(love.window.getWidth() - self.toolpaneWidth, love.window.getHeight() - self.toolbarHeight)
	self.centerOffset = self.mainAreaSize/2 + Vector.DOWN*self.toolbarHeight
	loveframes.resize(w, h)
end

function window:mousePressed(x, y, button)
	if (button == 'l') then
		if (self.mode == "place enemy") then
			if (self:isCoordInMainArea(x, y)) then
				enemyPlaced(world:getMouseWorldPositionSnapped(self.snap))
				if not (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
					self.mode = 'default'
				end
			end
		elseif(self.mode == "default") then
			
		end
	elseif (button == 'r') then
		self.mode = 'default'
	end
end

function window:isCoordInMainArea(x, y)
	return (x < self.mainAreaSize.x) and (y > self.toolbarHeight)
end