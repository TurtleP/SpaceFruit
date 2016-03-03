function newSplat(x, y, fruit)
	local splat = {}

	splat.x = x
	splat.y = y
	splat.graphic = graphics["splat"]
	splat.quad = quads["splat"]
	splat.quadi = 1
	splat.timer = 0

	splat.color = {255, 255, 255}
	if fruit == 1 then
		splat.color = {255, 0, 0}
	elseif fruit == 2 then
		splat.color = {0, 255, 0}
	elseif fruit == 3 then
		splat.color = {87, 0, 127}
	elseif fruit == 4 then
		splat.color = {53, 122, 42}
	elseif fruit == 5 then
		splat.color = {255, 255, 0}
	elseif fruit == 6 then
		splat.color = {196, 0, 0}
	elseif fruit == 7 then
		splat.color = {196, 0, 0}
	elseif fruit == 8 then
		splat.color = {255, 255, 0}
	elseif fruit == 9 then
		splat.color = {255, 106, 0}
	end

	function splat:update(dt)
		if self.quadi < 6 then
			self.timer = self.timer + 10 * dt
			self.quadi = math.floor(self.timer%6)+1
		else
			self.remove = true
		end
	end

	function splat:draw()
		love.graphics.setColor(self.color)
		love.graphics.draw(self.graphic, self.quad[self.quadi], self.x, self.y)
		love.graphics.setColor(255, 255, 255)
	end

	return splat
end