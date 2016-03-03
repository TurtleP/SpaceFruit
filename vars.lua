fruit_colors = 
{
	{255, 0, 0},
	{0, 255, 0},
	{87, 0, 127},
	{53, 122, 42},
	{255, 255, 0},
	{196, 0, 0},
	{196, 0, 0},
	{255, 255, 0},
	{255, 106, 0}
}

function colorfade(currenttime, maxtime, c1, c2) --Color function
	local tp = currenttime/maxtime
	local ret = {} --return color

	for i = 1, #c1 do
		ret[i] = c1[i]+(c2[i]-c1[i])*tp
		ret[i] = math.max(ret[i], 0)
		ret[i] = math.min(ret[i], 255)
	end

	return ret
end

function love.graphics.roundrectangle(mode, x, y, w, h, rd, s)
	local l = love.graphics.getLineWidth() or 1
	if mode == "fill" then l = 0 end --the line width doesn't matter if we're not using it :P
	
	local w, h = w+l, h+l
	local r, g, b, a = love.graphics.getColor()
	local rd = rd or math.max(w, h)/4
	local s = s or 32
	
	local corner = 1
	local function mystencil()
		if corner == 1 then
			return x-l, y-l, rd+l, rd+l
		elseif corner == 2 then
			return x+w-rd+l, y-l, rd+l, rd+l
		elseif corner == 3 then
			return x-l, y+h-rd+l, rd+l, rd+l
		elseif corner == 4 then
			return x+w-rd+l, y+h-rd+l, rd+l, rd+l
		elseif corner == 5 then
			return x+rd, y-l, w-2*rd+l, h+2*l
		elseif corner == 6 then
			return x-l, y+rd, w+2*l, h-2*rd+l
		end
	end

	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.circle(mode, x+rd, y+rd, rd, s)
	love.graphics.setScissor()
	corner = 2
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.circle(mode, x+w-rd, y+rd, rd, s)
	love.graphics.setScissor()
	corner = 3
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.circle(mode, x+rd, y+h-rd, rd, s)
	love.graphics.setScissor()
	corner = 4
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.circle(mode, x+w-rd, y+h-rd, rd, s)
	love.graphics.setScissor()
	corner = 5
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.rectangle(mode, x, y, w, h)
	love.graphics.setScissor()
	corner = 6
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.rectangle(mode, x, y, w, h)
	love.graphics.setScissor()
end

function toggleSound(blnOn)
	soundOn = not soundOn

	local f = soundfiles

	for k = 1, #f do
		if type(_G[f[k]]) ~= "table" then
			if soundOn then
				_G[f[k]]:setVolume(1)
			else
				_G[f[k]]:setVolume(0)
			end
		else
			print(f[k])
			for j = 1, #_G[f[k]] do
				if soundOn then
					_G[f[k]][j]:setVolume(1)
				else
					_G[f[k]][j]:setVolume(1)
				end
			end
		end
	end
end

function toggleMusic()
	musicOn = not musicOn

	local m = musicfiles

	for k = 1, #m do
		if musicOn then
			_G[m[k]]:setVolume(1)
		else
			_G[m[k]]:setVolume(0)
		end		
	end
end

credits =
{
	"Programmers:",
	" ",
	"Jeremy Postelnek",
	"Connor Power",
	"Nick Roache",
	"Steve Wade",
	" ",
	"Graphics:",
	"Steve Wade",
	" ",
	"Music:",
	"Steve Wade",
	" ",
	"Beta Testing:",
	"Nick Roache",
	"Jeremy Postelnek",
	"Steve Wade",
	"Connor Power",
	" ",
	" ",
	"A HackRU 2015 Game",
	"This version has been bug fixed for public use.",
	"Some features have also been added."
}