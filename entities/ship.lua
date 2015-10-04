function newShip(x, y, hp, screen)
	local ship = {}

	ship.x = x
	ship.y = y
	ship.hp = hp
	ship.rotation = 0
	ship.width = 40
	ship.height = 40
	ship.quadi = 1
	ship.animtimer = 0
	ship.shouldrotate = false
	ship.speedy = 0
	ship.speedx = 0
	ship.shouldMove = false 
	ship.invincible = false
	ship.invincibletimer = 0
	ship.drawable = true 
	ship.hud = newHud(hp)
	ship.hits = 1

	ship.rotationright = false
	ship.rotationleft = false
	ship.screen = screen
	
	function ship:draw()
		if self.drawable then
			love.graphics.setScreen(self.screen)
			
			love.graphics.draw(shipimg[self.hp][self.quadi], self.x, self.y, self.rotation, 1, 1, self.width / 2, self.height / 2)
	
		end

		self.hud:draw(self.hp)
	end

	function ship:shoot()
		--game_playsound(shoot[math.random(#shoot)])
		table.insert(objects.bullet, newBullet(self.x + (self.width / 2) - 0.5, self.y + (self.height / 2) - 3, self.rotation, self.screen, self))
	end

	function ship:update(dt)
		if self.rotationright then
			self.rotation = self.rotation + 4 * dt
		elseif self.rotationleft then
			self.rotation = self.rotation - 4 * dt 
		end

		if self.rotationright or self.rotationleft or self.moveForth then
			self.animtimer = self.animtimer + 8 * dt
			self.quadi = math.floor(self.animtimer%3)+2
		elseif not self.rotationleft and not self.rotationright and not self.moveForth then
			self.animtimer = 0
			self.quadi = 1
		end

		if self.shouldMove then
			if self.moveForth then
				self.speedy = -math.cos(self.rotation) * 120
				self.speedx = math.sin(self.rotation) * 120
			end
		end

		if self.speedy > 0 then
			self.speedy = math.max(self.speedy - 100 * dt, 0)
		else
			self.speedy = math.min(self.speedy + 100 * dt, 0)
		end

		if self.speedx > 0 then
			self.speedx = math.max(self.speedx - 100 * dt, 0)
		else
			self.speedx = math.min(self.speedx + 100 * dt, 0)
		end

		self:checkWarp()

		self.y = self.y + self.speedy * dt
		self.x = self.x + self.speedx * dt

		if self.invincible then
			self.invincibletimer = self.invincibletimer + 6 * dt 

			if math.floor(self.invincibletimer%2) == 0 then
				self.drawable = false 
			else
				self.drawable = true
			end

			if self.invincibletimer > 19 then
				self.invincibletimer = 0
				self.invincible = false
			end
		end
		
		if self.y < 0 and self.screen == "top" then
			self.speedy = 0
			self.y = 0
		elseif self.y + self.height > love.graphics.getHeight() and self.screen == "bottom" then
			self.speedy = 0
			self.y = love.graphics.getHeight() - self.height
		end

		self.hud:update(dt)
	end

	function ship:moveForward()
		self.moveForth = true
		self.shouldMove = true
	end

	function ship:rotateAdd(add)
		if add then
			self.rotationright = true
		else
			self.rotationleft = true
		end
	end

	function ship:move(key)
		if key == controls[4] then
			self:shoot()
		end

		if key == controls[1] then
			self:rotateAdd(true)
		elseif key == controls[2] then
			self:rotateAdd(false)
		end

		if key == controls[3] then
			self:moveForward()
		end

		if key == controls[5] then
			self:addShield()
		end
	end

	function ship:addShield()
		if self.hud.shieldbar == self.hud.shieldbarmax then
			table.insert(objects["powerup"], newShield(self, self.screen))
			self.hud.shieldActive = true
		end
	end

	function ship:stopMove(key)
		if key == controls[2] then
			self.rotationleft = false
		end

		if key == controls[1] then
			self.rotationright = false
		end

		if key == controls[3] then
			self.moveForth = false
			self.shouldMove = false
		end
	end

	function ship:checkWarp()
		local ww = love.graphics.getWidth()
		local wh = 240

		if self.x + self.width > ww then
			self.x = 0

			game_randomStaticPlanet()

		elseif self.y > wh and self.screen == "top" then
			self.screen = "bottom"
			self.y = 0
			
			--game_randomStaticPlanet()
		elseif self.x + self.width < 0 then
			self.x = ww - 40

			game_randomStaticPlanet()
		elseif self.y < 0 and self.screen == "bottom" then
			self.y = wh - 40
			self.screen = "top"

			--game_randomStaticPlanet()
		end
	end

	function ship:addLife(lifeAmount)
		if not self.invincible then
			self.hp = math.max(self.hp + lifeAmount, 0)

			if self.hp == 0 then
				gameover = true
				game_playsound(gameoversnd)
				self.drawable = false
				return
			end

			if lifeAmount < 0 then
				if not self.hud.shieldActive then
					--game_playsound(damage[math.random(#damage)])

					self.hits = math.min(self.hits + 1, 4)
					self.invincible = true
				end
			else
				self.hits = math.max(self.hits - 1, 1)
			end
		end
	end

	function ship:onCollide(name, data)
		if name == "powerup" then
			if data.quadi == 2 then
				self:addLife(1)
				data.remove = true
			end
		end
	end

	return ship
end