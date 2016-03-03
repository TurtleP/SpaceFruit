function newTimer(delay, func)
	local timer = {}

	timer.delay = delay
	timer.func = func

	function timer:update(dt)
		if self.delay > 0 then
			self.delay = self.delay - dt
		elseif self.delay == 0 then
			self.func()
			self.delay = -1
		end
	end

	return timer
end