local Renderer = {
	vertices = {}
}

local EntityType = require("main.modules.entity_type")
local ProjectileType = require("main.modules.entity_type")

function Renderer:init(mesh_url)
	self.mesh_url = mesh_url
	self.vertex_resource = go.get(mesh_url, "vertices")
	self.max_vertices = 120 * 6

	self.vertex_buffer = buffer.create(self.max_vertices, {
		{
			name = hash("position"),
			type = buffer.VALUE_TYPE_FLOAT32,
			count = 3
		},
		{
			name = hash("normal"),
			type = buffer.VALUE_TYPE_FLOAT32,
			count = 3
		}
	})
	self.positions = buffer.get_stream(self.vertex_buffer, hash("position"))
	self.normals = buffer.get_stream(self.vertex_buffer, hash("normal"))

	for i = 1, self.max_vertices * 3, 3 do
		self.normals[i] = 0
		self.normals[i + 1] = 0
		self.normals[i + 2] = 1
	end

	resource.set_buffer(self.vertex_resource, self.vertex_buffer)
end

function Renderer:clear()
	self.vertices = {}
end

function Renderer:render_shape(entity, x, y, cos, sin)
	if entity.type == EntityType.PLAYER then
		self:draw_player(x, y, cos, sin)

	elseif entity.type == EntityType.PROJECTILE then
		self:draw_projectile(2, x, y, cos, sin)

	elseif entity.type == EntityType.ENEMY then
		self:draw_enemy(x, y, cos, sin)
	end
end


function Renderer:draw_rectangle(width, height, x, y, cos, sin)
	local half_w = width / 2
	local half_h = height / 2

	local corners = {
		{-half_w, -half_h},
		{ half_w, -half_h},
		{ half_w,  half_h},
		{-half_w,  half_h}
	}

	local indices = {1, 2, 3, 1, 3, 4}

	for _, index in ipairs(indices) do
		local vertex = corners[index]

		local world_x = vertex[1] * cos - vertex[2] * sin + x
		local world_y = vertex[1] * sin + vertex[2] * cos + y

		table.insert(self.vertices, {world_x, world_y, 0})
	end
end

function Renderer:draw_player(x, y, cos, sin)
	self:draw_rectangle(4, 4, x, y, cos, sin)

	local triangle = {
		{3, 0},
		{1.5, 1},
		{1.5, -1}
	}

	for _, vertex in ipairs(triangle) do
		local world_x = vertex[1] * cos - vertex[2] * sin + x
		local world_y = vertex[1] * sin + vertex[2] * cos + y

		table.insert(self.vertices, {world_x, world_y, 0})
	end
end

function Renderer:draw_projectile(projectile_type, x, y, cos, sin)
	if projectile_type == 2 then
		self:draw_rectangle(3, 1, x, y, cos, sin)
	end
end

function Renderer:draw_enemy(x, y, cos, sin)
	-- Enemy shape goes here
	self:draw_rectangle(4, 4, x, y, cos, sin)
end

function Renderer:draw_entity(entity, interpolation)
	local x = entity.pos.previous.x
	+ (entity.pos.x - entity.pos.previous.x) * interpolation

	local y = entity.pos.previous.y
	+ (entity.pos.y - entity.pos.previous.y) * interpolation

	local cos = math.cos(entity.rotation)
	local sin = math.sin(entity.rotation)

	self:render_shape(entity, x, y, cos, sin)
end

function Renderer:flush()
	local vertex_count = #self.vertices

	if vertex_count > self.max_vertices then
		error("Renderer vertex capacity exceeded!")
	end
	
	for i, vertex in ipairs(self.vertices) do
		local offset = (i - 1) * 3

		self.positions[offset + 1] = vertex[1]
		self.positions[offset + 2] = vertex[2]
		self.positions[offset + 3] = vertex[3]
	end

	for i = vertex_count * 3 + 1, self.max_vertices * 3 do
		self.positions[i] = 0
	end

	resource.set_buffer(self.vertex_resource, self.vertex_buffer)
end

return Renderer