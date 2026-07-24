function sub(...)
	coroutine.wrap(...)()
end
local u1 = require(game.ServerScriptService.Modules.HitDetection)
local u2 = require(game.ServerScriptService.Modules.EffectModule)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Spear Crusher") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Spear Crusher"
	CD.Value = 12
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 12)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	local stormherald = false
	if data.Skills.Value:find("StormHerald") then
		stormherald = true
	end
	local emberwyrm = false
	if data.Skills.Value:find("TheEmberWyrm") then
		emberwyrm = true
	end
	local abyssalwyrm = false
	if data.Skills.Value:find("TheAbyssalWyrm") then
		abyssalwyrm = true
	end
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local anim = p1.Humanoid:LoadAnimation(script.Parent.Anim)
	anim.Priority = Enum.AnimationPriority.Action2
	anim:Play(0.1, 1.1)
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,1)
	if stormherald == true then
		HumanoidRootPart.SpearEmit:Emit(30)
		HumanoidRootPart.SwordCharge:Play()
		HumanoidRootPart.HeraldRoarQuiet:Play()
		HumanoidRootPart.HeraldCrusher:Emit(1)
		u2.Wings(HumanoidRootPart, Color3.fromRGB(172, 135, 211), 1)
	elseif emberwyrm == true then
		HumanoidRootPart.SpearEmit:Emit(30)
		HumanoidRootPart.SwordCharge:Play()
		HumanoidRootPart.DragonRoarQuiet:Play()
		HumanoidRootPart.EmberCrusher:Emit(1)
		u2.Wings(HumanoidRootPart, Color3.fromRGB(255, 100, 20), 1)
	elseif abyssalwyrm == true then
		HumanoidRootPart.SpearEmit:Emit(30)
		HumanoidRootPart.SwordCharge:Play()
		HumanoidRootPart.DragonRoarQuiet:Play()
		HumanoidRootPart.HeraldCrusher:Emit(1)
		u2.Wings(HumanoidRootPart, Color3.fromRGB(90, 30, 130), 1)
	else
		HumanoidRootPart.SpearEmit:Emit(30)
		HumanoidRootPart.SwordCharge:Play()
		HumanoidRootPart.DragonRoarQuiet:Play()
		HumanoidRootPart.DragonCrusher:Emit(1)
		u2.Wings(HumanoidRootPart, Color3.fromRGB(9, 137, 207), 1)
	end
	
	local cancelat = false
	local stuncheck = p1.ChildAdded:Connect(function(child)
		if child.Name == "Stun" then
			cancelat = true
		end
	end)
	wait(0.35)
	stuncheck:Disconnect()
	HumanoidRootPart.Swing:Play()
	if not p1:FindFirstChild("NoDam") and not cancelat then
		u1.magnitudeCheck(p1,HumanoidRootPart.Position,13,{
			damage = 25, -- 40
			noparry = true,
			physical = true,
			spear = true,
			knockback = true,
			manabreaker = true, 
			slash = true,
			spearmovestack = true,
			blade = true,
			move = "Spear Crusher"
		})
	end
	wait(12)
	canuse = true
end)