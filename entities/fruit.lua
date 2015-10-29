local fruitSpeedx = {-math.random(90, 180), math.random(90, 180)}
local fruitSpeedy = {math.random(90, 180), -math.random(90, 180)}

function newFruit(x, y, screen)

	local fruit= {}
	fruit.x = x
	fruit.y = y
	fruit.graphics = fruitimg
	fruit.rotation = 0
	fruit.width = 22
	fruit.height = 22
	fruit.i = math.random(1, 9)

	fruit.startx = x
	fruit.starty = y

	fruit.screen = screen

	fruit.speedx = fruitSpeedx[2]
	if fruit.startx == love.graphics.getWidth() / scale then
		fruit.speedx = fruitSpeedx[1]
	end

	fruit.speedy = fruitSpeedy[2]
	if fruit.starty < (love.graphics.getWidth() / scale) / 2 then
		fruit.speedy = fruitSpeedy[1]
	end
	

	function fruit:update(dt)
		self.rotation = self.rotation + dt

		self.x = self.x + self.speedx * dt
		self.y = self.y + self.speedy * dt

		if self.x + self.width < 0 and self.speedx < 0 then
			self.remove = true
		elseif self.x > love.graphics.getWidth() / scale and self.speedx > 0 then
			self.remove = true
		elseif self.y + self.height < 0 and self.speedy < 0 then
			self.remove = true
		elseif self.y > love.graphics.getWidth() / scale and self.speedy > 0 then
			self.remove = true
		end

		if self.x > 40 and self.x < love.graphics.getWidth() - 80 then
			if self.screen == "top" then
				if self.y > love.graphics.getHeight() then
					self.screen = "bottom"
					self.x = self.x - 40
					self.y = 0
				end
			else
				if self.y < 0 then
					self.screen = "top"
					self.x = self.x + 40
					self.y = love.graphics.getHeight()
				end
			end
		end
	end

	function fruit:draw()
		love.graphics.setScreen(self.screen)

		love.graphics.draw(self.graphics[self.i], self.x, self.y, self.rotation)

	end

	function fruit:onCollide(name,data)
		if name == "ship" then
			if not data.hud.shieldActive then
				data:addLife(-1)
			end
			self:destroy(true)
		end

		if name == "bullet" then
			self:destroy(false, data.parent)
		end
	end

	function fruit:destroy(playerHit, player)
		-- game_playsound(fruitboom[math.random(#fruitboom)])

		if not playerHit then
			addScore(1)

			player.hud.shieldbar = math.min(player.hud.shieldbar + 1, player.hud.shieldbarmax)
		end

		table.insert(splats, newSplat(self.x, self.y, self.i, self.screen))

		if self.i == 3 then
			table.insert(objects["fruit"], newGrapePiece(self.x + self.width, self.y + self.height, math.random(90, 120), math.random(90, 120), self.screen))
			table.insert(objects["fruit"], newGrapePiece(self.x + self.width, self.y - self.height, math.random(90, 120), -math.random(90, 120), self.screen))
			table.insert(objects["fruit"], newGrapePiece(self.x, self.y + self.height, -math.random(90, 120), math.random(90, 120), self.screen))
			table.insert(objects["fruit"], newGrapePiece(self.x, self.y, -math.random(90, 120), -math.random(90, 120), self.screen))
		end

		self.remove = true
	end

	return fruit
end

function newGrapePiece(x, y, speedx, speedy, screen)
	local grapepiece = {}

	grapepiece.x = x
	grapepiece.y = y

	grapepiece.speedx = speedx
	grapepiece.speedy = speedy

	grapepiece.width = 8
	grapepiece.height = 8
	grapepiece.graphic = graphics["grapepiece"]
	grapepiece.rotation = 0
	grapepiece.screen = screen

	function grapepiece:update(dt)
		self.x = self.x + self.speedx * dt
		self.y = self.y + self.speedy * dt

		self.rotation = self.rotation + dt

		if self.x + self.width < 0 and self.speedx < 0 then
			self.remove = true
		elseif self.x > love.graphics.getWidth() / scale and self.speedx > 0 then
			self.remove = true
		elseif self.y + self.height < 0 and self.speedy < 0 then
			self.remove = true
		elseif self.y > love.graphics.getWidth() / scale and self.speedy > 0 then
			self.remove = true
		end
	end

	function grapepiece:draw()
		love.graphics.setScreen(self.screen)

		love.graphics.draw(self.graphic, self.x, self.y, self.rotation)
	end

	function grapepiece:onCollide(name,data)
		if name == "ship" then
			if not data.hud.shieldActive then
				data:addLife(-1)
			end
			self:destroy(true)
		end

		if name == "bullet" then
			self:destroy(false, data.parent)
		end
	end

	function grapepiece:destroy(playerHit)
		--game_playsound(fruitboom[math.random(#fruitboom)])

		if not playerHit then
			addScore(2)
		end

		self.remove = true
	end

	return grapepiece
end