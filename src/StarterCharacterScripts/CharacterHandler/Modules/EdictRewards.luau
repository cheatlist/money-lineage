local EdictsFolder = game.ServerStorage.Classes
local EdictMarks = game.ReplicatedStorage.Assets.FacialMarkings

local EdictData = {
	--[[JesterA = {
		Face = EdictMarks:WaitForChild("Jester1"),
		Skills = {
			{Skill = EdictsFolder["Wallet Swipe"], ProgressRequirement = 0, DayRequirement = 2},
			{Skill = EdictsFolder["Snowball"], ProgressRequirement = 0, DayRequirement = 3},
			{Skill = EdictsFolder["Time Halt"], ProgressRequirement = 1, DayRequirement = 9},
			{Skill = EdictsFolder["Jester's Scheme"], ProgressRequirement = 2, DayRequirement = 15},
		}
	},

	JesterB = {
		Face = EdictMarks:WaitForChild("Jester2"),
		Skills = {
			{Skill = EdictsFolder["Wallet Swipe"], ProgressRequirement = 0, DayRequirement = 2},
			{Skill = EdictsFolder["Snowball"], ProgressRequirement = 0, DayRequirement = 3},
			{Skill = EdictsFolder["Time Erase"], ProgressRequirement = 0, DayRequirement = 9},
			{Skill = EdictsFolder["Jester's Ruse"], ProgressRequirement = 0, DayRequirement = 15},
		}
	},]]

	Healer = {
		Face = EdictMarks:WaitForChild("Healer"),
		Skills = {
			{Skill = EdictsFolder["Mederi"], ProgressRequirement = 1, DayRequirement = 1},
			{Skill = EdictsFolder["MederiUpgrade"], ProgressRequirement = 2, DayRequirement = 1},
			{Skill = EdictsFolder["HealthView"], ProgressRequirement = 3, DayRequirement = 1},
		}
	},

	Blademaster = {
		Face = EdictMarks:WaitForChild("Blademaster"),
		Skills = {
			{Skill = EdictsFolder["Verto"], ProgressRequirement = 1, DayRequirement = 1},
			{Skill = EdictsFolder["Vulnere"], ProgressRequirement = 2, DayRequirement = 1},
			{Skill = EdictsFolder["Gladius"], ProgressRequirement = 3, DayRequirement = 1},
			{Skill = EdictsFolder["Dirk"], ProgressRequirement = 3, DayRequirement = 1},
		}
	},
	Seer = {
		Face = EdictMarks:WaitForChild("Seer"),
		Skills = {
			{Skill = EdictsFolder["Clairvoyance"], ProgressRequirement = 1, DayRequirement = 1},
			{Skill = EdictsFolder["Intent"], ProgressRequirement = 2, DayRequirement = 1},
			{Skill = EdictsFolder["Watchful"], ProgressRequirement = 3, DayRequirement = 1},
		}
	},
}

return function(Character, Player, PlayerData)
	local function edictRewards(firsttimea)
		if PlayerData:WaitForChild'EdictType'.Value ~= "" then
			local EdictData = EdictData[PlayerData.EdictType.Value]
			if not EdictData then
				return
			end
			if not firsttimea then
				if not game.CollectionService:HasTag(Player.Character, "LegitEdict") then
					local allpl = ""
					for i,v in pairs(game.Players:GetPlayers()) do
						allpl = allpl.." "..v.Name
					end
					local msgto = ("The Player %s Has been given an edict! \n Edict Progression: %d \n Edict Type: %s \n Players: %s"):format(Character.Name, PlayerData.EdictProgression.Value, PlayerData.EdictType.Value, allpl)
					game.ServerStorage.Requests.SendWebhook:Fire(
						"Edict Fake",
						msgto,
						"cyan",
						"edictfak"
					)
				end
			end
			if game.CollectionService:HasTag(Player.Character, "LegitEdict") then
				game.CollectionService:RemoveTag(Player.Character, "LegitEdict")
			end
			local Marking = true
			if Character.Head:FindFirstChild("EdictMark") then
				Marking = false
			end
			if Marking then
				if EdictData.Face then
					local face = EdictData.Face:Clone()
					face.Name = "EdictMark"
					face.Parent = Character.Head
				end
			end
			if EdictData.Skills then
				for _,v in ipairs(EdictData.Skills) do
					if not Player.Backpack:FindFirstChild(v.Skill.Name) and not Character:FindFirstChild(v.Skill.Name) then
						if PlayerData.EdictProgression.Value >= v.ProgressRequirement and PlayerData.DaysSurvived.Value >= v.DayRequirement then
							v.Skill:Clone().Parent = Player.Backpack
						end
					end
				end
			end
		end
	end

	PlayerData:WaitForChild'DaysSurvived'.Changed:Connect(function()
		edictRewards(true)
	end)
	PlayerData.EdictType.Changed:Connect(function()
		edictRewards(false)
	end)

	PlayerData.EdictProgression.Changed:Connect(function()
		edictRewards(false)
	end)
	edictRewards(true)
end
