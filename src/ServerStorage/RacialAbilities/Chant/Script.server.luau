local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
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
		return true
	end
	return false
end
local canuse = true

local chants = {"Phase","Twilight","Eyes of Wisdom","Pillar of Light","Paramita","Nine Ropes","Polarized Light","Scale of the Dragon","Recoil","Twin Meteors","Pair of Meteors","Open","Weave the Mind","Through Gaia to Khei","From Khei to Gaia","Kai"}
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	if p1.Cooldowns:FindFirstChild("Chant") then
		return
	end
	if p1:FindFirstChild("SignChant") then
		return
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	local ascended = data and data.Ascended.Value == true and data.Race.Value == "Castellan"
	local cooldown = 15
	
	task.spawn(function()
		local hi = Instance.new("Highlight",p1)
		game.Debris:AddItem(hi,1)
		hi.Adornee = p1
		hi.FillColor = Color3.new(1, 1, 1)
		hi.OutlineColor = Color3.new(1, 1, 1)
		hi.FillTransparency = 0.3
		hi.OutlineTransparency = 0.3
		TweenService:Create(hi,TweenInfo.new(1),{
			FillTransparency = 1,
			OutlineTransparency = 1,
		}):Play()
		game:GetService("Chat"):Chat(p1.Head,chants[math.random(1,#chants)])
	end)

	local CD = Instance.new("NumberValue")
	CD.Name = "Chant"
	CD.Value = cooldown
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, cooldown)
	canuse = false
	task.delay(cooldown,function()
		canuse = true
	end)
	p1.HumanoidRootPart.Chant:Play()
	local v1 = Instance.new("NumberValue")
	v1.Name = "SignChant"
	v1.Parent = p1
	task.delay(60, function()
		if v1.Parent then
			v1.Parent = nil
			wait(1)
			v1:Destroy()
		end
	end)
	v1:GetPropertyChangedSignal("Parent"):Wait()
	if p1:IsDescendantOf(workspace)and p1:FindFirstChild'HumanoidRootPart'then
		p1.HumanoidRootPart.Chant:Play()
	end
end)