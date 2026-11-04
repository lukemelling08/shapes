local Renderer = {
	vertices = {}
}

local EntityType = require("main.modules.entity_type")
local ProjectileType = require("main.modules.projectile_type")

function Renderer:init(mesh_url)
	self.mesh_url = mesh_url
	self.vertex_resource = go.get(mesh_url, "vertices")
	self.max_vertices = 4096 * 6

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
		},
		{
			name = hash("color"),
			type = buffer.VALUE_TYPE_FLOAT32,
			count = 4
		}
	})
	self.positions = buffer.get_stream(self.vertex_buffer, hash("position"))
	self.normals = buffer.get_stream(self.vertex_buffer, hash("normal"))
	self.colors = buffer.get_stream(self.vertex_buffer, hash("color"))

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

function Renderer:create_shape(width, height, x, y, rotation, colour)
	local half_w = width / 2
	local half_h = height / 2

	local cos = math.cos(rotation)
	local sin = math.sin(rotation)

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

		table.insert(self.vertices, {
			position = {world_x, world_y, 0},
			colour = colour
		})
	end
end

function Renderer:flush()
	local vertex_count = #self.vertices

	if vertex_count > self.max_vertices then
		error("Renderer vertex capacity exceeded!")
	end

	for i, vertex in ipairs(self.vertices) do
		local position_offset = (i - 1) * 3
		local colour_offset = (i - 1) * 4

		self.positions[position_offset + 1] = vertex.position[1]
		self.positions[position_offset + 2] = vertex.position[2]
		self.positions[position_offset + 3] = vertex.position[3]

		self.colors[colour_offset + 1] = vertex.colour[1]
		self.colors[colour_offset + 2] = vertex.colour[2]
		self.colors[colour_offset + 3] = vertex.colour[3]
		self.colors[colour_offset + 4] = vertex.colour[4]
	end

	for i = vertex_count * 3 + 1, self.max_vertices * 3 do
		self.positions[i] = 0
	end

	resource.set_buffer(self.vertex_resource, self.vertex_buffer)
end

return Renderer