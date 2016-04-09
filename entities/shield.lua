function newShield(parent)
	local shield = {}

	shield.parent = parent
	shield.drawx = parent.x + (parent.width / 2)
	shield.drawy = parent.y + (parent.height / 2)

	shield.x = parent.x
	shield.y = parent.y
	shield.width = 40
	shield.height = 40
	shield.timer = 0

	shield.radius = 24
	shield.drawAbove = true

	shield.i = 1

	function shield:drawshield()
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(graphics["shield"], quads["shield"][self.i], (self.parent.x + (self.parent.width / 2)) * scale, (self.parent.y + (self.parent.height / 2)) * scale, 0, scale, scale)
	end

	function shield:update(dt)
		self.timer = self.timer + 8 *  dt

		self.i = math.floor(self.timer % 10) + 1

		if self.parent.hud.shieldbar == 0 then
			self.remove = true
		end
	end

	return shield
end