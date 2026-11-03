local InputHandler = {
	keys = {
		[hash("w")] = false,
		[hash("a")] = false,
		[hash("s")] = false,
		[hash("d")] = false,
		[hash("lshift")] = false
	},
	mouse = {
		x = nil,
		y = nil
	}
}

function InputHandler:on_input(action_id, action)
	if action.x and action.y then
		self.mouse.x = action.x
		self.mouse.y = action.y
		return
	end
	
	if self.keys[action_id] == nil then return end
	if action.pressed then
		self.keys[action_id] = true
	elseif action.released then
		self.keys[action_id] = false
	end
end

return InputHandler