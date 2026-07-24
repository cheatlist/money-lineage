script.Parent.MouseButton1Down:Connect(function()
	local ss = game:GetService("ServerStorage")
	local pdata = ss.PlayerData:FindFirstChild(script.Parent.Parent.Parent.Parent.Parent.Name.."Global")
	if not pdata.UnlockedRaces.Value:find(script.Parent.Parent.Parent.HouseName.Value) then
		pdata.UnlockedRaces.Value = pdata.UnlockedRaces.Value..script.Parent.Parent.Parent.HouseName.Value..","
	end
	script.Parent.Parent.Parent:Destroy()
end)