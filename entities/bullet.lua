function newBullet(x, y, rotation, parent)

	local bullet = {}
	bullet.x = x
	bullet.y = y
	bullet.rotation = rotation
	bullet.speedy = -math.cos(rotation)*8
	bullet.speedx = math.sin(rotation)*8
	bullet.graphic = bulletimg
	bullet.width = 1
	bullet.height = 6
	bullet.parent = parent

	function bullet:update(dt)
		self.x = self.x + self.speedx 
		self.y = self.y + self.speedy

		if self.x < 0 then
			self.remove = true
		elseif self.x > getWindowWidth() then
			self.remove = true
		elseif self.y > getWindowHeight() then
			self.remove = true
		elseif self.y + self.height < 0 then
			self.remove = true
		end
	end

	function bullet:draw()
		love.graphics.draw(self.graphic, self.x * scale, self.y * scale, self.rotation, scale, scale)
	end

	return bullet
end