require 'physics'
require 'vars'

require 'states/menu'
require 'states/game'

require 'classes/gui'
require 'classes/hud'
require 'classes/splat'
require 'classes/timer'

require 'entities/bullet'
require 'entities/fruit'
require 'entities/powerups'
require 'entities/shield'
require 'entities/ship'
require 'entities/star'
require 'entities/timer'

function love.load()
	scale = 1
	fullscrn = false

	--shield charge: line at the bottom of brackets, lshift to activate. It drains slowly over time
	--health regen: every 10 points

	graphics = {}
	audio = {}

	loadFonts()

	loadFonts()

	stars = {}

	versionstring = "version 1.0"

	graphics["grapepiece"] = love.graphics.newImage("graphics/enemies/grape_piece.png")
	graphics["health"] = love.graphics.newImage("graphics/hud/Health.png")

	staticBGs = {love.graphics.newImage("graphics/bg/moon.png"), love.graphics.newImage("graphics/bg/planet.png"), love.graphics.newImage("graphics/bg/sun.png"), love.graphics.newImage("graphics/bg/satalite.png"), 
				love.graphics.newImage("graphics/bg/blackhole.png"), love.graphics.newImage("graphics/bg/astroid_1.png"), love.graphics.newImage("graphics/bg/astroid_2.png"), love.graphics.newImage("graphics/bg/earth.png")}

	bulletimg = love.graphics.newImage("graphics/ship/bullet.png")
	
	titleimg = {love.graphics.newImage("graphics/title/title.png"), love.graphics.newImage("graphics/title/titlebottom.png")}
	
	local chars = {"F", "R", "U", "I", "T"}
	
	fruittitle = {}
	for k = 1, #chars do
		fruittitle[k] = love.graphics.newImage("graphics/title/" .. chars[k] .. ".png")
	end

	shipimg = {}
	shipimg[4] = {love.graphics.newImage("graphics/ship/3ds/normal/1.png"), love.graphics.newImage("graphics/ship/3ds/normal/2.png"), love.graphics.newImage("graphics/ship/3ds/normal/3.png"), love.graphics.newImage("graphics/ship/3ds/normal/4.png")}
	shipimg[3] = {love.graphics.newImage("graphics/ship/3ds/hurt1/1.png"), love.graphics.newImage("graphics/ship/3ds/hurt1/2.png"), love.graphics.newImage("graphics/ship/3ds/hurt1/3.png"), love.graphics.newImage("graphics/ship/3ds/hurt1/4.png")}
	shipimg[2] = {love.graphics.newImage("graphics/ship/3ds/hurt2/1.png"), love.graphics.newImage("graphics/ship/3ds/hurt2/2.png"), love.graphics.newImage("graphics/ship/3ds/hurt2/3.png"), love.graphics.newImage("graphics/ship/3ds/hurt2/4.png")}
	shipimg[1] = {love.graphics.newImage("graphics/ship/3ds/hurt3/1.png"), love.graphics.newImage("graphics/ship/3ds/hurt3/2.png"), love.graphics.newImage("graphics/ship/3ds/hurt3/3.png"), love.graphics.newImage("graphics/ship/3ds/hurt3/4.png")}
	
	fruitimg = {}
	for k = 1, 9 do
		fruitimg[k] = love.graphics.newImage("graphics/enemies/3ds/fruit" .. k .. ".png")
	end

	splatimg = {}
	for k = 1, 5 do
		splatimg[k] = love.graphics.newImage("graphics/enemies/3ds/splat" .. k .. ".png")
	end

	--[[bgm = love.audio.newSource("sound/bgm.ogg", "stream")
	bgm:setLooping(true)

	item = love.audio.newSource("sound/item.ogg")

	gameoversnd = love.audio.newSource("sound/gameover.ogg")

	damage = {love.audio.newSource("sound/explosion_1.ogg"), love.audio.newSource("sound/explosion_2.ogg")}
	shoot = {love.audio.newSource("sound/shoot_1.ogg"), love.audio.newSource("sound/shoot_2.ogg")}
	fruitboom = {love.audio.newSource("sound/fruit_explode_1.ogg"), love.audio.newSource("sound/fruit_explode_2.ogg"), love.audio.newSource("sound/fruit_explode_3.ogg")}
	
	mainmenu = love.audio.newSource("sound/title.ogg", "stream")]]

	highscore = 0
	
	love.window.setMode(400, 480)
	screens = {"top", "bottom"}
	controltypes = {"circle pad", "circle pad up + L/R"}
	controli = 1
	
	menu_load()
end

function saveLoadSettings(save)
	gamescore = 0

	local filepath = "sdmc:/3ds/LovePotion/save.txt"

	if save then
		local file = io.open(filepath, "w")
		
		if file then
			file:write(highscore)
			file:flush()
			file:close()
		end
	else
		local file = io.open(filepath, "r")

		if file then
			highscore = file:read("*n")
			
			file:close()
		end
	end
end

--[[function loadQuads()
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

	graphics["splat"] = love.graphics.newImage("graphics/enemies/explosion_quad.png")
	quads["splat"] = {}
	for k = 1, 6 do
		quads["splat"][k] = love.graphics.newQuad((k-1)*24, 0, 22, 22, graphics["splat"]:getWidth(), graphics["splat"]:getHeight())
	end
end]]

function love.update(dt)
	dt = math.min(0.1666667, dt)

	if _G[state .. "_update"] then
		_G[state .. "_update"](dt)
	end
end

function love.draw()
	--love.graphics.scale(scale, scale)

	if _G[state .. "_draw"] then
		_G[state .. "_draw"]()
	end
end

function getWindowWidth()
	return love.graphics.getWidth()
end

function getWindowHeight()
	return love.graphics.getHeight()
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

function loadFonts()
	hudfont = love.graphics.newFont("graphics/ARCADE_N.TTF", 8)
	mediumfont = love.graphics.newFont("graphics/ARCADE_N.TTF", 12)
	menubuttonfont = love.graphics.newFont("graphics/ARCADE_N.TTF", 20)
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
