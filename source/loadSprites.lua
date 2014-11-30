spritesArray = {}
enemyTypeArray = {}

local function aInsert(name)
	-- spritesArray:insert(love.graphics.newImage(dir .. name .. '.png'))
	table.insert(spritesArray, love.graphics.newImage("/resources/" .. name .. ".png"))
end

aInsert('ship1')
aInsert('ship2')
aInsert('ship3')

enemyTypeArray[1] = 'Enemy 1'
enemyTypeArray[2] = 'Enemy 2'
enemyTypeArray[3] = 'Enemy 3'