
local setScale = false
function love.load()

	love.graphics.setDefaultFilter("nearest", "nearest")

	fullscrn = false
	--shield charge: line at the bottom of brackets, lshift to activate. It drains slowly over time
	--health regen: every 10 points
	
	graphics = {}
	audio = {}
	
	requireFiles("") --start recursiveness!

	controls = {"d", "a", "w", "space", "lshift"}
	quads = {}

	stars = {}

	versionstring = "version 1.3"

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
	
	titleimg = {love.graphics.newImage("graphics/title/title.png"), love.graphics.newImage("graphics/title/titlebottom.png")}
	
	local chars = {"F", "R", "U", "I", "T"}
	
	fruittitle = {}
	for k = 1, #chars do
		fruittitle[k] = love.graphics.newImage("graphics/title/" .. chars[k] .. ".png")
	end
	
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
	
	if love.system.getOS() == "Android" then
		require 'classes/gyro'

		gyroController = newGyro(
		function(self, value)
			if not objects then
				return
			end

			local deadZone = 0.12
			local player = objects["ship"][1]

			if not player then
				return
			end

			if value > deadZone then
				player:rotateAdd(true)
				player:stopRotateLeft()
			elseif value >= 0 and value < deadZone then
				player:stopRotateLeft()
				player:stopRotateRight()
			elseif value < -deadZone then
				player:rotateAdd(false)
				player:stopRotateRight()
			elseif value > -deadZone and value <= 0 then
				player:stopRotateLeft()
				player:stopRotateRight()
			end
		end, 
		
		function(self, value)
			if not objects then
				return
			end

			local deadZone = 0.7
			local player = objects["ship"][1]

			if not player then
				return
			end
			
			if value < deadZone then
				player:moveForward()
			else 
				player:stopMovingForward()
			end
		end,

		nil, 
		
		function(self, id, x, y, pressure)
			self.taps = self.taps + 1
		end,
		
		function(self, id, x, y, pressure)
			self.taps = 0
			self.tapTimer = 0

			if not objects then
				return
			end

			local player = objects["ship"][1]
			
			if not player then
				return
			end
			
			player:shoot()
		end,

		{
			taps = 0,
			tapTimer = 0
		},

		function(self, dt)
			if not objects then
				return
			end

			local player = objects["ship"][1]

			if not player then
				return
			end

			if self.taps == 1 then
				self.tapTimer = self.tapTimer + dt

				if self.tapTimer > 3 then
					if paused then
						menu_load()
					end
				elseif self.tapTimer > 1 then
					if not paused then
						player:addShield()
					end
				end

				self.taps = 0
				self.tapTimer = 0
			else
				self.taps = 0
				self.tapTimer = 0
			end
		end)
		
		mobileMode = true
	else
		setFullscreen(false)
		
		love.window.setFullscreen(true, "desktop")
	end
	
	setFullscreen(true)
end

function defaultData()
	soundOn = true
	musicOn = true
	fullscrn = false
	highscore = 0
	controls = {"d", "a", "w", " ", "lshift"}
	
	setScale = false
end

function love.focus(focus)
	paused = not focus
	
	if not focus then
		if mobileMode then
			if not setScale then
				setFullscreen(true)
			end
		end
	end
end

function love.joystickadded(joy)
	if joy:getName() == "Android Accelerometer" then
		joystick = joy
	end
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

				highscore = tonumber(arg[4])

				for k = 1, 4 do
					controls[k] = arg[k+4]
				end
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

	if gyroController then
		gyroController:axis(1, joystick:getAxis(1))

		gyroController:axis(2, joystick:getAxis(2))

		gyroController:update(dt)
	end
end

function love.draw()
	love.graphics.push()
	
	if missingX and missingX > 0 and missingY and missingY > 0 then
		love.graphics.translate(missingX, missingY)
	end
	
	love.graphics.scale(scale, scale)
	
	if _G[state .. "_draw"] then
		_G[state .. "_draw"]()
	end

	love.graphics.pop()
	
	if state == "menu" then
		if menuGUI[menustate] then
			for i, v in pairs(menuGUI[menustate]) do
				v:draw()
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(hudfont)
		love.graphics.print(versionstring, 1, getWindowHeight() * scale - hudfont:getHeight(versionstring))

		if menustate == "credits" then
			love.graphics.setScissor(0, 120 * scale, getWindowWidth() * scale, getWindowHeight() * scale / 2)

			local currFont = love.graphics.getFont()

			love.graphics.setFont(hudfont)
			for k = 1, #credits do
				love.graphics.print(credits[k], (getWindowWidth() * scale) / 2 - hudfont:getWidth(credits[k]) / 2, (160 + (k - 1) * 16) * scale - creditsscroll * scale)
			end

			love.graphics.setFont(currFont)

			love.graphics.setScissor()
		end
	elseif state == "game" then
		love.graphics.setFont(hudfont)
	
		love.graphics.print("Score: " .. gamescore, 2 * scale, 2 * scale)

		pauseButton:draw()
		
		if not start_game then
			love.graphics.setFont(menubuttonfont)
			love.graphics.print(instructions[instructiontimeri], getWindowWidth() * scale / 2 - menubuttonfont:getWidth(instructions[instructiontimeri]) / 2, getWindowHeight() * scale / 2 - menubuttonfont:getHeight(instructions[instructiontimeri]) / 2)
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
		end
	end
end

function getWindowWidth()
	return love.graphics.getWidth() / scale
end

function getWindowHeight()
	return love.graphics.getHeight() / scale
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
	hudfont = love.graphics.newFont("graphics/PixelLCD.ttf", 7.5 * scale)
	menubuttonfont = love.graphics.newFont("graphics/PixelLCD.ttf", 15 * scale)
end

function setFullscreen(enable)
	width, height = love.window.getDesktopDimensions()
		
	currentWidth, currentHeight = love.graphics.getDimensions( )

	scale = math.floor( math.max( (width / 400), (height / 300) ) )
	
	missingX = ( (width / 2) - (400 * scale) / 2)
	missingY = ( (height / 2) - (300 * scale) / 2)
	
	loadFonts()
	
	menu_load()
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
