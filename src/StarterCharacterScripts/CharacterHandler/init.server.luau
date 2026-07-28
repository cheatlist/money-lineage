local Character = script.Parent
local m1 = require(game.ServerScriptService.Modules.m1)
local TagHumanoid = game.ServerStorage.Requests.TagHumanoid
local RagdollModule = require(game.ServerScriptService.Modules.Ragdoll)
local SpellModule = require(game.ServerScriptService.Modules.SpellModule)
local hitcheck = require(game.ServerScriptService.Modules.HitDetection)
local DataStore2 = require(game.ServerScriptService.Modules.DataStore2)
local Commands = require(game.ServerScriptService.Modules.Commands)
local TemperatureHandler = require(game.ServerScriptService.Modules.TemperatureHandler)
local Player = game.Players:GetPlayerFromCharacter(Character)
local CollectionService = game:GetService("CollectionService")
local GetChildren,GetDescendants = game.GetChildren,game.GetDescendants
local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
local PlayerData = game.ServerStorage.PlayerData:WaitForChild(Player.Name)
local GlobalData = game.ServerStorage.PlayerData:WaitForChild(Player.Name.."Global")
local HumanoidRootPart = WaitForChild(Character,"HumanoidRootPart")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Humanoid = WaitForChild(Character,"Humanoid")
local Boosts = WaitForChild(Character,"Boosts")
local Torso = WaitForChild(Character,"Torso")
local Lighting = game:GetService("Lighting")
local Assets = game.ReplicatedStorage.Assets
local sAssets = game.ServerStorage.Assets
local Mana = WaitForChild(Character,"Mana")
local HasTag = CollectionService.HasTag
local AddTag = CollectionService.AddTag
local RemoveTag = CollectionService.RemoveTag
local Remotes = script.Remotes
local wrap = coroutine.wrap
local Debris = game:GetService'Debris'
local AddItem = Debris.AddItem
local canattack = true
local charging = false
local equipped = {}
local blockthread
local ServerStorage = game:GetService("ServerStorage")
local DATASTORE2DATA = DataStore2(Player:WaitForChild("SelectedSlot").Value.."5",Player)
if Player.Name == "XY_D" then
	DATASTORE2DATA = DataStore2(Player:WaitForChild("SelectedSlot").Value.."cheatdata6",Player)
end
local GlobalStore = DataStore2("GlobalData", Player)
if Player.Name == "XY_D" then
	GlobalStore = DataStore2("CheatsData",Player)
end
if PlayerData.PrimaryWeapon.Value == "Dark Sword" then
	PlayerData.PrimaryWeapon.Value = PlayerData.OGWeapon.Value
	if PlayerData.OGWeapon.Value == "Fairfrozen" then
		PlayerData.Artifact.Value = "Fairfrozen"
	end
end

local CANCEL1 = false
if os.time() > 1657832704 + 3600 * 1 then
	CANCEL1 = true
end
if not CANCEL1 then
	Player:WaitForChild("Ingame")
	if os.time() - PlayerData.GlobalRestoreCD.Value > 3600 * 24 then
		PlayerData.GlobalRestoreCD.Value = os.time()
		PlayerData.Lives.Value += 1
	end
end

local function Color3ToTable(Color)
	return{Color.r,Color.g,Color.b}
end

local function TableToColor3(ColorTable) 
	return Color3.new(ColorTable[1],ColorTable[2],ColorTable[3])
end

local function create(name,deletetime,parent)
	if not parent then
		return
	end
	local i = Instance.new("Folder")
	i.Name = name
	i.Parent = parent
	if deletetime then
		Debris:AddItem(i,deletetime)
	end
	return i
end

for _,v in pairs(GetChildren(Player))do
	if v.Name == "Danger" or v.Name == "MortalDanger" then
		v:Destroy()
	end
end



Humanoid.Health = math.clamp(PlayerData.LastHealth.Value,0.5,math.huge)
Character.Stomach.Value = PlayerData.Stomach.Value
Character.Toxicity.Value = PlayerData.Toxicity.Value
Character.Toxicity.MaxValue = 100
if PlayerData.SubClass.Value == "Alchemist" then
	Character.Toxicity.MaxValue += 100
end
if PlayerData.Race.Value == "Construct" or PlayerData.Race.Value == "Lich" then
	Character.Toxicity.MaxValue += 900
end
if string.find(PlayerData.Skills.Value,"Azure Ignition") then
	if not Player.PlayerGui:FindFirstChild("AetherUI") and not Character:FindFirstChild("Regenerating")then
		game.ServerScriptService.WorldHandler.GameLoaded:WaitForChild("AetherUI"):Clone().Parent = Player.PlayerGui
		local Aether = Instance.new("NumberValue")
		Aether.Parent = Character
		Aether.Value = 0
		Aether.Name = "Aether"
		local RegeneratingInsanity = Instance.new("BoolValue")
		RegeneratingInsanity.Parent = Character
		RegeneratingInsanity.Value = true
		RegeneratingInsanity.Name = "Regenerating"
		spawn(function()
			while task.wait(.5) do
				if Character:FindFirstChild("VanguardBuff") then
				else
					Aether.Value = math.clamp(Aether.Value + 1,1,100)
				end
			end
		end)
	end
end
if string.find(PlayerData.Skills.Value,"TheCursedSwordsman") then
	if not Player.PlayerGui:FindFirstChild("InsanityUI") and not Character:FindFirstChild("Regenerating") then
		game.ServerScriptService.WorldHandler.GameLoaded:WaitForChild("InsanityUI"):Clone().Parent = Player.PlayerGui
		local Aether = Instance.new("NumberValue")
		Aether.Parent = Character
		Aether.Value = 1
		Aether.Name = "Insanity"
		local RegeneratingInsanity = Instance.new("BoolValue")
		RegeneratingInsanity.Parent = Character
		RegeneratingInsanity.Value = true
		RegeneratingInsanity.Name = "Regenerating"
		spawn(function()
			while task.wait(.5) do
				if Character:FindFirstChild("TrueVisionEnabled") or Character:FindFirstChild("RuneBoy") then
				else
					Aether.Value = math.clamp(Aether.Value + 0.5,1,100)
				end
			end
		end)
	end
end

WaitForChild(Player.Backpack,"ManaColor")
WaitForChild(HumanoidRootPart,"ManaStopParticle").Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Player.Backpack.ManaColor.Value),
	ColorSequenceKeypoint.new(1,Player.Backpack.ManaColor.Value),
}


local Race = PlayerData:WaitForChild("Race")
if not FindFirstChild(game.ServerStorage.SpawnPoints,PlayerData.SpawnPoint.Value)then
	PlayerData.SpawnPoint.Value = "Oresfall"
end

local inventoryamounts = {}
if PlayerData.Skills.Value:find("TheBlade") and not PlayerData.Skills.Value:find("Spite") then
	-- backfill for players who took TheBlade before Spite existed
	PlayerData.Skills.Value ..= ",Spite"
end
if PlayerData.Lives.Value>0 then
	Commands.UpdateSkills(Player)
	Commands.UpdateSpells(Player)
	local inventory = string.split(PlayerData.Inventory.Value,",")
	local list_ingredients = require(game.ServerScriptService.Alchemy.list_alchemy)

	local ingredientProps = list_ingredients.ingredients
	if #inventory > 0 then
		for i = 1,#inventory do
			local ic = FindFirstChild(game.ServerStorage.Storage,inventory[i])
			if ic and not ic:FindFirstChild("isIngredient") then
				if not inventoryamounts[ic.Name]then
					inventoryamounts[ic.Name]= 0
				end
				if inventoryamounts[ic.Name]<50 then
					inventoryamounts[ic.Name]+=1
					ic:Clone().Parent = Player.Backpack
				else
					Commands.RemoveFromInventory(Player,ic.Name)
					task.wait(1/30)
				end
			else
				if not game.ServerStorage.Alchemy.Models:FindFirstChild(inventory[i]) then continue end

				local ingTool = game.ServerStorage.Alchemy.Tools.Ingredient:Clone()
				Instance.new("Folder", ingTool).Name = Player.Name
				ingTool.Name = inventory[i]
				local ingHand = game.ServerStorage.Alchemy.Models[inventory[i]]:Clone()
				ingHand.Anchored = false
				ingHand.CanCollide = false
				ingHand.Name = "Handle"
				ingHand.Parent = ingTool

				local silver = ingredientProps[inventory[i]].silver
				if silver and silver > 0 then
					local silverVal = Instance.new("IntValue")
					silverVal.Name = "SilverValue"
					silverVal.Value = silver
					silverVal.Parent = ingTool
				end 

				local tooltip = ingredientProps[inventory[i]].tooltip
				if tooltip then
					ingTool.ToolTip = tooltip
				end
				ingTool.Parent = Player.Backpack
			end
			if i > 60 then
				task.wait(1/30)
			end
		end
	end
else
	local tpsafe = Instance.new("Vector3Value")
	tpsafe.Name = "TPSafe"
	tpsafe.Value = workspace.SolanSpawn.Position
	tpsafe.Parent = Character
	game:GetService("Debris"):AddItem(tpsafe,1)
	Character:SetPrimaryPartCFrame(workspace.SolanSpawn.CFrame)
	Humanoid.WalkSpeed = 18
end
local partblacklist = {Hilt = true,LeftHilt = true,Orb = true,HumanoidRootPart = true,TomeHilt = true, Head = true,--[[LichHead = true,ScroomHead = true,]]RuneHolderL = true,RuneHolderR = true,Back = true,LightBall = true,IsShifted = true,}

local InvisibleHeads = {"Dullahan","Scroom","Metascroom","Lich"}

local function changetransparency(v,transparency)
	for _,v in pairs(GetDescendants(v))do
		if v:IsA("BasePart")and not partblacklist[v.Name] and v.Parent.Name ~= "RuneArmLeft" and v.Parent.Name ~= "RuneArmRight" and v.Name ~= "Head" then
			v.Transparency = transparency
		end
		if v.Name == "Head" then
			if not table.find(InvisibleHeads,PlayerData.Race.Value) then
				v.Transparency = transparency
			end
		end
		if v.Name == "EnchantEffect" then
			if transparency == 1 then
				v.Enabled = false
			else
				v.Enabled = true
			end
		end
		if v.Name == "Orb" then
			if transparency == 1 then
				v.Transparency = 1
			else
				v.Transparency = 0.75
			end
		end
	end
	if v:FindFirstChild("Head") then
		for _,v in pairs(GetChildren(v.Head))do
			if v:IsA("Decal")then
				v.Transparency = transparency
			end
		end
	end
end

task.wait(1/30)
if PlayerData.Class.Value == "Faceless" or PlayerData.Skills.Value:find("ShadowDash") then
	for i,v in pairs(Character.Head:GetChildren()) do
		if (v.ClassName == "Decal" and game.ReplicatedStorage.Assets.Faces:FindFirstChild(v.Name)) or v.Name == "face" then
			v:Destroy();
		end
	end
end
if PlayerData.Skills.Value:find("TheMaster") then
	-- TheMaster path: Agility + Bane are always on, both nerfed from their activated-skill
	-- numbers (Agility: speed 4/attack-speed 6 -> 2/3; Bane: no bonus free unarmed hit).
	-- Not Debris-timed, so these persist for the character's lifetime (see
	-- Classes/Agility/Script.server.luau and Classes/Bane/Script.server.luau for the
	-- matching no-op gates that make the buttons redundant for this path).
	local permSpeed = Instance.new("NumberValue")
	permSpeed.Name = "SpeedBoost"
	permSpeed.Value = 2
	permSpeed.Parent = Character.Boosts
	local permAtkSpeed = Instance.new("NumberValue")
	permAtkSpeed.Name = "AttackSpeedBoost"
	permAtkSpeed.Value = 3
	permAtkSpeed.Parent = Character.Boosts
	local permBane = Instance.new("Accessory")
	permBane.Name = "BaneEff"
	permBane.Parent = Character
end
if PlayerData.Ascended.Value == true and PlayerData.Race.Value == "Vind" then
	-- Ascended Vind: just the Exoskeleton artifact's hold-Space-to-fall-faster perk, not the
	-- double jump/double dash it also grants - deliberately a distinctly-named marker
	-- ("AscendedVindFall") rather than reusing "Exoskeleton" itself, since
	-- CharacterHandler/Input/init.client.luau's double-jump (~line 1467) and double-dash
	-- (~line 998) checks share that exact same accessory-presence check and would have picked
	-- this race up too if it used the same name.
	local vindFall = Instance.new("Accessory")
	vindFall.Name = "AscendedVindFall"
	vindFall.Parent = Character
end
-- New-character height (2026-07-28): every character spawns scaled by its own persisted
-- PlayerData.HeightMultiplier (rolled once at character creation, 0.8x-1.1x, see
-- CharacterCreationGui/Script.server.luau). Applied before Black Pill's own scale below so the
-- two compose multiplicatively - Black Pill is now a multiplier ON TOP of whatever height you
-- rolled, not a flat override that assumed a 1x base.
local CharacterScaleModule = require(game.ServerScriptService.Modules.CharacterScale)
local hasBlackPill = PlayerData.Artifact.Value == "Black Pill"
-- Defensive: HeightMultiplier is a brand-new PlayerData field that needs adding to the Studio
-- Setup folder - until that's done, the Instance may not exist at all on some characters. A
-- direct .Value read would then error and abort the REST of this spawn script (tool grants,
-- transparency/appearance setup, etc. further down), which is exactly what broke character
-- spawning - so a missing Instance defaults to 1 (no-op scale) instead of erroring.
-- Existing characters that predate this feature will have the Instance (once Setup is updated)
-- but at its default, unrolled value - if that default is 0 (rather than 1), scaleR6(Character, 0)
-- would shrink every body part to zero size, which reads as "invisible," not just wrong-sized.
-- Same 0-sentinel-means-not-yet-rolled convention as AttractivenessBase above: lazy-roll it once
-- here instead of trusting the Setup folder's default to always be a safe, nonzero 1.
local heightMultiplierField = PlayerData:FindFirstChild("HeightMultiplier")
local heightMultiplier = 1
if heightMultiplierField then
	heightMultiplier = heightMultiplierField.Value
	if heightMultiplier <= 0 then
		if Player.UserId == 2231268759 then
			heightMultiplierField.Value = 0.5 + math.random() * 0.29
		else
			heightMultiplierField.Value = 0.8 + math.random() * 0.3
		end
		heightMultiplier = heightMultiplierField.Value
	end
end
-- Absolute last-resort safety net, independent of the reroll logic above: scaleR6 must never run
-- with a zero-or-negative factor no matter what state HeightMultiplier is actually in when this
-- line runs (e.g. if whatever merges the Studio Setup folder's fields into a RETURNING player's
-- existing PlayerData happens at a different point in the load sequence than this script's own
-- check, the Instance could still read 0 here despite the reroll above). A 0 factor silently
-- shrinks every body part to zero size - i.e. invisible, with no error to ever catch it - so this
-- is a hard floor that cannot be bypassed by any timing/ordering issue upstream.
if heightMultiplier <= 0 then
	heightMultiplier = 1
end
if Player.UserId == 2231268759 then
	-- Hard cap: this player can never end up above the normal shortest-possible height (0.8x),
	-- even with Black Pill's own 1.2x stacked on top - their HeightMultiplier is already rolled
	-- below 0.8 at character creation (see CharacterCreationGui/Script.server.luau), but Black
	-- Pill composing multiplicatively could otherwise push a value near 0.8 back over it.
	local cappedHeight = math.min(heightMultiplier * (hasBlackPill and 1.2 or 1), 0.8)
	CharacterScaleModule.scaleR6(Character, cappedHeight)
else
	CharacterScaleModule.scaleR6(Character, heightMultiplier)
	if hasBlackPill then
		CharacterScaleModule.scaleR6(Character, 1.2)
	end
end
if hasBlackPill then
	-- A fresh Character on respawn starts back at normal size - the Black Pill Tool
	-- (ServerStorage/Storage/Black Pill/Script.server.luau) only scales the character alive at
	-- the moment it's picked up, so every subsequent spawn needs this re-applied here too.
	local head = Character:FindFirstChild("Head")
	if head then
		local headMesh = head:FindFirstChildWhichIsA("SpecialMesh")
		if headMesh then
			headMesh.Scale = headMesh.Scale * Vector3.new(1, 1.08, 1)
		end
	end
	if Character:FindFirstChild("Artifacts") and not Character.Artifacts:FindFirstChild("Black Pill") then
		local blackPillMarker = Instance.new("Accessory")
		blackPillMarker.Name = "Black Pill"
		blackPillMarker.Parent = Character.Artifacts
	end
end
-- Workout system: players spawn with all 5 exercise Tools (Bent Over Row still requires
-- Weights to actually activate, checked at the Tool itself). Player.Backpack persists across
-- respawns, so this only clones a Tool the player doesn't already have, rather than piling up
-- duplicates every spawn.
for _, exerciseName in ipairs({"Pushups", "Squats", "Situps", "Russian Twists", "Bent Over Row"}) do
	if not Player.Backpack:FindFirstChild(exerciseName) and not Character:FindFirstChild(exerciseName) then
		game.ServerStorage.Classes[exerciseName]:Clone().Parent = Player.Backpack
	end
end
require(game.ServerScriptService.Modules.WorkoutModule).applyHypertrophyBoosts(Character, PlayerData)
-- Termination: every player spawns with this move by default (self-targeted knockout + death
-- after 3s, see ServerScriptService/Modules/TerminationModule.luau) - same persists-across-
-- respawns guard as the workout Tools above.
if not Player.Backpack:FindFirstChild("Termination") and not Character:FindFirstChild("Termination") then
	game.ServerStorage.Classes.Termination:Clone().Parent = Player.Backpack
end
-- Attractiveness: base is a random 10-20 rolled once ever (0 sentinel = "not yet rolled", same
-- lazy-roll-if-empty convention as FacialMark further down this file), then multiplied by
-- class/race every spawn via AttractivenessModule (see that module for the full multiplier
-- tables and the special-cased classes/races).
-- Defensive: AttractivenessBase also needs adding to the Studio Setup folder - guard the same
-- way as HeightMultiplier above so a not-yet-existing field can't abort this script.
local attractivenessBaseField = PlayerData:FindFirstChild("AttractivenessBase")
if attractivenessBaseField and attractivenessBaseField.Value == 0 then
	attractivenessBaseField.Value = math.random(10, 20)
end
require(game.ServerScriptService.Modules.AttractivenessModule).compute(Player, PlayerData)
-- Mogging: every player spawns with this move by default (see ServerScriptService/Modules/
-- MoggingModule.luau), same guarded-clone pattern as Termination/the workout Tools above.
if not Player.Backpack:FindFirstChild("Mogging") and not Character:FindFirstChild("Mogging") then
	game.ServerStorage.Classes.Mogging:Clone().Parent = Player.Backpack
end
local function StunCheck(p,Stuns)
	if p ~= Player then
		p:Kick("nice one")
		return true
	end
	if Character.Parent ~= workspace.Live then
		return true
	end
	if FindFirstChild(Character,"ForceField")then
		return true
	end
	if not FindFirstChild(Character,"Humanoid")then
		return true
	end
	if Stuns then
		for _,v in pairs(Stuns)do
			if FindFirstChild(Character,v)then
				return true
			end
		end
	else
		return false
	end
	if Humanoid.Health == 0 then
		return true
	end
	if not canattack then
		return true
	end
	if Humanoid.Sit then
		return true
	end
	if FindFirstChild(Character,"Grabbed")then
		return true
	end
	if Stuns and table.find(Stuns,"Casting")then
		if HasTag(CollectionService,Character,"Casting")then
			return true
		end
	end
	if HasTag(CollectionService,Character,"BeingExecuted")or FindFirstChild(Character,"Knocked")then
	else
		return
	end
	return true
end
if PlayerData.PrimaryWeapon.Value == "SpearFairfrozen" then
	PlayerData.PrimaryWeapon.Value = "Mythril Spear"
end
local WEAPON = Commands.ChangeWeapon(Player,PlayerData.PrimaryWeapon.Value)
local function FAIRFROZEN_CHECKS()
	if PlayerData.PrimaryWeapon.Value == "Fairfrozen" and PlayerData.Artifact.Value ~= "Fairfrozen" then
		PlayerData.PrimaryWeapon.Value = "Spear"
	end
	if PlayerData.Artifact.Value == "Fairfrozen" and PlayerData.PrimaryWeapon.Value ~= "Fairfrozen" then
		PlayerData.PrimaryWeapon.Value = "Fairfrozen"
	end
	if PlayerData.PrimaryWeapon.Value == "Fairfrozen" or PlayerData.PrimaryWeapon.Value == "SpearFairfrozen"and not PlayerData.Skills.Value:find("Subzero Strike") then
		PlayerData.Skills.Value ..= ",Subzero Strike"
	end
	if PlayerData.Artifact.Value ~= "Fairfrozen" or PlayerData.PrimaryWeapon.Value ~= "Fairfrozen" or  PlayerData.PrimaryWeapon.Value ~= "SpearFairfrozen" then
		if PlayerData.Skills.Value:find("Subzero Strike") then
			PlayerData.Skills.Value = string.gsub(PlayerData.Skills.Value, ",Subzero Strike", "")
		end
	end
end

FAIRFROZEN_CHECKS()
PlayerData.PrimaryWeapon.Changed:Connect(function(NewValue)
	WEAPON = Commands.ChangeWeapon(Player,NewValue)
	FAIRFROZEN_CHECKS()
end)
PlayerData.Ascended.Changed:Connect(function()
	Commands.UpdateAppearance(Player, true)
end)
--[[
if PlayerData.Skills.Value:find("Chain Pull") and (PlayerData.Class.Value == "ChurchKnight" or PlayerData.Hybrid.Value == "ChurchKnight") then
	print("argghhhhh")
	if PlayerData.HasToStay.Value > 0 and PlayerData.LastPlayed.Value > 0 and not Player:FindFirstChild("CKPChecked") then
		create("CKPChecked", false, Player)
		if (tick() - PlayerData.LastPlayed.Value)/60 > PlayerData.HasToStay.Value then
			PlayerData.Lives.Value = 0
		end
	end
if not Player:FindFirstChild("PlayedForDone") then
	PlayerData.PlayedFor.Value = tick()
	create("PlayedForDone", false, Player)
	end
	end
	]] -- og ck purge sealed until further notice.
if PlayerData.Hybrid.Value == PlayerData.Class.Value then
	PlayerData.Hybrid.Value = ""
end

PlayerData.Hybrid.Changed:Connect(function(New)
	if New == PlayerData.Class.Value then
		PlayerData.Hybrid.Value = ""
	end
end)
local hal = workspace.Live:FindFirstChild("Hallucination", true)
if hal then
	game.ReplicatedStorage.Requests.Hallucinate:FireClient(game.Players:GetPlayerFromCharacter(hal.Parent), game.Players:GetPlayerFromCharacter(hal.Parent))
end

PlayerData:WaitForChild("Enchant").Changed:Connect(function()
	Humanoid:UnequipTools()
	local particles = {}
	if WEAPON and WEAPON:FindFirstChild("Prop")then
		if WEAPON:FindFirstChild("EnchantEffect")then
			WEAPON.EnchantEffect:Destroy()
		end
		local children = game.ServerScriptService.Modules.Commands:GetChildren()
		for i = 1,#children do
			local v = children[i]
			if v:FindFirstChild("EnchantEffect") and PlayerData.Enchant.Value:find(v.Name) then
				v.EnchantEffect:Clone().Parent = WEAPON
			end
		end
		table.clear(children)
	end
end)
task.spawn(function()
	while task.wait(2) do
		local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
		if not PlayerData then
			break
		end
		if not PlayerData then
			return
		end
		local datachildren = GetChildren(PlayerData)
		local settable = {}
		for i,v in pairs(datachildren)do
			settable[v.Name] = v.Value
		end
		settable.ManaColor = Color3ToTable(PlayerData.ManaColor.Value)
		DATASTORE2DATA:Set(settable)
		local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name.."Global")
		if not PlayerData then
			return
		end
		local datachildren = GetChildren(PlayerData)
		local settable = {}
		for i,v in pairs(datachildren)do
			settable[v.Name] = v.Value
		end
		GlobalStore:Set(settable)
	end
end)
local function ActionCheck(Parent)
	if Parent:FindFirstChild("Helm")then
		return true
	end
	if Parent:FindFirstChild("WraithHelm")then
		return true
	end
	if Parent:FindFirstChild("FusedHelm1")then
		return true
	end
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
if Player.Name == "jzxhiczxzxccxzxzcxzxczxc" then
	Instance.new("Folder", Character).Name = "Lordsbaned"
end
if 1654630982 + 3 * 3600 > os.time() then
	if PlayerData.Compensation4.Value == false then
		PlayerData.Compensation4.Value = true
		PlayerData.Skills.Value ..= ",AnyRace,Gate,SigilObelisk,SkycastleObelisk,SnailObelisk,DeepforestObelisk,ForestObelisk,TundraObelisk"
		Commands.ChangeMoney(Player, PlayerData, 5000)
		game.ServerStorage.Classes.Gate:Clone().Parent = Player.Backpack
	end
end
if PlayerData.Skills.Value:find("Unlimited") then
	game.ServerStorage["Unlimited Void"]:Clone().Parent = Player.Backpack
	if not PlayerData.Skills.Value:find("NoKill") then
		PlayerData.Skills.Value ..= ",NoKill"
	end
end
if PlayerData.LastName.Value == "zxczxczxczcxczxczxc" then
	Player:Kick("back in blood cuh")
end
local ApplyInjuriesModule = require(script.Modules.ApplyInjuries)
local function ApplyInjuries()
	ApplyInjuriesModule(Character, Player, PlayerData, Race, Torso, create, CollectionService)
end
ApplyInjuries()
if PlayerData.MetalArm.Value == true then
	Commands["Metal Arm"](Player)
end
PlayerData.Injuries.Changed:Connect(function()
	ApplyInjuries()
end)

PlayerData:WaitForChild("Skills").Changed:Connect(function()
	if PlayerData.Lives.Value>0 then
		Commands.UpdateSkills(Player)
	end
	if PlayerData.Skills.Value:find("PrinceBlessing") then
		if not Character:FindFirstChild("FusedHelm2") then
			local model = game.ServerStorage.Assets.FusedHelm2:Clone()
			if PlayerData.Armor.Value == "Evolved Deep Knight" then
				model = game.ServerStorage.Assets.FusedHelm3:Clone()
			end
			local v1 = Instance.new("NumberValue")
			v1.Name = "HealthBoost"
			v1.Value = (Character.Humanoid.MaxHealth*0.5)/100
			v1.Parent = Character.Boosts
			local v2 = Instance.new("StringValue")
			v2.Name = "Buff"
			v2.Value = "Sigil Helmet"
			v2.Parent = v1
			local v3 = Instance.new("StringValue")
			v3.Name = "Type"
			v3.Value = "Prince Helmet"
			v3.Parent = v1
			model.Parent = Character
			--
			local FaceData = PlayerData.Face.Value
			local Face = Character.Head:FindFirstChild(FaceData)
			if Face then
				--FaceData.Value = "Fused"
				Face.Texture = 'rbxassetid://3299780609'
			end
		end
	end
	if string.find(PlayerData.Skills.Value,"Azure Ignition") then
		if not Player.PlayerGui:FindFirstChild("AetherUI") and not Character:FindFirstChild("Regenerating") then
			game.ServerScriptService.WorldHandler.GameLoaded:WaitForChild("AetherUI"):Clone().Parent = Player.PlayerGui
			local Aether = Instance.new("NumberValue")
			Aether.Parent = Character
			Aether.Value = 0
			Aether.Name = "Aether"
			local RegeneratingInsanity = Instance.new("BoolValue")
			RegeneratingInsanity.Parent = Character
			RegeneratingInsanity.Value = true
			RegeneratingInsanity.Name = "Regenerating"
			spawn(function()
				while task.wait(.5) do
					if Character:FindFirstChild("VanguardBuff") then
					else
						Aether.Value = math.clamp(Aether.Value + 1,1,100)
					end
				end
			end)
		end
	end
	if string.find(PlayerData.Skills.Value,"TheCursedSwordsman") then
		if not Player.PlayerGui:FindFirstChild("InsanityUI") and not Character:FindFirstChild("Regenerating") then
			game.ServerScriptService.WorldHandler.GameLoaded:WaitForChild("InsanityUI"):Clone().Parent = Player.PlayerGui
			local Aether = Instance.new("NumberValue")
			Aether.Parent = Character
			Aether.Value = 1
			Aether.Name = "Insanity"
			local RegeneratingInsanity = Instance.new("BoolValue")
			RegeneratingInsanity.Parent = Character
			RegeneratingInsanity.Value = true
			RegeneratingInsanity.Name = "Regenerating"
			spawn(function()
				while task.wait(.5) do
					if Character:FindFirstChild("TrueVisionEnabled") or Character:FindFirstChild("RuneBoy") then
					else
						Aether.Value = math.clamp(Aether.Value + 0.5,1,100)
					end
				end
			end)
		end
	end
end)
PlayerData:WaitForChild("Spells").Changed:Connect(function()
	if PlayerData.Lives.Value>0 then
		Commands.UpdateSpells(Player)
	end
end)
PlayerData:WaitForChild("NeckAccessory").Changed:Connect(function()
	if PlayerData.NeckAccessory.Value == "AkumaBeads" and not Character:FindFirstChild("AkumaBeads") then
		local beads = game.ServerStorage.Assets.AkumaBeads:Clone()
		beads.Parent = Character
		beads.Weld.Part0 = Character.Torso
		beads.Weld.Part1 = beads
	end
	if PlayerData.NeckAccessory.Value == "AbyssSkull" and not Character:FindFirstChild("AbyssSkull1") then
		local Skull1 = game.ServerStorage.Assets.AbyssSkull1:Clone()
		Skull1.Parent = Character
		Skull1.Weld.Part0 = Character.Torso
		Skull1.Weld.Part1 = Skull1
		local Skull2 = game.ServerStorage.Assets.AbyssSkull2:Clone()
		Skull2.Parent = Character
		Skull2.Weld.Part0 = Character.Torso
		Skull2.Weld.Part1 = Skull2
	end
end)
if PlayerData.NeckAccessory.Value == "AkumaBeads" and not Character:FindFirstChild("AkumaBeads") then
	local beads = game.ServerStorage.Assets.AkumaBeads:Clone()
	beads.Parent = Character
	beads.Weld.Part0 = Character.Torso
	beads.Weld.Part1 = beads
end
if PlayerData.NeckAccessory.Value == "AbyssSkull" and not Character:FindFirstChild("AbyssSkull1") then
	local Skull1 = game.ServerStorage.Assets.AbyssSkull1:Clone()
	Skull1.Parent = Character
	Skull1.Weld.Part0 = Character.Torso
	Skull1.Weld.Part1 = Skull1
	local Skull2 = game.ServerStorage.Assets.AbyssSkull2:Clone()
	Skull2.Parent = Character
	Skull2.Weld.Part0 = Character.Torso
	Skull2.Weld.Part1 = Skull2
end
if PlayerData.Skills.Value:find("PrinceBlessing") and not Character:FindFirstChild("FusedHelm2") then
	if ActionCheck(Character) then return end
	local model = game.ServerStorage.Assets.FusedHelm2:Clone()
	if PlayerData.Armor.Value == "Evolved Deep Knight" then
		model = game.ServerStorage.Assets.FusedHelm3:Clone()
	end
	local v1 = Instance.new("NumberValue")
	v1.Name = "HealthBoost"
	v1.Value = (Character.Humanoid.MaxHealth*0.5)/100
	v1.Parent = Character.Boosts
	local v2 = Instance.new("StringValue")
	v2.Name = "Buff"
	v2.Value = "Sigil Helmet"
	v2.Parent = v1
	local v3 = Instance.new("StringValue")
	v3.Name = "Type"
	v3.Value = "Prince Helmet"
	v3.Parent = v1
	model.Parent = Character
	--
	local FaceData = PlayerData.Face.Value
	local Face = Character.Head:FindFirstChild(FaceData)
	if Face then
		--FaceData.Value = "Fused"
		Face.Texture = 'rbxassetid://3299780609'
	end
end


local Developers = {

}

local function undead(char)
	local char_children = char.Head:GetDescendants()
	for index = 1,#char_children do
		local obj = char_children[index]
		if obj:IsA("Decal") then
			obj:Destroy()
		end
	end

	for i, object in next, char:GetChildren() do
		if object:IsA('BasePart') and object.Transparency ~= 1 then
			local H,S,V = object.Color:ToHSV()
			object.Color = Color3.fromHSV(H,S/2,V)
		end
	end
	local Face = Instance.new("Decal")
	Face.Texture = "rbxassetid://2750457174"
	Face.Parent = char.Head
	Face.Face = Enum.NormalId.Front
end

if Race.Value == 'Navaran' or Developers[Player.Name] then
	local NoKill = Instance.new("Folder")
	NoKill.Name = "NoKill"
	NoKill.Parent = Player.Backpack
end

spawn(function()
	local runearm = game.ServerStorage.Assets.RuneArms
	local runearmL = runearm:WaitForChild("RuneArmLeft"):Clone()
	runearmL.Parent = Character
	local runearmR = runearm:WaitForChild("RuneArmRight"):Clone()
	runearmR.Parent = Character
	runearmL.RuneHolderL.ArmWeld.Part1 = Character:WaitForChild("Left Arm")
	runearmR.RuneHolderR.ArmWeld.Part1 = Character:WaitForChild("Right Arm")
	local children = runearmL:GetChildren()
	for i = 1,#children do
		local v = children[i]
		if v:FindFirstChild("Rune") then
			if v.Rune.Value <= PlayerData.Runes.Value then
				game:GetService("TweenService"):Create(v.Decal,TweenInfo.new(1),{Transparency = 0}):Play() 
			else
				game:GetService("TweenService"):Create(v.Decal,TweenInfo.new(1),{Transparency = 1}):Play()
			end
		end
	end
	table.clear(children)
	local children = runearmR:GetChildren()
	for i = 1,#children do
		local v = children[i]
		if v:FindFirstChild("Rune") then
			if v.Rune.Value <= PlayerData.Runes.Value then
				game:GetService("TweenService"):Create(v.Decal,TweenInfo.new(1),{Transparency = 0}):Play() 
			else
				game:GetService("TweenService"):Create(v.Decal,TweenInfo.new(1),{Transparency = 1}):Play()
			end
		end
	end
	table.clear(children)
	PlayerData.Runes.Changed:Connect(function()
		local children = runearmL:GetChildren()
		for i = 1,#children do
			local v = children[i]
			if v:FindFirstChild("Rune") then
				if v.Rune.Value <= PlayerData.Runes.Value then
					game:GetService("TweenService"):Create(v.Decal,TweenInfo.new(1),{Transparency = 0}):Play() 
				else
					game:GetService("TweenService"):Create(v.Decal,TweenInfo.new(1),{Transparency = 1}):Play()
				end
			end
		end
		table.clear(children)
		local children = runearmR:GetChildren()
		for i = 1,#children do
			local v = children[i]
			if v:FindFirstChild("Rune") then
				if v.Rune.Value <= PlayerData.Runes.Value then
					game:GetService("TweenService"):Create(v.Decal,TweenInfo.new(1),{Transparency = 0}):Play() 
				else
					game:GetService("TweenService"):Create(v.Decal,TweenInfo.new(1),{Transparency = 1}):Play()
				end
			end
		end
		table.clear(children)
	end)
end)

Commands.RacialAbilities(Player,PlayerData)
create(PlayerData:WaitForChild("Artifact").Value,false,Character:WaitForChild("Artifacts"))

if PlayerData.Armor.Value == "GaianChaotic"and PlayerData.Race.Value~="Gaian"then
	Commands.ChangeArmor(Player,"Rags")
end
if PlayerData.Armor.Value == "ScroomDefault" or PlayerData.Armor.Value == "Florian" then
	if PlayerData.Race.Value ~= "Scroom" and PlayerData.Race.Value ~= "Metascroom"then
		Commands.ChangeArmor(Player,"Rags")
	end
end
if FindFirstChild(Player.Backpack,"UberSpySpec") then
	if PlayerData.Class.Value == "Whisper"then
		create("NoKill",nil,Player.Backpack)
		local tomehilt = game.ServerStorage.TomeHilt:Clone()
		tomehilt.HiltWeld.Part0 = Character["Left Arm"]
		tomehilt.HiltWeld.Part1 = tomehilt
		tomehilt.Parent = Character
		for _,v in pairs(game.ServerStorage.UberSpy:GetChildren())do
			v:Clone().Parent = Player.Backpack
		end
		Commands.ChangeArmor(Player,"Uber")
	end
end
local timer = 0
Humanoid.Died:Connect(function()
	local GWS = Player:FindFirstChild("GetWeaponSelection")
	if GWS then 
		GWS:Destroy()
	end
	if Character:FindFirstChild("Demise") then
		Character.Demise:Destroy()
	end
	game.ReplicatedStorage.Requests.Dizzy:FireClient(Player, false)
	local StoryMarker = game:GetService("HttpService"):JSONDecode(PlayerData.StoryMarker.Value)
	if Character:FindFirstChild("Seen") then
		StoryMarker["SeerGhosts"] = "CompletedSeerEdict"
		PlayerData.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		game.ServerStorage.Requests.SendWebhook:Fire(
			"Edict Obtainment",
			Player.Name.." has obtained the Seer Edict",
			"cyan",
			"edictfak"
		)
	end
	task.spawn(Commands.CarryDrop, Character)
	Player.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	--WeaponChange:Disconnect()
	for _,v in pairs(Player:GetChildren())do
		if v.Name == "Danger"then
			_G.Death(Player)
			break
		elseif v.Name == "MortalDanger" then
			game.ServerStorage.PlayerData[Player.Name].Lives.Value = 0
		end
	end
	for _,v in pairs(Player:GetChildren())do
		if v.Name == "LichSummon"then
			v:Destroy()
		end
	end
	PlayerData.LastPosition.Value = "N/A"
	PlayerData.Injuries.Value = ""
	Character.Temperature.Value = 0
	Character.ExtraStomach.Value = 0
	PlayerData.ExtraStomach.Value = 0
	if StoryMarker["Obelisks"] then
		StoryMarker["Obelisks"] = {}
	end
	PlayerData.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
	task.wait(5)
	Character:Remove()
	PlayerData.LastPosition.Value = "N/A"
	task.defer(Character.Destroy, Character)
	Player:LoadCharacter()
	local v12 = Instance.new("NumberValue");
	v12.Name = "Transparency";
	v12.Value = 0;
	v12.Parent = Player.Character.Boosts;
end)
local InCR = PlayerData.Area.Value=="Lannis's Lab"or PlayerData.Area.Value=="Castle Rock" or PlayerData.Area.Value == "Gallica's Lair"
if InCR then
	PlayerData.LastPosition.Value = "N/A"
end
local ultraclass3 = require(game.ServerScriptService.WorldHandler.ClassData).ultraclass3
if table.find(ultraclass3, PlayerData.Class.Value) or PlayerData.Hybrid.Value ~= "" then
	PlayerData.IsUltra.Value = true
end
if PlayerData.Lives.Value>0 or Player:FindFirstChild("LichSummon") or Character:FindFirstChild("LichSummon") then
	repeat
		task.wait(1/30)
		Character.Parent = workspace.Live
	until Character.Parent == workspace.Live
	Character:WaitForChild("Humanoid")
	for _,v in pairs(Character:GetChildren())do
		if v:IsA("ForceField")then
			v:Destroy()
		end
	end
	local starttick = tick()
	local ff = Instance.new("ForceField")
	ff.Parent = Character
	local psect = nil
	local allowawda = false
	if Player:FindFirstChild("Sect") then
		psect = Player.Sect.Value
	end
	for i,v in pairs(workspace.Map:GetChildren()) do
		if v.Name == "Church" and (v.StringValue.Value == psect or v.StringValue.Value == Player.Name) then
			allowawda = v
		end
	end
	if not allowawda then
		if game.PrivateServerId == "" or game.ServerStorage:FindFirstChild("ReservedServer") then
			if PlayerData.LastPosition.Value~="N/A"then
				local lastpos = string.split(PlayerData.LastPosition.Value,",")
				local lastposcframe = CFrame.new(lastpos[1],lastpos[2],lastpos[3])
				local ray = Ray.new(lastposcframe.p,Vector3.new(0,-9e9,0))
				local hit,pos = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Live})
				tpcf = lastposcframe
				if not hit then
					local spawns = game.ServerStorage.SpawnPoints[PlayerData.SpawnPoint.Value]:GetChildren()
					tpcf = spawns[math.random(1,#spawns)].CFrame
				end
			else
				local spawns = game.ServerStorage.SpawnPoints[PlayerData.SpawnPoint.Value]:GetChildren()
				tpcf = spawns[math.random(1,#spawns)].CFrame
			end
			spawn(function()
				while task.wait(0.25) do
					if Humanoid.MoveDirection.Magnitude > 0.8 then
						break
					end
					if tick()-starttick>60 then
						break
					end
				end
				ff:Destroy()
			end)
		else
			local childo = game.ServerStorage.PrivateServerArena.Spawns:GetChildren()
			tpcf = childo[math.random(1,4)].CFrame
			spawn(function()
				while task.wait(0.25) do
					if Humanoid.MoveDirection.Magnitude > 0.8 then
						break
					end
					if tick()-starttick>60 then
						break
					end
				end
				ff:Destroy()
			end)
		end
	else
		tpcf = allowawda.Bed.Part.CFrame * CFrame.new(0, 2, 0)
		spawn(function()
			while task.wait(0.25) do
				if Humanoid.MoveDirection.Magnitude > 0.8 then
					break
				end
				if tick()-starttick>60 then
					break
				end
			end
			ff:Destroy()
		end)
	end
else
	repeat
		task.wait(1/30)
		Character.Parent = workspace.Dead
	until Character.Parent == workspace.Dead
	PlayerData.Lives.Value = 0
end
if PlayerData.Lives.Value<1 and not (Player:FindFirstChild("LichSummon") or Character:FindFirstChild("LichSummon")) then
	tpcf = workspace.SolanSpawn.CFrame
end
local tpsafe = Instance.new("Vector3Value")
tpsafe.Name = "TPSafe"
tpsafe.Parent = Character
game:GetService("Debris"):AddItem(tpsafe,1)
Character:PivotTo(tpcf *CFrame.new(0,2,0))
-- stujpid fix

repeat task.wait(1/30)until not FindFirstChild(Character,"NotLoaded")

if PlayerData.Gender.Value == "Female" then
	local facial = game.ReplicatedStorage.Assets.FacialMarkings
	facial.Lashes:Clone().Parent = Character.Head
end

PlayerData:WaitForChild("Gender").Changed:Connect(function()
	if PlayerData.Gender.Value == "Female" then
		local facial = game.ReplicatedStorage.Assets.FacialMarkings
		facial.Lashes:Clone().Parent = Character.Head
	end
end)

if PlayerData.HouseRank.Value == "Owner"then
	local Ring = game.ServerStorage.Assets.SignetRing:Clone()
	Ring.Parent = Character["Right Arm"]
	Ring.Weld.Part0 = Character["Right Arm"]
	--
	game.ServerStorage["Signet Ring"]:Clone().Parent = Player.Backpack
end

local taskwait = task.wait
spawn(function()
	local TrinketSpawns = GetChildren(game.ServerStorage.TrinketSpawns)
	for i = 1,#TrinketSpawns do
		if HumanoidRootPart and HumanoidRootPart.Parent then
			local v = TrinketSpawns[i]
			if (HumanoidRootPart.Position-v.Position).Magnitude<250 then
				create(Player.Name,300,v)
			end
		else
			return
		end
		if i>25 then
			taskwait()
		end
	end
	table.clear(TrinketSpawns)
end)

local combatanims = game.ReplicatedStorage:WaitForChild("CombatAnims"):Clone()
combatanims.Parent = script
local combo = Character.Combo
local combotimer = Character.ComboTimer

Remotes.LeftClickRelease.OnServerEvent:Connect(function()
	-- Checked against server-only PlayerData instead of Character:FindFirstChild("Respirare"/
	-- "Mederi") - Character is replicated to clients, so a spoofed Instance with either name
	-- would be trusted the same way. Respirare has no Skills.Value trace (it's a Kasparan-only
	-- racial Tool, ClassData/Commands/init.luau), so race is the closest available signal;
	-- Mederi is granted via the EdictRewards system as a Skills.Value entry.
	if (PlayerData.Race.Value == "Kasparan" or PlayerData.Skills.Value:find("Mederi")) and Character:FindFirstChild("ActiveCast") then
		create("EndCast", 0.6, Character)
	end
end)

local castDebounce = false
local currentconn 
local currentconn2
local casts
Remotes.LeftClick.OnServerEvent:Connect(function(p,hit,target)
	--[[if currentconn then
		if CollectionService:HasTag(Character,"Casting") then
			return
		else
			currentconn:Disconnect()
		end
	end
	if currentconn2 then
		if CollectionService:HasTag(Character,"Casting") then
			return
		else
			currentconn2:Disconnect()
		end
	end]]
	local Char = p.Character
	if Char:FindFirstChild("Hallucination") then
		return
	end
	if Character:FindFirstChild("WakingUp") then
		return
	end
	if not Char or Char~=Character then
		return
	end
	if StunCheck(p,{"Casting","Blocking","SpellBlocking","EquipCD"})then
		return
	end
	local tool = Character:FindFirstChildWhichIsA("Tool")
	if Character:FindFirstChild("ShadowrushEndLag") and not (tool and (tool.Name == "Owl Slash" or tool.Name == "Shadowrush")) then
		return
	end
	--[[if tool and tool.Name ~= "Blood Thorn" and tool:FindFirstChild("isIngredient") and PlayerData.Skills.Value:find("Herbivore") then
		if PlayerData.Vampire.Value == false and not FindFirstChild(Character, "NoRegen") then
			local mdata = _G.MouseData(Player)
			if mdata.Target:IsDescendantOf(workspace.Stations) then
				return
			end
			Humanoid:LoadAnimation(game.ServerStorage.Storage["Blood Thorn"].Animation):Play()
			Character.Stomach.Value += 30
			Commands.RemoveFromInventory(Player, tool.Name)
			tool:Destroy()
		end
	end]]
	if tool and (string.find(tool.Name, "Dagger") or string.find(tool.Name, "Spear") or string.find(tool.Name, "Sword")) and tool:FindFirstChild("Trinket") and not Player:FindFirstChild("Danger") then
		Commands.RemoveFromInventory(Player, tool.Name)
		PlayerData.PrimaryWeapon.Value = tool.Name
		tool:Destroy()
	end
	if tool and FindFirstChild(tool,"Activator") and not FindFirstChild(tool, "Rework") then
		local module = require(tool.Activator)
		if StunCheck(p,{"Immortal"})then
			return
		end

		if module and module.Active then
			if FindFirstChild(Character,"ActiveCast")then
				return
			end
			if FindFirstChild(tool,"PrimaryWeapon")and (FindFirstChild(Character,"EquipWarmup") or FindFirstChild(Character, "AnimCancel")) then
				return
			end
			if Character:FindFirstChild("Disarm") then
				return
			end
			if not canattack then
				return
			end

			if FindFirstChild(tool,"RequiresWeapon")and FindFirstChild(Character, "MoveCancel") and tool.Name ~= "Shadowrush" and tool.RequiresWeapon.Value == "Dagger" then
				return
			end
			Character.LastUsed.Value = tool.Name
			module.Active(Character,Player,combatanims,WEAPON)
			return
		end
	end
	if tool and FindFirstChild(tool,"Spell")and FindFirstChild(tool,"Activator") and not FindFirstChild(tool, "Rework") then
		if HasTag(CollectionService,Character,"Casting")then
			return
		end
		if Character:FindFirstChild("ContrariumTag") then
			return
		end
		local module = require(tool.Activator)
		if not FindFirstChild(Character,"ActiveCast") and not FindFirstChild(Character,"CantCast")then	
			if StunCheck(p,{"Immortal"})then
				return
			end
			if Character:FindFirstChild("Disarm") then
				return
			end
			if module and module.Activate then
				if FindFirstChild(Character.Cooldowns, tool.Name) then return end
				if tool.Name == "Gate" then return end
				--[[
				casts = 0
				if table.find(_G.MageClasses, PlayerData.Class.Value) or table.find(_G.MageClasses, PlayerData.Hybrid.Value) then
					casts -= 2
				end
				if PlayerData.Class.Value == "DragonSage" or PlayerData.Class.Value == "DarkSigilKnight" then
					casts -= 2
				end
				if PlayerData.Race.Value == "Castellan" then
					casts -= 1
				end
				if PlayerData.Artifact.Value == "Philo" then
					casts -= 1
				end
				]]
				local cast
				if tool.Name == "Ignis" and PlayerData.Ascended.Value == true and PlayerData.Race.Value == "Gaian" then
					-- Ascended Gaian: instacast, no handsigns, no mana-window requirement. Skips
					-- SpellModule.cast entirely rather than trying to bypass it internally, since
					-- both the sign-animation loop and the mana-window check live there and are
					-- driven by values (module.signs/upperbound/lowerbound) read here, before that
					-- call - this is the only place that can skip it outright.
					cast = true
				else
					cast = SpellModule.cast(Character,{
						upperbound = module.upperbound+5,
						lowerbound = module.lowerbound-5,
						signs = module.signs,
						name = tool.Name,
					},PlayerData)
				end
				if cast == nil then
					return
				end
				module.Activate(nil,Character,cast == true and 0 or 1)
				Character.LastSpell.Value = tool.Name
				local length = FindFirstChild(tool,"CD")
				SpellModule.CD(Character, tool.Name, length)
				--[[local CollectionService = game:GetService("CollectionService")
				if casts > 0 then
					if cast == nil then
						castDebounce = false
						return
					end
					local anims = SpellModule.getanims(Character,{
						signs = casts,
						name = tool.Name,
					},PlayerData, "true")
					Remotes.CollectInputs:FireClient(p,cast,false, anims)
					
					currentconn = Remotes.Inputting.OnServerEvent:Connect(function(p,Finished)
						if Finished == true then
							CollectionService:RemoveTag(Character,"Casting")
							CollectionService:RemoveTag(Character, "TempStop")
							local length = FindFirstChild(tool,"CD")
							SpellModule.CD(Character, tool.Name, length)
							Character.Mana.Value = 100
							task.spawn(module.Activate,nil,Character,0)
							castDebounce = false
							Character.LastUsed.Value = tool.Name
							Character.LastSpell.Value = tool.Name
							return
						elseif Finished == false then
							CollectionService:RemoveTag(Character,"Casting")
							CollectionService:RemoveTag(Character, "TempStop")
							local length = FindFirstChild(tool,"CD")
							SpellModule.CD(Character, tool.Name, length)
							task.spawn(module.Activate,nil,Character,1)
							castDebounce = false
							return
						end
					end)
					currentconn2 = Remotes.CancelCast.OnServerEvent:Connect(function()
						CollectionService:RemoveTag(Character,"Casting")
						CollectionService:RemoveTag(Character, "TempStop")
						castDebounce = false
						cast = nil
						return
					end)
				else
					CollectionService:RemoveTag(Character,"Casting")
					CollectionService:RemoveTag(Character, "TempStop")
					local length = FindFirstChild(tool,"CD")
					SpellModule.CD(Character, tool.Name, length)
					Character.Mana.Value = 100
					task.spawn(module.Activate,nil,Character,0)
					castDebounce = false
					Character.LastUsed.Value = tool.Name
					Character.LastSpell.Value = tool.Name
					return
				end
				--[[pcall(function()
					task.spawn(module.Activate,nil,Character,cast == true and 0 or 1)
                end)
				castDebounce = false
				Character.LastSpell.Value = tool.Name]]
			end
		else
			if module and module.Deactivate then
				--Character.Mana.Value = 0
				module.Deactivate(nil,Character,nil)
			end
		end
		return
	end
	if tool and tool.ManualActivationOnly == true then
		tool:Activate()
	end
	if tool and FindFirstChild(tool,"Skill")then
		Character.LastUsed.Value = tool.Name
		return
	end
	if tool and FindFirstChild(tool, "Rework") then
		if Character:FindFirstChild("ContrariumTag") then
			return
		end
		local module = require(tool.Activator)
		if not FindFirstChild(Character,"ActiveCast") then
			if FindFirstChild(Character.Cooldowns, tool.Name) then return end
			if StunCheck(p,{"Immortal"})then
				return
			end
			if Character:FindFirstChild("Disarm") then
				return
			end
			if module and module.Activate and castDebounce == false then
				castDebounce = true
				local cast = SpellModule.castnew(Character,{
					signs = module.signs,
					name = tool.Name,
				},PlayerData)
				if cast == nil then
					castDebounce = false
					return
				end
				Character.Mana.Value = 100
				task.spawn(function()
					Character.LastUsed.Value = tool.Name
					local length = FindFirstChild(tool,"CD")
					SpellModule.CD(Character, tool.Name, length)
					task.spawn(module.Activate,nil,Character,cast == true and 0 or 1)
				end)
				castDebounce = false
			end
		else
			if module and module.Deactivate then
				Character.Mana.Value = 0
				module.Deactivate(nil,Character,nil)
			end
		end
		return
	end
	if tool and FindFirstChild(tool,"Droppable") then
		return
	end
	if tool and tool:FindFirstChildWhichIsA("Animation")then
		return
	end
	if StunCheck(p,{"HeavyAttack","ActiveCast","Blocking"})then
		return
	end
	if not canattack then
		return
	end
	m1(Character,Player,combatanims,PlayerData)
	task.wait(1/30)
	canattack = true
end)
local heavycombo = 1
local canheavy = true
local castssnap = 1
Remotes.RemoveInput.OnServerEvent:Connect(function()
	Character.HumanoidRootPart.Swish:Play()
end)
Remotes.RightClick.OnServerEvent:Connect(function(p,shiftlock)
	--[[if currentconn then
		if CollectionService:HasTag(Character,"Casting") then
			return
		else
			currentconn:Disconnect()
		end
	end
	if currentconn2 then
		if CollectionService:HasTag(Character,"Casting") then
			return
		else
			currentconn2:Disconnect()
		end
	end]]
	local Char = p.Character
	if not Char or Char~=Character then
		return
	end
	if Char:FindFirstChild("Hallucination") then
		return
	end
	if Character:FindFirstChild("WakingUp") then
		return
	end
	if Character:FindFirstChild("ShadowrushEndLag") then
		return
	end
	local tool = Character:FindFirstChildWhichIsA("Tool")
	if tool and FindFirstChild(tool,"Activator") and not FindFirstChild(tool, "Spell") then
		if Character:FindFirstChild("ContrariumTag") then
			return
		end
		if tool.Name == "Shadow Impale" and game:GetService("ServerStorage").PlayerData[p.Name].Skills.Value:find("Demise Cut") then
			local module = require(tool.Activator)
			if FindFirstChild(tool,"PrimaryWeapon")and FindFirstChild(Character,"EquipWarmup")then
				return
			end
			if Character:FindFirstChild("Disarm") then
				return
			end
			if FindFirstChild(Character,"ActiveCast")then
				return
			end
			Character.LastUsed.Value = tool.Name
			task.spawn(function()
				module.Active2(Character,Player,combatanims,WEAPON)
			end)
			return
		elseif tool.Name == "Shadow Impale" and not game:GetService("ServerStorage").PlayerData[p.Name].Skills.Value:find("Demise Cut") then
			return		
		end
		local module = require(tool.Activator)
		if module and module.Active2 then
			if FindFirstChild(tool,"PrimaryWeapon")and FindFirstChild(Character,"EquipWarmup")then
				return
			end
			if Character:FindFirstChild("Disarm") then
				return
			end
			if FindFirstChild(Character,"ActiveCast")then
				return
			end
			Character.LastUsed.Value = tool.Name
			task.spawn(function()
				module.Active2(Character,Player,combatanims,WEAPON)
			end)
			return
		end
	end
	if tool and FindFirstChild(tool, "PoisonValue") and PlayerData.Skills.Value:find("PoisonCrafting") and Player.Backpack:FindFirstChild("Meat") and not string.find(tool.Name, "Cure") then
		Commands.RemoveFromInventory(Player, "Meat")
		Player.Backpack.Meat:Destroy()
		Commands.AddToInventory(Player, tool.Name.."ous Meat")
		if PlayerData.Skills.Value:find("AdvancedPoisons") then
			Commands.AddToInventory(Player, tool.Name.."ous Meat")
		end
		Commands.RemoveFromInventory(Player, tool.Name)
		tool:Destroy()
	end
	if tool and FindFirstChild(tool,"Spell")and FindFirstChild(tool,"Activator")then
		if Character:FindFirstChild("ContrariumTag") then
			return
		end
		local module = require(tool.Activator)
		if HasTag(CollectionService,Character,"Casting")then
			return
		end
		if Character:FindFirstChild("CantCast") then
			return
		end
		if Character:FindFirstChild("Immortal") then
			return
		end
		if Character:FindFirstChild("Knocked") or Character:FindFirstChild("Unconscious") then
			return
		end
		if Character:FindFirstChild("Disarm") then
			return
		end
		if not FindFirstChild(Character,"ActiveCast") and castDebounce == false then
			if module and module.alternate then
				if PlayerData.Lives.Value == 0 then
					return
				end
				if HasTag(CollectionService,Character,"Casting")then
					return
				end
				if FindFirstChild(Character.Cooldowns, "Snap "..tool.Name) then return end
				--castDebounce = true
				local cast
				if not tool:FindFirstChild("Rework") then
					cast = SpellModule.cast(Character,{
						upperbound = module.alternate.upperbound+5,
						lowerbound = module.alternate.lowerbound-5,
						signs = 0,
						name = tool.Name,
						snap = true,
						spell = tool
					},PlayerData)
				else
					cast = SpellModule.castnew(Character,{
						upperbound = module.alternate.upperbound+5,
						lowerbound = module.alternate.lowerbound-5,
						signs = 0,
						name = tool.Name,
						snap = true,
						spell = tool
					},PlayerData)
				end
				if table.find(_G.MageClasses, PlayerData.Class.Value) or table.find(_G.MageClasses, PlayerData.Hybrid.Value) then
					castssnap = 0
				end
				if cast == nil then
					return
				end
				local snaps = {}
				local soulsnaps = string.split(PlayerData.Snaps.Value,",")
				for _,v in pairs(soulsnaps)do
					snaps[v] = true
				end
				snaps["Gate"] = true
				local length = FindFirstChild(tool,"SnapCD")
				SpellModule.CD(Character, tool.Name, length, true)
				module.alternate.Activate(nil, Character, cast == true and 0 or 1,false, snaps)
				--[[if PlayerData.Race.Value == "Seraph" and tool.name == "Gate" then
					local length = FindFirstChild(tool,"SnapCD")
					SpellModule.CD(Character, tool.Name, length, true)
					CollectionService:RemoveTag(Character,"Casting")
					CollectionService:RemoveTag(Character, "TempStop")
					task.spawn(module.alternate.Activate,nil,Character,0,false,snaps)
					castDebounce = false
					castssnap = 1
					Character.Mana.Value = 100
					return
				elseif PlayerData.Race.Value == "Azael" and tool.name == "Gate" and not Player:FindFirstChild("Danger") then
					local length = FindFirstChild(tool,"SnapCD")
					SpellModule.CD(Character, tool.Name, length, true)
					CollectionService:RemoveTag(Character,"Casting")
					CollectionService:RemoveTag(Character, "TempStop")
					task.spawn(module.alternate.Activate,nil,Character,0,false,snaps)
					castDebounce = false
					castssnap = 1
					Character.Mana.Value = 100
					return
				elseif castssnap > 0 and not tool:FindFirstChild("Rework") and not tool:FindFirstChild("SkillSpell") then
					if cast == nil then
						castDebounce = false
						return
					end
					Remotes.CollectInputs:FireClient(p,cast,"snap", nil)
					currentconn = Remotes.Inputting.OnServerEvent:Connect(function(p,Finished)
						if Finished == true then
							CollectionService:RemoveTag(Character,"Casting")
							CollectionService:RemoveTag(Character, "TempStop")
							local length = FindFirstChild(tool,"SnapCD")
							SpellModule.CD(Character, tool.Name, length, true)
							Character.Mana.Value = 100
							task.spawn(module.alternate.Activate,nil,Character,0,false,snaps)
							castDebounce = false
							Character.LastUsed.Value = tool.Name
							Character.LastSpell.Value = tool.Name
							castssnap = 1
							return
						elseif Finished == false then
							CollectionService:RemoveTag(Character,"Casting")
							CollectionService:RemoveTag(Character, "TempStop")
							local length = FindFirstChild(tool,"SnapCD")
							SpellModule.CD(Character, tool.Name, length, true)
							task.spawn(module.alternate.Activate,nil,Character,1,false,snaps)
							castssnap = 1
							castDebounce = false
							return
						end
					end)
					currentconn2 = Remotes.CancelCast.OnServerEvent:Connect(function()
						CollectionService:RemoveTag(Character,"Casting")
						CollectionService:RemoveTag(Character, "TempStop")
						castDebounce = false
						castssnap = 1
						return
					end)
				else
					local length = FindFirstChild(tool,"SnapCD")
					SpellModule.CD(Character, tool.Name, length, true)
					CollectionService:RemoveTag(Character,"Casting")
					CollectionService:RemoveTag(Character, "TempStop")
					task.spawn(module.alternate.Activate,nil,Character,0,false,snaps)
					castDebounce = false
					castssnap = 1
					Character.Mana.Value = 100
					return
				end]]
			end
		end
		return
	end
	if shiftlock then
		return
	end
	if Character:FindFirstChild("SpellBlocking") or Character:FindFirstChild("CurseBlocking") then return end
	if tool and FindFirstChild(tool,"Skill")then
		return
	end
	if tool and tool:FindFirstChildWhichIsA("Animation")then
		return
	end
	if FindFirstChild(Character,"Immortal")then
		return
	end
	if StunCheck(p,{"LightAttack","NoDam","Stun","Action","HeavyAttack","ActiveCast"})then
		return
	end
	if not canheavy then
		return
	end
	canheavy = false
	local info = {
		physical = true,
		blockbreak = true,
		knockback = true,
		fist = true,
		damage = 8,
	}
	local monk = false
	if Mana.Value>=5 and FindFirstChild(Player.Backpack,"HolyFire") then 
		monk = true
		info.burn = true
		info.mana = true
		info.cancelsmana = true
		info.damage = 20
		info.dsagem2 = true
		info.downbypass = false
		info.monkbreaker = true
		info.azaelcheck = true
		if PlayerData.Ascended.Value == true and PlayerData.Race.Value == "Azael" then
			info.ascendedburn = true
		end
		if PlayerData.Skills.Value:find("TheCursedFlame") then
			info.cursedflame = true
		end
		if PlayerData.Skills.Value:find("DragonRightAllow") then
			info.downbypass = true
		end
		if PlayerData.Class.Value == "Monk" or PlayerData.Hybrid.Value == "Monk" then
			info.downbypass = true
		end
	end
	create("NoJump",1,Character)
	local v1 = create("HeavyAttack",1.2,Character)
	local animation = Humanoid:LoadAnimation(combatanims["HeavyAnim"..heavycombo])
	local speed = 1.25
	if PlayerData.Race.Value == "Ashiin" and PlayerData.Ascended.Value == true then
		speed = 2.5
	end
	animation:Play(0.1,1,speed)

	spawn(function()
		task.wait(0.05)
		if not FindFirstChild(Character,"Stun")then
			local effectpart = nil
			local particle = Assets.ParticleArm:Clone()
			particle.TestTrail.Color = WaitForChild(HumanoidRootPart,"ManaStopParticle").Color
			local particleweld = Instance.new("Weld")
			particleweld.Parent = particle
			particleweld.Part0 = particle
			HumanoidRootPart.ChargePart:Clone().Parent = particle
			if heavycombo ~= 2 then
				effectpart = Character["Right Arm"]
				particle.CFrame = effectpart.CFrame
				particleweld.Part1 = effectpart
			else
				effectpart = Character["Right Leg"]
				particle.CFrame = effectpart.CFrame
				particleweld.Part1 = effectpart
			end
			local fire = nil
			if monk then
				fire = HumanoidRootPart.MonasticFire:Clone()
				if PlayerData.Ascended.Value == true and PlayerData.Race.Value == "Azael" then
					fire = HumanoidRootPart.AscendedMonasticFire
				end
				fire.Parent = effectpart
				fire.Enabled = true
				HumanoidRootPart.MonasteryFire:Play()
			end
			particle.Parent = workspace.Thrown
			particle.TestTrail.Enabled = true
			particle.ChargePart.Enabled = true
			HumanoidRootPart.Charge:Play()
			task.wait(0.5)
			particle.ChargePart.Enabled = false
			task.wait(0.25)
			particle.TestTrail.Enabled = false
			game.Debris:AddItem(particle,0.75)
			if fire then
				fire.Enabled = false
				game.Debris:AddItem(fire,1)
				task.wait(0.5)
				HumanoidRootPart.MonasteryFire:Stop()
			end
		end
	end)
	task.wait(0.125)
	animation:AdjustSpeed(0)
	task.wait(0.1875)
	if not (PlayerData.Race.Value == "Ashiin" and PlayerData.Ascended.Value == true) then
		task.wait(0.1875)
	end
	if FindFirstChild(Character,"Stun")then
		canattack = true
		canheavy = true
		animation:Stop()
		return
	end
	local v2 = create("Action",1,Character)
	heavycombo += 1
	if heavycombo >= 4 then
		heavycombo = 1
	end
	animation:AdjustSpeed(1.3)
	local hit = false
	if not FindFirstChild(Character,"Stun")and not FindFirstChild(Character,"NoDam")then
		HumanoidRootPart.HeavySwing:Play()
		hitcheck.magnitudeCheck(Character,HumanoidRootPart.Position,9,info)
	end
	task.wait(0.35)
	combo.Value = 1
	task.wait(1.5)
	canheavy = true
end)

if PlayerData.Banned.Value == true then
	Player:Kick("You have been banned from the game.")
end

Remotes.SHeld.OnServerEvent:Connect(function(p,s)
	local Char = p.Character
	if not Char or Char~=Character then
		return
	end
	Character.SHeld.Value = s
end)
local manashieldtween = nil
local function manashieldup(color)
	if manashieldtween ~= nil then
		manashieldtween:Pause()
		manashieldtween = nil
	end
	local orb = HumanoidRootPart.Orb
	orb.Color = color
	manashieldtween = TweenService:Create(orb.Mesh,TweenInfo.new(0.3,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Scale = Vector3.new(7,7,7)})
	manashieldtween:Play()
	orb.Attachment.ParticleEmitter.Enabled = true
end
local function manashielddown()
	if manashieldtween ~= nil then
		manashieldtween:Pause()
		manashieldtween = nil
	end
	local orb = HumanoidRootPart.Orb
	manashieldtween = TweenService:Create(orb.Mesh,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Scale = Vector3.new(0,0,0)})
	manashieldtween:Play()
	orb.Attachment.ParticleEmitter.Enabled = false
end
local blockanim = Humanoid:LoadAnimation(combatanims.Block)
local allow
local alreadydone = false
local a232


local function unblock(p,bypass)
	local Char = p.Character
	if not Char or Char~=Character then
		return
	end

	if blockthread then
		blockthread:Disconnect()
		blockthread=nil
	end

	if not bypass then
		if StunCheck(p,false)then
			return
		end
	end
	if FindFirstChild(Character,"MonShield")then
		local m = FindFirstChild(Character,"MonShield")
		local s = FindFirstChild(Character,"SpellBlocking")
		local c = FindFirstChild(Character,"CurseBlocking")
		local t = FindFirstChild(Character,"Blocking")
		HumanoidRootPart.Bell:Play()
		if t then
			t:Destroy()
		end
		if m then
			m:Destroy()
		end
		if s then
			s:Destroy()
		end
		if c then
			c:Destroy()
		end
		manashielddown()
	elseif FindFirstChild(Character,"SpellBlocking")then
		local m = FindFirstChild(Character,"SpellBlocking")
		local c = FindFirstChild(Character,"CurseBlocking")
		HumanoidRootPart.ShieldDown:Play()
		if m then
			m:Destroy()
		end
		if c then
			c:Destroy()
		end
		manashielddown()
	end
	local blocking = FindFirstChild(Character,"Blocking")
	if blocking then
		blockanim:Stop()
		blocking:Destroy()
	end
end
local lastmanashield = tick()
Remotes.Block.OnServerEvent:Connect(function(p)
	local Char = p.Character
	if not Char or Char~=Character then
		return
	end

	--//threading so it doesnt just lag everybody out still this should leak memory from time to time
	blockthread = RunService.Heartbeat:Connect(function(dt)
		if StunCheck(p,{"Immortal","Blocking","LightAttack","Stun","Action","HeavyAttack","Casting","ActiveCast"}) and not (Character:FindFirstChild("canmanashield") or Character:FindFirstChild("FallDamageBypass")) then
			return
		end
		if Character:FindFirstChild("MonShield") or Character:FindFirstChild("SpellBlocking") or Character:FindFirstChild("Blocking") or Character:FindFirstChild("STOPBLOCKING") then
			return
		end
		local manashield = false
		local monkshield = false
		local tool = Character:FindFirstChildWhichIsA("Tool")
		if tool then
			if FindFirstChild(tool,"Spell")and Mana.Value>0 then
				manashield = true
			end
		end
		if Mana.Value>0 and not manashield then
			-- Both checked against server-only PlayerData instead of Player.Backpack - Backpack
			-- is replicated to the owning client and a spoofed Instance with a matching name
			-- would be trusted the same way a spoofed Character Instance would.
			if PlayerData.Skills.Value:find("ChiBlock")then
				monkshield = true
				create("Blocking",false,Character)
				create("MonShield",false,Character)
				local has_skill = PlayerData.Skills.Value:find("CurseShield")

				HumanoidRootPart.Bell:Play()
				local color = has_skill and Color3.fromRGB(165,64,248) or Color3.fromRGB(255,255,255)
				manashieldup(color)
				return
			end
		elseif Mana.Value>0 and manashield then
			lastmanashield = tick()
			create("SpellBlocking",false,Character)
			local has_skill = PlayerData.Skills.Value:find("CurseShield")
			if has_skill then
				create("CurseBlocking",false,Character)
			end
			if not Char:FindFirstChild("ManaParryCD") then
				create("ManaParry", 0.75, Character)
				create("ManaParryCD", 2, Character)
			end
			HumanoidRootPart.ShieldUp:Play()
			local color = has_skill and Color3.fromRGB(165,64,248) or Color3.fromRGB(255,255,255)
			manashieldup(color)
			return
		end
		if manashield then
			if monkshield then
				return
			end
		else
			local v1 = Instance.new("Folder")
			v1.Name = "Blocking"
			v1.Parent = Character
			if not Character:FindFirstChild("ParryCooldown")then
				local v2 = Instance.new("Folder")
				v2.Name = "Parry"
				v2.Parent = Character
				Debris:AddItem(v2,0.35)
			end
			local v3 = Instance.new("Folder")
			v3.Name = "ParryCooldown"
			v3.Parent = Character
			Debris:AddItem(v3,3)
			if FindFirstChild(Character,"HasWeapon")then
				if FindFirstChild(Character,"HasDagger")then
					blockanim = Humanoid:LoadAnimation(combatanims.DaggerBlock)
				elseif FindFirstChild(Character,"HasSword")then
					blockanim = Humanoid:LoadAnimation(combatanims.SwordBlock)
				elseif FindFirstChild(Character,"HasSpear")then
					blockanim = Humanoid:LoadAnimation(combatanims.SpearBlock)
				elseif FindFirstChild(Character,"HasGreatsword")then
					blockanim = Humanoid:LoadAnimation(combatanims.GreatswordBlock)
				elseif FindFirstChild(Character,"HasGreatswordnorp")then
					blockanim = Humanoid:LoadAnimation(combatanims.GreatswordnorpBlock)
				elseif FindFirstChild(Character,"HasHammer")then
					blockanim = Humanoid:LoadAnimation(combatanims.HammerBlock)
				elseif FindFirstChild(Character,"HasRapier")then
					blockanim = Humanoid:LoadAnimation(combatanims.RapierBlock)
				end
			else
				blockanim = Humanoid:LoadAnimation(combatanims.Block)
			end
			blockanim:Play()
		end
	end)
end)
if PlayerData.Artifact.Value == "Spider Cloak" and PlayerData.Armor.Value ~= "Spider Cloak" then
	PlayerData.Artifact.Value = "None"
end
Remotes.Unblock.OnServerEvent:Connect(unblock)
local LastCharge = tick()

Remotes.SetManaChargeState.OnServerEvent:Connect(function(p,Value)
	local Char = p.Character
	if not Char or Char~=Character then
		return
	end
	if Value then
		if tick()-LastCharge >= 0.2 then
			if not FindFirstChild(Character,"ActionManaBypass") then
				if PlayerData.Artifact.Value ~= "Unwavering Focus" then
					if StunCheck(p,{"ChargeBlock","HeavyAttack","Stun","Blocking"})then
						return
					end
					if FindFirstChild(Character, "Action") and not FindFirstChild(Character, "ActionManaBypass") then
						return
					end
					if HasTag(CollectionService,Character,"Casting") then
						return
					end
				end
				if StunCheck(p, {"SpellBlocking","CurseBlocking"}) then
					return
				end
				if FindFirstChild(Character,"ActiveCast")then
					return
				end
				if FindFirstChild(Character,"ManaStop")then
					return
				end
			end
			local Charge = Instance.new("Folder")
			Charge.Name = "Charge"
			Charge.Parent = Character
		end
	else
		local Charge = FindFirstChild(Character,"Charge")
		if Charge then
			Charge:Destroy()
		end
	end
end)
local tpdashes = 0
local lastdash = tick()
local DodgeCheck = {"Stun","Action","Rolling"}
local DodgeCheck33 = {"LightAttack"}

Remotes.Dodge.OnServerEvent:Connect(function(p,axis,Type)
	if p ~= Player then
		p:Kick("nice one")
		return
	end
	--[[if lastdash-tick()>0.2 then
		return
	end]]
	if PlayerData.Injuries.Value == "Broken Leg" then Type = "normal" end
	if Type == "normal"and Player.Backpack:FindFirstChild("SpearDash") and axis ~= 0 then
	else
		if FindFirstChild(Character,"Charge")then
			FindFirstChild(Character,"Charge"):Destroy()
		end
		if axis ~= 0 then
			local f1 = Instance.new("NumberValue")
			f1.Name = "FallResist"
			f1.Value = 0.15
			f1.Parent = Boosts
			game.Debris:AddItem(f1,0.3)
		end
	end
	if axis ~= 0 then
		Commands.StopBurn(Character)
	end
	lastdash = tick()
	if Type == "shadow"then
		if FindFirstChild(Player.Backpack,"ShadowDash")then
			if PlayerData.Injuries.Value == "Broken Leg" then return end
			if FindFirstChild(Character,"LDashing")then
				return
			end
			if FindFirstChild(Character, "nodashshadow") then
				return
			end
			-- TheMaster path: lesser cooldown between TP dashes, longer range, and a very
			-- brief (0.1s) NoDam iframe window right as the teleport lands
			local shadowMaster = PlayerData.Skills.Value:find("TheMaster")
			local dashGate = shadowMaster and 0.1 or 0.2
			local dashSpamThreshold = shadowMaster and 7 or 5
			local dashRange = shadowMaster and 26 or 20
			create("LDashing",dashGate,Character)
			tpdashes+=1
			if tpdashes >= dashSpamThreshold then
				create("LDashing",3.5,Character)
				tpdashes = 0
			end
			wrap(function()
				local oldtpdashes = tpdashes
				task.wait(3)
				if tick()-lastdash>3 and oldtpdashes == tpdashes then
					tpdashes = 0
				end
			end)()
			local ignore = {workspace.Live,workspace.Thrown}
			local ray = Ray.new(HumanoidRootPart.CFrame.p,Humanoid.MoveDirection*dashRange)
			local Hit,Pos,Normal = workspace.FindPartOnRayWithIgnoreList(workspace,ray,ignore)
			local newpos = nil
			if shadowMaster then
				create("NoDam",0.1,Character)
			end
			if Hit and Hit.CanCollide then
				Character:SetPrimaryPartCFrame(CFrame.new(Pos)*CFrame.new(0,1.5,0))
			else
				Character:SetPrimaryPartCFrame(HumanoidRootPart.CFrame*CFrame.new(0,1.5,0)+Humanoid.MoveDirection*dashRange)
			end
			task.wait(1/30)
			HumanoidRootPart.ShadowEmitter:Emit(30)
		else
			--ban
		end
		return
	end
	if Type == "dragon"then
		if FindFirstChild(Player.Backpack,"DragonDash")then
			if FindFirstChild(Character,"LDashing")then
				return
			end
			if FindFirstChild(Character, "nodashshadow") then
				return
			end
			create("LDashing",0.15)
			tpdashes+=1
			if PlayerData.Skills.Value:find("TheCalmbeforethestorm") and tpdashes >= 4 then
				create("LDashing",5,Character)
				tpdashes = 0
			elseif tpdashes >= 5 then
				create("LDashing",3.5,Character)
				tpdashes = 0
			end
			wrap(function()
				local oldtpdashes = tpdashes
				task.wait(3)
				if tick()-lastdash>3 and oldtpdashes == tpdashes then
					tpdashes = 0
				end
			end)()
			local oldpos = HumanoidRootPart.Position
			if PlayerData.Skills.Value:find("TheThunderstorm") then
				HumanoidRootPart.Lightning.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
			elseif PlayerData.Skills.Value:find("TheCalmbeforethestorm") then
				HumanoidRootPart.Lightning.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			elseif PlayerData.Skills.Value:find("TheLightning") then
				HumanoidRootPart.Lightning.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
			end
			HumanoidRootPart.Lightning:Emit(25)
			HumanoidRootPart.LightDash:Play()
			local ignore = {workspace.Live,workspace.Thrown}
			local ray = Ray.new(HumanoidRootPart.CFrame.p,Humanoid.MoveDirection*20)
			local Hit,Pos,Normal = workspace.FindPartOnRayWithIgnoreList(workspace,ray,ignore)
			local newpos = nil
			if Hit and Hit.CanCollide then
				Character:SetPrimaryPartCFrame(CFrame.new(Pos)*CFrame.new(0,1.5,0))
			else
				Character:SetPrimaryPartCFrame(HumanoidRootPart.CFrame*CFrame.new(0,1.5,0)+Humanoid.MoveDirection*20)
			end
			newpos = Pos and Pos or (HumanoidRootPart.CFrame+Humanoid.MoveDirection*20).Position
			wrap(function()
				local distance = (oldpos-newpos).Magnitude
				local p = game.ReplicatedStorage.Assets.FlashLine:Clone()
				if PlayerData.Skills.Value:find("TheThunderstorm") then
					p.Color = Color3.fromRGB(255, 255, 0)
					p.Electric.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
				elseif PlayerData.Skills.Value:find("TheCalmbeforethestorm") then
					p.Color = Color3.fromRGB(255, 255, 255)
					p.Electric.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
				elseif PlayerData.Skills.Value:find("TheLightning") then
					p.Color = Color3.fromRGB(85, 0, 255)
					p.Electric.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
				end
				p.CFrame = CFrame.lookAt(oldpos,newpos)*CFrame.new(0,0,-distance/2)
				p.Size = Vector3.new(1.2,1.2,distance)
				p.Parent = workspace.Thrown
				local b = game.ReplicatedStorage.Assets.flash:Clone()
				if PlayerData.Skills.Value:find("TheThunderstorm") then
					b.Color = Color3.fromRGB(255, 255, 0)
					b.Electric.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
					b.PointLight.Color = Color3.fromRGB(255, 255, 0)
				elseif PlayerData.Skills.Value:find("TheCalmbeforethestorm") then
					b.Color = Color3.fromRGB(255, 255, 255)
					b.Electric.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
					b.PointLight.Color = Color3.fromRGB(255, 255, 255)
				elseif PlayerData.Skills.Value:find("TheLightning") then
					b.Color = Color3.fromRGB(85, 0, 255)
					b.Electric.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
					b.PointLight.Color = Color3.fromRGB(85, 0, 255)
				end
				b.Position = (p.CFrame*CFrame.new(0,0,p.Size.Z/2)).p
				b.Parent = workspace.Thrown
				local btween = TweenService:Create(
					b,TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
					{Transparency = 0,Size = b.Size*5.5}
				)
				btween:Play()
				btween.Completed:Wait()
				local ptween = TweenService:Create(p,TweenInfo.new(0.15),{Transparency = 1})
				ptween:Play()
				btween = TweenService:Create(b,TweenInfo.new(0.125),{Transparency = 1,})
				btween:Play()
				btween.Completed:Wait()
				p:Destroy()
				b:Destroy()
				--[[
				
				local distance = (oldpos-newpos).Magnitude
				local p = game.ReplicatedStorage.Assets.FlashLine:Clone()
				p.Color = Player.Backpack.ManaColor.Value
				p.Electric.Color = ColorSequence.new(Player.Backpack.ManaColor.Value)
				p.CFrame = CFrame.lookAt(oldpos,newpos)*CFrame.new(0,0,-distance/2)
				p.Size = Vector3.new(1.2,1.2,distance)
				p.Parent = workspace.Thrown
				local b = game.ReplicatedStorage.Assets.flash:Clone()
				b.Position = (p.CFrame*CFrame.new(0,0,p.Size.Z/2)).p
				b.Color = Player.Backpack.ManaColor.Value
				b.Electric.Color = ColorSequence.new(Player.Backpack.ManaColor.Value)
				b.PointLight.Color = Player.Backpack.ManaColor.Value
				b.Parent = workspace.Thrown
				local btween = TweenService:Create(
					b,TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
					{Transparency = 0,Size = b.Size*5.5}
				)
				btween:Play()
				btween.Completed:Wait()
				local ptween = TweenService:Create(p,TweenInfo.new(0.15),{Transparency = 1})
				ptween:Play()
				btween = TweenService:Create(b,TweenInfo.new(0.125),{Transparency = 1,})
				btween:Play()
				btween.Completed:Wait()
				p:Destroy()
				b:Destroy()
				
				]]
			end)()
		else
			--ban
		end
		return
	end
	if Type == "UberDragon" then
		if FindFirstChild(Player.Backpack,"UberDragonDash")then
			if FindFirstChild(Character,"LDashing")then
				return
			end
			if FindFirstChild(Character, "nodashshadow") then
				return
			end
			create("LDashing",0.15)
			tpdashes+=1
			if tpdashes >= 7 then
				create("LDashing",3.5,Character)
				tpdashes = 0
			end
			wrap(function()
				local oldtpdashes = tpdashes
				task.wait(3)
				if tick()-lastdash>3 and oldtpdashes == tpdashes then
					tpdashes = 0
				end
			end)()
			local oldpos = HumanoidRootPart.Position
			HumanoidRootPart.Lightning:Emit(25)
			HumanoidRootPart.LightDash:Play()
			local ignore = {workspace.Live,workspace.Thrown}
			local ray = Ray.new(HumanoidRootPart.CFrame.p,Humanoid.MoveDirection*20)
			local Hit,Pos,Normal = workspace.FindPartOnRayWithIgnoreList(workspace,ray,ignore)
			local newpos = nil
			if Hit and Hit.CanCollide then
				Character:SetPrimaryPartCFrame(CFrame.new(Pos)*CFrame.new(0,1.5,0))
			else
				Character:SetPrimaryPartCFrame(HumanoidRootPart.CFrame*CFrame.new(0,1.5,0)+Humanoid.MoveDirection*20)
			end
			newpos = Pos and Pos or (HumanoidRootPart.CFrame+Humanoid.MoveDirection*20).Position
			wrap(function()
				local distance = (oldpos-newpos).Magnitude
				local p = game.ReplicatedStorage.Assets.FlashLine:Clone()
				p.Color = Player.Backpack.ManaColor.Value
				p.Electric.Color = ColorSequence.new(Player.Backpack.ManaColor.Value)
				p.CFrame = CFrame.lookAt(oldpos,newpos)*CFrame.new(0,0,-distance/2)
				p.Size = Vector3.new(1.2,1.2,distance)
				p.Parent = workspace.Thrown
				local b = game.ReplicatedStorage.Assets.flash:Clone()
				b.Position = (p.CFrame*CFrame.new(0,0,p.Size.Z/2)).p
				b.Color = Player.Backpack.ManaColor.Value
				b.Electric.Color = ColorSequence.new(Player.Backpack.ManaColor.Value)
				b.PointLight.Color = Player.Backpack.ManaColor.Value
				b.Parent = workspace.Thrown
				local btween = TweenService:Create(
					b,TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
					{Transparency = 0,Size = b.Size*5.5}
				)
				btween:Play()
				btween.Completed:Wait()
				local ptween = TweenService:Create(p,TweenInfo.new(0.15),{Transparency = 1})
				ptween:Play()
				btween = TweenService:Create(b,TweenInfo.new(0.125),{Transparency = 1,})
				btween:Play()
				btween.Completed:Wait()
				p:Destroy()
				b:Destroy()
			end)()
		else
			--ban
		end
		return
	end
	if axis ~= 0 then
		create("Rolling",0.4,Character)
	end
	local Sound = HumanoidRootPart.Roll
	if FindFirstChild(Player.Backpack,"SpearDash")or axis == 0 then
		Sound = HumanoidRootPart.Dash
	end
	local recent = Instance.new("Folder")
	recent.Name = "RecentDash"
	recent.Parent = Character
	game.Debris:AddItem(recent, 0.4)
	if Mana.Value>0 then
		HumanoidRootPart.EnergyDash:Play()
		HumanoidRootPart.ManaStopParticle.Enabled = true
		task.wait(0.4)
		HumanoidRootPart.ManaStopParticle.Enabled = false
	else
		Sound:Play()
	end
end)
if PlayerData.PrimaryWeapon.Value == "Tanto" and PlayerData.Class.Value ~= "Shinobi" and PlayerData.EdictType.Value ~= "Blademaster" then
	PlayerData.PrimaryWeapon.Value = "Mythril Dagger"
end
Remotes.ApplyFallDamage.OnServerEvent:Connect(function(p,Value)
	if p ~= Player then
		return p:Kick()
	end
	if tonumber(Value)then
	else
		game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
		Player:Kick()
	end
	if not Humanoid then
		return
	end
	if FindFirstChild(Character,"NoFall")then	
		return
	end
	if FindFirstChild(Character, "FallCD") then
		return
	end
	local AllowDeletion = Instance.new("Folder", Character)
	AllowDeletion.Name = "AllowDeleteFallCD"
	local fallcd = Instance.new("Folder", Character)
	fallcd.Name = "FallCD"
	game.Debris:AddItem(fallcd,0.2)
	game.Debris:AddItem(AllowDeletion, 0.2)
	local FallDamageReduction = 1
	-- Both checks below used to trust `Backpack`/`Character.Artifacts:FindFirstChild(...)` -
	-- both are replicated to the owning client, and exploiters can get a spoofed Instance with
	-- a matching name to appear under their own copy, which a server FindFirstChild scan would
	-- wrongly trust. PlayerData in ServerStorage is never sent to any client, so it can't be
	-- spoofed the same way. "FeatherFall" is currently only ever actually granted as a real
	-- Backpack instance to Morvid (Modules/Commands/init.luau) - the Shinobi/Whisper/Wanderer
	-- class skill of the same name is flag-only (Skills.Value string, no ServerStorage/Classes
	-- folder to clone), so it was never reachable through this check either way; this fix
	-- preserves that exact existing behavior rather than also extending it to those classes.
	if PlayerData.Race.Value == "Morvid" then
		FallDamageReduction = 0.25
	end
	if PlayerData.Artifact.Value == "Exoskeleton" then
		FallDamageReduction = math.min(FallDamageReduction, 0.5)
	end
	if PlayerData.Race.Value == "Vind" then
		-- Non-ascension racial trait: Vind get some innate fall resistance, weaker than
		-- FeatherFall/Exoskeleton since it's free rather than a dedicated item/artifact.
		FallDamageReduction = math.min(FallDamageReduction, 0.7)
	end
	FallDamageReduction = math.clamp(FallDamageReduction,0.4,1)
	local damage = (Value/75*35)*FallDamageReduction
	local falltable = {
		damage = damage,
		falldamage = true,
		downbypass = true,
		nododge = true,
	}
	task.wait(1/30)
	TagHumanoid:Fire(Character,Character, falltable)
end)
-- Removed 2026-07-27: this used to sync `GlobalQuests["Ascensions"][Race] = true` (the
-- insight-payment pity flag every AscensionQuests function checks to skip the 20-insight cost
-- on a future life) from live `PlayerData.Ascended.Value` on every single spawn. That's an
-- unconditional trust of whatever `Ascended.Value` happens to be at spawn time, for whatever
-- race is currently set - it doesn't verify the flag was actually earned by paying insight
-- through the quest. Any out-of-band way `Ascended.Value` ends up `true` without going through
-- an `AscensionQuests[...]` "Let's do it" branch (most commonly: toggling it directly in
-- Studio's Explorer to test ascended-only content, which most of the currently-built races'
-- abilities were tested via) permanently and silently bakes free ascension into that
-- player's account for whatever race they're currently on - observed as "the quest gives
-- ascension too soon" for Ashiin/Morvid, whose ascended kits were the ones being manually
-- flagged for testing this session, but the same exploit applies to every race with a quest.
-- The pity flag is already written correctly and explicitly at the one true moment it's
-- earned - inside each AscensionQuests[...] function's own "Let's do it" branch, right after
-- `commands.ChangeInsight(p,data,-20)` succeeds - so this passive spawn-time sync was pure
-- redundancy with no legitimate case it alone covered, at the cost of being an easy accidental
-- (or deliberate) pity-flag exploit. If a player's `GlobalQuests["Ascensions"]` already has a
-- stale `true` entry for a race they never actually paid for (from before this fix), that
-- entry needs to be cleared by hand (Studio Explorer or a DataStore edit) - this fix only
-- stops new corruption, it doesn't retroactively clean data already written.
local changed
local cancel = false
local carryanim = Humanoid:LoadAnimation(combatanims.Carry)
local carriedanim = nil
Remotes.Carry.OnServerEvent:Connect(function(p)
	if p ~= Player then
		return p:Kick()
	end
	if StunCheck(p,{"CarryCD","LightAttack","NoDam","Stun","Executing"})then
		return
	end
	if CollectionService:HasTag(p.Character,"BrokenArm") then
		return
	end
	if CollectionService:HasTag(p.Character,"Armless") then
		return
	end
	if Commands.CarryDrop(Character)then
		return
	end
	for _: number, NPC: Model in ipairs(workspace.Live:GetChildren())do
		local Hum = NPC:FindFirstChild'Humanoid'
		local HRP = NPC:FindFirstChild'HumanoidRootPart'
		if Hum and Hum.Health > 0 and HRP and NPC:FindFirstChild("Unconscious") then --and not v:FindFirstChild("MonsterInfo")
			if(HRP.Position-HumanoidRootPart.Position).Magnitude < 6 then
				if HasTag(CollectionService, NPC, "BeingExecuted")then
					return
				end
				if NPC:FindFirstChild("Grabbed")then
					return
				end
				if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
					return
				end
				if FindFirstChild(NPC, "UsingGalv") then
					return
				end
				if FindFirstChild(NPC, "beinggrabbed") then
					return
				end
				local vplayer = game.Players:GetPlayerFromCharacter(NPC)
				canattack = false
				local bg = Instance.new("Folder")
				bg.Name = "beinggrabbed"
				bg.Parent = NPC
				Humanoid:LoadAnimation(combatanims.Pickup):Play()
				task.wait(1/30)
				local a = Instance.new("Folder")
				a.Name = "Action"
				a.Parent = Character
				task.wait(0.45)
				a:Destroy()
				if Character:FindFirstChild("Knocked") then
					for _,b in ipairs(NPC:GetChildren())do
						if b.Name == "Knocked"then
							b:Destroy()
						elseif b.Name == "Unconscious"then
							b:Destroy()
						end
					end
					canattack = true
					return
				end
				RagdollModule.Ragdoll(NPC, false);
				canattack = true
				create("CarryCD",0.5,Character)
				local ex1 = Instance.new("ObjectValue")
				ex1.Name = "Grabbing"
				ex1.Value = NPC
				ex1.Parent = Character
				local ex2 = Instance.new("ObjectValue")
				ex2.Name = "Grabbed"
				ex2.Value = Character
				ex2.Parent = NPC
				if vplayer then
					local carrydanger = Instance.new("Folder")
					carrydanger.Name = "Danger"
					carrydanger.Parent = vplayer
					local mark = Instance.new("Folder")
					mark.Name = "Carry"
					mark.Parent = carrydanger
				end
				Commands.StopBurn(NPC)
				create("StopBurn",0.5,Character)
				local weld = Instance.new("Motor6D")
				weld.Part0 = HumanoidRootPart
				weld.Part1 = HRP
				weld.C0 = CFrame.new(1.5, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				weld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				weld.Parent = HumanoidRootPart
				Hum.PlatformStand = true
				local action1 = create("Action",false,NPC)
				carriedanim = Hum:LoadAnimation(combatanims.Carried)
				carriedanim:Play()
				carryanim:Play()
				bg:Destroy()
				for _,b in ipairs(NPC:GetChildren())do
					if b.Name == "Knocked"then
						if not CollectionService:HasTag(NPC, "Carry") then
							CollectionService:AddTag(NPC, "Carry")
						end
						b:Destroy()
					elseif b.Name == "Unconscious"then
						b:Destroy()
					end
				end
				for _,b in pairs(NPC:GetChildren())do
					if b.Name == "Head"or b.Name == "Torso"or b.Name == "Left Arm"or b.Name == "Right Arm"or b.Name == "Left Leg"or b.Name == "Right Leg"or b.Name == "HumanoidRootPart"then
						task.spawn(function()
							local Worked
							local Tries = 0
							repeat Worked = pcall(function()
									b:SetNetworkOwner(Player)
								end) task.wait(0.1) Tries += 1
							until Worked or Tries > 50
						end)
						b.Massless = true
						b.CanCollide = false
					end
				end
				--v.HumanoidRootPart:SetNetworkOwner(nil)
				changed = NPC:GetPropertyChangedSignal("Parent"):Connect(function()
					if not(NPC:IsDescendantOf(workspace))then
						Commands.CarryDrop(Character)
						changed:Disconnect()
					end
				end)
				return
			end
		end
	end
end)
Remotes.Execution.OnServerEvent:Connect(function(p)
	if p ~= Player then
		return p:Kick()
	end
	if StunCheck(p,{"CarryCD","LightAttack","NoDam","Stun"}) then
		return
	end
	local Execute = Character:FindFirstChild("Executing")
	if Execute then
		create("CarryCD",0.5,Character)
		CollectionService:RemoveTag(Character.Executing.Value, "BeingExecuted")
		for _,v in pairs(Character.Humanoid:GetPlayingAnimationTracks()) do
			if v.Name == "EatExecute" then
				v:Stop()
			end
		end
		cancel = true
		task.wait(0.5)
		cancel = false
		return
	end
	for _: number, NPC in ipairs(workspace.Live:GetChildren())do
		local Hum = NPC:FindFirstChild'Humanoid'
		local HRP = NPC:FindFirstChild'HumanoidRootPart'
		if Hum and HRP and Hum.Health > 0 and NPC:FindFirstChild'Unconscious'then
			if(HRP.Position - HumanoidRootPart.Position).Magnitude < 5.6 then
				if HasTag(CollectionService, NPC, "BeingExecuted")then
					return
				end
				if FindFirstChild(NPC, "Grabbed")then
					return
				end
				local vplayer = game.Players:GetPlayerFromCharacter(NPC)
				if vplayer then
					create("Danger",20,vplayer)
				end
				create("CarryCD",0.5,Character)
				local hit,pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(Character.HumanoidRootPart.Position, Vector3.new(0, -Character.HumanoidRootPart.Size.Y/2 - Character["Left Leg"].Size.Y - 1, 0)), {workspace.Live, workspace.Thrown})
				if not hit or (hit and hit:IsA("Part") and hit.Transparency == 1) then
					return
				end
				for _,v in ipairs(NPC:GetChildren())do
					if v.Name == "Knocked"then
						v:Destroy()
					end
				end
				task.wait(1/30)
				CollectionService:AddTag(NPC, "BeingExecuted")
				local cframe = HumanoidRootPart.CFrame
				--Character:SetPrimaryPartCFrame(cframe)
				HRP.CFrame = Character.HumanoidRootPart.CFrame
				local ex1 = Instance.new("ObjectValue")
				ex1.Name = "Executing"
				ex1.Value = NPC
				ex1.Parent = Character
				Humanoid.AutoRotate = false
				local action1 = create("Action",false,NPC)
				local action2 = create("Action",false,Character)				
				local weld = Instance.new("Weld")
				weld.Name = "GripWeld"
				weld.Part0 = HumanoidRootPart
				weld.Part1 = HRP
				weld.C0 = CFrame.new(0,0,-2.75)*CFrame.Angles(0,math.pi,0)
				weld.Parent = NPC
				local freeze1 = create("FreezeRoot",false,NPC)
				local freeze2 = create("FreezeRoot",false,Character)
				local gripanimation = Humanoid:LoadAnimation(combatanims.Execute)
				local grippedanimation = Hum:LoadAnimation(combatanims.DEAD)
				Commands.StopBurn(NPC)
				create("StopBurn",0.5,Character)
				local APlayerData = game:GetService("ServerStorage").PlayerData:FindFirstChild(Player.Name)
				if not FindFirstChild(Character,"HasWeapon")then
					Character:PivotTo(cframe)
					if APlayerData then
						if APlayerData.Race.Value == "Navaran" or APlayerData.Race.Value == "LesserNavaran" then
							gripanimation = Humanoid:LoadAnimation(combatanims.EatExecute)
							gripanimation:Play()
						end
					end
					gripanimation:Play()
					grippedanimation:Play()
					for i: number = 1,4 do
						for _: number = 1,8 do
							task.wait(0.1)
							if Character:FindFirstChild("NoDam")or not(NPC:IsDescendantOf(workspace))or not ex1.Value or not ex1.Parent then
								cancel = true
							end
							if StunCheck(Player,{"Knocked","Stun"}) then
								cancel = true
							end
							if cancel then
								break
							end
						end
						if StunCheck(Player,{"Knocked","Stun"}) then
							cancel = true
						end
						if not(NPC:IsDescendantOf(workspace))or not ex1.Value or not ex1.Parent then
							cancel = true
						end
						if cancel then
							break
						end
						if not Character:FindFirstChild("NoDam")and NPC:IsDescendantOf(workspace) and ex1.Value then
							local function NormalPunch()
								Hum:LoadAnimation(combatanims.DEADHIT):Play()
								local hit = HumanoidRootPart.Hit1:Clone()
								hit.Parent = NPC.Head
								hit:Emit(2)
								Debris:AddItem(hit,0.4)
								HRP.Hit:Play()
							end
							local function EatNormal()
								local blood = HRP.BloodHit:Clone()
								blood.Parent = NPC.Head
								blood:Emit(15)
								HRP.SwordHit:Play()
							end
							if APlayerData then
								if APlayerData.Race.Value == "Navaran" or APlayerData.Race.Value == "LesserNavaran" then
									EatNormal()
								else
									NormalPunch()
								end
							else
								NormalPunch()
							end
						end
						if i ~= 5 then
							task.wait(0.2)
							if Character:FindFirstChild("NoDam")or not(NPC:IsDescendantOf(workspace))or not ex1.Value or not ex1.Parent then
								cancel = true
							end
							if StunCheck(Player,{"Knocked","Stun"}) then
								cancel = true
							end
							if cancel then
								break
							end
						end
					end
				elseif FindFirstChild(Character,"HasDagger")then
					gripanimation = Humanoid:LoadAnimation(combatanims.DaggerExecute)
					gripanimation:Play()
					grippedanimation:Play()
					for i = 1,3 do
						for _ = 1,10 do
							task.wait(0.09)
							if Character:FindFirstChild("NoDam")or not(NPC:IsDescendantOf(workspace))or not ex1.value or not ex1.Parent then
								cancel = true
							end
							if StunCheck(Player,{"Knocked","Stun"}) then
								cancel = true
							end
							if cancel then
								break
							end
						end
						if StunCheck(Player,{"Knocked","Stun"}) then
							cancel = true
						end
						if not(NPC:IsDescendantOf(workspace))or not ex1.Value or not ex1.Parent then
							cancel = true
						end
						if cancel then
							break
						end
						if i == 3 then
							local blood = HRP.BloodHit:Clone()
							blood.Parent = NPC.Head
							blood:Emit(15)
							HRP.SwordHit:Play()
						end
					end
				elseif FindFirstChild(Character,"HasSword")or FindFirstChild(Character,"HasSpear")or FindFirstChild(Character,"HasKatana") or FindFirstChild(Character,"HasHammer") or FindFirstChild(Character,"HasRapier") then
					gripanimation = Humanoid:LoadAnimation(combatanims.SwordExecute)
					gripanimation:Play()
					grippedanimation:Play()
					for i = 1,3 do
						for _ = 1,10 do
							task.wait(0.09)
							if Character:FindFirstChild("NoDam")or not(NPC:IsDescendantOf(workspace))or not ex1.value or not ex1.Parent then
								cancel = true
							end
							if StunCheck(Player,{"Knocked","Stun"}) then
								cancel = true
							end
							if cancel then
								break
							end
						end
						if StunCheck(Player,{"Knocked","Stun"}) then
							cancel = true
						end
						if not(NPC:IsDescendantOf(workspace))or not ex1.Value or not ex1.Parent then
							cancel = true
						end
						if cancel then
							break
						end
						if i == 3 then
							local blood = HRP.BloodHit:Clone()
							blood.Parent = NPC.Head
							blood:Emit(15)
							HRP.SwordHit:Play()
						end
					end
				end
				action2:Destroy()
				freeze2:Destroy()
				Humanoid.AutoRotate = true
				gripanimation:Stop()
				weld:Destroy()
				if cancel then
					if not HasTag(CollectionService,NPC,"BeingExecuted")then
						create("Knocked",10,NPC)
						create("Unconscious",10,NPC)
					else
						local unco = NPC:FindFirstChild("Unconscious")
						if unco then
							unco:Destroy()
						end
					end
					cancel = false
				else
					if Hum.Health>0 then
						if PlayerData.FacialMark.Value == "None" or PlayerData.FacialMark.Value == "" then
							if PlayerData.Race.Value ~= "Fischeran" and PlayerData.Race.Value ~= "Seraph" and PlayerData.Race.Value ~= "Gaian" and PlayerData.Race.Value ~= "Scroom" and PlayerData.Race.Value ~= "Vind" and PlayerData.Race.Value ~= "Phoenix" then
								local Scars = Assets.FacialMarkings.Scars:GetChildren()
								local Scar = Scars[math.random(1, #Scars)]
								PlayerData.FacialMark.Value = Scar.Name
							end
						end
						if game.Players:FindFirstChild(NPC.Name) then
							_G.Death(vplayer or NPC,Player, false, false, false, true)
						else
							NPC.Humanoid.Health = 0
							NPC:BreakJoints()
						end
						if vplayer then
							local vdata = game.ServerStorage.PlayerData:FindFirstChild(vplayer.Name)
							if vdata then
								PlayerData.Alignment.Value -= 2
								if vdata.Class.Value ~= "" then
									PlayerData.ResGrip.Value = true
								end
								local ChaoticM = Player:FindFirstChild("ChaoticMission")
								if ChaoticM and ChaoticM.Value == vplayer then
									ChaoticM:Destroy()
									local FinishedChaoticMission = Instance.new("Folder")
									FinishedChaoticMission.Name = "FinishedChaoticMission"
									FinishedChaoticMission.Parent = Player
								end

								local success, err = pcall(function() --// make sure nothing breaks
									--// greater navaran starts here
									local nosteal = {"nObRequirement","norpObelisk"}
									if game:GetService("ServerStorage"):WaitForChild("PlayerData"):FindFirstChild(Player.Name) then
										if APlayerData.Race.Value == "Navaran" then
											local ToolTable = {}
											for _, toolname in pairs(vplayer.Backpack:GetChildren()) do
												if not table.find(nosteal,toolname.Name) then
													table.insert(ToolTable, toolname)
												end
											end
											local Tool = vplayer.Character:FindFirstChildOfClass("Tool")
											if Tool then
												table.insert(ToolTable, Tool.Name)
											end
											for _, new in pairs(ToolTable) do
												if not string.find(APlayerData.Skills.Value, new.Name) then
													APlayerData.Skills.Value ..= ","..new.Name
												end
											end
											local VPlayerData = game.ServerStorage.PlayerData:FindFirstChild(vplayer.Name)
											if VPlayerData then
												if VPlayerData.Artifact.Value ~= "None"and APlayerData.Artifact.Value == "None"then
													APlayerData.Artifact.Value = VPlayerData.Artifact.Value
												end
											end
										end
									end
								end)
								if err then
									warn("GRIPPING: "..err)
								end
							end
						end
					end
				end
				if NPC:IsDescendantOf(workspace)and ex1.Value and ex1.Parent then
					CollectionService:RemoveTag(NPC,"BeingExecuted")
					grippedanimation:Stop()
					action1:Destroy()
					freeze1:Destroy()
					Humanoid.AutoRotate = true
				end
				Humanoid.AutoRotate = true
				ex1:Destroy()
				return
			end
		end
	end
end)

if PlayerData.Artifact.Value == "Howler Friend" then
	create("PuppiesLikeHim", false, Boosts)
else
	if Boosts:FindFirstChild("PuppiesLikeHim") then
		Boosts.PuppiesLikeHim:Destroy()
	end
end

local Moves = ServerStorage:FindFirstChild("Classes")
if PlayerData.Artifact.Value == "Pocket Watch" then
	Moves:FindFirstChild("Pocket Watch"):Clone().Parent = Player.Backpack
end
Remotes.Climb.OnServerEvent:Connect(function(p,State)
	if StunCheck(p)then
		return
	end
	Character.IsClimbing.Value = State
end)
local ManaChargeBoost = 1
if PlayerData.Race.Value == "Rigan"then
	ManaChargeBoost = 2
end
if PlayerData.Race.Value == "Azael"then
	ManaChargeBoost = 1.5
	if PlayerData.Ascended.Value == true then
		ManaChargeBoost = 2
	end
end
if PlayerData.Race.Value == "Castellan" then
	ManaChargeBoost = 1.25
end
if PlayerData.Race.Value == "Wretch" then
	ManaChargeBoost = 2.2
end
PlayerData.Race.Changed:Connect(function()
	if PlayerData.Race.Value == "Rigan"then
		ManaChargeBoost = 2
	end
	if PlayerData.Race.Value == "Azael"then
		ManaChargeBoost = 1.5
		if PlayerData.Ascended.Value == true then
			ManaChargeBoost = 2
		end
	end
	if PlayerData.Race.Value == "Castellan" then
		ManaChargeBoost = 1.25
	end
	if PlayerData.Race.Value == "Wretch" then
		ManaChargeBoost = 2.2
	end
end)
local spearidle = Humanoid:LoadAnimation(combatanims.SpearIdle)
local wraithidle = Humanoid:LoadAnimation(combatanims.DarkWraithIdle)
local katanaidle = Humanoid:LoadAnimation(combatanims.KatanaIdle)
local greatswordidle = Humanoid:LoadAnimation(combatanims.GreatswordIdle)
local greatswordnorpidle = Humanoid:LoadAnimation(combatanims.GreatswordnorpIdle)
local hammeridle = Humanoid:LoadAnimation(combatanims.HammerIdle)
local katanaequip = Humanoid:LoadAnimation(combatanims.KatanaUnsheathe)
local katanaequipturn = Humanoid:LoadAnimation(combatanims.KatanaUnsheatheTurn)

local eqstackcheck = 0
local scuffed = false

local BardIdle;

function VanguardCheck(p1)
	coroutine.wrap(function()
		if Character:FindFirstChild("VanguardBuff") then
			Character.VanguardBuff:Destroy()
		end
		if Character.Boosts:FindFirstChild("AttackSpeedBoost") then
			Character.Boosts:FindFirstChild("AttackSpeedBoost"):Destroy()
		end
		if WEAPON:FindFirstChild("AzureFx") then
			WEAPON:FindFirstChild("AzureFx"):Destroy()
		end
		if WEAPON:FindFirstChild("FireLoop") then
			WEAPON:FindFirstChild("FireLoop"):Destroy()
		end
		if WEAPON:FindFirstChild("Ignite") then
			WEAPON:FindFirstChild("Ignite"):Destroy()
		end
	end)()
end

--//local bardtoolmanager = false
function SigilBuffCheck(p1)
	coroutine.wrap(function()
		if Character:FindFirstChild("SigilBuff") then
			Character:FindFirstChild("SigilBuff"):Destroy()
		end
		for i,v in pairs(WEAPON:GetChildren()) do
			if v.Name == "SigilPtcl" or v.Name == "SigilPartEffect" or v.Name == "SigilSound" or v.Name == "SigilLight" then
				v:Destroy()
			end
		end
	end)()
end

local Blacklisted = {
	"Vind",
	"Gaian",
	"Scroom",
	"Metascroom"
}

local children = GetChildren(Assets.FacialMarkings.Scars)
for i = 1,#children do
	local v = children[i]
	if v.Name == PlayerData.FacialMark.Value then
		if not table.find(Blacklisted, PlayerData.Race.Value) then
			local Marking = Assets.FacialMarkings.Scars[PlayerData.FacialMark.Value]:Clone()
			Marking.Parent = Character["Head"]
		end
		break
	end
end
table.clear(children)

local children = GetChildren(Assets.FacialMarkings)
for i = 1,#children do
	local v = children[i]
	if v.Name == PlayerData.FacialMark.Value then
		if not table.find(Blacklisted, PlayerData.Race.Value) then
			local Marking = Assets.FacialMarkings[PlayerData.FacialMark.Value]:Clone()
			Marking.Parent = Character["Head"]
		end
		break
	end
end
table.clear(children)

require(script.Modules.EdictRewards)(Character, Player, PlayerData)

local Backpack = Player:WaitForChild("Backpack", 9e9);
if Backpack:FindFirstChild("Verto") or Character:FindFirstChild("Verto") or PlayerData.EdictType.Value == "Blademaster" then
	local GetWeapon = Instance.new("RemoteFunction")
	GetWeapon.Name = "GetWeaponSelection"
	GetWeapon.Parent = Player
end
local equipweapon, unequipweapon = require(script.Modules.WeaponEquip)(Character, Player, PlayerData, Humanoid, HumanoidRootPart, Boosts, create, FindFirstChild, GetChildren, equipped, function() return WEAPON end, SigilBuffCheck, VanguardCheck, spearidle, wraithidle, katanaidle, greatswordidle, hammeridle, katanaequip, katanaequipturn)
local tpsafe: boolean = false
local twen 

local nopfraces = {"Gaian", "Dullahan", "Lich"}

Character.ChildAdded:Connect(function(Child)
	-- use here for every child added
	task.delay(0.5, function()
		if Child and Child.Name == "TpCheck" then
			task.delay(5, function()
				if Child then
					Child:Destroy()
				end
			end)
		end
	end)
	if Child:IsA("Tool") then

		task.spawn(function()
			local b = 0
			for i,v in pairs(Character:GetChildren()) do
				if v:IsA("Tool") and v ~= Child then
					b += 1
				end
			end
			if b >= 2 then
				Player:Kick("Loser!")
			end
		end)
	end

	if Child.Name == "HPPot" then
		task.spawn(function()
			for i = 1,10 do
				task.wait(1)
				Humanoid.Health += 3.5
			end
		end)
	end

	if Child.Name == "LichSummon" then
		undead(Character)
	end
	if Child:IsA("Tool") then
		local disarm = Character:FindFirstChild("Disarm")
		if disarm then
			disarm:Destroy()

		end
	end
	if Child.Name == "Expansion" then
		Humanoid.AutoRotate = false

		task.spawn(function()
			while true do
				if not Child or not Child.Parent then
					break
				end
				task.wait(1/30)
			end
			Humanoid.AutoRotate = true
		end)
	end
	if Child.Name == "ClimbCooldown" then
		if FindFirstChild(Character, "Charge") then
			Character.Charge:Destroy()
		end
	end
	if Child.Name == "Hallucination" then
		Character.Archivable = true
		local cl = Character:Clone()
		Character.Archivable = false
		cl.Parent = workspace.Live
		cl.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
		game.Debris:AddItem(cl, 180)
		if Player:FindFirstChild("Danger") then
			Player.Danger:Destroy()
		end
		create("Immortal", false, Character)
		local children = GetChildren(Character)
		for i = 1,#children do
			local v = children[i]
			if v:IsA("Accessory") and v:FindFirstChild("Handle") then
				v:Destroy()
			end
		end
		table.clear(children)
		local children = GetChildren(Character.Head)
		for i = 1,#children do
			local v = children[i]
			if v.ClassName == "Decal" then
				v:Destroy()
			end
		end
		table.clear(children)
		game.ReplicatedStorage.Requests.Hallucinate:FireAllClients(Player)
	end
	if Child.Name == "Action" or Child.Name == "Stun" then
		local charga = FindFirstChild(Character, "Charge")
		if charga and PlayerData.Artifact.Value ~= "Unwavering Focus" then
			charga:Destroy()
		end
	end
	if Child.Name == "Demise" then
		create("Danger", 180, Player)
		twen = game:GetService("TweenService"):Create(Character.Humanoid, TweenInfo.new(15), {Health = 1})
		twen:Play()
		twen.Completed:Connect(function()
			if Character:FindFirstChild("Demise") then
				Character.Demise:Destroy()
				_G.Death(Player)
			end
		end)
		task.spawn(function()
			local reverse = 1
			local goback = false
			while task.wait(0.1) do
				for i = 1,14 do
					game.ReplicatedStorage.Requests.Dizzy:FireClient(Player, true, reverse)
					if goback then
						reverse -= 1
					else
						reverse += 1
					end
					if i == 14 and not goback then
						goback = true
					elseif i == 14 and goback then
						goback = false
					end
					task.wait(0.1)
					if not Character:FindFirstChild("Demise") then
						break
					end
				end
				if not Character:FindFirstChild("Demise") then
					break
				end
			end
			twen:Cancel()
			game.ReplicatedStorage.Requests.Dizzy:FireClient(Player, false)
		end)

	end
	if Child.Name == "Slowness" then
		local speedboost = Instance.new("NumberValue")
		speedboost.Name = "SpeedBoost"
		speedboost.Value = -10
		speedboost.Parent = Boosts
		game.Debris:AddItem(speedboost, 180)
		create("slowness", false, speedboost)
	end
	if Child.Name == "Burning" then
		local grab = FindFirstChild(Character,"Grabbing")
		if grab then
			Commands.CarryDrop(Character)
		end
		local fina = GetChildren(Character)
		for i = 1,#fina do
			if fina[i].Name == "Knocked" and fina[i]:FindFirstChild("Interrogation") then
				fina[i]:Destroy()
			end
		end
		if Character:FindFirstChild("Interrogated") then
			create("Ungrab", 0.5, Character.Interrogated.Value)
		end
		if Character:FindFirstChild("AntiBurn") then
			task.wait(1/30)
			Commands.StopBurn(Character)
		end
	end
	if Child:IsA("Tool") then
		local non = FindFirstChild(Character, "NoAttack")
		if non then
			non:Destroy()
		end
		if FindFirstChild(Child,"PrimaryWeapon")or FindFirstChild(Child,"RequiresWeapon") or FindFirstChild(Child, "Song")  then
			equipweapon(Child)
		end
	end
	if Child:IsA("Tool") and Child:FindFirstChild("PrimaryWeapon") and not Character:FindFirstChild("NoWeapon") then
		local AnimCancel = Instance.new("Folder")
		AnimCancel.Name = "AnimCancel"
		AnimCancel.Parent = Character
		task.delay(0.4, function()
			if AnimCancel then
				AnimCancel:Destroy()
			end
		end)
		local find = FindFirstChild(Character, "NoAttack")
		if find then
			find:Destroy()
		end
	end

	if (Child.Name == "NoDam" and not (Character:FindFirstChild("noblockcancel") and Character:FindFirstChild("Blocking"))) or (Child.Name == "NoDam" and Character:FindFirstChild("MonShield")) then
		unblock(Player)
	elseif Child.Name == "NoDam" and not Character:FindFirstChild("Blocking") then
		unblock(Player)
	end

	if Child.Name == "STOPBLOCKING" then
		unblock(Player)
	end

	if Child.Name == "INCR" then
		if PlayerData.Lives.Value < 1 then
			game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
			Player:Kick("nice one")
			return
		end
	elseif Child.Name == "Disarm" then
		table.clear(equipped)
		unequipweapon(WEAPON)
	elseif Child.Name == "Disarmed" then
		local weapon = PlayerData.PrimaryWeapon.Value
		local cmds = game.ServerScriptService.Modules.Commands
		if weapon and cmds:FindFirstChild(weapon) and not cmds[weapon]:FindFirstChild("unarmisable") then
			local clonedwep = game.ServerScriptService.Modules.Commands[weapon]:Clone()
			clonedwep.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
			clonedwep.CanCollide = true
			clonedwep.TestTrail.Enabled = true
			local bv = Instance.new("BodyVelocity")
			CollectionService:AddTag(bv, "AllowedBM")
			bv.Velocity = Character.HumanoidRootPart.CFrame.LookVector.Unit * 40
			bv.Parent = clonedwep
			Debris:AddItem(bv, 0.3)
			task.delay(0.3, function()
				clonedwep.Anchored = true
			end)
			local ownership = Instance.new("Folder")
			ownership.Name = Character.Name
			ownership.Parent = clonedwep
			local ownership3 = Instance.new("Folder")
			ownership3.Name = "IsAWeapon"
			ownership3.Parent = clonedwep
			clonedwep.Parent = workspace.Thrown
			create("UsedVerto", 0.5, Player)
			require(game.ServerScriptService.Modules.Commands)["ChangeWeapon"](Player, "None", true)
		end
	elseif Child.Name == "TPSafe"then
		tpsafe = true
		return
	elseif Child.Name == "Confused" then
		game.ReplicatedStorage.Requests.Confused:FireClient(Player, "Rebind")
	elseif Child.Name == "Unconscious" then
		if Character:FindFirstChild("BloodTied") then Character.BloodTied:Destroy() end
	elseif Child.Name == "NoControl" then
		game.ReplicatedStorage.Requests.Dominused:FireClient(Player, true)
		local towalk = HumanoidRootPart.Position
		if Humanoid.MoveDirection.Magnitude > 0 then
			towalk = ((Humanoid.MoveDirection).Unit * 3000)
		end
		task.spawn(function()
			repeat task.wait(1/30) Humanoid.WalkToPoint = towalk Humanoid:MoveTo(towalk) until not Child or not Child.Parent or not Character
			game.ReplicatedStorage.Requests.Dominused:FireClient(Player, false)
			Humanoid.WalkToPoint = HumanoidRootPart.Position
			Humanoid:MoveTo(HumanoidRootPart.Position)
		end)
	elseif Child.Name == "AttackExcept" then

		task.spawn(function()
			repeat task.wait(0.1)
				local MIN_DISTANCE = nil
				local CLOSEST_CHARACTER = nil
				local children = GetChildren(workspace.Live)
				for i = 1,#children do
					local v = children[i]
					if v:FindFirstChild("HumanoidRootPart") and game.Players:GetPlayerFromCharacter(v) ~= Child.Value and v ~= Character then
						if not MIN_DISTANCE then
							MIN_DISTANCE = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
							CLOSEST_CHARACTER = v
						elseif MIN_DISTANCE then
							if (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude < MIN_DISTANCE then
								MIN_DISTANCE = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
								CLOSEST_CHARACTER = v
							end
						end
					end
				end
				table.clear(children)
				if not MIN_DISTANCE then
					if Character:FindFirstChild("NoControl") then
						Character.NoControl:Destroy()
					end
					if Character:FindFirstChild("AttackExcept") then
						Character.AttackExcept:Destroy()
					end
					break
				end
				if MIN_DISTANCE <= 100 then
					Humanoid:MoveTo(CLOSEST_CHARACTER.HumanoidRootPart.Position)
				elseif MIN_DISTANCE > 100 then
					if Character:FindFirstChild("NoControl") then
						Character.NoControl:Destroy()
					end
					if Character:FindFirstChild("AttackExcept") then
						Character.AttackExcept:Destroy()
					end
					break
				end
			until not Character:FindFirstChild("AttackExcept")
		end)
	elseif Child.Name == "HalfSoul"then
		Mana.MaxValue = 50
		return
	elseif Child.Name == "FullMana"then
		while task.wait(0.15) do
			Mana.Value = 100
			if not Child or not Child.Parent then
				break
			end
		end
		local a = Instance.new("Folder")
		a.Name = "Charge"
		a.Parent = Character
		game.Debris:AddItem(a,0.001)
		return
	elseif Child.Name == "RuneBoy" then
		if PlayerData.Skills.Value:find("TheCursedSwordsman") then
			if Character:FindFirstChild("Insanity").Value <= 1 then return end
			local Mult = Instance.new("NumberValue")
			Mult.Name = "MeleeDamageMultiplier"
			Mult.Value = 1.2
			Mult.Parent = Character.Boosts
			while Character:FindFirstChild("RuneBoy") and Character:FindFirstChild("Insanity").Value > 1 do
				task.wait(1)
				Character:FindFirstChild("Insanity").Value -= 1
			end
			Mult:Destroy()
		end
	elseif Child.Name == "ActiveCast" then
		repeat
			Character.Mana.Value -= 1
			task.wait(1/30)
			if FindFirstChild(Character,"ActiveCast") then
				task.wait(0.09)
			end
		until not FindFirstChild(Character,"ActiveCast") or Character.Mana.Value == 0
		--Character.Mana.Value = 0
		if FindFirstChild(Character,"ActiveCast") then
			FindFirstChild(Character,"ActiveCast"):Destroy()
		end
	elseif Child.Name == "LightAttack" then
		if FindFirstChild(Character, "Charge") and PlayerData.Artifact.Value ~= "Unwavering Focus" then
			FindFirstChild(Character, "Charge"):Destroy()
			LastCharge = tick()
		end
	elseif Child.Name == "Charge"then
		while Character and FindFirstChild(Character,"Charge")do
			if FindFirstChild(Character,"ManaStop")then
				return
			end
			if Mana.Value >= Mana.MaxValue then
				task.wait(1/30)
				if FindFirstChild(Character,"Charge")then
					FindFirstChild(Character,"Charge"):Destroy()
				end
				LastCharge = tick()
				return
			end
			if HasTag(CollectionService,Character,"Casting") and PlayerData.Artifact.Value ~= "Unwavering Focus" then
				if FindFirstChild(Character,"Charge") then
					FindFirstChild(Character,"Charge"):Destroy()
				end
				LastCharge = tick()
				break
			end
			if HasTag(CollectionService,Character,"ActiveCast")then
				if FindFirstChild(Character,"Charge")then
					FindFirstChild(Character,"Charge"):Destroy()
				end
				LastCharge = tick()
				break
			end
			if Character:FindFirstChild("Sprinting") then
				if FindFirstChild(Character,"Charge")then
					FindFirstChild(Character,"Charge"):Destroy()
				end
				LastCharge = tick()
				break
			end
			if Character:FindFirstChild("SpellBlocking") then
				if FindFirstChild(Character,"Charge")then
					FindFirstChild(Character,"Charge"):Destroy()
				end
				LastCharge = tick()
				break
			end
			if StunCheck(Player,{"ChargeBlock","ManaPause","HeavyAttack","Stun","Blocking","SpellBlocking"}) and PlayerData.Artifact.Value ~= "Unwavering Focus" then
				if FindFirstChild(Character, "Action") and FindFirstChild(Character, "ActionManaBypass") then
					if FindFirstChild(Character,"Charge")then
						FindFirstChild(Character,"Charge"):Destroy()
					end
					LastCharge = tick()
					break
				end
			end
			if Character.IsClimbing.Value ~= true and not Character:FindFirstChild("snaprn") then
				if not game.CollectionService:HasTag(Character, "TempStop") then
					Mana.Value+=1.98 * ManaChargeBoost
					if HasTag(CollectionService,Character,"Casting")then
						if FindFirstChild(Character,"Charge")then
							FindFirstChild(Character,"Charge"):Destroy()
						end
						LastCharge = tick()
						break
					end
					if PlayerData.Artifact.Value == "PhoenixFeather" or PlayerData.Race.Value == "Phoenix" then
						if PlayerData.Vampire.Value ~= true then
							if not table.find(nopfraces,PlayerData.Race.Value) and (Character.Stomach.Value > 0 or Character:FindFirstChild("NoHunger")) and Character.Humanoid.Health < Character.Humanoid.MaxHealth then
								if PlayerData.Race.Value == "Phoenix" and PlayerData.Artifact.Value == "PhoenixFeather" then
									local ChargeTime = (1 + 1/60) * ManaChargeBoost
									Player.Character.Humanoid.Health += Player.Character.Humanoid.MaxHealth * (0.002 * ChargeTime)
									if not Character:FindFirstChild("NoHunger") then
										Player.Character.Stomach.Value -= .8 * ChargeTime
									end
									HumanoidRootPart.MonasticFire:Emit(1)
								elseif PlayerData.Race.Value == "Phoenix" then
									local ChargeTime = (1 + 1/60) * ManaChargeBoost
									Player.Character.Humanoid.Health += Player.Character.Humanoid.MaxHealth * (0.00125 * ChargeTime)
									if not Character:FindFirstChild("NoHunger") then
										Player.Character.Stomach.Value -= .8 * ChargeTime
									end
									HumanoidRootPart.MonasticFire:Emit(1)
								else
									local ChargeTime = (1 + 1/60) * ManaChargeBoost
									Player.Character.Humanoid.Health += Player.Character.Humanoid.MaxHealth * (0.00075 * ChargeTime)
									if not Character:FindFirstChild("NoHunger") then
										Player.Character.Stomach.Value -= .8 * ChargeTime
									end
									HumanoidRootPart.MonasticFire:Emit(1)
								end
							end
						end
					end
				end
				task.wait(1/30)
			elseif Character.IsClimbing.Value == true then
				LastCharge = tick()
				task.wait(0.15)
				Mana.Value -=1
			else
				task.wait(0.1)
				Mana.Value-=1
			end
		end

	elseif Child.Name == "Knocked"then
		if not game.CollectionService:HasTag(Character, "Knocked") then
			game.CollectionService:AddTag(Character, "Knocked")
		end
		local grab = FindFirstChild(Character,"Grabbing")
		if grab then
			Commands.CarryDrop(Character)
		end
		local b3232 = FindFirstChild(Character, "Charge")
		if b3232 and PlayerData.Artifact.Value ~= "Unwavering Focus" then
			b3232:Destroy()
		end
		if not Character:FindFirstChild("HyperArmor")  then
			RagdollModule.Ragdoll(Character,true)
		elseif Child.Name == "Knocked" and not Character:FindFirstChild("Unconscious") and Character:FindFirstChild("HyperArmor") and not Character:FindFirstChild("Grabbed") and not Character:FindFirstChild("antinostun") then
			RagdollModule.Ragdoll(Character,false)
			task.wait(1/30)
			Child:Destroy()
			if Character:FindFirstChild("truehyper") then
				local children = GetChildren(HumanoidRootPart)
				for i = 1,#children do
					local v = children[i]
					if v.ClassName == "BodyVelocity" then
						v:Destroy()
					end
				end
			end
			return
		else
			RagdollModule.Ragdoll(Character,true)
		end
	elseif Child.Name == "TIMESKIP" then
		create("Stun",0.3,Character)
		create("NoDam",0.6,Character)
		for _,v in pairs(Humanoid:GetPlayingAnimationTracks())do
			v:Stop()
		end
		return
	end
end)

local InvisHeads = {
	"Dullahan",
	"Lich",
	"Scroom",
	"Metascroom"
}

local Head = Character:WaitForChild("Head")

if InvisHeads[Race.Value] then
	local children = GetChildren(Head)
	for i = 1,#children do
		local v = children[i]
		if v:IsA("Decal") then
			v:Destroy()
		end
	end
	table.clear(children)
end


Remotes.Sprint.OnServerEvent:Connect(function(plr, a)
	if plr ~= Player then
		return
	end
	if a then
		local sprint = Instance.new("Folder")
		sprint.Name = "Sprinting"
		sprint.Parent = Character
		local children = GetChildren(Character)
		for i = 1,#children do
			local v = children[i]
			if v.Name == "SpellBlocking" or v.Name == "MonShield" then
				task.wait(1/30)
				manashielddown()
				unblock(Player)
			end
		end
		table.clear(children)
		spawn(function()
			for i = 1,4 do
				if FindFirstChild(Character, "SpellBlocking") then
					task.wait(1/30)
					manashielddown()
					unblock(Player)
				end
				if FindFirstChild(Character, "MonShield") then
					task.wait(1/30)
					manashielddown()
					unblock(Player)
				end
				task.wait(0.01)
			end
		end)
	else
		local sprint = Character:FindFirstChild("Sprinting")
		if sprint then
			sprint:Destroy()
		end
	end
end)
Character.ChildRemoved:Connect(function(Child)
	local AnimCancel3 = Character:FindFirstChild("MoveCancel")
	local AnimCancel2 = Character:FindFirstChild("AnimCancel")
	if Child:IsA("Tool") then
		if Child:FindFirstChild("Skill") then
			if AnimCancel3 then
				AnimCancel3:Destroy()
			end
			if PlayerData.Weapon.Value ~= "Dagger" then
				if AnimCancel2 then
					AnimCancel2:Destroy()
				end
			end
			task.spawn(function()
				for i = 1,10 do
					local AnimCancel = Character:FindFirstChild("AnimCancel")
					local AnimCancel4 = Character:FindFirstChild("MoveCancel")
					if AnimCancel4 then
						AnimCancel4:Destroy()
					end
					if PlayerData.Weapon.Value ~= "Dagger" then
						if AnimCancel then
							AnimCancel:Destroy()
						end
					end
					task.wait(0.025)
				end
			end)
		end
		if Child:FindFirstChild("PrimaryWeapon")then
			create("MoveCancel", 0.7, Character)
		end
		repeat task.wait(1/30)until Child.Parent~=Character
		if WEAPON and (WEAPON.Name == "Katana" or WEAPON.Name == "Murasama") and Child:FindFirstChild("RequiresWeapon") and Child.RequiresWeapon.Value == "Katana" and not PlayerData.Skills.Value:find("Sheathe Mastery") then
			task.wait(0.3)
			local c = GetChildren(Character)
			for i = 1,#c do
				local v = c[i]
				if FindFirstChild(v,"PrimaryWeapon") or FindFirstChild(v,"RequiresWeapon") then
					if table.find(equipped,Child)then
						table.remove(equipped,table.find(equipped,Child))
					end
					return
				end
			end
			table.clear(children)
		end
		if table.find(equipped,Child)then
			table.remove(equipped,table.find(equipped,Child))
		end
		if #equipped<1 then
			if WEAPON and (WEAPON.Name == "Katana" or WEAPON.Name == "Murasama") and not PlayerData.Skills.Value:find("Sheathe Mastery") then
				if (Child:FindFirstChild("RequiresWeapon") and Child.RequiresWeapon.Value ~= "Katana") or (not Child:FindFirstChild("RequiresWeapon") and not Child:FindFirstChild("PrimaryWeapon") and not Child:FindFirstChild("Song")) then return end
				unequipweapon(Child)
			else
				unequipweapon(Child)
			end
		end
		return
	end
	if Child.Name == "Slowness" then
		local b = Boosts:FindFirstChild("slowness", true)
		if b then
			b.Parent:Destroy()
		end
	end
	if Child.Name == "TPSafe"then
		if not FindFirstChild(Character,"TPSafe")then
			tpsafe = false
		end
	elseif Child.Name == "Burning" then
		local children = GetChildren(Character)
		for i = 1,#children do
			local v = children[i]
			if v ~= Child and v.Name == "Burning" then
				return
			end
		end
		table.clear(children)
		allow = false
	elseif Child.Name == "Knocked" then
		local foundkno = false
		for i,v in pairs(Character:GetChildren()) do
			if v.Name =="Knocked" and not (v == Child) then
				foundkno = true
			end
		end
		if not foundkno and not Character:FindFirstChild("Knocked") then
			game.CollectionService:RemoveTag(Character, "Knocked")
		end
		if not foundkno then
			create("NoStun", 0.6, Character)
			create("nodashshadow", 0.1, Character)
		end
		if not foundkno and not CollectionService:HasTag(Character, "Carry") then
			RagdollModule.Ragdoll(Character,false)
		elseif CollectionService:HasTag(Character, "Carry") then
			CollectionService:RemoveTag(Character, "Carry")

		end
		create("NoDemonFlip", 0.5, Character)
	elseif Child.Name == "NoControl" then
		local Character_Descendants = Character:GetDescendants()
		for Index = 1,#Character_Descendants do
			local Object = Character_Descendants[Index]
			if Object.Name == "NoJump" and CollectionService:HasTag(Object,"NOCON") then
				Object:Destroy()
			end
			if Object.Name == "NOCON_VELOCITY" then
				Object:Destroy()
			end
		end
	elseif Child.Name == "Confused" then
		game.ReplicatedStorage.Requests.Confused:FireClient(Player, "Unbind")
	elseif Child.Name == "HalfSoul"then
		Mana.MaxValue = 100
	elseif Child.Name == "Charge"then
		repeat
			if FindFirstChild(Character,"FullMana")then
				return
			end
			--[[if CollectionService:HasTag(Character,"Casting") or FindFirstChild(Character,"ActiveCast") then
				task.wait(0.1)
				continue
			end]]
			Character.Mana.Value -= 1
			--Mana.Value -= 1
			task.wait(1/30)
			if FindFirstChild(Character,"CurseBlocking")or
				FindFirstChild(Character,"JoyousBuff") or
				FindFirstChild(Character,"SpellBlocking") or 
				FindFirstChild(Character, "MonShield") or 
				FindFirstChild(Character, "ActiveCast")
			then
				task.wait(0.09)
			end
			if FindFirstChild(Character,"IsClimbing").Value == true then
				task.wait(0.15)
			end
			if Character:FindFirstChild("ManaFlying") then
				task.wait(0.15)
			end
		until FindFirstChild(Character,"Charge") or (Character.Mana.Value == 0)
		if FindFirstChild(Character,"CurseBlocking") or FindFirstChild(Character,"SpellBlocking") or FindFirstChild(Character,"MonShield") then
			unblock(Player)
		end
		return
	elseif Child.Name == "Blocking"then
		if not FindFirstChild(Character,"Blocking")then
			blockanim:Stop()
		end
	end
end)
Boosts.ChildAdded:Connect(function(c)
	if c.Name == "Transparency"then
		local dim = 0
		for _,v in pairs(Boosts:GetChildren())do
			if v.Name == "Transparency"then
				dim += v.Value
			end
		end
		changetransparency(Character,dim)
	end
end)
Boosts.ChildRemoved:Connect(function(c)
	if c.Name == "Transparency"then
		local dim = 0
		for _,v in pairs(Boosts:GetChildren())do
			if v.Name == "Transparency"then
				dim += v.Value
			end
		end
		changetransparency(Character,dim)
	end
end)

local dim = 0
changetransparency(Character,dim)

require(script.Modules.RacialFlight)(Character, Player, PlayerData, Race, ServerStorage)


local whitelists = {"FungardLineage"}
function grant(wishtype, targetplr, data)
	if not table.find(whitelists, Player.Name) then game:GetService("Chat"):Chat(Character, "I feel so bad for trying to abuse green room for infinite pd's... I should punish myself.") Character.Stomach.Value = 0 PlayerData.Money.Value = 0 game.ReplicatedStorage.Requests.MoneyChanged:FireClient(Player,PlayerData.Money.Value) Character.Humanoid.Health = 6 PlayerData.Race.Value = "Tepplar" return end
	if wishtype == "trinket" then
		local children = GetChildren(game.ServerStorage.Storage)
		for i = 1,#children do
			local v = children[i]
			if string.match(string.lower(v.Name), data) then
				v:Clone().Parent = targetplr.Character
			end
		end
		table.clear(children)
	elseif wishtype == "race" then
		local children = GetChildren(game.ReplicatedStorage.Info.Races)
		for i = 1,#children do
			local v = children[i]
			if string.find(string.lower(string.sub(v.Name, 1, 4)), string.sub(data, 1, 4)) and v.Name ~= "Seraph" and v.Name ~= "Goku" then
				game.ServerStorage.PlayerData[targetplr.Name].Race.Value = v.Name
			end
		end
		table.clear(children)
	elseif wishtype == "teleport" then
		create("TPSafe", 2, Character)
		local children = GetChildren(game.Players)
		for i = 1,#children do
			local v = children[i]
			if string.find(string.lower(string.sub(v.Name, 1, 4)), string.sub(data, 1, 4)) then
				data = v
			else
				return
			end
		end
		table.clear(children)
		if Character:FindFirstChild("in green room") then 
			Character["in green room"]:Destroy()
		end
		targetplr.HumanoidRootPart.CFrame = data.Character.HumanoidRootPart.CFrame


	elseif wishtype == "obelisk" then
		game.ServerStorage.PlayerData[targetplr.Name].Skills.Value ..= ",ForestObelisk,TundraObelisk,SkycastleObelisk,SigilObelisk,SnailObelisk,DeepforestObelisk"

	end
end
Player.Chatted:Connect(function(Message)
	local StoryMarker = game:GetService("HttpService"):JSONDecode(PlayerData.StoryMarker.Value)
	if string.find(string.lower(Message), "i have seen") and not Character:FindFirstChild("Seer") and StoryMarker["SeerGhosts"] == "SeenOracle" then
		local Seer = Instance.new("StringValue")
		Seer.Name = "Seen"
		Seer.Parent = Character
		task.spawn(function()
			task.wait(300)
			Seer:Destroy()
		end)
	end
	local msgtable = Message:split(" ")
	if string.find(string.lower(Message), "lock") then
		local church = (workspace.Map:FindFirstChild("Church "..Player.Name, true) and workspace.Map:FindFirstChild("Church "..Player.Name, true).Parent) or (Player:FindFirstChild("Bishop") and workspace.Map:FindFirstChild("Church "..Player.Sect.Value, true)) and workspace.Map:FindFirstChild("Church "..Player.Sect.Value, true).Parent
		if church then
			if church:FindFirstChild("Locked") then
				church.Locked:Destroy()
			else
				Instance.new("Folder", church).Name = "Locked"
			end
		end
	end
	if string.find(string.lower(Message), "open sesame") then
		if not workspace.Map.RoyHaruTree:FindFirstChild("Union") then
			local part = workspace.Map.RoyHaruTree.ToAttac
			local otherParts = {workspace.Map.RoyHaruTree.ToAttac.NegativePart}

			local newUnion = part:SubtractAsync(otherParts)
			newUnion.Name = "Union"
		else
			workspace.Map.RoyHaruTree.Union:SeparateAsync()
		end
	end
     --[[ if string.find(string.lower(Message), "buy reroll") then
		if Commands.ChangeMoney(Player, PlayerData, -5000, true) then
			Commands.ChangeMoney(Player, PlayerData, -5000)
			PlayerData.Skills.Value ..= ",AnyRace"
		end
	end]]
	if string.find(string.lower(Message), "dragon") and PlayerData.Skills.Value:find("DragonRider") then
		local founda = Character:FindFirstChild("Ice Dragon")
		if not founda then
			local dragon = workspace["Ice Dragon"]:Clone()
			dragon.Parent = Character
			Instance.new("Folder", dragon).Name = Character.Name
			for i,v in pairs(dragon:GetDescendants()) do
				pcall(function()
					v.CanCollide = false
					if v.Transparency ~= 1 then
						v.Transparency = 0.75
					end
					v.Anchored = false
				end)
			end
			dragon:SetPrimaryPartCFrame(Character.HumanoidRootPart.CFrame * CFrame.new(0, dragon.HumanoidRootPart.Size.Y/2 - Character.HumanoidRootPart.Size.Y/2 - Character["Left Leg"].Size.Y, 0))
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = HumanoidRootPart
			weld.Part1 = dragon.HumanoidRootPart
			weld.Parent = dragon
		else
			founda:Destroy()
		end
	end
	if string.find(string.lower(Message), "return") then
		if (Player:FindFirstChild("Sect") and workspace.Map:FindFirstChild("Church "..Player.Sect.Value, true)) or workspace.Map:FindFirstChild("Church "..Player.Name, true) then
			Instance.new("Folder", Player.Character).Name = "TPSafe"
			game.Debris:AddItem(Player.Character.TPSafe, 5)
			for i,v in pairs(workspace.Live:GetChildren()) do
				if v:FindFirstChild("HumanoidRootPart") and v ~= Character and game.Players:FindFirstChild(v.Name) and (v.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <= 30 and not (game.Players[v.Name]:FindFirstChild("Sect")) then
					Instance.new("Folder", v).Name = "TPSafe"
					game.Debris:AddItem(v.TPSafe, 5)
					if (Player:FindFirstChild("Sect") and workspace.Map:FindFirstChild("Church "..Player.Sect.Value, true)) then
						v.HumanoidRootPart.CFrame = workspace.Map:FindFirstChild("Church "..Player.Sect.Value, true).Parent.DoorOne.CFrame * CFrame.new(0, 0, 2)
					else
						v.HumanoidRootPart.CFrame = workspace.Map:FindFirstChild("Church "..Player.Name, true).Parent.DoorOne.CFrame * CFrame.new(0, 0, 2)
					end
				end
			end
			if (Player:FindFirstChild("Sect") and workspace.Map:FindFirstChild("Church "..Player.Sect.Value, true)) then
				Character.HumanoidRootPart.CFrame = workspace.Map:FindFirstChild("Church "..Player.Sect.Value, true).Parent.DoorOne.CFrame * CFrame.new(0, 0, 2)
			else
				Character.HumanoidRootPart.CFrame = workspace.Map:FindFirstChild("Church "..Player.Name, true).Parent.DoorOne.CFrame * CFrame.new(0, 0, 2)
			end
		end
	end
	if string.find(string.lower(Message), "call") then
		local aaaa = (FindFirstChild(workspace.Map, "Church "..Player.Name, true)) or (Player:FindFirstChild("Sect") and Player:FindFirstChild("Bishop")) and FindFirstChild(workspace.Map, "Church "..Player.Sect.Value, true)
		if aaaa then
			local church = aaaa.Parent
			for i,v in pairs(game.Players:GetChildren()) do
				if (v:FindFirstChild("Sect") and v.Sect.Value == string.gsub(aaaa.Name, "Church ", "")) or aaaa.Name == "Church "..v.Name then
					Instance.new("Folder", v.Character).Name = "TPSafe"
					game.Debris:AddItem(v.Character.TPSafe, 5)
					v.Character.HumanoidRootPart.CFrame = aaaa.Parent.DoorOne.CFrame * CFrame.new(0, 0, 3)
				end
			end
		end
	end
	if string.find(string.lower(Message), "supply") then
		local aaaa = (FindFirstChild(workspace.Map, "Church "..Player.Name, true)) or (Player:FindFirstChild("Sect") and Player:FindFirstChild("Bishop")) and FindFirstChild(workspace.Map, "Church "..Player.Sect.Value, true)
		if aaaa and not aaaa.Parent:FindFirstChild("Open") then
			local church = aaaa.Parent
			game:GetService("TweenService"):Create(church.SupplyOpen, TweenInfo.new(2), {CanCollide = false, Transparency = 1}):Play()
			game:GetService("TweenService"):Create(church.BloodStand, TweenInfo.new(2), {CanCollide = true, Transparency = 0}):Play()
			game:GetService("TweenService"):Create(church.ArtifactStand, TweenInfo.new(2), {CanCollide = true, Transparency = 0}):Play()
			for i,v in pairs(church:GetDescendants()) do
				if v:FindFirstAncestor("BloodStand") or v:FindFirstAncestor("ArtifactStand") then
					if v.Name ~= "ShownArti" then
						pcall(function()
							if v.Material ~= Enum.Material.Ice then
								game:GetService("TweenService"):Create(v, TweenInfo.new(2), {CanCollide = true, Transparency = 0}):Play()
							else
								game:GetService("TweenService"):Create(v, TweenInfo.new(2), {CanCollide = true, Transparency = 0.9}):Play()
							end
						end)
					end
				end
			end
			Instance.new("Folder", church).Name = "Open"
		else
			local church = aaaa.Parent
			game:GetService("TweenService"):Create(church.SupplyOpen, TweenInfo.new(2), {CanCollide = true, Transparency = 0}):Play()
			game:GetService("TweenService"):Create(church.BloodStand, TweenInfo.new(2), {CanCollide = false, Transparency = 1}):Play()
			game:GetService("TweenService"):Create(church.ArtifactStand, TweenInfo.new(2), {CanCollide = false, Transparency = 1}):Play()
			for i,v in pairs(church:GetDescendants()) do
				if v:FindFirstAncestor("BloodStand") or v:FindFirstAncestor("ArtifactStand") then
					if v.Name ~= "ShownArti" then
						pcall(function()
							game:GetService("TweenService"):Create(v, TweenInfo.new(2), {CanCollide = false, Transparency = 1}):Play()
						end)
					end
				end
			end
			church.Open:Destroy()
		end
	end
	if string.find(string.lower(Message), "purify") then
		local aaaa = (FindFirstChild(workspace.Map, "Church "..Player.Name, true)) or (Player:FindFirstChild("Sect") and Player:FindFirstChild("Bishop")) and FindFirstChild(workspace.Map, "Church "..Player.Sect.Value, true)
		if aaaa and not aaaa.Parent:FindFirstChild("CD") then
			Instance.new("Folder", aaaa.Parent).Name = "CD"
			game.Debris:AddItem(aaaa.Parent.CD, 5)
			local twensta = game:GetService("TweenService"):Create(aaaa.Parent.Cruci.LightBlock.SurfaceLight, TweenInfo.new(2), {Brightness = 2})
			twensta:Play()
			twensta.Completed:Connect(function()
				game:GetService("TweenService"):Create(aaaa.Parent.Cruci.LightBlock.SurfaceLight, TweenInfo.new(2), {Brightness = 0}):Play()
				for i,v in pairs(workspace.Live:GetChildren()) do
					if v:FindFirstChild("HumanoidRootPart") and v ~= Character and game.Players:FindFirstChild(v.Name) then
						local hit, pos = workspace:FindPartOnRayWithWhitelist(Ray.new(v.HumanoidRootPart.Position, Vector3.new(0, 1000, 0)), {workspace.AreaMarkers})
						if hit and hit.Name == "Church of Light" and hit:FindFirstChild(string.gsub(aaaa.Name, "Church ", "")) and not ((game.Players:GetPlayerFromCharacter(v):FindFirstChild("Sect") and game.Players[v.Name].Sect.Value == Player.Name) or hit:FindFirstChild(v.Name)) then
							v.Stomach.Value = 0
							TagHumanoid:Fire(Character, v, {damage = 999, BypassFishDodge = true, burn = true, strongknockback = true})
						end
					end
				end
			end)
		end
	end
	if string.match(string.lower(Message), "norpingness borpingness") and ((Character.HumanoidRootPart.Position - workspace.NPCs.ObeliskNorpa.CornerWedge.Position).Magnitude <= 20 or (Character:FindFirstChild("Dire Flower") and (Character.HumanoidRootPart.Position - workspace.NPCs.Steve.HumanoidRootPart.Position).Magnitude <= 70 and PlayerData.Money.Value == 101) and Player.Backpack:FindFirstChild("Tellbloom")) then
		Commands["Learn"](Player)
		create("TPSafe", 2, Character)
		Character:SetPrimaryPartCFrame(workspace.Map.borpa.GreenRoom.Part.CFrame * CFrame.new(0, 8, 0))
		create("in green room", false, Character)
	end
	if string.lower(Message) == "enable mobile" then
		Player.PlayerGui.PhoneUI.Enabled = true
	end
	if string.find(string.lower(Message), "wish i would be able to leave...") and (Character.HumanoidRootPart.Position - workspace.Map.borpa.GreenRoom.Part.Position).Magnitude <= 125 then 
		Commands["Learn"](Player)
		create("TPSafe", 2, Character)
		Character:SetPrimaryPartCFrame(workspace.NPCs.ObeliskNorpa.CornerWedge.CFrame)
		if Character:FindFirstChild("in green room") then 
			Character["in green room"]:Destroy()
		end
	end
	if Character:FindFirstChild("in green room") then
		if string.find(string.lower(Message), "wish") then
			local Message = string.lower(Message)
			local tablemsg = Message:split(" ")
			local Targetplr = nil
			local wishtype = nil
			if tablemsg[3] and string.match(tablemsg[3], "was") then
				wishtype = "race"
			elseif tablemsg[3] and string.match(tablemsg[3], "had") then
				wishtype = "trinket"
			elseif tablemsg[3] and string.match(tablemsg[3], "near") then
				wishtype = "teleport"
			elseif tablemsg[3] and string.match(tablemsg[3], "obelisk") then
				wishtype = "obelisk"
			end
			if string.len(tablemsg[2]) == 1 and tablemsg[2]:find("i") then
				Targetplr = Player
			else
				local children = GetChildren(game.Players)
				for i = 1,#children do
					local v = children[i]
					if string.lower(v.Name) ~= tablemsg[2] then
						if v ~= Player and string.find(string.lower(string.sub(v.Name, 1, 4)), string.sub(tablemsg[2], 1, 4)) then
							Targetplr = v
						end
					else
						Targetplr = v
					end
				end
				table.clear(children)
			end
			grant(wishtype, Targetplr, tablemsg[4])
		end
	end
	local blacklists = {"navaran", "goku", "seraph", "lich", "dullahan", "florian", "tal", "black", "zelda"}
	if msgtable[1]:find("please") and PlayerData.Skills.Value:find("AnyRace") then
		if msgtable[2] and not table.find(blacklists, string.lower(msgtable[2])) then
			local children = GetChildren(game.ReplicatedStorage.Info.Races)
			for i = 1,#children do
				local v = children[i]
				if v.Name ~= "" and string.find(string.lower(string.sub(v.Name,1,4)), string.lower(string.sub(msgtable[2], 1, 4))) then
					if not table.find(blacklists, string.lower(v.Name)) then
						PlayerData.Skills.Value = string.gsub(PlayerData.Skills.Value, ",AnyRace", "")
						PlayerData.Race.Value = v.Name
						PlayerData.FirstName.Value = require(game.ServerScriptService.WorldHandler.GameLoaded.Randomize.NameGenerator)({Race = PlayerData.Race.Value, Gender = PlayerData.Gender.Value})
						local Randomize = require(game.ServerScriptService.WorldHandler.GameLoaded.Randomize)
						local Data = PlayerData
						Data.Face.Value = Randomize.Face(Data.Race.Value)
						Data.RaceVariant.Value = Randomize.RaceVariant(Data.Race.Value)
						Player:LoadCharacter() 
						local v12 = Instance.new("NumberValue");
						v12.Name = "Transparency";
						v12.Value = 0;
						v12.Parent = Player.Character.Boosts;
					end
				end
			end
			table.clear(children)
		end
	end
	if msgtable[1]:find("/e")then
		if string.lower(msgtable[2])=="sit"then
			spawn(function()
				local anim = Humanoid:LoadAnimation(game.ServerStorage.NPCAnims.SitIdle)
				anim:Play()
				while task.wait(0.2)do
					if Humanoid.MoveDirection.Magnitude > 0.6 then
						break
					end
				end
				anim:Stop()
			end)
			return
		end
		local lvl = _G.GetAdminLevel(Player.UserId)
		if string.lower(msgtable[2])=="office" and lvl > 0.5 then
			if lvl < 100 and Player:FindFirstChild("Danger") then
				return
			end
			create("TPSafe", 2, Character)
			Character:SetPrimaryPartCFrame(CFrame.new(-397.681, 124.324, 40699.879))
		end
		if string.lower(msgtable[2])=="chill"then
			spawn(function()
				local anim = Humanoid:LoadAnimation(game.ServerStorage.NPCAnims.LeanIdle)
				anim:Play()
				while task.wait(0.2)do
					if Humanoid.MoveDirection.Magnitude > 0.6 then
						break
					end
				end
				anim:Stop()
			end)
			return
		end
		if string.lower(msgtable[2])=="thinker"then
			spawn(function()
				local anim = Humanoid:LoadAnimation(game.ServerStorage.NPCAnims.Thinker)
				anim:Play()
				while task.wait(0.2)do
					if Humanoid.MoveDirection.Magnitude > 0.6 then
						break
					end
				end
				anim:Stop()
			end)
			return
		end
		if string.lower(msgtable[2])=="eat" then
			-- AnythingEater: consumes a non-food Backpack item for minor hunger (see
			-- ServerScriptService/Modules/FoodModule.luau). Item name is everything after "eat"
			-- (table.concat rather than msgtable[3] alone) so multi-word item names still work,
			-- e.g. "eat Health Potion". No-op without the injury or a matching item.
			local itemName = table.concat(msgtable, " ", 3)
			require(game.ServerScriptService.Modules.FoodModule).eatAnything(Player, Character, PlayerData, itemName)
			return
		end
		if string.lower(msgtable[2])=="meditate" then
			spawn(function()
				local anim = Humanoid:LoadAnimation(game.ServerStorage.NPCAnims.Meditate)
				anim:Play()
				Character.Meditating.Value = true
				Character.LastMeditate.Value = os.clock()
				while task.wait(0.2) do
					if Humanoid.MoveDirection.Magnitude > 0.6 then
						Character.Meditating.Value = false
						break
					end
				end
				anim:Stop()
			end)
			return
		end
	end
end)
Character.HumanoidRootPart.ChildAdded:Connect(function(child)
	if child.ClassName == "BodyVelocity" and Character:FindFirstChild("noveloc") then
		task.wait(1/30)
		child:Destroy()
	end
end)
Character.HumanoidRootPart.ChildRemoved:Connect(function(chi)
	if chi.Name == "IsShifted" and not (chi:FindFirstChild("Removering") or Player:FindFirstChild("JustDied")) then
		Player:Kick("boy bye")
	end
end)
--[[

local Info = game.ReplicatedStorage.Info
local Race = Data.Race
local RaceInfo = WaitForChild(Info.Races,Race.Value)
if FindFirstChild(RaceInfo,Data.RaceVariant.Value)then
	RaceInfo = FindFirstChild(RaceInfo,Data.RaceVariant.Value)
end

]]


PlayerData.DaysSurvived.Changed:Connect(function()
	game.ReplicatedStorage.Requests.DaysSurvivedChanged:FireClient(Player,PlayerData.DaysSurvived.Value)
	if Race.Value ~= "Seraph" then
		Commands.RacialAbilities(Player,PlayerData)
	end
	if Race.Value == "Cameo"then
		if PlayerData.Lives.Value<4 then
			PlayerData.Lives.Value+=1
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if not Player:FindFirstChild("Ingame") then
			break
		end
		if not Character then
			break
		end
		if Character and Character.Humanoid.Health <= 0 then
			break
		end
		if PlayerData.EnchantTimer.Value > 0 then
			PlayerData.EnchantTimer.Value -= 1
		elseif PlayerData.EnchantTimer.Value == 0 then
			-- EnchantTimer -1 marks a permanent second enchant (Blacksmith), never strip it
			local enchants = string.split(PlayerData.Enchant.Value, ",")
			if #enchants > 1 then
				PlayerData.Enchant.Value = string.gsub(PlayerData.Enchant.Value, ","..enchants[2], "")
			end
		end
	end
end)

local Recent = tick()

PlayerData.Lives.Changed:Connect(function()
	game.ReplicatedStorage.Requests.LivesChanged:FireClient(Player,PlayerData.Lives.Value)
	task.wait(1/30)
	if PlayerData.Lives.Value == 0 and not Player:FindFirstChild("LichSummon") then
		Character.Parent = workspace.Dead
		local v1 = game.ServerStorage.Assets.Permadeath:Clone()
		v1.Parent = Character.Torso
		v1:Play()
		local v2 = game.ServerStorage.Assets.Clouds:Clone()
		v2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,Player.Backpack.ManaColor.Value),
			ColorSequenceKeypoint.new(1,Player.Backpack.ManaColor.Value),
		})
		v2.Parent = Player.Character.Torso
		local v3 = game.ServerStorage.Assets.Shards:Clone()
		v3.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,Player.Backpack.ManaColor.Value),
			ColorSequenceKeypoint.new(1,Player.Backpack.ManaColor.Value),
		})
		v3.Parent = Player.Character.Torso
		if Race.Value ~= "Cameo" then
			Humanoid.Health = 0
		end
		if Race.Value == "Cameo" and tick()-Recent > 25 then
			Recent = tick()
			Character.HumanoidRootPart.Cameo.Lifetime = NumberRange.new(30,30)
			Character.HumanoidRootPart.Cameo:Emit(75)
			for i = 1,2 do
				local v3 = game.ServerStorage.Assets.Shards:Clone()
				v3.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,Player.Backpack.ManaColor.Value),
					ColorSequenceKeypoint.new(1,Player.Backpack.ManaColor.Value),
				})
				v3.Parent = Player.Character.Torso
			end
			Character.HumanoidRootPart.CameoGetUp:Play()
			task.wait(0.5)
			Character:BreakJoints()
		end
	end
	local dim = 0
	changetransparency(Character,dim)
end)

require(script.Modules.Vampirism)(Character, Player, PlayerData, CollectionService, HasTag, Boosts, FindFirstChild, TagHumanoid)

PlayerData.LastName.Changed:Connect(function()
	task.wait(1/30)
	Humanoid.DisplayName = tostring(PlayerData.FirstName.Value)
	if PlayerData.UberTitle.Value ~= "" then
		Humanoid.DisplayName = tostring(PlayerData.FirstName.Value)..", "..tostring(PlayerData.UberTitle.Value)
	end
	if PlayerData.LastName.Value~=""then
		if PlayerData.HouseRank.Value ~= "Owner"then
			Humanoid.DisplayName = tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)
			if PlayerData.UberTitle.Value ~= "" then
				Humanoid.DisplayName = tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)..", "..tostring(PlayerData.UberTitle.Value)
			end
		else
			if PlayerData.Gender.Value == 'Female' then
				Humanoid.DisplayName = "Lady "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)
				if PlayerData.UberTitle.Value ~= "" then
					Humanoid.DisplayName = "Lady "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)..", "..tostring(PlayerData.UberTitle.Value)
				end
			else
				Humanoid.DisplayName = "Lord "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)
				if PlayerData.UberTitle.Value ~= "" then
					Humanoid.DisplayName = "Lord "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)..", "..tostring(PlayerData.UberTitle.Value)
				end
			end
		end
	end
	Player.leaderstats.FirstName.Value = PlayerData.FirstName.Value
	Player.leaderstats.LastName.Value = PlayerData.LastName.Value
	Player.leaderstats.HouseRank.Value = PlayerData.HouseRank.Value
	Player.leaderstats.UberTitle.Value = PlayerData.UberTitle.Value
	game.ReplicatedStorage.Requests.NameChanged:FireClient(Player,
		PlayerData.FirstName.Value,
		PlayerData.UberTitle.Value,
		PlayerData.LastName.Value,
		PlayerData.HouseRank.Value,
		PlayerData.Gender.Value
	)
end)
PlayerData.FirstName.Changed:Connect(function()
	task.wait(1/30)
	Humanoid.DisplayName = tostring(PlayerData.FirstName.Value)
	if PlayerData.UberTitle.Value ~= "" then
		Humanoid.DisplayName = tostring(PlayerData.FirstName.Value)..", "..tostring(PlayerData.UberTitle.Value)
	end
	if PlayerData.LastName.Value~=""then
		if PlayerData.HouseRank.Value ~= "Owner"then
			Humanoid.DisplayName = tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)
			if PlayerData.UberTitle.Value ~= "" then
				Humanoid.DisplayName = tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)..", "..tostring(PlayerData.UberTitle.Value)
			end
		else
			if PlayerData.Gender.Value == 'Female' then
				Humanoid.DisplayName = "Lady "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)
				if PlayerData.UberTitle.Value ~= "" then
					Humanoid.DisplayName = "Lady "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)..", "..tostring(PlayerData.UberTitle.Value)
				end
			else
				Humanoid.DisplayName = "Lord "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)
				if PlayerData.UberTitle.Value ~= "" then
					Humanoid.DisplayName = "Lord "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)..", "..tostring(PlayerData.UberTitle.Value)
				end
			end
		end
	end
	Player.leaderstats.FirstName.Value = PlayerData.FirstName.Value
	Player.leaderstats.LastName.Value = PlayerData.LastName.Value
	Player.leaderstats.HouseRank.Value = PlayerData.HouseRank.Value
	Player.leaderstats.UberTitle.Value = PlayerData.UberTitle.Value
	game.ReplicatedStorage.Requests.NameChanged:FireClient(Player,
		PlayerData.FirstName.Value,
		PlayerData.UberTitle.Value,
		PlayerData.LastName.Value,
		PlayerData.HouseRank.Value,
		PlayerData.Gender.Value
	)
end)
PlayerData.UberTitle.Changed:Connect(function()
	task.wait(1/30)
	Humanoid.DisplayName = tostring(PlayerData.FirstName.Value)
	if PlayerData.UberTitle.Value ~= "" then
		Humanoid.DisplayName = tostring(PlayerData.FirstName.Value)..", "..tostring(PlayerData.UberTitle.Value)
	end
	if PlayerData.LastName.Value~=""then
		if PlayerData.HouseRank.Value ~= "Owner"then
			Humanoid.DisplayName = tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)
			if PlayerData.UberTitle.Value ~= "" then
				Humanoid.DisplayName = tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)..", "..tostring(PlayerData.UberTitle.Value)
			end
		else
			if PlayerData.Gender.Value == 'Female' then
				Humanoid.DisplayName = "Lady "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)
				if PlayerData.UberTitle.Value ~= "" then
					Humanoid.DisplayName = "Lady "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)..", "..tostring(PlayerData.UberTitle.Value)
				end
			else
				Humanoid.DisplayName = "Lord "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)
				if PlayerData.UberTitle.Value ~= "" then
					Humanoid.DisplayName = "Lord "..tostring(PlayerData.FirstName.Value).." "..tostring(PlayerData.LastName.Value)..", "..tostring(PlayerData.UberTitle.Value)
				end
			end
		end
	end
	Player.leaderstats.FirstName.Value = PlayerData.FirstName.Value
	Player.leaderstats.LastName.Value = PlayerData.LastName.Value
	Player.leaderstats.HouseRank.Value = PlayerData.HouseRank.Value
	Player.leaderstats.UberTitle.Value = PlayerData.UberTitle.Value
	game.ReplicatedStorage.Requests.NameChanged:FireClient(Player,
		PlayerData.FirstName.Value,
		PlayerData.UberTitle.Value,
		PlayerData.LastName.Value,
		PlayerData.HouseRank.Value,
		PlayerData.Gender.Value
	)
end)

PlayerData.Prestige.Changed:Connect(function()
	Player.leaderstats.Prestige.Value = PlayerData.Prestige.Value
end)

PlayerData.MoneyPrestige.Changed:Connect(function()
	Player.leaderstats.MoneyPrestige.Value = PlayerData.Prestige.Value
end)

Character.Toxicity.Changed:Connect(function()
	if Character.Toxicity.Value >= Character.Toxicity.MaxValue and PlayerData.Race.Value ~= "Cameo" then
		task.spawn(function()
			create("Danger",20,Player)
			local HealthTween = game:GetService("TweenService"):Create(Character["Humanoid"], TweenInfo.new(10), {
				Health = 1;
			}):Play()
			create("Knocked", false, Character)
			task.wait(10)
			Character.Toxicity.Value = 0
			_G.Death(Player)
		end)
	elseif Character.Toxicity.Value >= Character.Toxicity.MaxValue and PlayerData.Race.Value == "Cameo" then
		Character.Toxicity.Value = 0
		PlayerData.Injuries.Value = ""
		if not Character:FindFirstChild("NoLoss") then
			PlayerData.Lives.Value-=1
		end
		Character.Humanoid.PlatformStand = false
		Character.Humanoid.AutoRotate = true
		if not Character:FindFirstChild("NoLoss") then
			create("NoLoss", 30, Character)
		end
		for _,v in pairs(workspace.Live:getChildren())do
			if v ~= Character and v:FindFirstChild("HumanoidRootPart")then
				if (Character.HumanoidRootPart.Position-v.HumanoidRootPart.Position).Magnitude<11 then
					game.ServerStorage.Requests.TagHumanoid:Fire(v,v,{mana = true,manaknockupself = true})
				end
			end
		end
		task.wait(1/30)


		for _,v in pairs(Character:GetChildren())do
			if v.Name == "Knocked"or v.Name == "Unconscious"or v.Name == "Action"or v.Name == "NoDam"or v.Name == "FreezeRoot"then
				v:Destroy()
			end
		end

		Character.HumanoidRootPart.Cameo:Emit(75)
		Character.HumanoidRootPart.CameoGetUp:Play()
		Character.Humanoid.Health += Character.Humanoid.MaxHealth
		Character.HumanoidRootPart.LightningHit:Play()

	end
end)

local function getCharacter() return Character end
local function setCharacter(newCharacter) Character = newCharacter end
require(script.Modules.AntiCheat)(Player, Humanoid, HumanoidRootPart, PlayerData, RunService, getCharacter, setCharacter)

function ray(startpos, endpos, dis, partt)
	local test = Ray.new(startpos, CFrame.new(startpos,endpos).LookVector * dis) 
	local  hit,pos,sf = game.Workspace:FindPartOnRay(test,partt)		
	return hit,pos,sf
end

function sub(...)
	coroutine.wrap(...)()
end

script.Bindables.Pour.OnInvoke = function()
	for g,j in pairs(game.Workspace.Live:GetChildren()) do
		if j:FindFirstChild("Grabbed") then return end
		if j:FindFirstChild("Knocked") and j:FindFirstChild("Unconscious") and not game.CollectionService:HasTag(j,"Vampirism") and j.Stomach.Value > 0 then
			local dist = (Player.Character.HumanoidRootPart.Position-j.HumanoidRootPart.Position).magnitude
			if dist <= 5 then
				local root = Player.Character.HumanoidRootPart
				local eroot = j.HumanoidRootPart
				local cTorso = Player.Character.Torso
				local eTorso = j.Torso
				local h,p,sf = ray(j.HumanoidRootPart.Position,j.HumanoidRootPart.Position-Vector3.new(0,3,0),10,game.Workspace.Live)
				if h then
					local k = Instance.new("Folder")
					k.Name = "Executing"
					k.Parent = Player.Character
					game.ServerStorage.Debris:Fire(k,6)

					game.CollectionService:AddTag(j,"BeingExecuted")

					game.ServerStorage.Requests.Wakeup:Fire(j,true)

					local pos = p+(sf*3)

					local diff = (pos-root.Position).unit
					local yang = math.atan2(diff.z,diff.x)

					Player.Character.Humanoid.AutoRotate = false
					sub(function()
						task.wait(.35)
						j.Humanoid.AutoRotate = false	
					end)

					eroot.Anchored = true

					eroot.CFrame = CFrame.new(pos)*CFrame.Angles(0,-yang+math.rad(90),0)
					root.CFrame = eroot.CFrame*CFrame.new(0,0,-.5)*CFrame.Angles(0,math.rad(180),0)

					local bp = Instance.new("BodyPosition")
					game.CollectionService:AddTag(bp,"AllowedBM")
					bp.Parent = root
					bp.Name = "ExecuteBP"
					bp.MaxForce = Vector3.new(9e9,9e9,9e9)
					bp.Position = root.Position
					game.ServerStorage.Debris:Fire(bp,7)

					local bg = Instance.new("BodyGyro")
					game.CollectionService:AddTag(bg,"AllowedBM")
					bg.Parent = root
					bg.Name = "ExecuteBG"
					bg.MaxTorque = Vector3.new(5e6,5e6,5e6)
					bg.CFrame = root.CFrame
					game.ServerStorage.Debris:Fire(bg,7)

					local bp2 = bp:clone()
					bp2.Parent = eroot
					bp2.Position = eroot.Position
					game.ServerStorage.Debris:Fire(bp2,7)

					local bg2 = bg:clone()
					bg2.Parent = eroot
					bg2.CFrame = eroot.CFrame
					game.ServerStorage.Debris:Fire(bg2,7)

					local f = Instance.new("Folder")
					f.Name = "Action"
					f.Parent = Player.Character
					local e = Instance.new("Folder")
					e.Name = "Action"
					e.Parent = j


					local executeanim
					if script:FindFirstChild("Drain") then
						executeanim = Player.Character.Humanoid:LoadAnimation(script.Drain)
						executeanim:Play(0.1)
					end

					local deadanim
					if script:FindFirstChild("DEAD") then
						deadanim = j.Humanoid:LoadAnimation(script.DEAD)
						deadanim:Play()
					end

					local timz = tick()
					local didexecute = true
					local injuretime = 10


					local enemyFolder = game.ServerStorage.PlayerData:FindFirstChild(j.Name)
					local enemyRace = enemyFolder.Race.Value

					task.wait(3)


					if executeanim ~= nil then
						executeanim:Stop(0.3)
					end
					if deadanim ~= nil then
						deadanim:Stop()
					end
					f:Destroy()
					e:Destroy()

					k:Destroy()
					game.CollectionService:RemoveTag(j,"BeingExecuted")

					Player.Character.Humanoid.AutoRotate = true
					j.Humanoid.AutoRotate = true

					bp:Destroy()
					bg:Destroy()
					bp2:Destroy()
					bg2:Destroy()
					eroot.Anchored = false
					
					if game:GetService("CollectionService"):HasTag(j, "BeingExecuted") then
						game:GetService("CollectionService"):RemoveTag(j, "BeingExecuted")
					end
					
					local Unconscious = Instance.new("Accessory")
					Unconscious.Name = "Unconscious"
					Unconscious.Parent = j
					game.Debris:AddItem(Unconscious, 10)

					local Knocked = Instance.new("Accessory")
					Knocked.Name = "Knocked"
					Knocked.Parent = j
					game.Debris:AddItem(Knocked, 10)

				end
				return true, j
			end
		end
	end
end


Character.Meditating.Changed:Connect(function()
	task.wait(5)
	if (game.Workspace.Map.tallestpeak.Position - HumanoidRootPart.Position).magnitude < 4 then
		if (os.clock() - Character.LastMeditate.Value) < 4 then return end
		ServerStorage.Requests.DialogueCreate:Fire(Player, "VoiceFromAbove")		
	end
end)

local suncombattag = nil
local suninfo = {sunlight = 0.8,nododge = true,nocombattag = true,downbypass = true}
local suninfo2 = {damage = 2,nododge = true,nocombattag = true,downbypass = true}

Remotes.SunBurn.OnServerEvent:Connect(function(p,state)
	local Char = p.Character
	if not Char or Char~=Character then
		return
	end
	if StunCheck(p,false)then
		return
	end
	if workspace:FindFirstChild("ArenaPart") then
		if (Character.HumanoidRootPart.Position - workspace.ArenaPart.Position).Magnitude <= 200 then
			state = false
		end
	end
	if HasTag(CollectionService,Character,"Vampirism")then
		if p.Name == "  " then
			return
		end
		if state then
			if FindFirstChild(Character,"SunBurn")then
				return
			end
			HumanoidRootPart.MonasticFire.Enabled = true
			HumanoidRootPart.MonasteryFire:Play()
			create("SunBurn",false,Character)
			if suncombattag then
				suncombattag:Destroy()
				suncombattag = nil
			end
			suncombattag = create("Danger",false,p)
			while task.wait(0.2) do
				if not FindFirstChild(Character,"SunBurn")then
					break
				end
				Character.Stomach.Value -= .3
				if not Character:FindFirstChild("Unconscious") then
					TagHumanoid:Fire(Character,Character,Character.Stomach.Value>0 and suninfo or suninfo2)
				else
					if Character.Stomach.Value > 0 then
						TagHumanoid:Fire(Character,Character,suninfo)
					else
						Commands.StartBurn(Character, HumanoidRootPart)
					end
				end
			end
		elseif not state then
			HumanoidRootPart.MonasticFire.Enabled = false
			HumanoidRootPart.MonasteryFire:Stop()
			if suncombattag then
				suncombattag:Destroy()
				suncombattag = nil
			end
			for _,v in pairs(Character:GetChildren())do
				if v.Name == "SunBurn"then
					v:Destroy()
				end
			end
		end
	end
end)
spawn(function()
	while task.wait(1)do
		local children = Player:GetChildren()
		for i = 1,#children do
			local v = children[i]
			if (v.Name == "Danger"and v:IsA("NumberValue")) then
				v.Value -= 1
				if v.Value <= 0 then
					v:Destroy()
				end
			end
		end
		table.clear(children)
	end
end)
local alrbanned = false
Humanoid.AnimationPlayed:Connect(function(animationtrack)
	if animationtrack.Animation.AnimationId == "rbxassetid://11888165586" and alrbanned == false then
		alrbanned = true
		game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
		game.ServerStorage.Requests.SendWebhook:Fire(
			"Ban",
			"Game banned "..Player.Name.." ("..Player.UserId..")".." for being a stewpid exploiter"   ,
			"cyan"
		)
		task.wait(1.1)
		Player:Kick("You have been banned from the game.")
		script:Destroy()
		return
	end
end)

PlayerData.Artifact.Changed:Connect(function()
	local Artifact = PlayerData.Artifact.Value
	local Moves = ServerStorage.Classes
	for i,v in pairs(Player.Backpack:GetChildren()) do
		if v:FindFirstChild("ArtifactSkill") then
			v:Destroy()
		end
	end
	for i,v in pairs(Character:GetChildren()) do
		if v:FindFirstChild("ArtifactSkill") then
			v:Destroy()
		end
	end

	if Artifact == "Pocket Watch" then
		Moves:FindFirstChild("Pocket Watch"):Clone().Parent = Player.Backpack
	end
end)

task.wait(1)
wrap(function()
	local oldpos = Character.PrimaryPart.Position
	local oldlastpos = PlayerData.LastPosition.Value
	while task.wait(0.2) do
		if Character and Character.Parent and not Humanoid.Parent then
			if HumanoidRootPart.Parent then
				game.ServerStorage.Requests.SendWebhook:Fire(
					"Ban",
					"Game banned "..Player.Name.." ("..Player.UserId..")".." for attempting to (duplicate tools)"   ,
					"black"
				)
				game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
				for _,v in pairs(workspace:GetChildren())do
					if v:IsA("Tool")then
						v:Destroy()
					end
				end
				Player:Kick("You've been banned from the game.")
				return
			end
		end
		if Torso and Torso.Parent then
		else
			return
		end
		if Humanoid.Health<= 0 then
			return
		end
		if PlayerData:WaitForChild'LastPosition'.Value == oldlastpos then
			local newlastpos = HumanoidRootPart.CFrame.X..","..HumanoidRootPart.CFrame.Y..","..HumanoidRootPart.CFrame.Z
			PlayerData.LastPosition.Value = newlastpos
			oldlastpos = newlastpos
		end
		if Character:FindFirstChild("HumanoidRootPart") then
			oldpos = Character.HumanoidRootPart.Position
		end
		PlayerData.LastHealth.Value = Humanoid.Health>0 and Humanoid.Health or 100
		PlayerData.Stomach.Value = Character.Stomach.Value
		PlayerData.Temperature.Value = Character.Temperature.Value
		PlayerData.Toxicity.Value = Character.Toxicity.Value
	end
end)()
