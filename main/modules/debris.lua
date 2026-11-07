local Debris = {
	fragments = {},
	rows = 4,
	columns = 4,
	lifetime = 3,
	min_speed = 4,
	max_speed = 6
}

local Renderer = require("main.modules.render")

function Debris:spawn(entity, source_entity)
	local width = entity.dimensions.width
	local height = entity.dimensions.height

	local fragment_width = width / self.columns
	local fragment_height = height / self.rows

	local cos = math.cos(entity.rotation)
	local sin = math.sin(entity.rotation)

	local dx, dy = 0, 0
	local impact_x, impact_y = 0, 0

	if source_entity then
		dx = source_entity.pos.x - source_entity.pos.previous.x
		dy = source_entity.pos.y - source_entity.pos.previous.y

		local length = math.sqrt(dx * dx + dy * dy)

		if length > 0 then
			dx, dy = dx / length, dy / length
		end

		-- Convert bullet position into target-local coordinates
		local rel_x = source_entity.pos.x - entity.pos.x
		local rel_y = source_entity.pos.y - entity.pos.y

		impact_x = rel_x * cos + rel_y * sin
		impact_y = -rel_x * sin + rel_y * cos

		-- Convert bullet direction into target-local coordinates
		local local_dx = dx * cos + dy * sin
		local local_dy = -dx * sin + dy * cos

		dx, dy = local_dx, local_dy
	end

	-- Perpendicular to bullet direction
	local px, py = -dy, dx

	-- World-space perpendicular for fragment movement
	local world_px = -dy * cos - dx * sin
	local world_py = -dy * sin + dx * cos

	for row = 1, self.rows do
		for column = 1, self.columns do
			local local_x = (column - 0.5) * fragment_width - width / 2
			local local_y = (row - 0.5) * fragment_height - height / 2

			local x = entity.pos.x + local_x * cos - local_y * sin
			local y = entity.pos.y + local_x * sin + local_y * cos

			-- Measure fragment position relative to bullet impact
			local side = (local_x - impact_x) * px
			+ (local_y - impact_y) * py

			local direction = side >= 0 and 1 or -1
			local speed = math.random(self.min_speed, self.max_speed)

			table.insert(self.fragments, {
				pos = {x = x, y = y},
				velocity = {
					x = world_px * direction * speed,
					y = world_py * direction * speed
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

		local fade_start = self.lifetime * 0.75

		if fragment.lifetime > fade_start then
			fragment.colour[4] = fragment.alpha
		else
			fragment.colour[4] = fragment.alpha * (fragment.lifetime / fade_start)
		end

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