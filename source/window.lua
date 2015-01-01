window = {}

window.toolpaneWidth = 250
window.toolbarHeight = 32
window.crosshairSize = 32
window.snap = 32
window.enemyIndex = nil
window.cameraCenterPos = Vector(0,0)					-- the position in global coordinates that the center of the main area is at
window.mode = "default"

-- TODO: this doesn't update
cameraFieldx, cameraFieldy = nil, nil			-- the two gui fields that display the cameras position

window.mainAreaStart = Vector(0, window.toolbarHeight)
window.mainAreaSize = Vector(love.window.getWidth() - window.toolpaneWidth, love.window.getHeight() - window.toolbarHeight)
window.centerOffset = window.mainAreaSize/2 + Vector.DOWN*window.toolbarHeight

function window:getStageCenter()
	local center = world.cameraPosition + window.centerOffset
	center.x = roundTo(center.x, 1, 'nearest')
	center.y = roundTo(center.y, 1, 'nearest')
end