local InputHandler = {
	keys = {
		[hash("w")] = false,
		[hash("a")] = false,
		[hash("s")] = false,
		[hash("d")] = false
	}
}

function InputHandler:on_input(action_id, action)
	if self.keys[action_id] == nil then return end
	if action.pressed then
		self.keys[action_id] = true
	elseif action.released then
		self.keys[action_id] = false
	end
end

return InputHandler