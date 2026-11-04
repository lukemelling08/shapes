local Collision = {}

local Entity = require("main.modules.entity")

function Collision:check(a, b)
	local dx = math.abs(a.pos.x - b.pos.x)
	local dy = math.abs(a.pos.y - b.pos.y)

	return dx < (a.dimensions.width + b.dimensions.width) / 2
	and dy < (a.dimensions.height + b.dimensions.height) / 2
end

function Collision:update()
	local entities = {}

	for _, entity in pairs(Entity.active) do
		table.insert(entities, entity)
	end

	for i = 1, #entities - 1 do
		for j = i + 1, #entities do
			local a = entities[i]
			local b = entities[j]

			if self:check(a, b) then
				a:on_collision(b)
			end
		end
	end
end
return Collision