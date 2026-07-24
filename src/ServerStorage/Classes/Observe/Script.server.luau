local cool = false
local state = false
local observestate = false
local tweenService = game:GetService("TweenService")

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","NoDam","ReturnStun","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end

script.Parent.Activated:Connect(function()
	local char = script.Parent.Parent
	local data = game.ServerStorage.PlayerData[char.Name]
	if char:FindFirstChild("usecd") then return end
	local usecd = Instance.new("Folder", char) usecd.Name = "usecd" game.Debris:AddItem(usecd, 0.25)
	local player = game.Players:GetPlayerFromCharacter(char)
	local humanoid = char:FindFirstChild("Humanoid")
	local humrp = char:FindFirstChild("HumanoidRootPart")
	if ActionCheck(char) then
		return
	end
	if data.Lives.Value == 0 then
		return
	end
	if not humanoid then
		return
	end
	if not humrp then
		return
	end
	if observestate then
		observestate = false
		char.HumanoidRootPart.Anchored = false
		if char:FindFirstChild("FreezeRoot") then
			char.FreezeRoot:Destroy()
		end
		pcall(function()
			local Mind = char.Head.MindMage
			Mind.Name = "MindMage2"
			Mind.Enabled = false
			workspace.Debris:Fire(Mind, 5)
		end)
		return
	end

	if char.Humanoid.FloorMaterial ~= Enum.Material.Air then
		local ObserveAnim = char.Humanoid:LoadAnimation(script.Meditate)
		ObserveAnim:Play()
		observestate = true
		char.HumanoidRootPart.Anchored = true
		local MindMage = char.HumanoidRootPart.MindMage:Clone()
		MindMage.Parent = char.Head
		MindMage.Enabled = true
		local action = Instance.new("Accessory")
		action.Name = "Action"
		action.Parent = char

		-- Build list of observable players to send to client
		local observablePlayers = {}
		for _, v in pairs(game.Players:GetPlayers()) do
			local Char = v.Character
			if v ~= player 
				and not v:FindFirstChild("MonsterInfo") 
				and Char 
				and Char:FindFirstChild("Head") 
				and not v.Backpack:FindFirstChild("ObserveBlock") 
				and not Char.Boosts:FindFirstChild("ObserveBlock") 
				and not Char:FindFirstChild("in green room") 
			then
				local firstName = game.ServerStorage.PlayerData[v.Name].FirstName.Value
				local lastName = game.ServerStorage.PlayerData[v.Name].LastName.Value
				table.insert(observablePlayers, {
					name = v.Name,
					displayName = firstName .. " " .. lastName
				})
			end
		end

		-- Invoke the client to show the selection UI, yields until they pick or cancel
		local ObserveRequest = game.ReplicatedStorage.Requests.ObserveRequest
		local result = nil
		local invokeSuccess = pcall(function()
			result = ObserveRequest:InvokeClient(player, observablePlayers)
		end)

		local observeplr = nil

		task.spawn(function()
			repeat wait() until not observestate 
				or ActionCheck(char) 
				or script.Parent.Parent ~= char 
			game.ReplicatedStorage.Observe:FireClient(player, nil, true)
			ObserveAnim:Stop()
			action:Destroy()
			ObserveRequest:InvokeClient(player, "DESTROY")
			if observestate then
				observestate = false
				char.HumanoidRootPart.Anchored = false
				MindMage.Name = "MindMage2"
				MindMage.Enabled = false
				game.Debris:AddItem(MindMage, 5)
			end
		end)
	end
end)