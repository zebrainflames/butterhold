Player = {}
Player.__index = Player

local ENTITY_SIZE = 28

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.w = ENTITY_SIZE
    self.h = ENTITY_SIZE
    self.vx = 0.0
    self.vy = 0.0
    self.is_grounded = false
    self.name = "plr"
    return self
end

function Player:update(dt, world)
    local gravity = 9.81 * 10
	local jumpAccel = 2000
	local brakeAccel = 2000
	local runSpeed = 150
	local dragCoeff = 0.9
	-- input handling
	local dx, dy = self.vx, self.vy
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		dx = dx + runSpeed
	elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
		dx = dx - runSpeed
	end
	-- apply braking if needed
	if not love.keyboard.isDown("left") and dx < 0 then
		dx = dx + brakeAccel * dt
		if dx > 0 then
			dx = 0
		end
	end
	if not love.keyboard.isDown("right") and dx > 0 then
		dx = dx - brakeAccel * dt
		if dx < 0 then
			dx = 0
		end
	end

	if (love.keyboard.isDown("space") or love.keyboard.isDown("w")) and self.is_grounded then
		dy = dy - jumpAccel
		self.is_grounded = false
	end

	local jumpFactor = 1.0 -- TODO: this needs a better name
	if (love.keyboard.isDown("space") or love.keyboard.isDown("w")) and not self.is_grounded and dy < 0.0 then
		jumpFactor = 0.2 -- TODO: implement frame or time counter for this
	end
	dy = dy + gravity * jumpFactor

	dx = dx * dragCoeff
	dy = dy * dragCoeff

	self.vx, self.vy = dx, dy
	-- physics update
	local cols
	local cols_len = 0
	self.x, self.y, cols, cols_len = world:move(self, self.x + dx * dt, self.y + dy * dt)
	for i = 1, cols_len do
		local col = cols[i]
		-- Vertical collision:
		if col.normal.y ~= 0 then
			self.is_grounded = true
			self.vy = 0
		end
		-- Horizontal collision
		if col.normal.x ~= 0 then
			self.vx = 0
		end
	end
end

return Player