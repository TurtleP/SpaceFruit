
local setScale = false
io.stdout:setvbuf("no")
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

	versionstring = "version 1.3"

	graphics["ship"] = love.graphics.newImage("graphics/ship/space_ship.png")
	quads["ship"] = {}
	for k = 1, 4 do
		quads["ship"][k] = {}
		for y = 1, 4 do
			quads["ship"][k][y] = love.graphics.newQuad((k-1) * 41, (y - 1) * 40, 40, 40, graphics["ship"]:getWidth(), graphics["ship"]:getHeight())
		end
	end

	graphics["shield"] = love.graphics.newImage("graphics/ship/shield.png")
	quads["shield"] = {}
	for k = 1, 10 do
		quads["shield"][k] = love.graphics.newQuad((k - 1) * 40, 0, 40, 40, graphics["shield"]:getWidth(), graphics["shield"]:getHeight())
	end

	graphics["fruit"] = love.graphics.newImage("graphics/enemies/fruits.png")
	quads["fruit"] = {}
	for k = 1, graphics["fruit"]:getWidth()/23 do
		quads["fruit"][k] = love.graphics.newQuad((k-1)*23, 0, 22, 22, graphics["fruit"]:getWidth(), graphics["fruit"]:getHeight())
	end

	graphics["health"] = love.graphics.newImage("graphics/hud/health.png")
	quads["health"] = {}
	for y = 1, 2 do
		for x = 1, 2 do
			table.insert(quads["health"], love.graphics.newQuad((x - 1) * 8, (y - 1) * 8, 8, 8, 16, 16))
		end
	end
	
	titleimg = love.graphics.newImage("graphics/title/title.png")
	
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

	asteroidGraphics = 
	{
		love.graphics.newImage("graphics/bg/astroid_1.png"), 
		love.graphics.newImage("graphics/bg/astroid_2.png"),
	}

	asteroidSounds = 
	{
		love.audio.newSource("sound/asteroid.ogg"),
		love.audio.newSource("sound/asteroid2.ogg")
	}

	backgroundImages = 
	{
		love.graphics.newImage("graphics/bg/moon.png"), 
		love.graphics.newImage("graphics/bg/planet.png"), 
		{}, 
		love.graphics.newImage("graphics/bg/satalite.png"), 
		love.graphics.newImage("graphics/bg/blackhole.png"), 
		love.graphics.newImage("graphics/bg/earth.png")
	}

	for k = 1, 4 do
		table.insert(backgroundImages[3], love.graphics.newImage("graphics/bg/sun" .. k .. ".png"))
	end

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

	json = require 'libraries/json'

	gamescore = 0
	highscore = 0
	
	if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
		require 'mobile/touchcontrol'
		require 'mobile/analog'
		require 'mobile/gyro'

		gyroController = newGyro(
		
		nil,

		nil,

		nil, 
		
		function(self, id, x, y, pressure)
			if analogStick then
				if id ~= analogStick.held then
					self.taps = self.taps + 1
				end
			end
		end,
		
		function(self, id, x, y, pressure)
			self.tapTimer = 0

			if not objects then
				return
			end

			local player = objects["ship"][1]
			
			if not player then
				return
			end

			if id ~= analogStick.lastHeld then
				if self.shootingTimer == 0 then	
					player:shoot()

					self.shootingTimer = 1/4
				end
			end
		end,

		{
			taps = 0,
			tapTimer = 0,
			shootingTimer = 1/4
		},

		function(self, dt)
			if not objects then
				return
			end

			local player = objects["ship"][1]

			if not player then
				return
			end

			self.shootingTimer = math.max(self.shootingTimer - dt, 0)

			if self.taps == 1 then
				self.tapTimer = self.tapTimer + dt

				if self.tapTimer > 3 then
					if paused then
						menu_load()
					
						self.taps = 0
						self.tapTimer = 0
					end
				elseif self.tapTimer > 1 then
					if not paused then
						player:addShield()
					
						self.taps = 0
						self.tapTimer = 0
					end
				end
			else
				self.taps = 0
				self.tapTimer = 0
			end
		end)
		
		mobileMode = true

		setFullscreen()
	else
		love.window.setFullscreen(true, "desktop")

		setFullscreen()

		--[[
		scale = 2
		loadFonts()
		menu_load()
		love.audio.setVolume(0)
		--]]
	end
	
	firstLoad = true
	--setFullscreen(true)
	
end

function defaultData()
	soundOn = true
	musicOn = true
	fullscrn = false
	highscore = 0
	controls = {"d", "a", "w", "space", "lshift"}
	
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

function saveLoadSettings(load)
	if load then
		if not love.filesystem.isFile("save.txt") then
			highscores = {}
			for k = 1, 5 do
				highscores[k] = {rank = k, name = "????", score = "????"}
			end
		else
			highscores = json:decode(love.filesystem.read("save.txt"))
			firstLoad = false
		end
	else
		love.filesystem.write("save.txt", json:encode_pretty(highscores))
	end
end

function love.update(dt)
	dt = math.min(0.1666667, dt)
	
	if _G[state .. "_update"] then
		_G[state .. "_update"](dt)
	end

	if gyroController then
		gyroController:update(dt)
	end
end

function love.draw()
	if _G[state .. "_draw"] then
		_G[state .. "_draw"]()
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

function love.textinput(t)
	if _G[state .. "_textinput"] then
		_G[state .. "_textinput"](t)
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
		if love.filesystem.isDirectory(f[k]) and f[k] ~= "mobile" then
			requireFiles(f[k] .. "/")
		else
			if f[k]:sub(-4) == ".lua" then
				if f[k] ~= "json.lua" then
					require(path .. f[k]:gsub(".lua", ""))
				end
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
	
	if mobileMode then
		touchControls = newTouchControl()
		touchControls:init()
	else
		scale = 1
		love.window.setMode(600, 300, {fullscreen = false})
	end

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
