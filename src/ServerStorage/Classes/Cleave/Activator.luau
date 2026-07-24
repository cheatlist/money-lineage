local v1 = {};
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

function v1.Active(p1, p2, p3, p4)
	local p12 = script.Parent.Parent
	if ActionCheck(p12)then
		return
	end
	if not canuse then
		return
	end
	canuse = false
	local p22 = game.Players:GetPlayerFromCharacter(p12)
	local HumanoidRootPart = p1.HumanoidRootPart
	local anim = p12.Humanoid:LoadAnimation(script.Parent.Animation)
	anim.Priority = Enum.AnimationPriority.Action2
	anim:Play(0.1, 1, 1.25)
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p12
	game.Debris:AddItem(v1,0.4)
	local cancelat = false
	local stuncheck = p12.ChildAdded:Connect(function(child)
		if child.Name == "Stun" then
			cancelat = true
		end
	end)
	wait(0.1)
	anim:AdjustSpeed(0)
	wait(0.2)
	anim:AdjustSpeed(1)
	anim:GetMarkerReachedSignal("swing"):Connect(function()
		wait(0.1)
		if not p12:FindFirstChild("FireHit") then
			script.Parent:FindFirstChild("FireHit"):Clone().Parent = p12
		end
			p4.TestTrail.Enabled = true
		p4.Attachmentz.DUST:Emit(30)
		HumanoidRootPart.TemplarCleaver:Emit()
		HumanoidRootPart.TemplarEmit:Emit(30)
		HumanoidRootPart.CleaveCharge:Play()
			stuncheck:Disconnect()
			HumanoidRootPart.Greatswordhit:Play()
			if not p1:FindFirstChild("NoDam") and not cancelat then
				u1.magnitudeCheck(p12,HumanoidRootPart.Position,13,{
					damage = 3, -- eradicate all templars
					noparry = false,
					blockbreak = true,
					physical = true,
					sword = true,
					knockback = false,
					manabreaker = true, 
					slash = true,
					sigilwhitefire = true,
					move = "Cleave"
				})
				wait(0.1)
				p4.TestTrail.Enabled = false
			end
	end)
	wait(15)
	canuse = true
end;
return v1;