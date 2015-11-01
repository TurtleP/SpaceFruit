function newBullet(x, y, rotation, screen, parent)

	local bullet = {}
	bullet.x = x
	bullet.y = y
	bullet.rotation = rotation
	bullet.speedy = -math.cos(rotation)* 200
	bullet.speedx = math.sin(rotation)* 200
	bullet.graphic = bulletimg
	bullet.width = 1
	bullet.height = 6
	bullet.screen = screen
	bullet.parent = parent

	bullet.lifetime = 0

	function bullet:update(dt)
		self.x = self.x + self.speedx * dt
		self.y = self.y + self.speedy * dt

		if self.x + self.width < 0 then
			self.x = love.graphics.getWidth()
		elseif self.x > love.graphics.getWidth() then
			self.x = 0
		elseif self.y > love.graphics.getHeight() and self.screen == "top" then
			if self.x > 40 and self.x < love.graphics.getWidth() - 80 then
				self.screen = "bottom"
				self.x = self.x - 40
				self.y = 0
			end
		elseif self.y + self.height < 0 and self.screen == "bottom" then
			if self.x > 40 and self.x < love.graphics.getWidth() - 80 then
				self.screen = "top"
				self.x = self.x + 40
				self.y = love.graphics.getHeight() - self.height
			end
		elseif self.y > love.graphics.getHeight() and self.screen == "bottom" then
			self.y = 0
			self.screen = "top"
			self.x = self.x + 40
		elseif self.y + self.height < 0 and self.screen == "top" then
			self.y = love.graphics.getHeight()
			self.screen = "bottom"
			self.x = self.x - 40
		end

		if self.lifetime < 2 then
			self.lifetime = self.lifetime + dt
		else
			self.remove = true
		end
	end

	function bullet:draw()
		love.graphics.setScreen(self.screen)
		
		love.graphics.draw(self.graphic, self.x, self.y, self.rotation)
		
	end

	return bullet
end