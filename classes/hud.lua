function newHud()
	local hud = {}

	hud.x = ( love.graphics.getWidth() / scale ) / 2 - hudfont:getWidth("[Health:") / 2 - 30
	hud.y = 2

	hud.shieldbar = 0
	hud.shieldbarmax = 8
	hud.shieldActive = false

	function hud:draw(hearts)
		love.graphics.setColor(255, 255, 255)

		love.graphics.print("[Health:", self.x, self.y)

		if hearts < 4 then
			for k = 1, hearts do
				love.graphics.draw(graphics["health"], ( self.x + hudfont:getWidth("[Health:") + 4 ) + (k - 1) * 10, self.y)
			end
		else
			love.graphics.draw(graphics["health"], ( self.x + hudfont:getWidth("[Health:") + 1 ), self.y)
			love.graphics.print(hearts, ( self.x + hudfont:getWidth("[Health:") + 14 ), self.y)
		end

		love.graphics.print("]", self.x + hudfont:getWidth("[Health:") + 37, self.y)

		love.graphics.setColor(0, 163, 255)

		love.graphics.rectangle("fill", ( self.x + hudfont:getWidth("[") ), self.y + hudfont:getHeight("["), ( self.shieldbar / self.shieldbarmax ) * 92, 1)

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