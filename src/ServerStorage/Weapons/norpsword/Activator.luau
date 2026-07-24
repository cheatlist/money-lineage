local module = {}
function sub(...)
	coroutine.wrap(...)()
end

local function create(name,deletetime,parent)
	if not parent then
		return
	end
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	if deletetime then
		game.Debris:AddItem(i,deletetime)
	end
	return i
end

tool = script.Parent
TagHumanoid = game.ServerStorage.Requests.TagHumanoid
parent = script.Parent.Parent
combatanims = game.ReplicatedStorage:WaitForChild("CombatAnims")
sAssets = game.ServerStorage.Assets
greatswordnorpidle = nil
function ActionCheck()
	if not parent:FindFirstChild("Humanoid") then
		return true
	end
	if parent:FindFirstChild("NoAttack") then
		return true
	end
	if parent:FindFirstChild("Charge") then
		return true
	end
	if parent:FindFirstChild("Stun") then
		return true
	end
	if parent:FindFirstChild("ReturnStun") then
		return true
	end
	if parent:FindFirstChild("Action") then
		return true
	end
	if parent:FindFirstChild("Blocking") then
		return true
	end
	if parent:FindFirstChild("SpellBlocking") then
		return true
	end
	if game.CollectionService:HasTag(parent, "Unconscious") then
		return true
	end
	if game.CollectionService:HasTag(parent, "Knocked") then
		return true
	end
	if parent:FindFirstChild("HeavyAttack") then
		return true
	end
	if parent:FindFirstChild("LightAttack") then
		return
	end
	return false
end
local canM1 = true
local ComboTimer = parent:WaitForChild("ComboTimer")
local CurrentCombo = parent:WaitForChild("Combo")
local LastHit = false
local HitDetection = require(game.ServerScriptService.Modules.HitDetection)
equippedSword = false
function module.Active(Character, Player, CombatAnims, WeaponModel)
	if ActionCheck() then
		return
	end
	if Character:FindFirstChild("NoAttack") then
		return
	end
	if Character:FindFirstChild("Grabbing") then
		return
	end
	if game.CollectionService:HasTag(Character, "Knocked") then
		return
	end
	if Character:FindFirstChild("Rolling") then
		return
	end
	if not canM1 then
		return
	end
	if Character:FindFirstChild("Stun") then
		return
	end
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	local Speed = WeaponModel.Stats.Speed.Value
	local Damage = WeaponModel.Stats.Damage.Value
	--game.ReplicatedStorage.Requests.ClientSprint:FireClient(Player)
	canM1 = false
	local timeSinceCombo = tick() - ComboTimer.Value
	if timeSinceCombo >= 1.5 then
		CurrentCombo.Value = 1
	end
	ComboTimer.Value = tick()

	local DamageTable
	if LastHit then
		DamageTable = {
			physical = true, 
			damage = Damage, 
			knockback = true, 
			blockbreak = true,
			fist = true,
		}
	else
		DamageTable = {
			physical = true, 
			damage = Damage,
			fist = true,
		}
	end
	if not Character:FindFirstChild("Stun") and not Character:FindFirstChild("NoDam") then
		HitDetection.magnitudeCheck(Character, HumanoidRootPart.Position, WeaponModel.Stats.Length.Value, DamageTable, true)
	end
	--wait(EndLag)
	--AttackingDeb:Destroy()
	--NoJump:Destroy()
	canM1 = true
end
function module.Active2(Character, Player, CombatAnims, WeaponModel)
	if Character:FindFirstChild("Grabbing") then
		return
	end
	if ActionCheck() then
		return
	end
	if Character:FindFirstChild("NoAttack") then
		return
	end
	if game.CollectionService:HasTag(Character, "Knocked") then
		return
	end
	if not canM1 then
		return
	end
	local deb = Instance.new("Accessory")
	deb.Name = "HeavyAttack"
	game:GetService("Debris"):AddItem(deb, 5)

	local Humanoid = Character.Humanoid
	local HumanoidRootPart = Character.HumanoidRootPart
	if not Character:FindFirstChild("GnorpEquipping") then
		if equippedSword == false then
			if Character:FindFirstChild("RecentnorpEquip") then
				WeaponModel.Weld.Part0 = nil
				WeaponModel.PropWeld.Part0 = Character.Hilt
				WeaponModel.Parent = Character.Hilt
				if not greatswordnorpidle then
					greatswordnorpidle = Humanoid:LoadAnimation(combatanims.GreatswordnorpIdle)
				end
				greatswordnorpidle:Play()
				equippedSword = true
				create("HasGreatswordnorp",false,Character)
				create("equippednorpGS",false,Character)
			else
				local slowdown = Instance.new("NumberValue")
				slowdown.Value = -14
				slowdown.Name = "SpeedBoost"
				slowdown.Parent = Character.Boosts
				local deb = create("GnorpEquipping",false,Character)
				local anim = Humanoid:LoadAnimation(combatanims.GreatswordnorpEquip)
				local events = {weldChange = 0.208, swing1 = 0.674, swing2 = 0.97, complete = 2.243}
				anim:Play()
				task.spawn(function()
					task.wait(events.weldChange)
					if tool.Parent ~= Character then
						Humanoid:UnequipTools()
						Humanoid:EquipTool(tool)
					end
					WeaponModel.Weld.Part0 = nil
					WeaponModel.PropWeld.Part0 = Character.Hilt
					WeaponModel.Parent = Character.Hilt
					WeaponModel.TestTrail.Enabled = true
					local s = sAssets.norpstuff.equip:Clone()
					s.Parent = WeaponModel
					s:Play()
					game.Debris:AddItem(s,1)
				end)
				task.spawn(function()
					task.wait(events.swing1)
					if tool.Parent ~= Character then
						Humanoid:UnequipTools()
						Humanoid:EquipTool(tool)
					end
					local s = sAssets.norpstuff.RoundSlash1:Clone()
					s.Parent = WeaponModel
					s:Play()
					game.Debris:AddItem(s,1)
					local DamageTable = {
						physical = true, 
						damage = 9.5, 
						norpsword = true,
						slash = true,
						currentprop = WeaponModel,
						blade = true,
						bypassblock = true,
					}
					HitDetection.magnitudeCheck(Character, HumanoidRootPart.Position, WeaponModel.Stats.Length.Value, DamageTable, true)
				end)
				task.spawn(function()
					task.wait(events.swing2)
					if tool.Parent ~= Character then
						Humanoid:UnequipTools()
						Humanoid:EquipTool(tool)
					end
					local s = sAssets.norpstuff.RoundSlash2:Clone()
					s.Parent = WeaponModel
					s:Play()
					game.Debris:AddItem(s,1)
					local DamageTable = {
						physical = true, 
						damage = 9.5, 
						norpsword = true,
						slash = true,
						currentprop = WeaponModel,
						blade = true,
						knockback = true,
						bypassblock = true,
					}
					HitDetection.magnitudeCheck(Character, HumanoidRootPart.Position, WeaponModel.Stats.Length.Value, DamageTable, true)
				end)
				task.spawn(function()
					task.wait(events.complete)
					equippedSword = true
					WeaponModel.TestTrail.Enabled = false
					if tool.Parent ~= Character then
						Humanoid:UnequipTools()
						Humanoid:EquipTool(tool)
					end
					if not greatswordnorpidle then
						greatswordnorpidle = Humanoid:LoadAnimation(combatanims.GreatswordnorpIdle)
					end
					greatswordnorpidle:Play()
					create("HasGreatswordnorp",false,Character)
					create("RecentnorpEquip",8,Character)
					create("equippednorpGS",false,Character)
					slowdown:Destroy()
					deb:Destroy()
				end)
			end
		else
			equippedSword = false
			if Character:FindFirstChild("equippednorpGS") then
				Character.equippednorpGS:Destroy()
			end
			if Character:FindFirstChild("HasGreatswordnorp") then
				Character.HasGreatswordnorp:Destroy()
			end
			if greatswordnorpidle ~= nil then
				greatswordnorpidle:Stop()
			end
			WeaponModel.PropWeld.Part0 = nil
			WeaponModel.Weld.Part0 = Character.Back
			WeaponModel.Parent = Character.Torso
			deb:Destroy()
		end
	end
end
return module
