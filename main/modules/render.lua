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

function Renderer:draw_entity(entity, interpolation)
	local half = 2

	local lerp_x = entity.pos.previous.x
	+ (entity.pos.x - entity.pos.previous.x) * interpolation

	local lerp_y = entity.pos.previous.y
	+ (entity.pos.y - entity.pos.previous.y) * interpolation

	local cos = math.cos(entity.rotation)
	local sin = math.sin(entity.rotation)

	local corners = {
		{-half, -half},
		{ half, -half},
		{ half,  half},
		{-half,  half}
	}

	local transformed = {}

	for _, corner in ipairs(corners) do
		local x = corner[1]
		local y = corner[2]

		local world_x = x * cos - y * sin + lerp_x
		local world_y = x * sin + y * cos + lerp_y

		table.insert(transformed, {world_x, world_y, 0})
	end

	local indices = {1, 2, 3, 1, 3, 4}

	for _, index in ipairs(indices) do
		table.insert(self.vertices, transformed[index])
	end

	-- Direction indicator
	local triangle = {
		{3, 0},
		{1.5, 1},
		{1.5, -1}
	}

	for _, vertex in ipairs(triangle) do
		local x = vertex[1]
		local y = vertex[2]

		local world_x = x * cos - y * sin + lerp_x
		local world_y = x * sin + y * cos + lerp_y

		table.insert(self.vertices, {world_x, world_y, 0})
	end
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