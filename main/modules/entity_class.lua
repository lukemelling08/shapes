local EntityType = require("main.modules.entity_type")

local EntityClass = {
	
	PLAYER = {
		acceleration = {
			speed = 500,
			x = 0,
			y = 0
		},
		speed = {
			base = 25,
			max = 45
		},
		dimensions = {
			height = 8,
			width = 8
		},
		colour = {1, 1, 1, 1},
		friction = 200,
		type = EntityType.PLAYER
	},

	BULLET = {
		speed = {
			base = 600,
			max = 0
		},
		dimensions = {
			width = 2,
			height = 14
		},
		colour = {1, 0.6, 0.6, 1},
		friction = 0,
		type = EntityType.PROJECTILE
	}
}

return EntityClass