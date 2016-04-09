function newHud()
	local hud = {}

	hud.x = getWindowWidth() * scale - 40 * scale
	hud.y = 2

	hud.shieldbar = 0
	hud.shieldbarmax = 8
	hud.shieldActive = false

	hud.width = menubuttonfont:getWidth("[Health:") + 40 * scale

	hud.sineWave = 1
	hud.sineTimer = 0

	function hud:draw(hearts)
		for k = 1, 4 do
			
			local i = 1
			
			love.graphics.setColor(255, 255, 255, 255)

			if self.shieldbar / 2 >= k then
				love.graphics.setColor(255, 255, 255, 255 * self.sineWave)

				if k > hearts then
					i = 4
				else
					i = 3
				end	
			else
				if k > hearts then
					i = 2
				end
			end

			love.graphics.draw(graphics["health"], quads["health"][i], self.x + (k - 1) * 10 * scale, 2 * scale + menubuttonfont:getHeight("Score: " .. gamescore) / 2 - 4 * scale, 0, scale, scale)
		end
	end

	function hud:update(dt)
		if self.shieldbar > 0 then
			self.sineTimer = self.sineTimer + 0.5 * dt

			self.sineWave = math.abs( math.sin( self.sineTimer * math.pi ) / 2 ) + 0.5
		else
			self.sineTimer = 0
		end

		if self.shieldActive then
			self.shieldbar = math.max(self.shieldbar - dt, 0)

			if self.shieldbar == 0 then
				self.shieldActive = false
			end
		else
			return
		end
	end

	return hud
end