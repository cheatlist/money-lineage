local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local HasTag = CollectionService.HasTag
local function ActionCheck(Parent)
	if not(Parent:FindFirstChild("Immortal"))then
		return
	end
	return true
end
local canuse: boolean = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if p1.Humanoid.Health>0 then
		if data.Lives.Value-1>0 and p1:FindFirstChild("Unconscious") then
			canuse = false
			task.delay(4, function()
				canuse = true
			end)
			data.Lives.Value-=1
			p1.Humanoid.PlatformStand = false
			p1.Humanoid.AutoRotate = true
			
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
			for _,v in pairs(p1:GetChildren())do
				if v.Name == "Knocked"or v.Name == "Unconscious"or v.Name == "Action"or v.Name == "NoDam"or v.Name == "FreezeRoot"then
					v:Destroy()
				end
			end
			local cantgetragdolled = p1.ChildAdded:Connect(function(v)
				if v.Name == "Knocked"or v.Name == "Unconscious"or v.Name == "Action"or v.Name == "NoDam"or v.Name == "FreezeRoot"then
					task.wait()
					v:Destroy()
				end
			end)
			task.delay(2, function()
				cantgetragdolled:Disconnect()
			end)
			
			p1.HumanoidRootPart.Cameo:Emit(75)
			p1.HumanoidRootPart.CameoGetUp:Play()
			p1.Humanoid.Health += p1.Humanoid.MaxHealth
			p1.HumanoidRootPart.LightningHit:Play()
		end
	end
end)