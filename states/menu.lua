function menu_load(fromGame)

	for k = 1, 100 do
		stars[k] = newStar(love.math.random(4, love.window.getWidth() / scale - 8), love.math.random(4, love.window.getHeight() / scale - 8))
	end

	if fromGame then
		bgm:stop()
		saveLoadSettings(false)
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

	menuGUI = 
	{
		["main"] = 
		{
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Start Game") / 2, 160, "Start Game", function() love.audio.stop(mainmenu) game_load() end, {}),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Settings") / 2, 190, "Settings", function() menustate = "settings" end),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Credits") / 2, 220, "Credits", function() menustate = "credits" end),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Exit Game") / 2, 250, "Exit Game", function() love.event.quit() end)
		},

		["settings"] = 
		{
			newGUI("button", 4, 4, "MAIN MENU", function() menustate = "main" saveLoadSettings(false) end),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Sounds: " .. tostring(soundOn)) / 2, 140, "Sounds: " .. tostring(soundOn), function() toggleSound() menuGUI["settings"][2]:setText("Sounds: " .. tostring(soundOn)) menuGUI["settings"][2]:center() end),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Music: " .. tostring(musicOn)) / 2, 170, "Music: " .. tostring(musicOn), function() toggleMusic() menuGUI["settings"][3]:setText("Music: " .. tostring(musicOn)) menuGUI["settings"][3]:center() end),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Toggle Fullscreen") / 2, 200, "Toggle Fullscreen", function() setFullscreen() end),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Rebind Controls") / 2, 230, "Rebind Controls", function() if game_joystick then return end setControls = true end),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Erase Data") / 2, 260, "Erase data", function() saveLoadSettings("del") game_playsound(gameoversnd) end)
		},

		["credits"] =
		{
			newGUI("button", 4, 4, "MAIN MENU", function() menustate = "main" creditsscroll = 0 credits_delay = 3 end),
		}
	}

	setControls = false 
	currentControl = 1

	for k = 2, #menuGUI["settings"] do
		menuGUI["settings"][k]:setFont(mediumfont)
		menuGUI["settings"][k]:center()
	end

	menuGUI["settings"][1]:setFont(hudfont, false)
	menuGUI["credits"][1]:setFont(hudfont)

	menustate = "main"

	settings_boxX = getWindowWidth() / 2 - 175
	settings_boxY = 140
	settings_boxW = 350
	settings_boxH = 140
	settings_box_timer = 0

	credits_delay = 3
	creditsscroll = 0

	controlCycle = {"Turn Right", "Turn Left", "Thrust", "Shoot", "Shield"}

	gamepadDelayDown = false
	gamepadDelay = 0.6
end


function menu_update(dt)
	for k, v in ipairs(stars) do
		v:update(dt)
	end

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

	if menustate == "credits" then
		if credits_delay > 0 then
			credits_delay = math.max(credits_delay - dt, 0)
		else
			creditsscroll = math.min(creditsscroll + 26 * dt, 120 + hudfont:getHeight(credits[#credits]) * 16)
		end
	end

	if gamepadDelayDown then
		gamepadDelay = math.max(0, gamepadDelay - dt)
	end
end

function menu_draw()

	for k, v in ipairs(stars) do
		v:draw()
	end

	for k, v in pairs(menuFruit) do
		v:draw()
	end

	if _G["menu_" .. menustate .. "_draw"] then
		_G["menu_" .. menustate .. "_draw"]()
	end

	if menuGUI[menustate] then
		for i, v in pairs(menuGUI[menustate]) do
			v:draw()
		end
	end

	love.graphics.setFont(title)

	love.graphics.setStencil(function() love.graphics.rectangle("fill", getWindowWidth() / 2 - title:getWidth("SPACE") / 2, 40, title:getWidth("SPACE"), title:getHeight("SPACE") / 2) end )
	love.graphics.setColor(93, 96, 160)
	love.graphics.print("SPACE", getWindowWidth() / 2 - title:getWidth("SPACE") / 2, 40)
	love.graphics.setStencil()

	love.graphics.setStencil(function() love.graphics.rectangle("fill", getWindowWidth() / 2 - title:getWidth("SPACE") / 2, 40 + title:getHeight("SPACE") / 2, title:getWidth("SPACE"), title:getHeight("SPACE") / 2) end )
	love.graphics.setColor(67, 70, 114)
	love.graphics.print("SPACE", getWindowWidth() / 2 - title:getWidth("SPACE") / 2, 40)
	love.graphics.setStencil()

	love.graphics.setFont(titleHuge)
	for k = 1, #titlewords do
		love.graphics.setColor(colorfade(titletimer[k], 2, fruit_colors[titleColor1[k]], fruit_colors[titleColor2[k]]))
		love.graphics.print(titlewords[k], getWindowWidth() / 2 - titleHuge:getWidth("FRUIT") / 2 + (k - 1) * 40, 70)
	end

	if setControls then
		love.graphics.setColor(0, 0, 0, 120)
		love.graphics.rectangle("fill", 0, 0, getWindowWidth() * scale, getWindowHeight() * scale)

		love.graphics.setFont(mediumfont)

		local key = controls[currentControl]
		local newkey = ""
		if key == " " then
			newkey = "Spacebar"
		end

		love.graphics.setColor(32, 32, 32)
		love.graphics.rectangle("fill", getWindowWidth() / 2 - mediumfont:getWidth("Press a key for: " .. controlCycle[currentControl]) / 2, getWindowHeight() / 2 - mediumfont:getHeight("Press a key for: " .. controlCycle[currentControl]) / 2, mediumfont:getWidth("Press a key for: " .. controlCycle[currentControl]), mediumfont:getHeight("Press a key for: " .. controlCycle[currentControl]))
		love.graphics.rectangle("fill", getWindowWidth() / 2 - mediumfont:getWidth("Current Bind: " .. newkey) / 2, getWindowHeight() / 2 - mediumfont:getHeight("Current Bind: " .. newkey) / 2 + 16, mediumfont:getWidth("Current Bind: " .. newkey), mediumfont:getHeight("Current Bind: " .. key))

		love.graphics.setColor(255, 255, 255)

		

		love.graphics.print("Press a key for: " .. controlCycle[currentControl], getWindowWidth() / 2 - mediumfont:getWidth("Press a key for: " .. controlCycle[currentControl]) / 2, getWindowHeight() / 2 - mediumfont:getHeight("Press a key for: " .. controlCycle[currentControl]) / 2)
		love.graphics.print("Current Bind: " .. newkey, getWindowWidth() / 2 - mediumfont:getWidth("Current Bind: " .. newkey) / 2, getWindowHeight() / 2 - mediumfont:getHeight("Current Bind: " .. newkey) / 2 + 16)
	end
end

function menu_main_draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(hudfont)
	love.graphics.print(versionstring, 1, getWindowHeight() - hudfont:getHeight(versionstring))
end

function menu_credits_draw()
	love.graphics.setScissor(0, 120 * scale, getWindowWidth() * scale, getWindowHeight() * scale - 120 * scale)

	local currFont = love.graphics.getFont()

	love.graphics.setFont(hudfont)
	for k = 1, #credits do
		love.graphics.print(credits[k], getWindowWidth() / 2 - hudfont:getWidth(credits[k]) / 2, (120 + (k - 1) * 16) - creditsscroll)
	end

	love.graphics.setFont(currFont)

	love.graphics.setScissor()
end

function menu_mousepressed(x, y, button)
	if menuGUI[menustate] then
		for i, v in pairs(menuGUI[menustate]) do
			v:mousepressed(x, y, button)
		end
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