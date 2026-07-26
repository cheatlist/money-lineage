local CollectionService = game:GetService("CollectionService")
local ShiftAppearance = require(game.ServerScriptService.Modules.ShiftAppearance)
local OptionPicker = require(game.ServerScriptService.Modules.OptionPicker)
local Commands = require(game.ServerScriptService.Modules.Commands)

local MEMORY_LIMIT = 10
local STOLEN_TAG = "StolenAbility"

local function DoAccessories(Player)
	local Character = game.Players:GetCharacterAppearanceAsync(Player.CharacterAppearanceId)
	Character.Parent = game.ServerStorage
	local Hairs,Accessories = {},{}
	for _,v in ipairs(Character:GetChildren())do
		if v:IsA("Accessory")then
			local Attachment = v:FindFirstChildWhichIsA("Attachment",true)
			if v:FindFirstChild("ParticleEmitter") then
				v:Destroy()
			end
			if v.Name:find("Snorkel") then
				table.insert(Accessories,v:Clone())
			end
			if v.Name == "EarsAccessory" then
				table.insert(Hairs,v:Clone())
			end
			if Attachment then
				if Attachment.Name == "HairAttachment" then
					table.insert(Hairs,v:Clone())
				elseif Attachment.Name == "FaceFrontAttachment"then
					table.insert(Accessories,v:Clone())
				elseif Attachment.Name == "FaceCenterAttachment"then
					table.insert(Accessories,v:Clone())
				end
			end
		end
	end
	game.Debris:AddItem(Character,1)
	return Hairs,Accessories
end
local cd = false
local embedOverrides = {
	footer = {
		icon_url = "https://media.discordapp.net/attachments/508290690619277313/977884569728593960/thrown-sapari-cat-1.gif",
		text =  "Server: ".. game.JobId.. " | Version: | "..game.PlaceVersion.." ",
	}
}

local function isAscendedMadrasian(data)
	return data.Ascended.Value == true and data.Race.Value == "Madrasian"
end

local function clearStolenAbility(Player)
	for _,v in pairs(CollectionService:GetTagged(STOLEN_TAG)) do
		if v:IsDescendantOf(Player.Backpack) or (Player.Character and v:IsDescendantOf(Player.Character)) then
			v:Destroy()
		end
	end
end

local function grantStolenAbility(Player, abilityName)
	clearStolenAbility(Player)
	if abilityName and abilityName ~= "" then
		local tool = game.ServerStorage.Classes:FindFirstChild(abilityName)
		if tool then
			local clone = tool:Clone()
			CollectionService:AddTag(clone, STOLEN_TAG)
			clone.Parent = Player.Backpack
		end
	end
end

-- Picks one skill/spell from `targetData` that `shifterData` is weapon-compatible with (checked
-- against the SHIFTER's own Weapon/PrimaryWeapon, not the target's). Random among eligible, since
-- there's no "richest ability" ranking data anywhere in this codebase to do better than random.
local function stealAbility(shifterData, targetData)
	local pool = {}
	for _,list in ipairs({targetData.Skills.Value, targetData.Spells.Value}) do
		for _,name in ipairs(string.split(list, ",")) do
			if name ~= "" then
				local tool = game.ServerStorage.Classes:FindFirstChild(name)
				if tool and Commands.CanUseTool(tool, shifterData) then
					table.insert(pool, name)
				end
			end
		end
	end
	if #pool == 0 then
		return ""
	end
	return pool[math.random(1,#pool)]
end

local function sortedMemorySlots(mem)
	local numbered = {}
	if mem then
		for _,v in pairs(mem:GetChildren()) do
			if v:IsA("Folder") then
				table.insert(numbered, v)
			end
		end
		table.sort(numbered, function(a,b) return tonumber(a.Name) < tonumber(b.Name) end)
	end
	return numbered
end

-- `mem` is parented to the Player instance, NOT PlayerData (see ShiftAppearance's
-- snapshotOriginalIfMissing comment) — the DataStore save walk unconditionally reads `.Value` off
-- every direct child of a player's PlayerData folder, and a bare Folder there throws and aborts
-- that player's save. Player-parented data is outside the save walk entirely (same place `Shifted`
-- already lives) — Shift Memory is intentionally session-only as a result (resets on rejoin,
-- survives respawns/death within a session).
local function pushMemorySlot(Player, targetCharacter, targetData, stolenAbility)
	local mem = Player:FindFirstChild("ShiftMemory")
	if not mem then
		mem = Instance.new("Folder")
		mem.Name = "ShiftMemory"
		local nextIndex = Instance.new("NumberValue")
		nextIndex.Name = "NextIndex"
		nextIndex.Parent = mem
		mem.Parent = Player
	end

	local nextIndex = mem.NextIndex
	nextIndex.Value += 1

	local slot = Instance.new("Folder")
	slot.Name = tostring(nextIndex.Value)
	local appearance = ShiftAppearance.snapshot(targetCharacter, targetData, slot, "Appearance")

	local targetName = Instance.new("StringValue")
	targetName.Name = "TargetName"
	targetName.Value = appearance:GetAttribute("DisplayName") or targetData.Name
	targetName.Parent = slot

	local stolen = Instance.new("StringValue")
	stolen.Name = "StolenAbility"
	stolen.Value = stolenAbility or ""
	stolen.Parent = slot

	slot.Parent = mem

	local numbered = sortedMemorySlots(mem)
	while #numbered > MEMORY_LIMIT do
		table.remove(numbered,1):Destroy()
	end
end

local function openMemoryPicker(Player, Character)
	local mem = Player:FindFirstChild("ShiftMemory")
	local numbered = sortedMemorySlots(mem)
	local options = {}
	local slotsByKey = {}
	for _,slot in ipairs(numbered) do
		slotsByKey[slot.Name] = slot
		table.insert(options, {key = slot.Name, label = slot.TargetName.Value})
	end
	table.insert(options, {key = "__original", label = "Return to normal"})

	local choice = OptionPicker.prompt(Player, "Shift Memory", options, 15)
	if not choice then
		return
	end
	if choice == "__original" then
		ShiftAppearance.restoreOriginal(Character, Player)
		clearStolenAbility(Player)
		return
	end
	local slot = slotsByKey[choice]
	if not slot then
		return
	end
	ShiftAppearance.apply(Character, slot.Appearance)
	grantStolenAbility(Player, slot.StolenAbility.Value)
end

script.Parent.Activated:Connect(function(Player, Character, Data)
	if cd then return end

	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Data = game.ServerStorage.PlayerData[Player.Name]

	ShiftAppearance.snapshotOriginalIfMissing(Character, Data, Player)

	local ascended = isAscendedMadrasian(Data)

	local validTarget = nil
	local mouse = _G.MouseData(Player)
	if mouse.Target and mouse.Target:IsDescendantOf(workspace.Live) and not mouse.Target:IsDescendantOf(Character) then
		local candidate = mouse.Target.Parent:FindFirstChild("HumanoidRootPart") and mouse.Target.Parent
			or mouse.Target.Parent.Parent:FindFirstChild("HumanoidRootPart") and mouse.Target.Parent.Parent
		if candidate and game.ServerStorage.PlayerData:FindFirstChild(candidate.Name) then
			validTarget = candidate
		end
	end

	if not validTarget then
		cd = true
		task.delay(2, function()
			cd = false
		end)
		if ascended then
			openMemoryPicker(Player, Character)
		else
			ShiftAppearance.restoreOriginal(Character, Player)
		end
		return
	end

	cd = true
	task.delay(2, function()
		cd = false
	end)

	local u4 = validTarget

	coroutine.wrap(function()
		local sphere = Instance.new("Part")
		sphere.Anchored = true
		sphere.CanCollide = false
		sphere.Color = Color3.fromRGB(220, 220, 220)
		sphere.Transparency = 0.5
		sphere.Material = Enum.Material.Neon
		sphere.Size = Vector3.new(0.05,0.05,0.05)
		local specialmesh = Instance.new("SpecialMesh")
		specialmesh.Parent = sphere
		specialmesh.MeshType = Enum.MeshType.Sphere
		sphere.Parent = workspace
		sphere.CFrame = Character.HumanoidRootPart.CFrame
		game:GetService("TweenService"):Create(sphere,TweenInfo.new(0.4),{Size = Vector3.new(6,6,6)}):Play()
		game.Debris:AddItem(sphere,1.5)
		wait(0.6)
		game:GetService("TweenService"):Create(sphere,TweenInfo.new(0.4),{Size = Vector3.new(0.05,0.05,0.05)}):Play()
	end)()

	local data2 = game.ServerStorage.PlayerData[u4.Name]
	local tempSnap = ShiftAppearance.snapshot(u4, data2, game.ServerStorage, "TempShiftSnap")
	ShiftAppearance.apply(Character, tempSnap)
	tempSnap:Destroy()

	game.ServerStorage.Requests.SendWebhook:Fire("Shifter",Player.Name.." ("..Player.UserId..") has shifted into. "..u4.Name,"blue","Shifter",embedOverrides)

	if Player:FindFirstChild("Shifted") then
		Player.Shifted.Value = u4.Name
	else
		local b = Instance.new("StringValue")
		b.Name = "Shifted"
		b.Value = u4.Name
		b.Parent = Player
	end

	if ascended then
		local stolen = stealAbility(Data, data2)
		grantStolenAbility(Player, stolen)
		pushMemorySlot(Player, u4, data2, stolen)
	end
end)
