local module = {}

module.isCalm = function(Character)
	return Character:FindFirstChild("CalmMind")and true or false
end

module.hasParticles = function(Character)
	return Character:FindFirstChild("Particles")and true or false
end

module.isEvil = function(Character)
	local player = game.Players:GetPlayerFromCharacter(Character)
	return player.Backpack:FindFirstChild("EvilCounter") and true or false
end

local a1 = game.ReplicatedStorage.CombatAnims.KatanaUnsheathe
local a2 = game.ReplicatedStorage.CombatAnims.KatanaUnsheatheTurn
module.glint = function(Character)
	local Folder = Instance.new("Accessory")
	Folder.Name = "HeavyAttack"
	Folder.Parent = Character
	game.Debris:AddItem(Folder,0.3)
	local Humanoid = Character.Humanoid
	Humanoid:LoadAnimation(a1):Play()
	Humanoid:LoadAnimation(a2):Play()
	local Katana = Character.Hilt:FindFirstChild("Katana")
	if Katana then
		Katana.Attachment1.Sparkle:Emit(3)
	end
end

module.slash = function(enemy)
	local root = enemy.HumanoidRootPart
	local v31 = script.SlashLine:clone()
	v31.CFrame = CFrame.new(root.Position + Vector3.new(math.random(-10, 10) / 10, math.random(-10, 10) / 10, math.random(-10, 10) / 10))
	v31.Parent = workspace.Thrown
	game.Debris:AddItem(v31,0.5)
	game.TweenService:Create(v31,TweenInfo.new(0.25),{
		Transparency = 1
	}):Play()
	game.TweenService:Create(v31.Mesh,TweenInfo.new(0.25),{
		Scale = Vector3.new(1, 1, 5)
	}):Play()
end
module.cleaveslash = function(enemy)
	local root = enemy.HumanoidRootPart
	local v31 = script.SlashLine:clone()
	v31.CFrame = CFrame.new(root.Position + Vector3.new(math.random(-10, 10) / 10, math.random(-10, 10) / 10, math.random(-10, 10) / 10))
	v31.Parent = workspace.Thrown
	game.Debris:AddItem(v31,0.5)
	game.TweenService:Create(v31,TweenInfo.new(0.25),{
		Transparency = 1
	}):Play()
	game.TweenService:Create(v31.Mesh,TweenInfo.new(0.25),{
		Scale = Vector3.new(1, 1, 5)
	}):Play()
end

module.disspear = function(Character)
	local Cubic = Enum.EasingStyle.Cubic
	local Linear = Enum.EasingStyle.Linear
	local Quad = Enum.EasingStyle.Quad

	local InOut = Enum.EasingDirection.InOut
	local In = Enum.EasingDirection.In
	local Out = Enum.EasingDirection.Out
	
	local LeftArm = Character["Left Arm"]
	local RightArm = Character["Right Arm"]
	local Torso = Character.Torso
	local Head = Character.Head
	local LeftLeg = Character["Left Leg"]
	local RightLeg = Character["Right Leg"]
	
	local function Tween(Object, Time, Customization, EasingStyle, EasingDirection)
		local tweenInfo = TweenInfo.new(
			Time,
			EasingStyle,
			EasingDirection
		)

		game:GetService("TweenService"):Create(Object, tweenInfo, Customization):Play()
	end
	
	local Highlight = Instance.new("Highlight")
	game.Debris:AddItem(Highlight, 2)
	Highlight.Name = "DisspearHighlight"
	Highlight.OutlineColor = Color3.fromRGB(0, 85, 127)
	
	Highlight.OutlineTransparency = 0
	
	Tween(Highlight, 1, {OutlineTransparency = 1}, Quad, InOut)
	Tween(LeftArm, 1, {Transparency = 1}, Quad, InOut)
	Tween(RightArm, 1, {Transparency = 1}, Quad, InOut)	
	Tween(Head, 1, {Transparency = 1}, Quad, InOut)
	Tween(Torso, 1, {Transparency = 1}, Quad, InOut)
	Tween(LeftLeg, 1, {Transparency = 1}, Quad, InOut)
	Tween(RightLeg, 1, {Transparency = 1}, Quad, InOut)
end

module.appear = function(Character)
	local Cubic = Enum.EasingStyle.Cubic
	local Linear = Enum.EasingStyle.Linear
	local Quad = Enum.EasingStyle.Quad

	local InOut = Enum.EasingDirection.InOut
	local In = Enum.EasingDirection.In
	local Out = Enum.EasingDirection.Out

	local LeftArm = Character["Left Arm"]
	local RightArm = Character["Right Arm"]
	local Torso = Character.Torso
	local Head = Character.Head
	local LeftLeg = Character["Left Leg"]
	local RightLeg = Character["Right Leg"]

	local function Tween(Object, Time, Customization, EasingStyle, EasingDirection)
		local tweenInfo = TweenInfo.new(
			Time,
			EasingStyle,
			EasingDirection
		)

		game:GetService("TweenService"):Create(Object, tweenInfo, Customization):Play()
	end
	
	local Highlight = Character:FindFirstChild("DisspearHighlight")
	
	if Highlight then
		Tween(Highlight, 1, {OutlineTransparency = 0}, Quad, InOut)
	else
	end
	Tween(LeftArm, 1, {Transparency = 0}, Quad, InOut)
	Tween(RightArm, 1, {Transparency = 0}, Quad, InOut)	
	Tween(Head, 1, {Transparency = 0}, Quad, InOut)
	Tween(Torso, 1, {Transparency = 0}, Quad, InOut)
	Tween(LeftLeg, 1, {Transparency = 0}, Quad, InOut)
	Tween(RightLeg, 1, {Transparency = 0}, Quad, InOut)
end

module.Impact = function(p12, typeOf)
	local v12 = nil;
	if typeOf == "Backhand" then
		v12 = game.ReplicatedStorage.ChaoticRoninAssets.BackhandImpact:Clone();
	elseif typeOf == "Ring2" then
		v12 = game.ReplicatedStorage.ChaoticRoninAssets.Impact2:Clone();
	end;
	v12.Parent = workspace.Thrown;
	game:GetService("Debris"):AddItem(v12, 0.5);
	v12.Size = Vector3.new(0, 0, 0);
	if typeOf == "Ring2" then
		v12.Transparency = 0;
	else
		v12.Transparency = 0.5;
	end;
	v12.CFrame = p12.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(math.rad(90), 0, 0);
	game.TweenService:Create(v12, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(12, 0.05, 12), 
		Transparency = 1, 
		CFrame = p12.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(math.rad(90), math.rad(math.random(-180, 180)), 0)
	}):Play();
	local v13 = p12.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(math.rad(90), 0, 0);
	for v14 = 1, math.random(8, 15) do
		local v15 = Instance.new("Part", game.Debris);
		v15.Anchored = true;
		v15.CanCollide = false;
		v15.Material = Enum.Material.Neon;
		v15.Color = Color3.fromRGB(29, 29, 29);
		local v16 = math.random(-50, 50) / 10;
		local v17 = math.random(-50, 50) / 10;
		v15.Transparency = 0.5;
		v15.CFrame = v13 * CFrame.new(v16, 0, v17);
		v15.Size = Vector3.new(0.1, 0.1, 0.1);
		v15.Parent = game.Workspace.Thrown;
		local v18 = math.random(25, 50) / 100;
		game.TweenService:Create(v15, TweenInfo.new(v18), {
			Transparency = 1, 
			CFrame = v13 * CFrame.new(v16, math.random(-15, -8), v17), 
			Size = Vector3.new(0.05, math.random(5, 9), 0.05)
		}):Play();
		game.Debris:AddItem(v15, v18);
	end;
end

module.ActionCheck = function(Parent)
	if Parent:FindFirstChild("EquipCD")then
		return true
	end
	if Parent:FindFirstChild("Stun")then
		return true
	end
	if Parent:FindFirstChild("NoDam")then
		return true
	end
	if Parent:FindFirstChild("ReturnStun")then
		return true
	end
	if Parent:FindFirstChild("Action")then
		return true
	end
	if Parent:FindFirstChild("Blocking")then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking")then
		return true
	end
	if Parent:FindFirstChild("ActiveCast")then
		return true
	end
	if Parent:FindFirstChild("Unconscious")then
		return true
	end
	if Parent:FindFirstChild("Knocked")then
		return true
	end
	if Parent.Humanoid.Health<5 then
		return true
	end
	if Parent:FindFirstChild("Immortal")then
	else
		return
	end
	return true
end

return module