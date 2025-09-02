-- File: conf.lua
-- Purpose: Configuration file for the LÖVE engine.

function love.conf(t)
	t.window.title = "LÖVE Jam 2025 (B-Side)" -- The title of the window
	t.window.icon = nil -- Filepath to an image to use as the window's icon
	t.window.width = 1280 -- The width of the window
	t.window.height = 720 -- The height of the window
	t.window.resizable = false -- Let the player resize the window
	--t.window.minwidth = 800 -- Minimum window width if resizing is enabled
	--t.window.minheight = 600 -- Minimum window height if resizing is enabled
	t.window.vsync = true -- Enable vertical synchronization

	-- For more options, see the LÖVE wiki: https://love2d.org/wiki/Config_Files
end