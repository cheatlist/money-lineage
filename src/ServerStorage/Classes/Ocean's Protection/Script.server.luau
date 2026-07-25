function sub(...)
	coroutine.wrap(...)()
end
local u1 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
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
	task.wait(60)
	canuse = true
end)