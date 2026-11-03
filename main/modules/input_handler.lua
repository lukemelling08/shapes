local InputHandler = {
	keys = {
		[hash("w")] = false,
		[hash("a")] = false,
		[hash("s")] = false,
		[hash("d")] = false,
		[hash("lshift")] = false,
		[hash("lmb")] = false
	},
	mouse = {
		x = nil,
		y = nil
	}
}

local Camera = require("main.modules.camera")

function InputHandler:on_input(action_id, action)
	if self.keys[action_id] ~= nil then
		if action.pressed then
			self.keys[action_id] = true
		elseif action.released then
			self.keys[action_id] = false
		end
	end
	
	if action.screen_x and action.screen_y then
		self.mouse.x = action.screen_x
		self.mouse.y = action.screen_y
		return
	end
end

return InputHandler