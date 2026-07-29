local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local AttractivenessModule = require(game.ServerScriptService.Modules.AttractivenessModule)
local MoggingModule = require(game.ServerScriptService.Modules.MoggingModule)

local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun", "NoDam", "ReturnStun", "Action", "Blocking", "SpellBlocking", "ActiveCast", "Unconscious", "Knocked", "Immortal", "Grabbed"},
	})
end

local RANGE = 20
local COOLDOWN = 20

-- Targeting: reuses the exact "find the player my mouse is over" resolution already solved in
-- RacialAbilities/Shift/Script.server.luau, rather than a new HitDetection-style AOE - Mogging
-- reads as a targeted social interaction, not an attack.
local canuse = true
script.Parent.Activated:Connect(function()
	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	if ActionCheck(character) then
		return
	end
	if character.Cooldowns:FindFirstChild("Mogging") then
		return
	end
	if canuse == false then
		return
	end

	local casterData = game.ServerStorage.PlayerData:FindFirstChild(player.Name)
	if not casterData then
		return
	end
	
	canuse = false
	local validTarget = nil
	local mouse = _G.MouseData(player)
	if mouse.Target and mouse.Target:IsDescendantOf(workspace.Live) and not mouse.Target:IsDescendantOf(character) then
		local candidate = mouse.Target.Parent:FindFirstChild("HumanoidRootPart") and mouse.Target.Parent
			or mouse.Target.Parent.Parent:FindFirstChild("HumanoidRootPart") and mouse.Target.Parent.Parent
		if candidate and game.ServerStorage.PlayerData:FindFirstChild(candidate.Name) then
			validTarget = candidate
		end
	end
	if not validTarget then
		canuse = true
		return
	end
	if (validTarget.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude > RANGE then
		canuse = true
		return
	end

	local targetPlayer = game.Players:GetPlayerFromCharacter(validTarget)
	local targetData = game.ServerStorage.PlayerData:FindFirstChild(validTarget.Name)
	if not targetPlayer or not targetData then
		canuse = true
		return
	end

	local CD = Instance.new("NumberValue")
	CD.Name = "Mogging"
	CD.Value = COOLDOWN
	CD.Parent = character.Cooldowns
	game.Debris:AddItem(CD, COOLDOWN)

	-- Computed fresh for both sides so a live Madrasian shift/Sigil Solans-Will bonus/current
	-- Alignment (Morvid)/etc. is reflected, not a possibly-stale cached PlayerData.Attractiveness.
	local casterAttr = AttractivenessModule.compute(player, casterData)
	local targetAttr = AttractivenessModule.compute(targetPlayer, targetData)

	MoggingModule.resolve(player, character, casterData, casterAttr, targetPlayer, validTarget, targetData, targetAttr)
	canuse = true
end)
