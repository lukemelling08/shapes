local EntityType = {
	PLAYER = 1,
	PROJECTILE = 2,
	ENEMY = 3,
	SUBTYPE = {
		PLAYER = 1,
		PROJECTILE = {
			BULLET = 2
		},
		ENEMY = 3
	}
}

return EntityType