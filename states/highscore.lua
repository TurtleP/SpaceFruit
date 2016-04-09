function highscore_load(fromGame)
	state = "highscore"

	currentScore = 0

	if fromGame then
		for k = 1, 5 do
			local s = highscores[k].score
			if highscores[k].score == "????" then
				s = 0
			end

			if gamescore > s then
				currentScore = k
				break
			end
		end

		if currentScore > 0 then
			highscores[currentScore].name = ""
			highscores[currentScore].score = gamescore
		else
			menu_load()
		end

		if mobileMode then
			love.keyboard.setTextInput(true, 0, (getWindowHeight() * .5 + (currentScore - 1) * 24) * scale, love.graphics.getWidth(), love.graphics.getHeight())
		end
	end

	if firstLoad and currentScore == 0 and not fromGame then
		love.window.showMessageBox(love.window.getTitle(), "You can erase this data with a long tap.", {"OK"})
	end

	highScoreSineWave = 1
	highScoreSineTimer = 0
	dataClearTimer = 0
end

function highscore_update(dt)
	updateTitleScreen(dt)

	highScoreSineTimer = highScoreSineTimer + 0.5 * dt

	highScoreSineWave = math.abs( math.sin( highScoreSineTimer * math.pi ) / 2 ) + 0.5

	if currentScore == 0 then
		if love.mouse.isDown(1) then
			dataClearTimer = dataClearTimer + dt
		else
			dataClearTimer = 0
		end

		if dataClearTimer > 1 then
			local button = love.window.showMessageBox(love.window.getTitle(), "Would you like to delete the save data?", {"Yes", "No"})

			if button == 1 then
				love.filesystem.remove("save.txt")
			end
		end
	end
end

function highscore_draw()
	drawTitleScreen()

	love.graphics.setFont(menubuttonfont)
	for k = 1, #highscores do
		local v = highscores[k].rank .. ". " .. highscores[k].name .. "\t" .. highscores[k].score

		if currentScore == k then
			love.graphics.setColor(255, 255, 255, 255 * highScoreSineWave)
		else
			love.graphics.setColor(255, 255, 255)
		end

		love.graphics.print(v, (getWindowWidth() * .5) * scale - menubuttonfont:getWidth(v) / 2, (getWindowHeight() * .5 + (k - 1) * 24) * scale)
	end
end

function highscore_textinput(t)
	if #highscores[currentScore].name < 4 then
		highscores[currentScore].name = highscores[currentScore].name .. t
	end
end

function highscore_keypressed(key)
	if key == "escape" then
		if currentScore == 0 then
			menu_load()
		end
	end

	if key == "return" then
		if #highscores[currentScore].name > 0 then
			menu_load(true)
		end
	end

	if key == "backspace" then
		highscores[currentScore].name = highscores[currentScore].name:sub(1, -2)
	end
end