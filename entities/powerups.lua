local powerupsSpeedx = {-math.random(90, 180), math.random(90, 180)}
local powerupsSpeedy = {math.random(90, 180), -math.random(90, 180)}

function newPowerup(x, y, i)

	local powerups= {}
	powerups.x = x
	powerups.y = y
	powerups.graphics = graphics["powerup"]
	powerups.rotation = 0
	powerups.width = 16
	powerups.height = 16
	powerups.quad = quads["powerups"]
	powerups.quadi = i
	powerups.speedy = 20	

	function powerups:update(dt)
		self.rotation = self.rotation + dt

		self.y = self.y + self.speedy * dt

		if self.x < 0 and self.speedx < 0 then
			self.remove = true
		elseif self.x + self.width > love.window.getWidth() / scale and self.speedx > 0 then
			self.remove = true
		elseif self.y < 0 and self.speedy < 0 then
			self.remove = true
		elseif self.y + self.height > love.window.getHeight() / scale and self.speedy > 0 then
			self.remove = true
		end
	end

	function powerups:draw()
		love.graphics.draw(self.graphics, self.quad[self.quadi], self.x + 8, self.y + 8,self.rotation,1,1, 8, 8)
	
	end


	return powerups
end