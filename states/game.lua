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

	splats = {}
	backgroundImages = {}

	objects["ship"][1] = newShip( getWindowWidth() / 2 - 20, getWindowHeight() / 2 - 20, 3)

	local keys = {}
	for k, v in pairs(controls) do
		if v == " " then
			keys[k] = "SPACEBAR"
		else
			keys[k] = v
		end
	end

	instructions = 
	{
		"Tilt the device to turn",
		"Short tap to shoot",
		"Long tap to use the shield\n(max blue bar)",
		"Shoot as many fruits\nas possible!",
		"Ready?",
		"3..",
		"2..",
		"1..",
		"Go!",
		""
	}

	instructiontimer = 0
	instructiontimeri = 1
	gameover = false

	start_game = false
	state = "game"

	gamescore = 0

	game_randomStaticPlanet()

	game_playsound(bgm)

	restart_key = "'r'"
	if game_joystick then
		restart_key = "start"
	end

	timeout = 0
	
	pauseButton = newGUI("button", getWindowWidth() * scale - hudfont:getWidth("[Pause]") - 2 * scale, 4, "[Pause]", 
		function() 
			if start_game then
				paused = not paused 
			end
		end
	)

	pauseButton.font = hudfont
end

function game_randomStaticPlanet()
	local a = love.math.random(#staticBGs)
	planetX = love.math.random(0, getWindowWidth() - 50)
	planetY = love.math.random(0, getWindowHeight() - 50)
	planetimg = staticBGs[a]

	local b = love.math.random(#staticBGs)
	while b == a do
		b = love.math.random(#staticBGs)
	end
	planet2X = love.math.random(0, getWindowWidth() - 50)
	planet2Y = love.math.random(0, getWindowHeight() - 50)
	planetimg2 = staticBGs[b]
	
	for k = 1, 100 do
		stars[k] = {love.math.random(4, getWindowWidth() - 8), love.math.random(4, getWindowHeight() - 8)}
		starSizes[k] = love.math.random(1, 3)
	end
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

	for k = #splats, 1, -1 do
		if splats[k].remove then
			table.remove(splats, k)
		end
	end
end

function game_update(dt)

	if paused then
		return
	end

	if gameover then
		for k, v in pairs(splats) do
			v:update(dt)
		end

		if timeout < 3 then
			timeout = timeout + dt
		else
			menu_load(true)
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
			instructiontimer = instructiontimer + dt / 2
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
	end

	for k, v in ipairs(splats) do
		v:update(dt)
	end

	for k, v in pairs(backgroundImages) do
		v:update(dt)
	end

	game_garbageCollect()
end

function addScore(points)
	gamescore = math.max(gamescore + points, 0)
end

function game_draw()
	love.graphics.setColor(255, 255, 255)
	
	love.graphics.draw(planetimg, planetX, planetY)

	love.graphics.draw(planetimg2, planet2X, planet2Y)

	love.graphics.setFont(hudfont)

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.draw then
				w:draw()
			end
		end
	end

	for k, v in pairs(objects["powerup"]) do
		if v.drawshield then
			v:drawshield()
		end
	end

	for k, v in ipairs(splats) do
		v:draw()
	end

	for k, v in pairs(backgroundImages) do
		v:draw()
	end
	
	love.graphics.setColor(255, 255, 255)
	for k = 1, #starSizes do
		love.graphics.setPointSize(starSizes[k])
	end
	love.graphics.points(stars)
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

function game_mousepressed(x, y, button)
	pauseButton:mousepressed(x, y, button)
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