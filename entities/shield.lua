function newShield(parent, screen)
	local shield = {}

	shield.parent = parent
	shield.drawx = parent.x + (parent.width / 2)
	shield.drawy = parent.y + (parent.height / 2)

	shield.x = parent.x
	shield.y = parent.y
	shield.width = 48
	shield.height = 48
	shield.alpha = 1
	shield.timer = 0

	shield.radius = 24
	shield.drawAbove = true
	shield.screen = screen

	function shield:drawshield()
		love.graphics.setScreen(self.screen)

		love.graphics.setColor(0, 148, 255, 128)
		love.graphics.circle("fill", self.parent.x + (self.parent.width / 2), self.parent.y + (self.parent.height / 2), self.radius)
		love.graphics.setColor(255, 255, 255, 255)
		
	end

	function shield:update(dt)
		if self.parent.hud.shieldbar == 0 then
			self.remove = true
		else

		end
	end

	return shield
end