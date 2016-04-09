--Gyro class
function newGyro(xAxis, yAxis, Zaxis, touch, unTouch, vars, onUpdate)

	local gyro = {}

	if xAxis then
		gyro.onXAxis = xAxis
	end

	if yAxis then
		gyro.onYAxis = yAxis
	end

	if Zaxis then
		gyro.onZAxis = Zaxis
	end

	if touch then
		gyro.onTouch = touch
	end

	if unTouch then
		gyro.onReleaseTouch = unTouch
	end

	if vars then
		for k, v in pairs(vars) do
			gyro[k] = v
		end
	end

	if onUpdate then
		gyro.onUpdate = onUpdate
	end

	function gyro:update(dt)
		if self.onUpdate then
			self:onUpdate(dt)
		end
	end

	function gyro:touchPressed(id, x, y, pressure)
		if self.onTouch then
			self:onTouch(id, x, y, pressure)
		end
	end

	function gyro:touchReleased(id, x, y, pressure)
		if self.onReleaseTouch then
			self:onReleaseTouch(id, x, y, pressure)
		end
	end

	function gyro:axis(axis, value)
		if axis == 1 then
			if self.onXAxis then
				self:onXAxis(value)
			end
		elseif axis == 2 then
			if self.onYAxis then
				self:onYAxis(value)
			end
		elseif axis == 3 then
			if self.onZAxis then
				self:onZAxis(value)
			end
		end
	end

	return gyro
end