local Entity = {
	active = {},
	next_id = 1
}
local Renderer = require("main.modules.render")

function Entity:new()
	local entity = {
		id = Entity.next_id,
		x = 0,
		y = 0,
		rotation = 0,
		v_x = 0,
		v_y = 0
	}

	function entity:register()
		Entity.active[self.id] = self
	end
	
	function entity:unregister()
		Entity.active[self.id] = nil
	end

	function entity:render()
		Renderer:draw_entity(self)
	end

	function entity:set_pos(x, y)
		self.x = x
		self.y = y
	end

	function entity:get_pos()
		return self.x, self.y
	end


	function entity:update_pos(dt)
		self.x = self.x + (self.v_x*dt)
		self.y = self.y + (self.v_y*dt)
	end

	Entity.next_id = Entity.next_id + 1
	return entity
end

function Entity:create(pos)
	local entity = self:new()
	entity:set_pos(pos[1], pos[2])
	entity:register()
	return entity
end

return Entity