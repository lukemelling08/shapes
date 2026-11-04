local Debris = {
	fragments = {},
	rows = 4,
	columns = 4,
	lifetime = 6,
	min_speed = 0.5,
	max_speed = 1
}

local Renderer = require("main.modules.render")

function Debris:spawn(entity)
	local width = entity.dimensions.width
	local height = entity.dimensions.height

	local fragment_width = width / self.columns
	local fragment_height = height / self.rows

	local cos = math.cos(entity.rotation)
	local sin = math.sin(entity.rotation)

	for row = 1, self.rows do
		for column = 1, self.columns do
			local local_x = (column - 0.5) * fragment_width - width / 2
			local local_y = (row - 0.5) * fragment_height - height / 2

			local x = entity.pos.x + local_x * cos - local_y * sin
			local y = entity.pos.y + local_x * sin + local_y * cos

			local angle = math.random() * math.pi * 2
			local speed = math.random(self.min_speed, self.max_speed)

			table.insert(self.fragments, {
				pos = {x = x, y = y},
				velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				},
				width = fragment_width,
				height = fragment_height,
				rotation = entity.rotation,
				rotation_speed = math.random(-0.7, 0.7),
				colour = {
					entity.colour[1],
					entity.colour[2],
					entity.colour[3],
					entity.colour[4]
				},
				alpha = entity.colour[4],
				lifetime = self.lifetime
			})
		end
	end
end

function Debris:update(dt)
	for i = #self.fragments, 1, -1 do
		local fragment = self.fragments[i]

		fragment.pos.x = fragment.pos.x + fragment.velocity.x * dt
		fragment.pos.y = fragment.pos.y + fragment.velocity.y * dt

		fragment.rotation = fragment.rotation + fragment.rotation_speed * dt
		fragment.lifetime = fragment.lifetime - dt

		fragment.colour[4] = fragment.alpha * math.max(0, fragment.lifetime / self.lifetime)

		if fragment.lifetime <= 0 then
			table.remove(self.fragments, i)
		end
	end
end

function Debris:render()
	for _, fragment in ipairs(self.fragments) do
		Renderer:create_shape(
			fragment.width,
			fragment.height,
			fragment.pos.x,
			fragment.pos.y,
			fragment.rotation,
			fragment.colour
		)
	end
end

return Debris