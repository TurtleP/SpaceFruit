function newStar(x, y, screen)
	local star = {}

	star.x = x
	star.y = y
	star.twinkle = false
	star.screen = screen

	local r = math.random(100)
	if r < 25 then
		star.twinkle = true
	end
	star.alpha = 1
	star.timer = 0

	function star:update(dt)
		if self.twinkle then
			self.timer = self.timer + dt 
			self.alpha = math.max(0, math.min(math.sin(self.timer), 1))
		else 
			return
		end
	end

	function star:draw()
		love.graphics.setScreen(self.screen)
		
		love.graphics.setColor(255, 255, 255, 255 * self.alpha)
		love.graphics.rectangle('fill', self.x, self.y, 1, 1)

		love.graphics.setColor(255, 255, 255)
	end

	return star
end