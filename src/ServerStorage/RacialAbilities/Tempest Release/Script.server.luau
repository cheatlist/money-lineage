-- Ascended Vind racial ability, M2 to Tempest Soul's reworked M1. Releases every spell
-- TagHumanoid/init.server.luau's `canspellcounter` block banked into `Character.StoredTempest`
-- (one "TempestHit" Folder per stored hit, holding an `Attacker` ObjectValue + `Damage`
-- NumberValue) while Tempest Soul's counter window was active, firing one hit back at each
-- original attacker instead of one instant reflect per landed spell.
--
-- Implemented as its own Tool/button rather than Tempest Soul's RightClick, deliberately:
-- RightClick on a spell Tool already drives the unrelated "Snap" quick-cast system
-- (CharacterHandler/init.server.luau's `module.alternate.Activate` dispatch, gated on the
-- player owning a Snap for that spell and requiring a `SnapCD` NumberValue child under the
-- Tool instance) - reusing it here would either fight that system or need a Studio-side asset
-- this session can't add. A separate Tool needs nothing placed in Studio beyond the Tool
-- itself (via commands.RacialAbilities, same as every other racial ability Tool).
local TagHumanoidEvent = game.ServerStorage.Requests.TagHumanoid
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local COOLDOWN = 3

local Cooldown = false
script.Parent.Activated:Connect(function()
	local Character = script.Parent.Parent
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
	if not data or not (data.Ascended.Value == true and data.Race.Value == "Vind") then
		return
	end
	if Cooldown then
		return
	end
	if Character.Cooldowns:FindFirstChild("Tempest Release") then
		return
	end

	local storeFolder = Character:FindFirstChild("StoredTempest")
	if not storeFolder or #storeFolder:GetChildren() == 0 then
		return
	end

	Cooldown = true
	local CD = Instance.new("NumberValue")
	CD.Name = "Tempest Release"
	CD.Value = COOLDOWN
	CD.Parent = Character.Cooldowns
	game.Debris:AddItem(CD, COOLDOWN)
	task.delay(COOLDOWN, function()
		Cooldown = false
	end)

	if Character:FindFirstChild("HumanoidRootPart") and game.ServerStorage.Assets:FindFirstChild("CounterField") then
		local burst = game.ServerStorage.Assets.CounterField:Clone()
		burst.CFrame = Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(90), math.rad(90))
		burst.Parent = game.Workspace.Thrown
		burst.Weld.Part0 = Character.HumanoidRootPart
		burst.Weld.Part1 = burst
		TweenService:Create(burst.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Scale = Vector3.new(4, 4, 4),
		}):Play()
		TweenService:Create(burst, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 1,
		}):Play()
		game.Debris:AddItem(burst, 0.5)
	end

	for _,hit in pairs(storeFolder:GetChildren()) do
		local attackerRef = hit:FindFirstChild("Attacker")
		local dmg = hit:FindFirstChild("Damage")
		if attackerRef and attackerRef.Value and dmg then
			local attacker = attackerRef.Value
			if attacker.Parent and attacker:FindFirstChild("Humanoid") and attacker.Humanoid.Health > 0 then
				TagHumanoidEvent:Fire(Character, attacker, {
					damage = dmg.Value,
					mana = true,
					blockbreak = true,
					nododge = true,
					noparry = true,
					move = "Tempest Release",
				})
			end
		end
		hit:Destroy()
	end
end)
