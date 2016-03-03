local fruitSpeedx = {-love.math.random(90, 180), love.math.random(90, 180)}
local fruitSpeedy = {love.math.random(90, 180), -love.math.random(90, 180)}

function newFruit(x, y)

	local fruit= {}
	fruit.x = x
	fruit.y = y
	fruit.graphics = graphics["fruit"]
	fruit.rotation = 0
	fruit.width = 22
	fruit.height = 22
	fruit.quad = quads["fruit"]
	fruit.quadi = love.math.random(#quads["fruit"])

	fruit.startx = x
	fruit.starty = y

	fruit.speedx = fruitSpeedx[2]
	if fruit.startx == getWindowWidth() then
		fruit.speedx = fruitSpeedx[1]
	end

	fruit.speedy = fruitSpeedy[2]
	if fruit.starty < getWindowHeight() / 2 then
		fruit.speedy = fruitSpeedy[1]
	end
	

	function fruit:update(dt)
		self.rotation = self.rotation + dt

		self.x = self.x + self.speedx * dt
		self.y = self.y + self.speedy * dt

		if self.x + self.width < 0 and self.speedx < 0 then
			self.remove = true
		elseif self.x > getWindowWidth() and self.speedx > 0 then
			self.remove = true
		elseif self.y + self.height < 0 and self.speedy < 0 then
			self.remove = true
		elseif self.y > getWindowHeight() and self.speedy > 0 then
			self.remove = true
		end
	end

	function fruit:draw()
		love.graphics.draw(self.graphics, quads["fruit"][self.quadi], self.x + 11, self.y + 11,self.rotation,1,1, 11, 11)
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
		game_playsound(fruitboom[love.math.random(#fruitboom)])

		if not playerHit then
			addScore(1)

			--if game's score is divisible by 10
			if gamescore%10 == 0 then
				table.insert(objects["powerup"], newPowerup(self.x + (self.width / 2) - 8, self.y + (self.height / 2) - 8, 2))
			end

			player.hud.shieldbar = math.min(player.hud.shieldbar + 1, player.hud.shieldbarmax)
		end

		table.insert(splats, newSplat(self.x, self.y, self.quadi))

		if self.quadi == 3 then
			table.insert(objects["fruit"], newGrapePiece(self.x + self.width, self.y + self.height, love.math.random(90, 120), love.math.random(90, 120)))
			table.insert(objects["fruit"], newGrapePiece(self.x + self.width, self.y - self.height, love.math.random(90, 120), -love.math.random(90, 120)))
			table.insert(objects["fruit"], newGrapePiece(self.x, self.y + self.height, -love.math.random(90, 120), love.math.random(90, 120)))
			table.insert(objects["fruit"], newGrapePiece(self.x, self.y, -love.math.random(90, 120), -love.math.random(90, 120)))
		end

		self.remove = true
	end

	return fruit
end

function newGrapePiece(x, y, speedx, speedy, quadi)
	local grapepiece = {}

	grapepiece.x = x
	grapepiece.y = y

	grapepiece.speedx = speedx
	grapepiece.speedy = speedy

	grapepiece.width = 8
	grapepiece.height = 8
	grapepiece.graphic = graphics["grapepiece"]
	grapepiece.rotation = 0

	function grapepiece:update(dt)
		self.x = self.x + self.speedx * dt
		self.y = self.y + self.speedy * dt

		self.rotation = self.rotation + dt

		if self.x + self.width < 0 and self.speedx < 0 then
			self.remove = true
		elseif self.x > getWindowWidth() and self.speedx > 0 then
			self.remove = true
		elseif self.y + self.height < 0 and self.speedy < 0 then
			self.remove = true
		elseif self.y > getWindowHeight() and self.speedy > 0 then
			self.remove = true
		end
	end

	function grapepiece:draw()
		love.graphics.draw(self.graphic, self.x + 4, self.y + 4, self.rotation, 1, 1, 4, 4)
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
		game_playsound(fruitboom[love.math.random(#fruitboom)])

		if not playerHit then
			addScore(2)
		end

		self.remove = true
	end

	return grapepiece
end