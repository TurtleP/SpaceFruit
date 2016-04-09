function newAsteroid()
	local asteroid = {}

	local sides = {0, getWindowWidth()}

	asteroid.x = sides[love.math.random(2)]
	asteroid.y = love.math.random(0, getWindowHeight())

	asteroid.graphic = asteroidGraphics[love.math.random(2)]

	asteroid.rotation = 0

	asteroid.width = asteroid.graphic:getWidth()
	asteroid.height = asteroid.graphic:getHeight()

	if not objects["ship"][1] then
		return
	end

	asteroid.direction = math.atan( (asteroid.y - objects["ship"][1].y) / (asteroid.x - objects["ship"][1].x) )

	local speed = 256
	if asteroid.x > getWindowWidth() / 2 then
		speed = -256
	end
	
	asteroid.maxSpeed = speed

	asteroidSounds[love.math.random(2)]:play()

	function asteroid:update(dt)
		self.x = self.x + math.cos(self.direction) * self.maxSpeed * dt
		self.y = self.y + math.sin(self.direction) * self.maxSpeed * dt
 
		self.rotation = self.rotation + 4 * dt

		if self.x + self.width < 0 then
			self.remove = true
		elseif self.x > getWindowWidth() then
			self.remove = true
		elseif self.y + self.height < 0 then
			self.remove = true
		elseif self.y > getWindowHeight() then
			self.remove = true
		end
	end

	function asteroid:draw()
		love.graphics.draw(self.graphic, (self.x + self.width / 2) * scale, (self.y + self.height / 2) * scale, self.rotation, scale, scale, self.width / 2, self.height / 2)
	end

	function asteroid:onCollide(name, data)
		if name == "ship" then
			data:addLife(-1)
			
			self.remove = true
		end
	end

	return asteroid
end