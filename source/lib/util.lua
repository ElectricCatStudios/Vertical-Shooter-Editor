--- Rounds a number to a specified interval.
-- The number can be rounded up or down to the nearest interval, or it can be rounded to the nearest interval.
-- If the method is 'nearest' and the number is exactly in between intervals, the number will be rounded up
-- @param number The number to round.
-- @param interval The interval to round to.
-- @param method The method to use (use 'up', 'down' or 'nearest').
-- @returns  The rounded number
function roundTo(number, interval, method)
	if method == 'up' then
		return interval*(math.ceil(number/interval))
	elseif method == 'down' then
		return interval*(math.floor(number/interval))
	elseif method == 'nearest' then
		local roundedUp = (roundTo(number, interval, 'up'))
		local roundedDown = (roundTo(number, interval, 'down'))
		if math.abs(roundedUp - number) <= math.abs(roundedDown - number) then
			return roundedUp
		else
			return roundedDown
		end
	end
end

-- cardinal direction constants
Vector.UP = Vector(0,-1)
Vector.DOWN = Vector(0,1)
Vector.LEFT = Vector(-1,0)
Vector.RIGHT = Vector(1,0)