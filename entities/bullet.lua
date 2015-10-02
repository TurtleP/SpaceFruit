function newBullet(x, y, rotation, parent, screen)

	local bullet = {}
	bullet.x = x
	bullet.y = y
	bullet.rotation = rotation
	bullet.speedy = -math.cos(rotation)* 200
	bullet.speedx = math.sin(rotation)* 200
	bullet.graphic = bulletimg
	bullet.width = 1
	bullet.height = 6
	bullet.parent = parent
	bullet.screen = screen
	
	function bullet:update(dt)
		self.x = self.x + self.speedx * dt
		self.y = self.y + self.speedy * dt

		if self.x < 0 then
			self.remove = true
		elseif self.x > love.graphics.getWidth() / scale then
			self.remove = true
		elseif self.y > love.graphics.getHeight() / scale then
			self.remove = true
		elseif self.y + self.height < 0 then
			self.remove = true
		end
	end

	function bullet:draw()
		love.graphics.setScreen(self.screen)
		
		love.graphics.draw(self.graphic, self.x, self.y, self.rotation)
		
	end

	return bullet
end