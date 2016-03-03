function newTimer(delay, func)
	local timer = {}

	timer.delay = delay
	timer.func = func
	timer.enabled = true

	function timer:update(dt)
		self.delay = self.delay - dt

		if self.delay < 0 then
			self.func()
		end
	end

	return timer
end

function newRecursionTimer(delay, func)
	local rTimer = {}

	rTimer.start = delay
	rTimer.delay = delay
	rTimer.func = func

	function rTimer:update(dt)

		self.delay = self.delay - dt
		if self.delay < 0 then
			if self.func then
				self.func()
			end
			self.delay = self.start
		end
	end

	return rTimer
end