local CollectionService = game:GetService("CollectionService")
local PlayerData = game.ServerStorage.PlayerData
local HasTag = CollectionService.HasTag
local module = {
	cd = {}
}
local allcast = {"Verto","Vulnere","Mederi","Gladius","Respirare","Tempest Soul","Gate"} --bypass all cast restrictions (abysswalker, cameo)
local function cdcheck(character,name)
	if character:FindFirstChild("EndCast")then
		return
	end

	if name == "Fimbulvetr"then
		if game.CollectionService:HasTag(character,"FIMBULCD")then
			return true
		end
	end
	if name == "Telorum" and game.CollectionService:HasTag(character,"TelorumCooldown")then
		return true
	end
	return false
end
function module.cast(character,info,data, pathing)
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	if HasTag(CollectionService,character,"Casting")then
		return nil
	end
	if not character then
		return nil
	end
	if character.Mana.Value<=0 and game.ServerStorage.PlayerData[player.Name].Runes.Value <= 0 then
		return nil
	end
	if not info then
		return nil
	end
	if character:FindFirstChild("SpellBlocking")or character:FindFirstChild("CurseBlocking")then
		return nil
	end
	if cdcheck(character,info.name)then
		return nil
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if info.name == "Gate" and game.Lighting.WarLocation.Value ~= "" then
		return nil
	end
	if info.name == "Gate" then
		if StoryMarker["NoGate"] and StoryMarker["NoGate"] == true then
			return nil
		end
	end
	if (data.Skills.Value:find("Abysswalker") or data.Skills.Value:find("AbyssTraining")) or data.Skills.Value:find("ArdorCalls") and data.Race.Value ~= "Lich"  and data.Race.Value ~= "Seraph" then
		if (not (data.Race.Value == "Azael" and info.name == "Gate")) and not table.find(allcast,info.name) then

			return nil
		end
	end
	if character.Humanoid.Health <= 0 then
		return nil
	end
	if info.snap and info.snap == true then
		if string.find(data.Snaps.Value,info.name) or info.name == "Gate" or info.name == "Verto" or (info.spell and info.spell:FindFirstChild("SkillSpell")) then

		else
			return nil
		end
	end
	if data.Race.Value == "Cameo" then
		if info.name ~= "Gate" then
			return nil
		end
	end
	CollectionService:AddTag(character,"Casting")
	local mana = character.Mana.Value
	local animation

	game.CollectionService:AddTag(character, "TempStop")
	local mana = 0
	mana = character:FindFirstChild("Mana").Value
	if info.signs and info.signs > 0 then
		local cancelled = false
		local casted = 0
		for i = 1,info.signs do
			if character:FindFirstChild("NoDam")or character:FindFirstChild("Knocked")then
				CollectionService:RemoveTag(character,"Casting")
				game.CollectionService:RemoveTag(character, "TempStop")
				return nil
			end
			if not character:FindFirstChild(info.name)then
				CollectionService:RemoveTag(character,"Casting")
				game.CollectionService:RemoveTag(character, "TempStop")
				return nil
			end
			character.HumanoidRootPart.Swish:Play()
				if animation then
					animation:Stop()
				end
				casted = math.random(1,6)
				if casted >= 6 then
					casted = 1
				end
				animation = character.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims["WandlessAnim"..casted])
				animation.Priority = Enum.AnimationPriority.Action2
				animation:Play(0.04,1.3,1.59)
				task.wait(5 * (0.1/3))



		end
	end
	--[[if data.Artifact.Value == "Philo" and data.Hybrid.Value == "" then
		character.HumanoidRootPart.CommandFX:Emit(16)
		info.lowerbound = 15
		info.upperbound = 100
	elseif data.Artifact.Value == "Philo" and data.Hybrid.Value ~= "" then 
		if character and mana >= 50 then
			character.HumanoidRootPart.CommandFX:Emit(16)
			info.lowerbound = 0
			info.upperbound = 100
		end
	end]]
	local scholar_boost = 0
	local Boosts = character:FindFirstChild'Boosts'
	if Boosts then
		local Scholars = Boosts:FindFirstChild'ScholarsBoon'
		if Scholars then
			scholar_boost += Scholars.Value
		end
	end
	local wise_casting = player.Backpack:FindFirstChild("WiseCasting")
	if wise_casting then
		scholar_boost += 2
	end
	local rem_training = player.Backpack:FindFirstChild("RemTraining")
	if rem_training then
		scholar_boost += 3
	end
	local castellan = PlayerData[player.Name].Race.Value
	if castellan == "Castellan" then
		scholar_boost += 2
	end
	if castellan == "Wretch" then
		scholar_boost += 10
	end
	info.lowerbound -= scholar_boost
	info.upperbound += scholar_boost
	game.CollectionService:RemoveTag(character, "TempStop")
	CollectionService:RemoveTag(character,"Casting")
	task.wait(0.1)
	if (mana >= info.lowerbound and mana <= info.upperbound) or Boosts:FindFirstChild("GuaranteedCast") then
		return true
	else
		return false
	end
end
local castnumbers = {67,88,90}
function module.castnew(character, info, data, pathing)
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	if HasTag(CollectionService,character,"Casting")then
		return nil
	end
	if not character then
		return nil
	end
	if not info then
		return nil
	end
	if character:FindFirstChild("SpellBlocking")or character:FindFirstChild("CurseBlocking")then
		return nil
	end
	if info.name == "Gate" and game.Lighting.WarLocation.Value ~= "" then
		return nil
	end
	if (data.Skills.Value:find("Abysswalker") or data.Skills.Value:find("AbyssTraining")) or data.Skills.Value:find("ArdorCalls") and data.Race.Value ~= "Lich"  and data.Race.Value ~= "Seraph" then
		if (not (data.Race.Value == "Azael" and info.name == "Gate")) and not table.find(allcast,info.name) then

			return nil
		end
	end
	if character.Humanoid.Health <= 0 then
		return nil
	end
	local animation
	CollectionService:AddTag(character,"Casting")
	if info.signs and info.signs > 0 then
		local cancelled = false
		local casted = 0
		for i = 1,info.signs do
			if character:FindFirstChild("NoDam")or character:FindFirstChild("Knocked")then
				CollectionService:RemoveTag(character,"Casting")
				game.CollectionService:RemoveTag(character, "TempStop")
				return nil
			end
			if not character:FindFirstChild(info.name)then
				CollectionService:RemoveTag(character,"Casting")
				game.CollectionService:RemoveTag(character, "TempStop")
				return nil
			end
			character.HumanoidRootPart.Swish:Play()
			if animation then
				animation:Stop()
			end
			casted = math.random(1,6)
			animation = character.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims["WandlessAnim"..casted])
			animation.Priority = Enum.AnimationPriority.Action2
			animation:Play(0.04,1.3,1.59)
			task.wait(5 * (0.1/3))
		end
	end
	game.CollectionService:RemoveTag(character, "TempStop")
	CollectionService:RemoveTag(character,"Casting")
	task.wait(0.1)
	return true
end
function module.getanims(character,info,data)
	local spellpaths = {
		Ignis = {
			2, 5, 3, 1, 1, 1
		},
		Hoppa = {
			2, 6, 4, 3, 3
		},
		Gelidus = {
			2, 4, 4, 3, 5, 5
		},
		Telorum = {
			1, 6, 4, 2, 3, 1
		},
		Snarvindur = {
			6, 2, 6
		},
		Percutiens = {
			6, 5, 2, 4, 1, 6, 6, 5
		},
		Nocere = {
			4, 5, 5
		},
		Viribus = {
			6, 2, 4, 2
		}
	}
	
	if spellpaths[info.name] ~= nil then
		return spellpaths[info.name]
	else
		local tablet = {}
		for i = 1,info.signs do
			local random = math.random(1,6)
			table.insert(tablet,random)
		end
		return tablet
	end
end
function module.CD(character, name, length,snap)
	if length == nil then

	else
		if snap and snap == true then
			local cooldown = Instance.new("BoolValue")
			cooldown.Name = name.."SnapCD"
			cooldown.Parent = character
			game.Debris:AddItem(cooldown,length.Value)
		else
			local cooldown = Instance.new("BoolValue")
			cooldown.Name = name.."CD"
			cooldown.Parent = character
			game.Debris:AddItem(cooldown,length.Value)
		end
	end
end
return module