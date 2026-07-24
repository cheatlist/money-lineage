function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("WraithHelm")then
		return true
	end
	if Parent:FindFirstChild("FusedHelm1")then
		return true
	end
	if Parent:FindFirstChild("FusedHelm2")then
		return true
	end
	if Parent:FindFirstChild("Baima")then
		return true
	end
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
local model = game.ReplicatedStorage.Assets.Outfits.Bucket:Clone()
local canuse = true
local equipped = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	for i,v in pairs(p1.Boosts:GetChildren()) do
		if v.Name == "HealthBoost" then
			if v:FindFirstChild("Type") then
				if v:FindFirstChild("Type").Value ~= "Helmet" then return end 
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
	wait(0.25)
	if equipped then
		local v1 = Instance.new("NumberValue")
		v1.Name = "HealthBoost"
		v1.Value = (p1.Humanoid.MaxHealth*0.25)/100
		v1.Parent = p1.Boosts
		local v2 = Instance.new("StringValue")
		v2.Name = "Buff"
		v2.Value = "Sigil Helmet"
		v2.Parent = v1
		local v3 = Instance.new("StringValue")
		v3.Name = "Type"
		v3.Value = "Helmet"
		v3.Parent = v1
		for _,v in pairs(p1:GetChildren())do
			if v:IsA("Accessory")then
				if v:FindFirstChild("Handle")then
					v.Handle.Transparency = 1
				end
			end
		end
		model.Parent = p1
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
	end
	wait(0.75)
	canuse = true
end)