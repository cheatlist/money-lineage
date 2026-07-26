local ShiftAppearance = require(game.ServerScriptService.Modules.ShiftAppearance)
local OptionPicker = require(game.ServerScriptService.Modules.OptionPicker)
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end

local REVERT_DELAY = 18
local COOLDOWN = 25

-- Cone/range single-target picker modeled directly on RacialAbilities/Shoulder Throw's own
-- Nearest(Origin, User) — 12 studs, forward-facing box check, skips dead/Immortal/IFRAME targets.
local function Nearest(Origin, User)
	local High = 12
	local Target = nil
	local BestDist = math.huge
	for _, v in pairs(workspace.Live:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= User and not v:FindFirstChild("ForceField") then
			if v.Humanoid.Health > 0 and not v:FindFirstChild("Immortal") and not v:FindFirstChild("IFRAME") then
				local dist = (v.HumanoidRootPart.Position - Origin).Magnitude
				if dist <= High then
					local rel = User.HumanoidRootPart.CFrame:Inverse() * v.HumanoidRootPart.CFrame
					if rel.Z < 0 and math.abs(rel.X) <= 7 and math.abs(rel.Y) <= 5 and dist < BestDist then
						BestDist = dist
						Target = v
					end
				end
			end
		end
	end
	return Target
end

script.Parent.Activated:Connect(function(Player, Character, Data)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Data = game.ServerStorage.PlayerData[Player.Name]

	if ActionCheck(Character) then
		return
	end
	if Character.Cooldowns:FindFirstChild("False Assumptions") then
		return
	end
	if not (Data.Ascended.Value == true and Data.Race.Value == "Madrasian") then
		return
	end

	local options = {{key = "__current", label = "My current form"}}
	local slotsByKey = {}
	-- ShiftMemory lives on the Player instance, not PlayerData — see ShiftAppearance's
	-- snapshotOriginalIfMissing comment (a bare Folder directly under PlayerData crashes the save routine).
	local mem = Player:FindFirstChild("ShiftMemory")
	if mem then
		local numbered = {}
		for _,v in pairs(mem:GetChildren()) do
			if v:IsA("Folder") then
				table.insert(numbered, v)
			end
		end
		table.sort(numbered, function(a,b) return tonumber(a.Name) < tonumber(b.Name) end)
		for _,slot in ipairs(numbered) do
			slotsByKey[slot.Name] = slot
			table.insert(options, {key = slot.Name, label = slot.TargetName.Value})
		end
	end

	local choice = OptionPicker.prompt(Player, "False Assumptions", options, 8)
	if not choice then
		return
	end

	local appearanceSource
	local tempSnap
	if choice == "__current" then
		tempSnap = ShiftAppearance.snapshot(Character, Data, game.ServerStorage, "TempFalseAssumptionsSnap")
		appearanceSource = tempSnap
	else
		local slot = slotsByKey[choice]
		if not slot then
			return
		end
		appearanceSource = slot.Appearance
	end

	local victim = Nearest(Character.HumanoidRootPart.Position, Character)
	local victimData = victim and game.ServerStorage.PlayerData:FindFirstChild(victim.Name)
	if not victim or not victimData then
		if tempSnap then
			tempSnap:Destroy()
		end
		return
	end

	local CD = Instance.new("NumberValue")
	CD.Name = "False Assumptions"
	CD.Value = COOLDOWN
	CD.Parent = Character.Cooldowns
	game.Debris:AddItem(CD, COOLDOWN)

	if not victim:FindFirstChild("FalseAssumptionsSnapshot") then
		ShiftAppearance.snapshot(victim, victimData, victim, "FalseAssumptionsSnapshot")
	end

	ShiftAppearance.apply(victim, appearanceSource)
	if tempSnap then
		tempSnap:Destroy()
	end

	task.delay(REVERT_DELAY, function()
		if victim and victim.Parent and victim:FindFirstChild("FalseAssumptionsSnapshot") then
			ShiftAppearance.apply(victim, victim.FalseAssumptionsSnapshot)
			victim.FalseAssumptionsSnapshot:Destroy()
		end
	end)
end)
