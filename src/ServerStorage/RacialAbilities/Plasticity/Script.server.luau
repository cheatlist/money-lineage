local OptionPicker = require(game.ServerScriptService.Modules.OptionPicker)
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end

local DURATION = 15
local COOLDOWN = 30

local materialData = {
	Ice = {
		enum = Enum.Material.Ice,
		label = "Ice — Speed",
		apply = function(Character)
			local sb = Instance.new("NumberValue")
			sb.Name = "SpeedBoost"
			sb.Value = 8
			sb.Parent = Character.Boosts
			game.Debris:AddItem(sb, DURATION)
			local asb = Instance.new("NumberValue")
			asb.Name = "AttackSpeedBoost"
			asb.Value = 0.1
			asb.Parent = Character.Boosts
			game.Debris:AddItem(asb, DURATION)
		end,
	},
	Slate = {
		enum = Enum.Material.Slate,
		label = "Slate — Defense",
		apply = function(Character)
			local dd = Instance.new("NumberValue")
			dd.Name = "DamageDivisor"
			dd.Value = 1.3
			dd.Parent = Character.Boosts
			game.Debris:AddItem(dd, DURATION)
		end,
	},
	DiamondPlate = {
		enum = Enum.Material.DiamondPlate,
		label = "Diamond Plate — Offense",
		apply = function(Character)
			local mdm = Instance.new("NumberValue")
			mdm.Name = "MeleeDamageMultiplier"
			mdm.Value = 1.25
			mdm.Parent = Character.Boosts
			game.Debris:AddItem(mdm, DURATION)
		end,
	},
	Neon = {
		enum = Enum.Material.Neon,
		label = "Neon — Sustain",
		apply = function(Character)
			local hr = Instance.new("NumberValue")
			hr.Name = "HealthRegen"
			hr.Value = 4
			hr.Parent = Character.Boosts
			game.Debris:AddItem(hr, DURATION)
		end,
	},
	Wood = {
		enum = Enum.Material.Wood,
		label = "Wood — Utility",
		apply = function(Character)
			local marker = Instance.new("BoolValue")
			marker.Name = "NoFallDamage"
			marker.Value = true
			marker.Parent = Character.Boosts
			game.Debris:AddItem(marker, DURATION)

			local humanoid = Character.Humanoid
			local originalJump = humanoid.JumpPower
			humanoid.JumpPower = originalJump * 1.3
			task.delay(DURATION, function()
				if humanoid and humanoid.Parent then
					humanoid.JumpPower = originalJump
				end
			end)
		end,
	},
}

local function setMaterial(Character, enum)
	local originals = {}
	for _,part in ipairs(Character:GetDescendants()) do
		if part:IsA("BasePart") then
			originals[part] = part.Material
			part.Material = enum
		end
	end
	return originals
end

local function restoreMaterial(originals)
	for part, mat in pairs(originals) do
		if part and part.Parent then
			part.Material = mat
		end
	end
end

script.Parent.Activated:Connect(function(Player, Character, Data)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Data = game.ServerStorage.PlayerData[Player.Name]

	if ActionCheck(Character) then
		return
	end
	if Character.Cooldowns:FindFirstChild("Plasticity") then
		return
	end
	if not (Data.Ascended.Value == true and Data.Race.Value == "Madrasian") then
		return
	end

	local options = {}
	for key, info in pairs(materialData) do
		table.insert(options, {key = key, label = info.label})
	end

	local choice = OptionPicker.prompt(Player, "Plasticity", options, 8)
	if not choice or not materialData[choice] then
		return
	end

	local CD = Instance.new("NumberValue")
	CD.Name = "Plasticity"
	CD.Value = COOLDOWN
	CD.Parent = Character.Cooldowns
	game.Debris:AddItem(CD, COOLDOWN)

	local chosen = materialData[choice]
	local originals = setMaterial(Character, chosen.enum)
	chosen.apply(Character)

	task.delay(DURATION, function()
		if Character and Character.Parent then
			restoreMaterial(originals)
		end
	end)
end)
