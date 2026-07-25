function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local HasTag = CollectionService.HasTag
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if not canuse then
		return
	end
	if p1:FindFirstChild("ResGlobalCD") then
		return
	end
	if game.ServerStorage.PlayerData[p1.Name].GalvExcept.Value == game.ServerStorage.PlayerData[p1.Name].DaysSurvived.Value then
		return
	end
	if p1.Cooldowns:FindFirstChild("Galvanize") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Galvanize"
	CD.Value = 600
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 600)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if p1.Toxicity.Value+600>=1000 then
		canuse = true
		return
	end
	for i,v in pairs(workspace.Live:GetChildren()) do
		if v:FindFirstChild("Grabbing") and v.Grabbing.Value == p1 then
			require(game.ServerScriptService.Modules.Commands).CarryDrop(v)
			for _,v in pairs(p1:GetChildren())do
				if v.Name == "Knocked"or v.Name == "Unconscious"or v.Name == "Action"or v.Name == "NoDam"or v.Name == "FreezeRoot" then
					v:Destroy()
				end
			end
		end
	end
	game.ServerStorage.PlayerData[p1.Name].LastRessed.Value = game.ServerStorage.PlayerData[p1.Name].DaysSurvived.Value
	local Galvanized = Instance.new("Accessory")
	Galvanized.Name = "UsingGalv"
	Galvanized.Parent = p1
	game.Debris:AddItem(Galvanized, 1)
	local particle = script.Parent.galv:Clone()
	particle.Parent = p1.HumanoidRootPart
	for i = 1,3 do
		if p1 and p1.Parent then
			particle:Emit(20)
			p1.HumanoidRootPart.LightningHit.PlaybackSpeed = 2
			p1.HumanoidRootPart.LightningHit:Play()
			wait(0.5)
		else
			canuse = true
			return
		end
	end

	for _,v in pairs(workspace.Live:getChildren())do
		if v ~= p1 and v:FindFirstChild("HumanoidRootPart")then
			if (p1.HumanoidRootPart.Position-v.HumanoidRootPart.Position).Magnitude<11 then
				game.ServerStorage.Requests.TagHumanoid:Fire(v,v,{mana = true,manaknockupself = true})
			end
		end
	end
	wait()
	if HasTag(CollectionService,p1,"BeingExecuted")then
		CollectionService:RemoveTag(p1,"BeingExecuted")
	end
	task.spawn(function()
		for i = 1,20 do
	for _,v in pairs(p1:GetChildren())do
		if v.Name == "Knocked"or v.Name == "Unconscious"or v.Name == "Action"or v.Name == "NoDam"or v.Name == "FreezeRoot" then
			v:Destroy()
		end
			end
			task.wait(0.1)
			end
	end)
	
	particle:Emit(25)
	p1.Humanoid.Health += p1.Humanoid.MaxHealth*0.5
	p1.HumanoidRootPart.LightningHit.PlaybackSpeed = 1.25
	p1.HumanoidRootPart.LightningHit:Play()
	p1.Toxicity.Value += 600
	
	local NoPots = Instance.new("Accessory")
	NoPots.Name = "NoPotions"
	NoPots.Parent = p2.Character
	
	game.Debris:AddItem(NoPots, 60)
	
	local v3 = Instance.new("Accessory")
	v3.Name = "ResGlobalCD"
	v3.Parent = p1
	game.Debris:AddItem(v3,300)
	
	wait(600)
	canuse = true
end)