--Function hooks/Callbacks
local analogFade = 0
local oldupdate = love.update

local function distance(x1, y1, x2, y2)
    return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end
 
local function round(n, d)
    local d = d or 2
    return math.floor(n*10^d)/10^d
end

function love.update(dt)
	if analogStick then
		if not analogStick:isHeld() then
			analogFade = math.max(analogFade - 0.6 * dt, 0)

			love.keyreleased(controls[1])
			love.keyreleased(controls[2])
			love.keyreleased(controls[3])
			love.keyreleased(controls[4])
		else
			analogFade = 1
		end

		analogStick.areaColor = {255, 255, 255, 150 * analogFade}
		analogStick.stickColor = {42, 42, 42, 240 * analogFade}
	end

	oldupdate(dt)
	
	touchControls:update(dt)
end

local oldDraw = love.draw
function love.draw()
	oldDraw()

	if analogStick then
		analogStick:draw()
	end
end

function love.touchpressed(id, x, y, pressure)
	touchControls:touchpressed(id, x, y, pressure)

	gyroController:touchPressed(id, x, y, pressure)
end

function love.touchreleased(id, x, y, pressure)
	touchControls:touchreleased(id, x, y, pressure)

	gyroController:touchReleased(id, x, y, pressure)
end

function love.touchmoved(id, x, y, pressure)
	if analogStick:isHeld() then
		analogFade = 1
	end

	analogStick:touchMoved(id, x, y, pressure)
end

function newTouchControl()
	local touchcontrol = {}

	touchcontrol.trackAngle = true

	function touchcontrol:init()
		analogStick = newAnalog(0, 0, 36 * scale, 12 * scale, 0.5)
	end

	function touchcontrol:touchpressed(id, x, y, pressure)
		if state ~= "game" then
			return
		end

		if not analogStick:isHeld() then
			analogStick.cx, analogStick.cy = x, y
		else
			analogFade = 1
		end

		analogStick:touchPressed(id, x, y, pressure)
	end

	function touchcontrol:update(dt)
		if state ~= "game" then
			return
		end

		analogStick:update(dt)

		if not analogStick:isHeld() then
			analogFade = math.max(analogFade - 0.6 * dt, 0)

			love.keyreleased(controls[1])
			love.keyreleased(controls[2])
			love.keyreleased(controls[3])
			love.keyreleased(controls[4])
		else
			analogFade = 1

			if state == "game" and not paused then
				local player = objects["ship"][1]

				if not player then
					return
				end

				local angle = player.rotation

				while angle >= math.pi * 2 do
					angle = angle - math.pi * 2
				end

				while angle < 0 do
					angle = angle + math.pi * 2
				end

				local currentAngle = round(angle - math.pi / 2, 2)

				if currentAngle < 0 then
					currentAngle = currentAngle + math.pi * 2
				end

				local targetAngle = round(math.pi * 2 - analogStick.angle, 2)

				local deadzone = .6

				if self.trackAngle then
					if targetAngle > currentAngle then
						if targetAngle - currentAngle <= math.pi then
							player:stopRotateLeft()
							player:rotateAdd(true)
						else
							player:stopRotateRight()
							player:rotateAdd(false)
						end
					else
						if currentAngle - targetAngle <= math.pi then
							player:stopRotateRight()
							player:rotateAdd(false)
						else
							player:stopRotateLeft()
							player:rotateAdd(true)
						end
					end
				end

				if currentAngle < targetAngle + deadzone and currentAngle > targetAngle - deadzone then
					player:moveForward()
				--	self.trackAngle = false
				else
					self.trackAngle = true
				--	player:stopMovingForward()
				end

				--[[if angle >= 4.5 or angle <= 1.5 then
					if angleX > 0.5 then
						player:stopRotateLeft()
						player:rotateAdd(true)
					elseif angleX < -0.5 then
						player:stopRotateRight()
						player:rotateAdd(false)
					end
				else
					if angleX > 0.5 then
						player:stopRotateRight()
						player:rotateAdd(false)
					elseif angleX < -0.5 then
						player:stopRotateLeft()
						player:rotateAdd(true)
					end
				end

				if (angleX <= 0.5 and angleX > 0) or (angleX >= -0.5 and angleX <= 0) then
					player:stopRotateRight()
					player:stopRotateLeft()
				end

				--player faces upward at math.pi/2 by default, should this work?
				if angleY < -0.5 then
					if angle >= 4.5 or angle <= 1.5 then
						player:moveForward()
					end
				elseif angleY > 0.5 then
					if angle <= 4.5 and angle >= 1.5 then
						player:moveForward()
					end
				elseif angleY >= -0.5 and angleY <= 0.5 then
					player:stopMovingForward()
				end]]
			end
		end
	end

	function touchcontrol:touchreleased(id, x, y, pressure)
		analogStick:touchReleased(id, x, y, pressure)
	end

	return touchcontrol
end