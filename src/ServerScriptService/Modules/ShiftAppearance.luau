-- Shared appearance-mimicry logic, extracted from the original single-use body of
-- ServerStorage/RacialAbilities/Shift/Script.server.luau so it can be reused by: a normal Shift,
-- reapplying a saved Shift-memory slot, reverting to your own original appearance, and forcing an
-- appearance onto an unwilling target (False Assumptions). Behavior mirrors the original script
-- exactly (same asset folders, same race branches), just made re-appliable/reversible.
local CollectionService = game:GetService("CollectionService")

local FindFirstChild, WaitForChild = game.FindFirstChild, game.WaitForChild
local Faces = game.ReplicatedStorage.Assets.Faces

local ShiftAppearance = {}

local SHIFT_PIECE_TAG = "ShiftAppearancePiece"

local function displayNameFor(SourcePlayerData)
	if SourcePlayerData.HouseRank.Value == "Owner" then
		return "Lord " .. SourcePlayerData.FirstName.Value .. " " .. SourcePlayerData.LastName.Value
	end
	return SourcePlayerData.FirstName.Value .. " " .. SourcePlayerData.LastName.Value
end

-- Builds a self-contained Folder describing SourceCharacter's current appearance (Shirt/Pants,
-- handled Accessories, face Decal, race-specific head pieces are recorded by attribute and rebuilt
-- fresh on apply since they're welded per-Character). Parented under `Parent`, named `FolderName`.
function ShiftAppearance.snapshot(SourceCharacter, SourcePlayerData, Parent, FolderName)
	local folder = Instance.new("Folder")
	folder.Name = FolderName

	folder:SetAttribute("DisplayName", displayNameFor(SourcePlayerData))
	folder:SetAttribute("Race", SourcePlayerData.Race.Value)
	folder:SetAttribute("RaceVariant", SourcePlayerData.RaceVariant.Value)
	folder:SetAttribute("HeadColor", SourceCharacter.Head.Color)
	local dullahanLight = SourceCharacter:FindFirstChild("DullahanLight")
	if dullahanLight then
		folder:SetAttribute("DullahanLightColor", dullahanLight.Color)
	end
	if SourcePlayerData.Skills.Value:find("PrinceBlessing") then
		folder:SetAttribute("PrinceBlessing", true)
	end

	for _, v in pairs(SourceCharacter:GetChildren()) do
		if v:IsA("Shirt") or v:IsA("Pants") then
			v:Clone().Parent = folder
		elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
			v:Clone().Parent = folder
		end
	end

	for _, v in pairs(Faces:GetChildren()) do
		if FindFirstChild(SourceCharacter.Head, v.Name) then
			SourceCharacter.Head[v.Name]:Clone().Parent = folder
		end
	end

	folder.Parent = Parent
	return folder
end

local function clearAppearance(Character)
	for _, v in pairs(Character:GetChildren()) do
		if v:IsA("Shirt") or v:IsA("Pants") then
			v:Destroy()
		end
	end
	for _, v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") and v:FindFirstChild("Handle") then
			v:Destroy()
		end
	end
	for _, v in pairs(CollectionService:GetTagged(SHIFT_PIECE_TAG)) do
		if v:IsDescendantOf(Character) then
			v:Destroy()
		end
	end
	for _, v in pairs(Faces:GetChildren()) do
		if FindFirstChild(Character.Head, v.Name) then
			Character.Head[v.Name]:Destroy()
		end
	end
	Character.Head.Transparency = 0
end

local function applyRacePieces(Character, snapFolder)
	local Race = snapFolder:GetAttribute("Race")
	if Race == "Kasparan" then
		for _, v in pairs(game.ServerStorage.Assets.KasparanHorns:GetChildren()) do
			local c = v:Clone()
			CollectionService:AddTag(c, SHIFT_PIECE_TAG)
			c.Parent = Character:WaitForChild("Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	elseif Race == "Azael" then
		for _, v in pairs(game.ServerStorage.Assets.AzaelHorns:GetChildren()) do
			local c = v:Clone()
			CollectionService:AddTag(c, SHIFT_PIECE_TAG)
			c.Parent = Character:WaitForChild("Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	elseif Race == "Zelda" then
		for _, v in pairs(game.ServerStorage.Assets.ZeldaHorns:GetChildren()) do
			local c = v:Clone()
			CollectionService:AddTag(c, SHIFT_PIECE_TAG)
			c.Parent = WaitForChild(Character, "Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	end

	if Race == "Lich" or Race == "Scroom" or Race == "Metascroom" or Race == "Dullahan" or Race == "Howler" then
		if Race == "Scroom" then
			local Variant = snapFolder:GetAttribute("RaceVariant")
			local sourceHead = game.ServerStorage.Assets.ScroomHeads:FindFirstChild(Variant)
				or game.ServerStorage.Assets.ScroomHeads:FindFirstChild("Default")
			local Head = sourceHead.ScroomHead:Clone()
			CollectionService:AddTag(Head, SHIFT_PIECE_TAG)
			Head.Weld.Part0 = Head
			Head.Weld.Part1 = Character.Head
			Head.Parent = Character
			Character.Head.Transparency = 0.99
		end
		if Race == "Metascroom" then
			local sourceHead = game.ServerStorage.Assets.ScroomHeads:FindFirstChild("Metascroom")
			if sourceHead then
				local Head = sourceHead.ScroomHead:Clone()
				CollectionService:AddTag(Head, SHIFT_PIECE_TAG)
				Head.Weld.Part0 = Head
				Head.Weld.Part1 = Character.Head
				Head.Parent = Character
				Character.Head.Transparency = 0.99
			end
		end
		if Race == "Lich" then
			local lichhead = game.ServerStorage.Assets.LichHead:Clone()
			CollectionService:AddTag(lichhead, SHIFT_PIECE_TAG)
			lichhead.Weld.Part0 = Character.Head
			lichhead.Weld.Part1 = lichhead
			lichhead.Weld.C1 = CFrame.new(0, 0, 0.2) * CFrame.Angles(math.rad(630), math.rad(90), 0)
			lichhead.Parent = Character
			Character.Head.Transparency = 0.99
		end
		if Race == "Dullahan" then
			local Head = game.ServerStorage.Assets.DullahanHead:Clone()
			CollectionService:AddTag(Head, SHIFT_PIECE_TAG)
			Head.Parent = Character
			Head.Weld.Part0 = Head
			Head.Weld.Part1 = Character.Head
			local dullahanLightColor = snapFolder:GetAttribute("DullahanLightColor")
			if dullahanLightColor then
				local Light = game.ServerStorage.Assets.DullahanLight:Clone()
				CollectionService:AddTag(Light, SHIFT_PIECE_TAG)
				Light.Color = dullahanLightColor
				Light.Weld.Part0 = WaitForChild(Character, "Head")
				Light.Parent = Character
			end
			Character.Head.Transparency = 0.99
		end
		if Race == "Howler" then
			local Variant = snapFolder:GetAttribute("RaceVariant")
			local maneSource = game.ReplicatedStorage.Assets.HowlerManes:FindFirstChild(Variant)
			if maneSource then
				local Mane = maneSource.HowlerMane:Clone()
				CollectionService:AddTag(Mane, SHIFT_PIECE_TAG)
				Mane.Parent = Character
			end
		end
	end
end

-- Applies a snapshot Folder (from .snapshot) onto DestCharacter: clears whatever appearance is
-- currently there and clones the snapshot's pieces on.
function ShiftAppearance.apply(DestCharacter, snapFolder)
	clearAppearance(DestCharacter)

	for _, v in pairs(snapFolder:GetChildren()) do
		if v:IsA("Shirt") or v:IsA("Pants") or (v:IsA("Accessory") and v:FindFirstChild("Handle")) then
			v:Clone().Parent = DestCharacter
		end
	end

	applyRacePieces(DestCharacter, snapFolder)

	if snapFolder:GetAttribute("PrinceBlessing") then
		local bald = Instance.new("Accessory")
		bald.Name = "Bald"
		CollectionService:AddTag(bald, SHIFT_PIECE_TAG)
		bald.Parent = DestCharacter
		local model = game.ServerStorage.Assets.FusedHelm2:Clone()
		CollectionService:AddTag(model, SHIFT_PIECE_TAG)
		model.Parent = DestCharacter
	end

	for _, v in pairs(snapFolder:GetChildren()) do
		if v:IsA("Decal") then
			v:Clone().Parent = DestCharacter.Head
		end
	end

	local headColor = snapFolder:GetAttribute("HeadColor")
	if headColor then
		for _, v in pairs(DestCharacter:GetChildren()) do
			if v.Name == "Head" or v.Name == "Torso" or v.Name == "Left Arm" or v.Name == "Right Arm" or v.Name == "Left Leg" or v.Name == "Right Leg" then
				v.Color = headColor
			end
		end
	end

	local displayName = snapFolder:GetAttribute("DisplayName")
	if displayName then
		DestCharacter.Humanoid.DisplayName = displayName
	end
end

-- No-ops if StorageParent already has a ShiftOriginalAppearance child; otherwise snapshots
-- Character's current (pre-any-overwrite) appearance there. Must be called before the first ever
-- appearance overwrite for that player.
--
-- StorageParent must NOT be a PlayerData folder (game.ServerStorage.PlayerData.<Name>): the save
-- routine walks every DIRECT child of that folder and unconditionally reads `.Value` off it
-- (GameLoaded/init.server.luau, ~8 copy-pasted call sites) with no type guard — a bare Folder
-- parented there throws ("Value is not a valid member of Folder") and silently aborts that
-- player's save. Callers should pass the Player instance instead (same place `Shifted` already
-- lives) — it's outside the save walk entirely, at the cost of this data being session-only
-- (resets on rejoin, survives respawns/death within a session, same as `Shifted`).
function ShiftAppearance.snapshotOriginalIfMissing(Character, SourcePlayerData, StorageParent)
	if StorageParent:FindFirstChild("ShiftOriginalAppearance") then
		return
	end
	ShiftAppearance.snapshot(Character, SourcePlayerData, StorageParent, "ShiftOriginalAppearance")
end

-- Restores Character to StorageParent.ShiftOriginalAppearance. Returns false (no-op) if there's
-- nothing to restore from yet (snapshotOriginalIfMissing was never called).
function ShiftAppearance.restoreOriginal(Character, StorageParent)
	local original = StorageParent:FindFirstChild("ShiftOriginalAppearance")
	if not original then
		return false
	end
	ShiftAppearance.apply(Character, original)
	return true
end

return ShiftAppearance
