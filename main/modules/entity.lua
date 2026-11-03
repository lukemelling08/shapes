local Entity = {
	active = {},
	vip = {
		player = nil
	},
	next_id = 1
}
local Renderer = require("main.modules.render")
local InputHandler = require("main.modules.input_handler")
local Camera = require("main.modules.camera")
local EntityType = require("main.modules.entity_type")

function Entity:new()
	local entity = {
		id = Entity.next_id,
		pos = {
			-- current x and y
			x = 0,
			y = 0,
			previous = {
				x = 0,
				y = 0
			}
		},
		velocity = {
			x = 0,
			y = 0,
		},
		acceleration = {
			speed = 500,
			x = 0,
			y = 0
		},
		speed = {
			base = 25,
			max = 45
		},
		friction = 200,
		rotation = 0,
		type = nil
	}

	function entity:register()
		Entity.active[self.id] = self
	end
	
	function entity:unregister()
		Entity.active[self.id] = nil
	end

	function entity:render()
		Renderer:draw_entity(self, 0.05)
	end

	function entity:set_pos(x, y)
		self.pos.x = x
		self.pos.y = y
	end

	function entity:get_pos()
		return self.pos.x, self.pos.y
	end

	function entity:face(x, y)
		local dx = x - self.pos.x
		local dy = y - self.pos.y
		self.rotation = math.atan2(dy, dx)
	end


	function entity:update_pos(dt)
		if self == Entity.vip.player then
			if InputHandler.mouse.x ~= nil and InputHandler.mouse.y ~= nil then
				local mouse_pos = Camera:screen_to_world(InputHandler.mouse.x, InputHandler.mouse.y)
				self:face(mouse_pos.x, mouse_pos.y)
			end
			
			local speed = self.acceleration.speed
			if (not InputHandler.keys[hash("a")] and not InputHandler.keys[hash("d")])
			or (InputHandler.keys[hash("a")] and InputHandler.keys[hash("d")]) then
				self.acceleration.x = 0
			else
				if InputHandler.keys[hash("a")] then
					self.acceleration.x = -speed
				elseif InputHandler.keys[hash("d")] then
					self.acceleration.x = speed
				end
			end

			if (not InputHandler.keys[hash("w")] and not InputHandler.keys[hash("s")])
			or (InputHandler.keys[hash("w")] and InputHandler.keys[hash("s")]) then
				self.acceleration.y = 0
			else
				if InputHandler.keys[hash("w")] then
					self.acceleration.y = speed
				elseif InputHandler.keys[hash("s")] then
					self.acceleration.y = -speed
				end
			end
		end

		for _, axis in ipairs({"x", "y"}) do
			local velocity = self.velocity[axis]
			local acceleration = self.acceleration[axis]

			velocity = velocity + acceleration * dt

			if velocity > 0 then
				velocity = math.max(0, velocity - self.friction * dt)
			elseif velocity < 0 then
				velocity = math.min(0, velocity + self.friction * dt)
			end

			self.velocity[axis] = velocity
			self.pos[axis] = self.pos[axis] + velocity * dt
		end

		local magnitude = math.sqrt(
			self.velocity.x^2 + self.velocity.y^2
		)

		local sprinting = InputHandler.keys[hash("lshift")]
		local max_speed = sprinting and self.speed.max or self.speed.base

		if magnitude > max_speed then
			local scale = max_speed / magnitude
			self.velocity.x = self.velocity.x * scale
			self.velocity.y = self.velocity.y * scale
		end
	end

	Entity.next_id = Entity.next_id + 1
	return entity
end

function Entity:create(data)
	data = data or {}
	local entity = self:new()
	if data.pos and data.pos.x and data.pos.y then
		entity:set_pos(data.pos.x, data.pos.y)
	end
	if data.type then
		entity.type = data.type
	end
	if data.velocity then
		if data.velocity.x then
			entity.velocity.x = data.velocity.x
		end
		if data.velocity.y then
			entity.velocity.y = data.velocity.y
		end
	end
	if data.friction then
		entity.friction = data.friction
	end
	if data.rotation then
		entity.rotation = data.rotation
	end
	entity:register()
	return entity
end

return Entity