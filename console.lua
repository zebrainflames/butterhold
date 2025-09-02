--[[
-- This file implements a bunch of utility functions for drawing and printing to a console visible on screen.
-- This is primarily used for debug purposes.
--
-- Copied from Kikito's bump.lua library
--]]

local shouldDrawDebug = false

function draw_message()
	local msg = instructions:format(tostring(shouldDrawDebug))
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(msg, 550, 10)
end

local consoleBuffer = {}
local consoleBufferSize = 15
for i = 1, consoleBufferSize do
	consoleBuffer[i] = ""
end
function console_print(msg)
	table.remove(consoleBuffer, 1)
	consoleBuffer[consoleBufferSize] = msg
end

function draw_console()
	local str = table.concat(consoleBuffer, "\n")
	for i = 1, consoleBufferSize do
		love.graphics.setColor(1, 1, 1, i / consoleBufferSize)
		love.graphics.printf(consoleBuffer[i], 10, 580 - (consoleBufferSize - i) * 12, 790, "left")
	end
end

return shouldDrawDebug
