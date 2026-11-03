local Projectile = {}

local Entity = require("main.modules.entity")
local EntityType = require("main.modules.entity_type")
local Camera = require("main.modules.camera")

function Projectile:fire(proj_type, proj_position, proj_velocity, proj_rotation, proj_friction)
	local projectile = Entity:create({
		type = proj_type,
		pos = {
			x = proj_position.x,
			y = proj_position.y
		},
		velocity = {
			x = proj_velocity.x,
			y = proj_velocity.y
		},
		friction = proj_friction,
		rotation = proj_rotation,
	})

	return projectile
end

return Projectile