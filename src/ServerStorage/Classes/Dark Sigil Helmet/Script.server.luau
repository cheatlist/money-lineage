function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"FusedHelm2","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local model = game.ServerStorage.Assets.WraithHelm:Clone()
local canuse = true
local equipped = false
local interaction = nil
script.Parent.Use.OnServerEvent:Connect(function(player, use)
	if use == 1 then
		if interaction ~= nil and interaction ~= "1" then return end
		local p1 = script.Parent.Parent
		for i,v in pairs(p1.Boosts:GetChildren()) do
			if v.Name == "HealthBoost" then
				if v:FindFirstChild("Type") then
					if v:FindFirstChild("Type").Value ~= "Wraith Knight Helmet" then return end 
				end
			end
		end
		if ActionCheck(p1)then
			return
		end
		if not canuse then
			return
		end
		canuse = false
		interaction = "1"
		local p2 = game.Players:GetPlayerFromCharacter(p1)
		local HumanoidRootPart = p1.HumanoidRootPart
		local animation
		if not equipped then
			animation = p1.Humanoid:LoadAnimation(script.Parent.Anim1)
			equipped = true
		else
			animation = p1.Humanoid:LoadAnimation(script.Parent.Anim2)
			equipped = false
		end
		animation:Play()
		if equipped then
			local v1 = Instance.new("NumberValue")
			v1.Name = "HealthBoost"
			v1.Value = p1.Humanoid.MaxHealth*0.5/100
			v1.Parent = p1.Boosts
			local v2 = Instance.new("StringValue")
			v2.Name = "Buff"
			v2.Value = "Sigil Helmet"
			v2.Parent = v1
			local v3 = Instance.new("StringValue")
			v3.Name = "Type"
			v3.Value = "Wraith Knight Helmet"
			v3.Parent = v1
			if p1.Name ~= "VexedToast" then 
				for _,v in pairs(p1:GetChildren())do
					if v:IsA("Accessory") and v.Name ~= "HowlerMane" then
						if v:FindFirstChild("Handle")then
							v.Handle.Transparency = 1
						end
					end
				end
				model.Parent = p1
			end
		else
			for _,v in pairs(p1.Boosts:GetChildren())do
				if v:FindFirstChild("Buff")and v.Buff.Value == "Sigil Helmet"then
					v:Destroy()
				end
			end
			for _,v in pairs(p1:GetChildren())do
				if v:IsA("Accessory")then
					if v:FindFirstChild("Handle")then
						v.Handle.Transparency = 0
					end
				end
			end
			model.Parent = nil
			interaction = nil
		end
		task.wait(0.25)
		task.wait(0.75)
		canuse = true
	else
		if interaction ~= nil and interaction ~= "2" then return end
		local p1 = script.Parent.Parent
		for i,v in pairs(p1.Boosts:GetChildren()) do
			if v.Name == "HealthBoost" then
				if v:FindFirstChild("Type") then
					if v:FindFirstChild("Type").Value ~= "Wraith Knight Helmet" then return end 
				end
			end
		end
		if ActionCheck(p1)then
			return
		end
		if not canuse then
			return
		end
		canuse = false
		interaction = "2"
		local p2 = game.Players:GetPlayerFromCharacter(p1)
		local HumanoidRootPart = p1.HumanoidRootPart
		local animation
		if not equipped then
			animation = p1.Humanoid:LoadAnimation(script.Parent.Anim1)
			equipped = true
		else
			animation = p1.Humanoid:LoadAnimation(script.Parent.Anim2)
			equipped = false
		end
		animation:Play()
		if equipped then
			local v1 = Instance.new("NumberValue")
			v1.Name = "HealthBoost"
			v1.Value = p1.Humanoid.MaxHealth*0.5/100
			v1.Parent = p1.Boosts
			local v2 = Instance.new("StringValue")
			v2.Name = "Buff"
			v2.Value = "Sigil Helmet"
			v2.Parent = v1
			local v3 = Instance.new("StringValue")
			v3.Name = "Type"
			v3.Value = "Wraith Knight Helmet"
			v3.Parent = v1
		else
			for _,v in pairs(p1.Boosts:GetChildren())do
				if v:FindFirstChild("Buff")and v.Buff.Value == "Sigil Helmet"then
					v:Destroy()
				end
			end
			interaction = nil
		end
		task.wait(0.25)
		task.wait(0.75)
		canuse = true
	end
end)