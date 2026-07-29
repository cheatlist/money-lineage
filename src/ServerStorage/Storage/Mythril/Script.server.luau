script.Parent.Handle.Touched:Connect(function(hit)
	if hit:IsDescendantOf(workspace.Seats) and hit.Name == "Furnace" then
		require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(script.Parent.Parent, script.Parent.Name)
		hit.Smoke:Emit(70)
		require(game.ServerScriptService.Modules.Commands).AddToInventory(script.Parent.Parent, script.Parent.Name.." Bar")
		if game.ServerStorage.PlayerData[script.Parent.Parent.Name].Skills.Value:find("DoubleBars") then
			require(game.ServerScriptService.Modules.Commands).AddToInventory(script.Parent.Parent, script.Parent.Name.." Bar")
		end
	end
end)