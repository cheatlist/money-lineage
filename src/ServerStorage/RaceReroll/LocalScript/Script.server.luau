script.Parent.RemoteEvent.OnServerEvent:Connect(function(p)
	if p~=script.Parent.Parent.Parent.Parent then
		return
	end
	if script.Parent.Parent.HouseName.Value~=""then
		local pdata = game:GetService("ServerStorage").PlayerData
		local PlayerData = pdata:FindFirstChild(p.Name)
		if PlayerData.Race.Value == "Gaian" then
			PlayerData.Armor.Value = "Rags"
		end
		PlayerData.Race.Value = script.Parent.Parent.HouseName.Value
	end
end)