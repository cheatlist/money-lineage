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
	WorkoutModule.toggleExercise(script.Parent, character, data, "Pushups")
end)
