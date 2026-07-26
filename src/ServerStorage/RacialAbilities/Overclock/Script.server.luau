local TagHumanoid = game.ServerStorage.Requests.TagHumanoid
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end

local COOLDOWN = 60
local DURATION = 30

script.Parent.Activated:Connect(function()
	local char = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(char)
	local data = player and game.ServerStorage.PlayerData:FindFirstChild(player.Name)
	if not data or not (data.Ascended.Value == true and data.Race.Value == "Gaian") then
		return
	end

	if ActionCheck(char) then
		return
	end
	if char.Cooldowns:FindFirstChild("Overclock") then
		return
	end

	local CD = Instance.new("NumberValue")
	CD.Name = "Overclock"
	CD.Value = COOLDOWN
	CD.Parent = char.Cooldowns
	game.Debris:AddItem(CD, COOLDOWN)
	
	char.HumanoidRootPart.LightningHit:Play()
	
	for v62 = 1, 2 do
		for v63, v64 in pairs(char:GetChildren()) do
			if v64:IsA("Part") and (v64.Name == "Right Arm" or v64.Name == "Left Arm") then
				local v65 = game.ReplicatedStorage.Assets.Electric:Clone()
				v65.Parent = v64
				game:GetService("Debris"):AddItem(v65, 1)
			end
		end
	end

	-- Fired with no `executes` flag, so TagHumanoid's universal knockout floor applies (Health
	-- clamps to 3 + Knocked/Unconscious instead of reaching 0) - "cannot kill, can knock
	-- unconscious" is the engine's existing behavior for any non-executes hit, not something this
	-- move implements itself. Fired before the boosts below so the self-damage isn't softened by
	-- the DamageDivisor this same move is about to grant.
	local selfDamage = char.Humanoid.MaxHealth * 0.1
	TagHumanoid:Fire(char, char, {
		mana = true,
		manaknockupself = true,
		damage = selfDamage,
		noenchant = true,
		move = "Overclock",
	})

	local function boost(name, value)
		local v = Instance.new("NumberValue")
		v.Name = name
		v.Value = value
		v.Parent = char.Boosts
		game.Debris:AddItem(v, DURATION)
	end
	boost("SpeedBoost", 8)
	boost("AttackSpeedBoost", 0.15)
	boost("MeleeDamageMultiplier", 1.3)
	boost("DamageDivisor", 1.3)
end)
