function newHud()
	local hud = {}

	hud.x = getWindowWidth() * scale / 2 - hudfont:getWidth("[Health:") / 2 - 30 * scale
	hud.y = 2

	hud.shieldbar = 0
	hud.shieldbarmax = 8
	hud.shieldActive = false

	function hud:draw(hearts)
		love.graphics.setFont(hudfont)
		
		love.graphics.setColor(255, 255, 255)

		love.graphics.print("[Health:", self.x, self.y * scale)

		if hearts < 4 then
			for k = 1, hearts do
				love.graphics.draw(graphics["health"], ( self.x + hudfont:getWidth("[Health:") + 4 * scale ) + (k - 1) * 10 * scale, self.y * scale - graphics["health"]:getHeight() / 2, 0, scale, scale)
			end
		else
			love.graphics.draw(graphics["health"], ( self.x + hudfont:getWidth("[Health:") + 1 * scale ), self.y * scale, 0, scale, scale)
			love.graphics.print(hearts, ( self.x + hudfont:getWidth("[Health:") + 14 * scale), self.y * scale)
		end

		love.graphics.print("]", self.x + hudfont:getWidth("[Health:") + 37 * scale, self.y * scale)

		love.graphics.setColor(0, 163, 255)

		love.graphics.rectangle("fill", ( self.x + hudfont:getWidth("[") ), self.y * scale + hudfont:getHeight("["), ( self.shieldbar / self.shieldbarmax ) * 92 * scale, 1 * scale)

		love.graphics.setColor(255, 255, 255)
	end

	function hud:update(dt)
		if self.shieldActive then
			self.shieldbar = math.max(self.shieldbar -  2 * dt, 0)

			if self.shieldbar == 0 then
				self.shieldActive = false
			end
		else
			return
		end
	end

	return hud
end