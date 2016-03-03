function menu_load(fromGame)

	stars = {}
	starSizes = {}
	for k = 1, 100 do
		stars[k] = {love.math.random(4, getWindowWidth() - 8), love.math.random(4, getWindowHeight() - 8)}
		starSizes[k] = love.math.random(1, 3)
	end
	
	if love.filesystem.exists("data.txt") then
		saveLoadSettings(true, "onlyHigh")
	else
		highscore = 0
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
			newGUI("button", (getWindowWidth() * scale) / 2 - menubuttonfont:getWidth("Start Game") / 2, 140, "Start Game", function() love.audio.stop(mainmenu) game_load() end, {}),
			newGUI("button", (getWindowWidth() * scale) / 2 - menubuttonfont:getWidth("Settings") / 2, 164, "Settings", function() menustate = "settings" end),
			newGUI("button", (getWindowWidth() * scale) / 2 - menubuttonfont:getWidth("Highscores") / 2, 188, "Highscores", function() menustate = "credits" end),
			newGUI("button", (getWindowWidth() * scale) / 2 - menubuttonfont:getWidth("Exit Game") / 2, 212, "Exit Game", function() love.event.quit() end)
		},

		["settings"] = 
		{
			newGUI("button", 4, 4, "MAIN MENU", function() menustate = "main" saveLoadSettings(false) end),
			newGUI("button", (getWindowWidth() * scale) / 2 - menubuttonfont:getWidth("Sounds: " .. tostring(soundOn)) / 2, 140, "Sounds: " .. tostring(soundOn), function() toggleSound() menuGUI["settings"][2]:setText("Sounds: " .. tostring(soundOn)) menuGUI["settings"][2]:center() end),
			newGUI("button", (getWindowWidth() * scale) / 2 - menubuttonfont:getWidth("Music: " .. tostring(musicOn)) / 2, 164, "Music: " .. tostring(musicOn), function() toggleMusic() menuGUI["settings"][3]:setText("Music: " .. tostring(musicOn)) menuGUI["settings"][3]:center() end),
			newGUI("button", (getWindowWidth() * scale) / 2 - menubuttonfont:getWidth("View credits") / 2, 188, "View credits",function() menustate = "credits" end),
			newGUI("button", (getWindowWidth() * scale) / 2 - menubuttonfont:getWidth("Erase Data") / 2, 212, "Erase data", function() saveLoadSettings("del") game_playsound(gameoversnd) end)
		},

		["credits"] =
		{
			newGUI("button", 4, 4, "MAIN MENU", function() menustate = "main" creditsscroll = 0 credits_delay = 3 end),
		}
	}

	setControls = false 
	currentControl = 1

	menuGUI["settings"][1]:setFont(hudfont, false)
	menuGUI["credits"][1]:setFont(hudfont)

	menustate = "main"

	credits_delay = 3
	creditsscroll = 0
end


function menu_update(dt)
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
end

function menu_draw()
	
	love.graphics.setColor(255, 255, 255)
	for k = 1, #starSizes do
		love.graphics.setPointSize(starSizes[k])
	end
	love.graphics.points(stars)

	for k, v in pairs(menuFruit) do
		v:draw()
	end

	if _G["menu_" .. menustate .. "_draw"] then
		_G["menu_" .. menustate .. "_draw"]()
	end

	love.graphics.setColor(93, 96, 160)
	love.graphics.draw(titleimg[1], getWindowWidth() / 2 - titleimg[1]:getWidth() / 2, 32)

	love.graphics.setColor(67, 70, 114)
	love.graphics.draw(titleimg[2], getWindowWidth() / 2 - titleimg[1]:getWidth() / 2, 48)
	
	for k = 1, #fruittitle do
		love.graphics.setColor(unpack(colorfade(titletimer[k], 2, fruit_colors[titleColor1[k]], fruit_colors[titleColor2[k]])))
		love.graphics.draw(fruittitle[k], (getWindowWidth() / 2 - 100) + (k - 1) * 42, 72)
	end
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
