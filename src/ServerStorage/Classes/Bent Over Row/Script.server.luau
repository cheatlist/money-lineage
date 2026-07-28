local WorkoutModule = require(game.ServerScriptService.Modules.WorkoutModule)

script.Parent.Activated:Connect(function()
	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(player.Name)
	if not data then
		return
	end
	-- Requires Weights: gated on the server-truth PlayerData.WeightsOwned flag (set by
	-- ServerStorage/Storage/Weights/Script.server.luau on pickup), not a Backpack presence
	-- check, per this session's spoofable-check security fix.
	WorkoutModule.toggleExercise(script.Parent, character, data, "Bent Over Row", true)
end)
