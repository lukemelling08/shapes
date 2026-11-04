local Camera = {
	x = 0,
	y = 0,
	zoom = 1.4,
	rotation = 0,
	view_w = 640,
	view_h = 360
}

function Camera:move(x, y)
	self.x = self.x + x
	self.y = self.y + y
end

function Camera:set_pos(x, y)
	self.x = x
	self.y = y
end

function Camera:set_zoom(zoom)
	self.zoom = math.max(0.1, zoom)
end

function Camera:set_rotation(rotation)
	self.rotation = rotation
end

function Camera:screen_to_world(screen_x, screen_y)
	local width, height = window.get_size()

	local x = (screen_x / width) * 2 - 1
	local y = (screen_y / height) * 2 - 1

	return {
		x = self.x + x * width / 2,
		y = self.y + y * height / 2
	}
end

function Camera:update(dt)
	if self.target then
		local lerp = 5 * dt

		self.x = self.x + (self.target.pos.x - self.x) * lerp
		self.y = self.y + (self.target.pos.y - self.y) * lerp
	end
	local width, height = window.get_size()

	self.view_w = self.view_h * (width / height)

	local view_w = self.view_w / self.zoom
	local view_h = self.view_h / self.zoom

	go.set("/renderer#mesh", "cam",
		vmath.vector4(
			self.x,
			self.y,
			2 / view_w,
			2 / view_h
		)
	)
end

function Camera:follow(entity)
	self.target = entity
end

return Camera