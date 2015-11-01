function menu_load(fromGame)
	state = "menu"

	if bgm:isPlaying() then
		bgm:stop()
	end

	for k = 1, 100 do
		stars[k] = newStar(screens[math.random(#screens)])
	end

	if fromGame then
		saveLoadSettings(true)
	end
	
	--hahaha load
	saveLoadSettings()
	
	controls = {"rbutton", "lbutton", "cpadup", "a", "b"}

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
			newGUI("button", 160 - menubuttonfont:getWidth("Start Game") / 2, 80, "Start Game", function() game_load() end, {}),
			newGUI("button", 160 - menubuttonfont:getWidth("Credits") / 2, 108, "Credits", function() menustate = "credits" end),
			newGUI("button", 160 - menubuttonfont:getWidth("Exit Game") / 2, 136, "Exit Game", function() love.event.quit() end)
		},

		["credits"] =
		{
			newGUI("button", 4, 4, "MAIN MENU", function() menustate = "main" creditsscroll = 0 credits_delay = 3 end),
		}
	}

	menuGUI["credits"][1]:setFont(hudfont)

	menustate = "main"

	creditsscroll = 0
end

function menu_update(dt)
	menufruitTimer:update(dt)

	for k = 1, #titletimer do

		if dt > 0 then
			titletimer[k] = titletimer[k] + dt
		end

		if titletimer[k] > 2 then
			local tmpColors = {unpack(titleColor1)}
			local tmpColors2 = {unpack(titleColor2)}

			for k = 1, #titleColor1 do
				local temp = tmpColors2[k]

				titleColor1[k] = temp
			end

			for k = 1, #titleColor2 do
				local temp = tmpColors[k]

				titleColor2[k] = temp
			end

			titletimer[k] = 0
		end
	end

	for k, v in pairs(menuFruit) do
		v:update(dt)
	end	

	if menustate == "credits" then
		creditsscroll = math.min(creditsscroll + 26 * dt, (120 - hudfont:getHeight(credits[#credits]) / 2) * 16)
	end

	for k = #menuFruit, 1, -1 do
		if menuFruit[k].remove then
			table.remove(menuFruit, k)
		end
	end

	if not mainmenu:isPlaying() then
		mainmenu:play()
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

	love.graphics.setDepth(30 / 40)

	love.graphics.setColor(93, 96, 160)
	love.graphics.draw(titleimg[1], love.graphics.getWidth() / 2 - titleimg[1]:getWidth() / 2, 48)

	love.graphics.setColor(67, 70, 114)
	love.graphics.draw(titleimg[2], love.graphics.getWidth() / 2 - titleimg[1]:getWidth() / 2, 64)
	
	for k = 1, #fruittitle do
		love.graphics.setColor(unpack(colorfade(titletimer[k], 2, fruit_colors[titleColor1[k]], fruit_colors[titleColor2[k]])))
		love.graphics.draw(fruittitle[k], (love.graphics.getWidth() / 2 - 100) + (k - 1) * 42, 96)
	end

	love.graphics.setDepth(0)
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
