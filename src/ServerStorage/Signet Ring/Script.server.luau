script.Parent.RemoteEvent.OnServerEvent:Connect(function(p,target)
	if p.Character ~= script.Parent.Parent then
		return
	end
	local data = game.ServerStorage.PlayerData:WaitForChild(p.Name)
	if target~=nil and data.HouseRank.Value == "Owner"and data.LastName.Value~=""then
		local t = target.Parent:FindFirstChild("HumanoidRootPart") and target.Parent
		if not t then
			return
		end
		if t:FindFirstChild("InviteCD")then
			return
		end
		local tplr = game.Players:GetPlayerFromCharacter(t)
		local tdata = game.ServerStorage.PlayerData:FindFirstChild(tplr.Name)
		if t and tplr and tdata and tdata.LastName.Value == ""then
			local gui = game.ServerStorage.HouseInvite:Clone()
			gui.Parent = tplr.PlayerGui
			gui.HouseName.Value = data.LastName.Value
			game.Debris:AddItem(gui,5)
			local cd = Instance.new("Accessory")
			cd.Name = "InviteCD"
			cd.Parent = t
			game.Debris:AddItem(cd,6)
		elseif t and tplr and tdata and tdata.LastName.Value == data.LastName.Value then
			game.ServerStorage.Requests.LeaveHouse:Invoke(tplr)
		end
	end
end)