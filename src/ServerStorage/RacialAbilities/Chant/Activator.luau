local module = {}

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

function module.Active(p5,p6,p7,p8)
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
end

function module.Active2(p5,p6,p7,p8)
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
	local cooldown = 300
	
	p1.Humanoid.Animator:LoadAnimation(script.Handsign):Play(0.1,1,1)
	
	game:GetService("Chat"):Chat(p1.Head,"Domain Expansion")
	task.delay(0.5,function()
		game:GetService("Chat"):Chat(p1.Head,"Chamber of Isolation")
	end)
	
	task.wait(2.5)
	
	task.spawn(function()
		local asset = game.ReplicatedStorage.Assets.Domain:Clone()
		game.Debris:AddItem(asset,130)
		asset.Size = Vector3.new(1,1,1)
		asset.Parent = workspace.Effects
		asset.CFrame = p1.HumanoidRootPart.CFrame
		TweenService:Create(asset,TweenInfo.new(2.5),{
			Size = Vector3.new(100,100,100)
		}):Play()
		for _,enemy in pairs(workspace.Live:GetChildren()) do
			local mag = (p1.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
			if mag <= 100 then
				local hi = Instance.new("Highlight",enemy)
				hi.Adornee = enemy
				hi.FillTransparency = 1
				game.Debris:AddItem(hi,120)
				local v14 = Instance.new("Accessory")
				v14.Name = "Action"
				v14.Parent = enemy
				game.Debris:AddItem(v14,2.5)
				local nogate = Instance.new("Folder",enemy)
				nogate.Name = "NOGATE"
				game.Debris:AddItem(nogate,120)
			end
		end
		task.wait(2.5)
		asset.CanCollide = true
		task.delay(120,function()
			asset.CanCollide = false
			TweenService:Create(asset,TweenInfo.new(2.5),{
				Size = Vector3.new(0.1,0.1,0.1)
			}):Play()
			task.wait(2.5)
			asset:Destroy()
		end)
	end)
end

return module
