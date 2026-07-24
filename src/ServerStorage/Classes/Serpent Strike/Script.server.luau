function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
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
	if p1.Cooldowns:FindFirstChild("Serpent Strike") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Serpent Strike"
	CD.Value = 11
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 11)
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
	HumanoidRootPart.SpearEmit:Emit(30)
	HumanoidRootPart.SwordCharge:Play()
	local cancelat = false
	local stuncheck = p1.ChildAdded:Connect(function(child)
		if child.Name == "Stun" then
			cancelat = true
		end
	end)
	wait(0.3)
	stuncheck:Disconnect()
	HumanoidRootPart.Swing:Play()
	if not p1:FindFirstChild("NoDam") and not cancelat then
		u3.magnitudeCheck(p1,HumanoidRootPart.Position,13,{
			damage = 7,
			poison = true,
			physical = true,
			spear = true,
			knockback = true,
			slash = true,
			spearmovestack = true,
			move = "Serpent Strike"
		})
	end
	wait(11)
	canuse = true
end)