function newGUI(...)
	
	local f = {...}
	local gui = {}

	gui.type = f[1]
	gui.x = f[2]
	gui.y = f[3]
	gui.width = f[4]
	gui.height = f[5]

	gui.unHighlight = {255, 255, 255}
	gui.hightlight = {100, 100, 100}
	gui.currColor = gui.unHighlight

	gui.oldfont = love.graphics.getFont()
	gui.font = menubuttonfont

	if f[1]== "button" then
		gui.text = f[4]
		gui.func = f[5]
		gui.args = (f[6] or {})

		gui.width = gui.font:getWidth(f[4])
		gui.height = gui.font:getHeight(f[4]) 
	end

	function gui:setFont(font, shouldCenter)
		self.font = font

		self:performLayout(shouldCenter)
	end

	function gui:performLayout(center)
		self.width = self.font:getWidth(self.text)
		self.height = self.font:getHeight(self.text) 

		if center then
			self:center()
		end
	end
	
	function gui:draw()
		love.graphics.setFont(self.font)

		if self.type == "button" then
			if self:inside() then
				self.currColor = self.hightlight
			else
				self.currColor = self.unHighlight
			end

			love.graphics.setColor(self.currColor)
			love.graphics.print(self.text, self.x, self.y)
		end

		love.graphics.setFont(self.oldfont)

		love.graphics.setColor(255, 255, 255)
	end

	function gui:center()
		self.x = getWindowWidth() / 2 - self.font:getWidth(self.text) / 2 
	end

	function gui:setText(text)
		self.text = text

		self:performLayout()
	end	

	function gui:mousepressed(x, y, button)
		if button == "l" then
			if self:inside() then
				if self.type == "button" then
					if self.func then
						if self.func and not self.args then
							self.func()
						else
							self.func(unpack(self.args))
						end
					end
				end
			end
		end
	end

	function gui:inside()
		local mx = love.mouse.getX()
		local my = love.mouse.getY()

		return mx > self.x * scale and mx < self.x * scale + self.width * scale and my > self.y * scale and my < self.y * scale + self.height * scale
	end

	return gui
end