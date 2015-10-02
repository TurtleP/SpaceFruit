function love.load()

	love.graphics.setDefaultFilter("nearest", "nearest")
	scale = 2
	fullscrn = false

	--shield charge: line at the bottom of brackets, lshift to activate. It drains slowly over time
	--health regen: every 10 points
	
	graphics = {}
	audio = {}

	requireFiles("") --start recursiveness!

	loadFonts()

	controls = {"d", "a", "w", " ", "lshift"}
	quads = {}

	stars = {}

	versionstring = "version 1.2"

	graphics["ship"] = love.graphics.newImage("graphics/ship/space_ship.png")
	quads["ship"] = {}
	for k = 1, 4 do
		quads["ship"][k] = {}
		for y = 1, 4 do
			quads["ship"][k][y] = love.graphics.newQuad((k-1) * 41, (y - 1) * 40, 40, 40, graphics["ship"]:getWidth(), graphics["ship"]:getHeight())
		end
	end

	graphics["fruit"] = love.graphics.newImage("graphics/enemies/fruits.png")
	quads["fruit"] = {}
	for k = 1, graphics["fruit"]:getWidth()/23 do
		quads["fruit"][k] = love.graphics.newQuad((k-1)*23, 0, 22, 22, graphics["fruit"]:getWidth(), graphics["fruit"]:getHeight())
	end

	graphics["health"] = love.graphics.newImage("graphics/hud/Health.png")
	graphics["hurt"] = love.graphics.newImage("graphics/hud/Health_Broken.png")

	graphics["splat"] = love.graphics.newImage("graphics/enemies/explosion_quad.png")
	quads["splat"] = {}
	for k = 1, 6 do
		quads["splat"][k] = love.graphics.newQuad((k-1)*24, 0, 22, 22, graphics["splat"]:getWidth(), graphics["splat"]:getHeight())
	end

	graphics["powerups"] = love.graphics.newImage("graphics/items/power_ups_quad.png")
	quads["powerups"] = {}
	for k = 1, 3 do
		quads["powerups"][k] = love.graphics.newQuad((k-1)*24, 0, 16, 16, graphics["powerups"]:getWidth(), graphics["powerups"]:getHeight())
	end

	graphics["grapepiece"] = love.graphics.newImage("graphics/enemies/grape_piece.png")

	staticBGs = {love.graphics.newImage("graphics/bg/moon.png"), love.graphics.newImage("graphics/bg/planet.png"), love.graphics.newImage("graphics/bg/sun.png"), love.graphics.newImage("graphics/bg/satalite.png"), 
				love.graphics.newImage("graphics/bg/blackhole.png"), love.graphics.newImage("graphics/bg/astroid_1.png"), love.graphics.newImage("graphics/bg/astroid_2.png"), love.graphics.newImage("graphics/bg/earth.png")}

	bulletimg = love.graphics.newImage("graphics/ship/bullet.png")

	graphics["powerup"] = love.graphics.newImage("graphics/items/power_ups_quad.png")
	quads["powerups"] = {}
	for k = 1, graphics["powerup"]:getWidth()/17 do
		quads["powerups"][k] = love.graphics.newQuad((k-1)*17, 0, 16, 16, graphics["powerup"]:getWidth(), graphics["powerup"]:getHeight())
	end

	soundfiles =
	{
		"item",
		"damage",
		"fruitboom"
	}

	musicfiles =
	{
		"bgm",
		"mainmenu"
	}

	love.window.setTitle("Space Fruit")
	love.window.setMode(800, 600, {vsync = true})

	love.graphics.setFont(title)
	love.graphics.setPointStyle("rough")

	bgm = love.audio.newSource("sound/bgm.ogg", "stream")
	bgm:setLooping(true)

	item = love.audio.newSource("sound/item.ogg")

	gameoversnd = love.audio.newSource("sound/gameover.ogg")

	damage = {love.audio.newSource("sound/explosion_1.ogg"), love.audio.newSource("sound/explosion_2.ogg")}
	shoot = {love.audio.newSource("sound/shoot_1.ogg"), love.audio.newSource("sound/shoot_2.ogg")}
	fruitboom = {love.audio.newSource("sound/fruit_explode_1.ogg"), love.audio.newSource("sound/fruit_explode_2.ogg"), love.audio.newSource("sound/fruit_explode_3.ogg")}
	
	mainmenu = love.audio.newSource("sound/title.ogg", "stream")

	love.window.setIcon(love.image.newImageData("graphics/ship/ship.png"))

	saveLoadSettings(true)

	gamescore = 0
	highscore = 0

	menu_load()
end

function defaultData()
	soundOn = true
	musicOn = true
	fullscrn = false
	highscore = 0
	controls = {"d", "a", "w", " ", "lshift"}
end

function love.focus(focus)
	paused = not focus
end

function saveLoadSettings(load, onlyHigh)
	if not load then

		local s = highscore
		if gamescore > highscore then
			s = gamescore
		end

		datastring = tostring(soundOn) .. ";" .. tostring(musicOn) .. ";" .. tostring(fullscrn) .. ";" .. s .. ";" .. controls[1] .. ";" .. controls[2] .. ";" .. controls[3] .. ";" .. controls[4] .. ";" .. controls[5] .. ";"

		love.filesystem.write("data.txt", datastring)
	else

		if load ~= "del" then

			if not love.filesystem.exists("data.txt") then
				defaultData()

				return
			end

			local data = love.filesystem.read("data.txt")

			local arg = data:split(";")

			if #arg ~= 9 then
				print("Save Data is corrupt! Deleting..")
				love.filesystem.remove("data.txt")
				saveLoadSettings(true)
			end

			if not onlyHigh then
				if arg[1] == "true" then
					soundOn = true
				else
					soundOn = false
				end

				if arg[2] == "true" then
					musicOn = true
				else
					musicOn = false
				end

				if arg[3] == "true" then
					fullscrn = true
				else
					fullscrn = false
				end

				highscore = tonumber(arg[4])

				for k = 1, 4 do
					controls[k] = arg[k+4]
				end

				setFullscreen(fullscrn)
			else
				highscore = tonumber(arg[4])
			end
		else
			if love.filesystem.exists("data.txt") then
				love.filesystem.remove("data.txt")
			end

			if love.filesystem.exists("highscore.txt") then
				love.filesystem.remove("highscore.txt")
			end

			soundOn = true
			musicOn = true
		end

	end
end

function love.update(dt)
	dt = math.min(0.1666667, dt)

	if _G[state .. "_update"] then
		_G[state .. "_update"](dt)
	end

	if game_joystick then
		if state ~= "game" then
			local horAxis = game_joystick:getAxis(1)
			local verAxis = game_joystick:getAxis(2)

			if horAxis > 0.2 then
				love.mouse.setX(love.mouse.getX() + 180 * scale * dt)
			end

			if horAxis < -0.2 then
				love.mouse.setX(love.mouse.getX() - 180 * scale * dt)
			end

			if verAxis > 0.2 then
				love.mouse.setY(love.mouse.getY() + 180 * scale * dt)
			end

			if verAxis < -0.2 then
				love.mouse.setY(love.mouse.getY() - 180 * scale * dt)
			end
		else
			return
		end
	end
end

function love.draw()
	love.graphics.scale(scale, scale)

	if _G[state .. "_draw"] then
		_G[state .. "_draw"]()
	end
end

function getWindowWidth()
	return love.window.getWidth() / scale
end

function getWindowHeight()
	return love.window.getHeight() / scale
end

function love.keypressed(key)
	if _G[state .. "_keypressed"] then
		_G[state .. "_keypressed"](key)
	end
end

function love.mousepressed(x, y, button)
	if _G[state .. "_mousepressed"] then
		_G[state .. "_mousepressed"](x, y, button)
	end
end

function love.keyreleased(key)
	if _G[state .. "_keyreleased"] then
		_G[state .. "_keyreleased"](key)
	end
end

function requireFiles(path)
	local f = love.filesystem.getDirectoryItems(path)

	for k = 1, #f do
		if love.filesystem.isDirectory(f[k]) then
			requireFiles(f[k] .. "/")
		else
			if f[k]:sub(-4) == ".lua" then
				require(path .. f[k]:gsub(".lua", ""))
			end
		end
	end
end

function loadFonts()
	title = love.graphics.newFont("graphics/ARCADE_N.TTF", 32)
	titleHuge = love.graphics.newFont("graphics/ARCADE_N.TTF", 40)
	hudfont = love.graphics.newFont("graphics/ARCADE_N.TTF", 8)
	mediumfont = love.graphics.newFont("graphics/ARCADE_N.TTF", 12)
	menubuttonfont = love.graphics.newFont("graphics/ARCADE_N.TTF", 16)
end

function setFullscreen(fs)

	if not fs then
		fullscrn = not fullscrn
	else
		fullscrn = fs
	end

	if fullscrn then
		w, h = love.window.getDesktopDimensions(1)
		love.window.setMode(w, h, {fullscreen = true, vsync = true})

		scale = h / 300

		loadFonts()
	else
		love.window.setMode(800, 600, {fullscreen = false, vsync = true})
		scale = 2
	end

	if state then
		if state ~= "menu" then
			_G[state .. "_load"]()
		else
			_G[state .. "_load"]()
			menustate = "settings"
		end
	end
end

function string:split(delimiter) --Not by me
	local result = {}
	local from   = 1
	local delim_from, delim_to = string.find( self, delimiter, from   )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from   )
	end
	table.insert( result, string.sub( self, from   ) )
	return result
end

function love.joystickadded(joy)
	if joy:getID() == 1 then
		game_joystick = joy
	end
end

function love.gamepadpressed( joystick, button )
	if joystick == game_joystick then
		if button == "a" then
			if state ~= "game" then
				love.mousepressed(love.mouse.getX(), love.mouse.getY(), "l")
			end
		end
		
		if state == "game" then
			if objects["ship"][1] then
				objects["ship"][1]:gamePad(button)
			end
		end

		if button == "start" then
			if gameover then
				game_load()
			else
				paused = not paused
			end
		end
	end
end

function love.joystickaxis( joystick, axis, value )
	if joystick == game_joystick then
		if state == "game" then
			game_joystickaxis(joystick, axis, value)
		end
	end
end

function love.joystickremoved(joystick)
	if joystick == game_joystick then
		game_joystick = nil
	end
end