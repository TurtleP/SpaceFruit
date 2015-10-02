function menu_load(fromGame)

	for k = 1, 100 do
		stars[k] = newStar(math.random(4, love.graphics.getWidth() / scale - 8), math.random(4, love.graphics.getHeight() / scale - 8), screens[math.random(#screens)])
	end

	--[[if fromGame then
		bgm:stop()
		saveLoadSettings(false)
	end]]

	state = "menu"

	titlewords = {"F", "R", "U", "I", "T"}
	titletimer = {0, 0, 0, 0, 0}

	titleColor1 = {1, 9, 5, 2, 3}
	titleColor2 = {2, 1, 6, 3, 4}

	menuFruit = {}

	menufruitTimer = newRecursionTimer(math.random(2, 4),
		function()
			local posx = {4, getWindowWidth()}
			local posy = {math.random(4, getWindowHeight())}

			table.insert(menuFruit, newFruit(posx[math.random(#posx)], posy[math.random(#posy)], screens[math.random(#screens)]))
		end
	)

	--mainmenu:setLooping(true)
	--mainmenu:play()

	menuGUI = 
	{
		["main"] = 
		{
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Start Game") / 2, 80, "Start Game", function() game_load() end, {}),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Credits") / 2, 108, "Credits", function() menustate = "credits" end),
			newGUI("button", getWindowWidth() / 2 - menubuttonfont:getWidth("Exit Game") / 2, 136, "Exit Game", function() love.event.quit() end)
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

	creditsscroll = 0
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
		creditsscroll = math.min(creditsscroll + 26 * dt, 240 + hudfont:getHeight(credits[#credits]) * 16)
	end
end

function menu_draw()

	for k, v in ipairs(stars) do
		v:draw()
	end

	for k, v in pairs(menuFruit) do
		v:draw()
	end

	love.graphics.setScreen("bottom")

	if _G["menu_" .. menustate .. "_draw"] then
		_G["menu_" .. menustate .. "_draw"]()
	end

	if menuGUI[menustate] then
		
		for i, v in pairs(menuGUI[menustate]) do
			v:draw()
		end
		
	end

	love.graphics.setScreen("top")

	love.graphics.setColor(93, 96, 160)
	love.graphics.draw(titleimg[1], love.graphics.getWidth() / 2 - titleimg[1]:getWidth() / 2, 48)

	love.graphics.setColor(67, 70, 114)
	love.graphics.draw(titleimg[2], love.graphics.getWidth() / 2 - titleimg[1]:getWidth() / 2, 64)
	
	for k = 1, #titlewords do
		love.graphics.setColor(unpack(colorfade(titletimer[k], 2, fruit_colors[titleColor1[k]], fruit_colors[titleColor2[k]])))
		love.graphics.draw(fruittitle[k], (love.graphics.getWidth() / 2 - 100) + (k - 1) * 42, 96)
	end
		
end

function menu_main_draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(hudfont)
	love.graphics.print(versionstring, 1, getWindowHeight() - hudfont:getHeight(versionstring))
end

function menu_credits_draw()
	--love.graphics.setScissor(0, 120 * scale, getWindowWidth() * scale, getWindowHeight() * scale - 120 * scale)

	love.graphics.setFont(hudfont)
	for k = 1, #credits do
		love.graphics.setScreen("bottom")

		love.graphics.print(credits[k], getWindowWidth() / 2 - hudfont:getWidth(credits[k]) / 2, (240 + (k - 1) * 16) - creditsscroll)
	end

	--love.graphics.setScissor()
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
	end
end