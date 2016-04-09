function menu_load(fromGame)
	bgm:stop()

	--save
	if fromGame then
		saveLoadSettings()
	end

	--reload
	saveLoadSettings(true)
	
	stars = {}
	starSizes = {}
	for k = 1, 100 do
		stars[k] = {love.math.random(4, getWindowWidth() - 8), love.math.random(4, getWindowHeight() - 8)}
		starSizes[k] = love.math.random(1, 3)
	end

	if mobileMode then
		love.keyboard.setTextInput(false)
	end

	state = "menu"

	titlewords = {"F", "R", "U", "I", "T"}
	titletimer = {0, 0, 0, 0, 0}

	titleColor1 = {1, 9, 5, 2, 3}
	titleColor2 = {2, 1, 6, 3, 4}

	menuFruit = {}

	menufruitTimer = newRecursionTimer(love.math.random(2, 4),
		function()
			local posx = {4, getWindowWidth()}
			local posy = {love.math.random(4, getWindowHeight())}

			table.insert(menuFruit, newFruit(posx[love.math.random(#posx)], posy[love.math.random(#posy)]))
		end
	)

	mainmenu:setLooping(true)
	mainmenu:play()

	titleGUI =
	{
		["main"] =
		{
			{love.graphics.newImage("graphics/title/gui/play.png"), function() love.audio.stop(mainmenu) game_load() end},
			{love.graphics.newImage("graphics/title/gui/highscores.png"), highscore_load},
			{love.graphics.newImage("graphics/title/gui/credits.png"), function() menustate = "credits" end},
			{love.graphics.newImage("graphics/title/gui/quit.png"), love.event.quit}
		},
	}

	creditsBack = {love.graphics.newImage("graphics/title/gui/back.png"), function() menustate = "main" end, pos = {4, 4}}

	menustate = "main"

	credits_delay = 3
	creditsscroll = 0
end


function updateTitleScreen(dt)
	menufruitTimer:update(dt)

	for k, v in pairs(titletimer) do
		titletimer[k] = titletimer[k] + dt

		if titletimer[k] > 2 then
			local tmpColors = {unpack(titleColor1)}
			local tmpColors2 = {unpack(titleColor2)}

			for k, v in pairs(titleColor1) do
				local temp = tmpColors2[k]

				titleColor1[k] = temp
			end

			for k, v in pairs(titleColor2) do
				local temp = tmpColors[k]

				titleColor2[k] = temp
			end

			titletimer[k] = 0
		end
	end

	for k, v in pairs(menuFruit) do
		v:update(dt)
	end	

	for k = #menuFruit, 1, -1 do
		if menuFruit[k].remove then
			table.remove(menuFruit, k)
		end
	end
end

function menu_update(dt)
	updateTitleScreen(dt)

	if menustate == "credits" then
		if credits_delay > 0 then
			credits_delay = math.max(credits_delay - dt, 0)
		else
			creditsscroll = math.min(creditsscroll + 26 * dt, 120 + hudfont:getHeight(credits[#credits]) * 16)
		end
	end
end

function drawTitleScreen()
	love.graphics.setColor(255, 255, 255)
	for k = 1, #starSizes do
		love.graphics.setPointSize(starSizes[k])
		love.graphics.points(stars[k][1] * scale, stars[k][2] * scale)
	end
	

	for k, v in pairs(menuFruit) do
		v:draw()
	end

	love.graphics.draw(titleimg, (getWindowWidth() / 2 - titleimg:getWidth() / 2) * scale, (getWindowHeight() * 0.10) * scale, 0, scale, scale)
	
	for k = 1, #fruittitle do
		love.graphics.setColor(unpack(colorfade(titletimer[k], 2, fruit_colors[titleColor1[k]], fruit_colors[titleColor2[k]])))
		love.graphics.draw(fruittitle[k], (getWindowWidth() / 2 - 100) * scale + (k - 1) * 42 * scale, (getWindowHeight() * 0.25) * scale, 0, scale, scale)
	end
end

function menu_draw()
	drawTitleScreen()
	
	love.graphics.setColor(255, 255, 255)
	if titleGUI[menustate] then
		for k = 1, #titleGUI[menustate] do
			love.graphics.draw(titleGUI[menustate][k][1], (getWindowWidth() / 2 - titleGUI[menustate][k][1]:getWidth() / 2) * scale, (getWindowHeight() * 0.50) * scale + (k - 1) * 28 * scale, 0, scale, scale)
		end
	end

	if menustate == "credits" then
		love.graphics.draw(creditsBack[1], creditsBack.pos[1] * scale, creditsBack.pos[2] * scale, 0, scale, scale)
	end

	if menustate == "credits" then
		love.graphics.setScissor(0, 120 * scale, getWindowWidth() * scale, getWindowHeight() * scale / 2)

		local currFont = love.graphics.getFont()

		love.graphics.setFont(menubuttonfont)
		for k = 1, #credits do
			love.graphics.print(credits[k], (getWindowWidth() * scale) / 2 - menubuttonfont:getWidth(credits[k]) / 2, ((getWindowHeight() * 0.50) + (k - 1) * 24) * scale - creditsscroll * scale)
		end

		love.graphics.setFont(currFont)

		love.graphics.setScissor()
	end

	love.graphics.setFont(hudfont)
	love.graphics.print(versionstring, 1, getWindowHeight() * scale - hudfont:getHeight(versionstring))
end

function menu_mousepressed(x, y, button)
	if titleGUI[menustate] then
		for k, v in pairs(titleGUI[menustate]) do
			if titleGUI[menustate] then
				local checkX, checkY, checkWidth, checkHeight = (getWindowWidth() / 2 - titleGUI[menustate][k][1]:getWidth() / 2) * scale, (getWindowHeight() * 0.50) * scale + (k - 1) * 28 * scale, titleGUI[menustate][k][1]:getWidth() * scale, titleGUI[menustate][k][1]:getHeight() * scale
				if (x > checkX and x < checkX + checkWidth and y > checkY and y < checkY + checkHeight) then
					titleGUI[menustate][k][2]()
				end
			end
		end
	end

	local checkX, checkY, checkWidth, checkHeight = creditsBack.pos[1] * scale, creditsBack.pos[2] * scale, creditsBack[1]:getWidth() * scale, creditsBack[1]:getHeight() * scale
	if (x > checkX and x < checkX + checkWidth and y > checkY and y < checkY + checkHeight) then
		creditsBack[2]()
	end
end

function menu_keypressed(key)
	if setControls and key ~= "escape" then
		menu_setControls("keyboard", key)
	else
		menu_setControls()
	end
end

function menu_setControls(t, value)
	if setControls and value then
		
		if t == "gamepad" then
			if gamepadDelay > 0 then
				gamepadDelayDown = true
				return
			end

			if controlCycle[currentControl] == "Turn Right" or controlCycle[currentControl] == "Turn Left" or controlCycle[currentControl] == "Thrust" then
				if not value:find(":") then
					return
				end
			end
		end

		controls[currentControl] = value

		currentControl = currentControl + 1

		if t == "gamepad" then
			if gamepadDelay == 0 then
				gamepadDelay = 0.6
			end
		end

		if currentControl > #controls then
			print("Stopping!")
			setControls = false
			currentControl = 1
		end
	else
		setControls = false
		currentControl = 1
	end
end
