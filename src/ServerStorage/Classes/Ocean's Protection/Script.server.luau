function sub(...)
	coroutine.wrap(...)()
end
local u1 = require(game.ServerScriptService.Modules.HitDetection)
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
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Ocean's Protection") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Ocean's Protection"
	CD.Value = 60
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 60)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local armor = game:GetService("ReplicatedStorage").Assets.sf.OP.Armor:Clone()
	armor.Parent = p1
	armor.TorsoPiece.Torso.Part1 = p1.Torso
	armor.RightShoulderCap["Right Arm"].Part1 = p1["Right Arm"]
	armor.LeftSHoulderCap["Left Arm"].Part1 = p1["Left Arm"]
	armor.TorsoBeam.Torso.Part1 = p1.Torso
	game:GetService("Debris"):AddItem(armor, 40)
	local v1 = Instance.new("Accessory")
	v1.Name = "OceanProt"
	v1.Parent = p1
	game.Debris:AddItem(v1,40)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	task.spawn(function()
		task.wait(40)
		for i,v in armor:GetChildren() do
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
			local tween = TweenService:Create(v, tweenInfo, {Transparency = 1}) 
			tween:Play()
		end
	end)
	for i,v in HumanoidRootPart.oceanpActivate:GetChildren() do
		v:Emit(v:GetAttribute("EmitCount"))
	end
	HumanoidRootPart.ArmorActivate:Play()
	wait(60)
	canuse = true
end)