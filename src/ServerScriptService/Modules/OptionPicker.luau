-- Generic "show the player N labeled choices, get one back" prompt, modeled directly on the
-- existing Gate/GateLocationRequest RemoteFunction pattern (ServerStorage/Classes/Gate/Activator.luau).
local Requests = game.ReplicatedStorage:WaitForChild("Requests")

local function ensureRemote(name)
	local existing = Requests:FindFirstChild(name)
	if existing then
		return existing
	end
	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = Requests
	return remote
end

local OptionPickerRequest = ensureRemote("OptionPickerRequest")

local OptionPicker = {}

-- options: {{key=string, label=string}, ...}
-- Returns the chosen key string, or nil on cancel/timeout/disconnect.
function OptionPicker.prompt(player, title, options, timeoutSeconds)
	local result
	local ok = pcall(function()
		result = OptionPickerRequest:InvokeClient(player, {
			title = title,
			options = options,
			timeout = timeoutSeconds or 10,
		})
	end)
	if not ok or typeof(result) ~= "table" or typeof(result.key) ~= "string" then
		return nil
	end
	return result.key
end

return OptionPicker
