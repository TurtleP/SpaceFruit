function game_load()

	paused = false
	if love.filesystem.exists("data.txt") then
		saveLoadSettings(true, "onlyHigh")
	else
		highscore = 0
	end

	objects = {}

	objects["ship"] = {}
	objects["bullet"] = {}
	objects["fruit"] = {}
	objects["powerup"] = {}
	objects["asteroid"] = {}
	objects["background"] = {}

	splats = {}

	objects["ship"][1] = newShip( getWindowWidth() / 2 - 20, getWindowHeight() / 2 - 20, 4)

	instructions = 
		{
			"Hold a tap to use the analog stick.",
			"Short tap to shoot.",
			"Long tap with full blue hearts to gain a shield.",
			"Shoot as many fruits as possible!",
			"Ready?",
			"3..",
			"2..",
			"1..",
			"Go!",
			""
		}
	if not mobileMode then
		instructions = 
		{
			"Use " .. controls[1] .. " and " .. controls[2] .. " to rotate.",
			"Hold " .. controls[3] .. " to move forward.",
			"Press " .. controls[4] .. " to shoot.",
			"With full blue hearts, press " .. controls[5] .. " to gain a shield",
			"Shoot as many fruits as possible!",
			"Ready?",
			"3..",
			"2..",
			"1..",
			"Go!",
			""
		}
	end

	instructiontimer = 0
	instructiontimeri = 1
	gameover = false

	start_game = false
	state = "game"

	gamescore = 0

	game_randomStaticPlanet()

	game_playsound(bgm)

	timeout = 0

	asteroidTimer = love.math.random(4, 6)
end

function game_randomStaticPlanet()
	positionDontUse = {}

	local positions =
	{
		{getWindowWidth() * 0.10, getWindowHeight() * 0.10},
		{getWindowWidth() * 0.90, getWindowHeight() * 0.10},
		{getWindowWidth() * 0.10, getWindowHeight() * 0.90},
		{getWindowWidth() * 0.90, getWindowHeight() * 0.90}
	}

	local function checkPosition(positionTable)
		for k = #positionDontUse, 1, -1 do
			if positionDontUse[k] == positionTable then
				return false
			end
		end
		return true
	end

	local function getPosition()
		local pos = positions[love.math.random(#positions)]
		local pass = checkPosition(pos)

		while not pass do
			pos = positions[love.math.random(#positions)]
			pass = checkPosition(pos)
		end

		return pos
	end

	if #objects["background"] == 0 then
		local t = {"out", "out"}

		for k = 1, #t do
			local pos = getPosition()
			objects["background"][k] = newBackgroundObject(pos[1], pos[2], t[k])
			table.insert(positionDontUse, pos)
		end

		objects["background"][3] = newBackgroundObject(getWindowWidth() * 0.5, getWindowHeight() * 0.5, "ins")
	else
		for k = 1, 2 do
			local pos = getPosition()
			objects["background"][k]:changeItem()
			objects["background"][k]:changePosition(pos[1], pos[2])
			table.insert(positionDontUse, pos)
		end
		objects["background"][3]:changeItem()
	end

	for k = 1, 100 do
		stars[k] = {love.math.random(4, getWindowWidth() - 8), love.math.random(4, getWindowHeight() - 8)}
		starSizes[k] = love.math.random(1, 3)
	end

	--clear them so players don't hurt themselves, kthxbai
	objects["fruit"] = {}
	objects["asteroid"] = {}
end

function game_garbageCollect()
	for k = #objects["fruit"], 1, -1 do
		if objects["fruit"][k].remove then
			table.remove(objects["fruit"], k)
		end
	end

	for k = #objects["bullet"], 1, -1 do
		if objects["bullet"][k].remove then
			table.remove(objects["bullet"], k)
		end
	end

	for k = #objects["powerup"], 1, -1 do
		if objects["powerup"][k].remove then
			table.remove(objects["powerup"], k)
		end
	end

	for k = #objects["asteroid"], 1, -1 do
		if objects["asteroid"][k].remove then
			table.remove(objects["asteroid"], k)
		end
	end

	if objects["ship"][1] then
		if objects["ship"][1].dead then
			table.remove(objects["ship"], 1)
		end
	end

	for k = #splats, 1, -1 do
		if splats[k].remove then
			table.remove(splats, k)
		end
	end
end

function game_update(dt)

	if paused then
		if love.keyboard.isDown("escape") then
			timeout = timeout + dt
			if timeout > 3 then
				menu_load()
				timeout = 0
			end
		end
		return
	end

	if gameover then
		for k, v in pairs(splats) do
			v:update(dt)
		end

		if timeout < 3 then
			timeout = timeout + dt
		else
			highscore_load(true)
		end

		return
	end

	physics:update(dt)

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.update then
				w:update(dt)
			end
		end
	end

	if not start_game then
		if instructiontimeri < 10 then
			instructiontimer = instructiontimer + dt / 4
			instructiontimeri = math.floor(instructiontimer%#instructions)+1
		else
			fruitTimer = newRecursionTimer(love.math.random(2, 4),
				function()
					local posx = {4, getWindowWidth()}
					local posy = love.math.random(4, getWindowHeight())

					table.insert(objects["fruit"], newFruit(posx[love.math.random(#posx)], posy))
				end
			)

			start_game = true
			instructiontimer = 0
		end
	else
		fruitTimer:update(dt)

		if #objects["asteroid"] == 0 then
			if asteroidTimer > 0 then
				asteroidTimer = asteroidTimer - dt
			else
				table.insert(objects["asteroid"], newAsteroid())
				asteroidTimer = love.math.random(4, 6)
			end
		end
	end

	for k, v in ipairs(splats) do
		v:update(dt)
	end

	game_garbageCollect()
end

function addScore(points)
	gamescore = math.max(gamescore + points, 0)
end

function game_draw()
	love.graphics.setColor(255, 255, 255)
	for k = 1, #starSizes do
		love.graphics.setPointSize(starSizes[k])
		love.graphics.points(stars[k][1] * scale, stars[k][2] * scale)
	end

	for k, v in pairs(objects["background"]) do
		v:draw()
	end

	if objects["ship"][1] then
		objects["ship"][1]:draw()
	end

	for k, v in pairs(objects["bullet"]) do
		v:draw()
	end

	for k, v in pairs(objects["powerup"]) do
		v:draw()
	end

	for k, v in pairs(objects["fruit"]) do
		v:draw()
	end

	for k, v in pairs(objects["asteroid"]) do
		v:draw()
	end

	for k, v in pairs(objects["powerup"]) do
		if v.drawshield then
			v:drawshield()
		end
	end

	for k, v in ipairs(splats) do
		v:draw()
	end

	love.graphics.setFont(menubuttonfont)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print("Score: " .. gamescore, 1 * scale, 1 * scale)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Score: " .. gamescore, 2 * scale, 2 * scale)

	love.graphics.setFont(hudfont)

	if not start_game then
		love.graphics.setFont(menubuttonfont)
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf(instructions[instructiontimeri], getWindowWidth() * scale / 2 - 101 * scale, getWindowHeight() * scale / 2 - menubuttonfont:getHeight(instructions[instructiontimeri]) / 2 - 1 * scale, 200 * scale, "center")
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf(instructions[instructiontimeri], getWindowWidth() * scale / 2 - 100 * scale, getWindowHeight() * scale / 2 - menubuttonfont:getHeight(instructions[instructiontimeri]) / 2, 200 * scale, "center")
	end
	
	if paused then
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(menubuttonfont)
		love.graphics.print("Game Paused", getWindowWidth() * scale / 2 - menubuttonfont:getWidth("Game Paused") / 2, getWindowHeight() * scale / 2 - menubuttonfont:getHeight("Game Paused") / 2)
		love.graphics.setFont(hudfont)
		love.graphics.print("(Hold to return to the menu)", getWindowWidth() * scale / 2 - hudfont:getWidth("(Hold to return to the menu)") / 2, getWindowHeight() * scale / 2 + menubuttonfont:getHeight("Game Paused") / 2 + hudfont:getHeight("(Hold to return to the menu)"))
	end

	if gameover then
		love.graphics.setFont(menubuttonfont)
		love.graphics.print("Game Over!", getWindowWidth() * scale / 2 - menubuttonfont:getWidth("Game Over!") / 2, getWindowHeight() * scale / 2 - menubuttonfont:getHeight("Game Over!") / 2)
		love.graphics.setFont(hudfont)
	end
		
	if objects["ship"][1] then
		objects["ship"][1].hud:draw(objects["ship"][1].hp)
	end
		
	if paused then
		love.graphics.setColor(0, 0, 0, 120)
		love.graphics.rectangle("fill", 0, 0, getWindowWidth() * scale, getWindowHeight() * scale)
		love.graphics.setColor(255, 255, 255)
	end
end

function game_keypressed(key)
	if not gameover then
		if not paused then
			if objects["ship"][1] then
				objects["ship"][1]:move(key)
			end
		end

		if key == "escape" and start_game then
			paused = not paused
		end
	end
end

function game_keyreleased(key)
	if objects["ship"][1] then
		if key == controls[1] then
			objects["ship"][1]:stopRotateRight()
		elseif key == controls[2] then
			objects["ship"][1]:stopRotateLeft()
		elseif key == controls[3] then
			objects["ship"][1]:stopMovingForward()
		end
	end
end

function game_playsound(audio)
	audio:stop()
	audio:rewind()
	audio:play()
end