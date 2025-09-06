Player = {}
Player.__index = Player

local EPSILON = 0.1

function Player.new(x, y, w, h)
	local self = setmetatable({}, Player)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.vx = 0.0
	self.vy = 0.0
	self.is_grounded = false
	self.name = "plr"

	-- # mechanics
	self.max_speed = 1500
	self.acceleration = 800
	self.friction = 2400 -- friction and some other parameters should at some point be set by terrain type
	self.air_acceleration = 500
	self.air_drag = 200
	self.gravity = 2000
	self.jump_impulse = 650
	self.is_grounded = false

	-- Timers
	self.coyote_timer = 0
	self.coyote_time = 0.1
	self.jump_buffer_timer = 0
	self.jump_buffer_time = 0.1

	-- debug
	self.debug_state = "idle"
	--print("Player created...")
	return self
end

-- TODO: move to Entity or shared procedure
function Player:update_velocity_on_collision(nx, ny, bounciness)
	bounciness = bounciness or 0.0
	local vx, vy = self.vx, self.vy
	--print("Got vx, vy: (" .. vx .. ", " .. vy .. ").")
	if (nx < 0 and vx > 0) or (nx > 0 and vx < 0) then
		vx = -vx * bounciness
	end

	if (ny < 0 and vy > 0) or (ny > 0 and vy < 0) then
		vy = -vy * bounciness
	end

	self.vx, self.vy = vx, vy
end

-- TODO: move to math module
local sign = function(dir)
	if dir < 0.0 then
		return -1.0
	elseif dir > 0.0 then
		return 1.0
	end
	return 0.0
end

-- TODO: iterate on exact logic & numbers used before push!
function Player:update(dt, world)
	self.debug_state = "idle"
	local was_grounded = self.is_grounded
	self.is_grounded = false

	self.coyote_timer = self.coyote_timer - dt
	self.jump_buffer_timer = self.jump_buffer_timer - dt

	local move_direction = 0
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		self.debug_state = "move_right"
		move_direction = 1
	elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
		self.debug_state = "move_left"
		move_direction = -1
	end

	if love.keyboard.isDown("space") or love.keyboard.isDown("w") then
		self.debug_state = self.debug_state .. "_jumping"
		self.jump_buffer_timer = self.jump_buffer_time
	end

	local acc, fric
	if was_grounded then
		acc = self.acceleration
		fric = self.friction
	else
		acc = self.air_acceleration
		fric = self.air_drag
	end

	self.vx = self.vx + acc * move_direction * dt
	self.vx = math.max(-self.max_speed, math.min(self.max_speed, self.vx))

	if sign(move_direction) ~= sign(self.vx) then
		self.debug_state = self.debug_state .. "_braking"
		local fric_dir = sign(self.vx) * -1.0
		local f = fric_dir * fric * dt
		if math.abs(f) + EPSILON >= math.abs(self.vx) then
			self.vx = 0.0
		else
			self.vx = self.vx + f
		end
	end

	self.vy = self.vy + self.gravity * dt

	if self.coyote_timer > 0 and self.jump_buffer_timer > 0 then
		self.vy = -self.jump_impulse
		self.jump_buffer_timer = 0 -- Consume the buffered jump
		self.coyote_timer = 0 -- Coyote jump has been used
		print("Jumped!")
	end

	local target_x = self.x + self.vx * dt
	local target_y = self.y + self.vy * dt
	local next_x, next_y, cols, cols_len = world:move(self, target_x, target_y)

	for i = 1, cols_len do
		local col = cols[i]

		-- general collision velocity response...
		self:update_velocity_on_collision(col.normal.x, col.normal.y)

		--... and ground hit check
		if col.normal.y < 0 then
			self.is_grounded = true
			self.coyote_timer = self.coyote_time
			self.debug_state = self.debug_state .. "_grounded"
		end
	end
	self.x, self.y = next_x, next_y
end

return Player
