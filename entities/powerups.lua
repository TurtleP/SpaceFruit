function newPowerup(x, y)

	local powerups= {}
	powerups.x = x
	powerups.y = y
	powerups.graphics = graphics["health"]
	powerups.rotation = 0
	powerups.width = 8
	powerups.height = 8
	powerups.quad = quads["health"]
	powerups.quadi = 1
	powerups.speedy = 256	

	function powerups:update(dt)
		self.rotation = self.rotation + dt

		self.y = self.y + self.speedy * dt

		if self.x + self.width < 0 and self.speedx < 0 then
			self.remove = true
		elseif self.x > getWindowWidth() and self.speedx > 0 then
			self.remove = true
		elseif self.y + self.height < 0 and self.speedy < 0 then
			self.remove = true
		elseif self.y > getWindowHeight() and self.speedy > 0 then
			self.remove = true
		end
	end

	function powerups:draw()
		love.graphics.draw(self.graphics, self.quad[self.quadi], (self.x + 4) * scale, (self.y + 4) * scale, self.rotation, scale, scale, 4, 4)
	end


	return powerups
end