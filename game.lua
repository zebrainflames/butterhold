local game = { tick = 0, totaltime = 0 }

function game:update(dt)
	self.totaltime = self.totaltime + dt
	self.tick = self.tick + 1
end

function game:draw()
	love.graphics.print("This comes from game on tick " .. self.tick)
end

return game
