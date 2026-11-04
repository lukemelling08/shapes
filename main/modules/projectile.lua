local Projectile = {}

local Entity = require("main.modules.entity")
local EntityType = require("main.modules.entity_type")
local EntityClass = require("main.modules.entity_class")
local Camera = require("main.modules.camera")

function Projectile:fire(entity_class, proj_owner, proj_position, proj_rotation)
	local projectile = Entity:new({
		class = entity_class,
		pos = {
			x = proj_position.x,
			y = proj_position.y
		},
		owner = proj_owner,
		velocity = {
			x = math.cos(proj_rotation) * entity_class.speed.base,
			y = math.sin(proj_rotation) * entity_class.speed.base
		},
		rotation = proj_rotation
	})

	return projectile
end

return Projectile