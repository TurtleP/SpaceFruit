function newStar(screen)
	local star = {}

	local w = 320
	if screen == "top" then
		w = 400
	end

	star.x = math.random(4, w - 8)
	star.y = math.random(4, 312) 
	star.screen = screen

	star.depth = math.random(20, 80)

	function star:draw()
		love.graphics.setScreen(self.screen)
		
		love.graphics.setDepth(self.depth / 40)

		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle('fill', self.x, self.y, 1, 1)

		love.graphics.setColor(255, 255, 255)

		love.graphics.setDepth(0)
	end

	return star
end