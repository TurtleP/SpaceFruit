function newStar(x, y)
	local star = {}

	star.x = x
	star.y = y
	star.twinkle = false

	local r = love.math.random(100)
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
		love.graphics.setColor(255, 255, 255, 255 * self.alpha)
		love.graphics.point(self.x, self.y)

		love.graphics.setColor(255, 255, 255)
	end

	return star
end