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
local Debris = require("main.modules.debris")

function Entity:new(data)
	data = data or {}

	local function default(value, fallback)
		if value == nil then
			return fallback
		end
		return value
	end

	local class = data.class or {}

	local entity = {
		id = Entity.next_id,

		pos = {
			x = data.pos and data.pos.x or 0,
			y = data.pos and data.pos.y or 0,
			previous = {
				x = data.pos and data.pos.x or 0,
				y = data.pos and data.pos.y or 0
			}
		},

		velocity = default(data.velocity, {x = 0, y = 0}),
		acceleration = default(data.acceleration, class.acceleration or {
			speed = 500,
			x = 0,
			y = 0
		}),
		speed = default(data.speed, class.speed or {
			base = 25,
			max = 45
		}),
		dimensions = default(data.dimensions, class.dimensions or {
			height = 8,
			width = 8
		}),
		colour = default(data.colour, class.colour or {1, 1, 1, 1}),
		friction = default(data.friction, class.friction or 200),
		rotation = default(data.rotation, 0),
		type = default(data.type, class.type),
		class = class,
		owner = data.owner
	}

	function entity:register()
		Entity.active[self.id] = self
	end
	
	function entity:unregister()
		Entity.active[self.id] = nil
	end

	function entity:render()
		Renderer:create_shape(self.dimensions.width, self.dimensions.height, self.pos.x, self.pos.y, self.rotation + math.pi/2, self.colour)
	end

	function entity:set_pos(x, y)
		self.pos.x = x
		self.pos.y = y
	end

	function entity:get_pos()
		return self.pos.x, self.pos.y
	end

	function entity:on_collision(other)
		if self.owner == other or other.owner == self then return end
		print("Entity", self.id, "collided with entity", other.id)

		if self.type == EntityType.PROJECTILE or other.type == EntityType.PROJECTILE then
			-- projectile collision event
			local isSelfProjectile = self.type == EntityType.PROJECTILE
			local isOtherProjectile = other.type == EntityType.PROJECTILE

			if isSelfProjectile and isOtherProjectile then
				self:damage()()
				other:damage()
			end
			if isSelfProjectile and not isOtherProjectile then
				self:remove()
				other:damage()
			elseif not isSelfProjectile and isOtherProjectile then
				other:remove()
				self:damage()
			end
		end
	end

	function entity:damage()
		self:kill()
	end

	function entity:kill()
		Debris:spawn(self)
		self:remove()
	end

	function entity:remove()
		self:unregister()
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

	entity:register()
	Entity.next_id = Entity.next_id + 1
	return entity
end

return Entity