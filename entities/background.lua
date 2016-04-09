backgroundDontUse = {}
function newBackgroundObject(x, y, t)
	local background = {}

	background.x = x
	background.y = y
	background.type = t

	background.types = 
	{
		["out"] = {backgroundImages[1], backgroundImages[2], backgroundImages[4], backgroundImages[6], love.graphics.newImage(love.image.newImageData(40, 40))},
		["ins"] = {backgroundImages[3], backgroundImages[5], love.graphics.newImage(love.image.newImageData(40, 40))}
	}

	background.animationTimer = 0
	background.quadi = 1

	function checkImageUse(usingImage)
		for k = #backgroundDontUse, 1, -1 do
			if backgroundDontUse[k] == usingImage then
				return false
			end
		end
		return true
	end

	function releaseImage(usingImage)
		for k = #backgroundDontUse, 1, -1 do
			if backgroundDontUse[k] == usingImage then
				table.remove(backgroundDontUse, k)
				break
			end
		end
	end

	function getImage(t)
		print(t)
		local v = background.types[t][love.math.random(#background.types[t])]
		local pass = checkImageUse(v)

		while not pass do
			v = background.types[t][love.math.random(#background.types[t])]
			pass = checkImageUse(v)
		end

		return v
	end

	background.graphic = getImage(background.type)

	local w, h
	if type(background.graphic) == "table" then
		w, h = background.graphic[1]:getWidth(), background.graphic[1]:getHeight()
	else
		w, h = background.graphic:getWidth(), background.graphic:getHeight()
	end

	background.width = w
	background.height = h

	background.x = background.x - background.width / 2
	background.y = background.y - background.height / 2

	table.insert(backgroundDontUse, background.graphic)

	function background:update(dt)
		if type(self.graphic) == "table" then
			self.animationTimer = self.animationTimer + 4 * dt
			self.quadi = math.floor(self.animationTimer % #self.graphic) + 1
		else
			return
		end
	end

	function background:draw()
		if type(self.graphic) == "table" then
			love.graphics.draw(self.graphic[self.quadi], self.x * scale, self.y * scale, 0, scale, scale)
		else
			love.graphics.draw(self.graphic, self.x * scale, self.y * scale, 0, scale, scale)
		end
	end

	function background:changeItem()
		releaseImage(self.graphic)
		
		self.graphic = getImage(self.type)

		table.insert(backgroundDontUse, self.graphic)
	end

	function background:changePosition(x, y)
		self.x = x - self.width / 2
		self.y = y - self.width / 2
	end

	return background
end