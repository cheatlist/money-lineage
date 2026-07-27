-- Same single-slot artifact grant pattern as Exoskeleton/Charming Stone/Playful Stone: a
-- consumable Tool, Activated-triggered, sets PlayerData.Artifact.Value and drops an Accessory
-- marker into Character.Artifacts. The actual scale effect is applied here for the character
-- that's alive right now, AND separately re-applied on every future spawn by
-- CharacterHandler/init.server.luau (see the `data.Artifact.Value == "Black Pill"` block near
-- the top of that script) - a fresh Character on respawn starts back at normal size, so without
-- that spawn-time hook the effect would only ever apply to the life you picked it up in.
local CharacterScale = require(game.ServerScriptService.Modules.CharacterScale)

function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("Action") then
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
end

local SCALE = 1.2
local FACE_STRETCH = Vector3.new(1, 1.08, 1)

local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1) then
		return
	end
	if not canuse then
		return
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	if not p2 then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not data then
		return
	end
	if (data.Artifact.Value ~= "None" and data.Artifact.Value ~= "") and data.Artifact.Value ~= "Spider Cloak" then
		return
	end
	canuse = false
	data.Artifact.Value = "Black Pill"
	local v1 = Instance.new("Accessory")
	v1.Name = "Black Pill"
	v1.Parent = p1.Artifacts

	CharacterScale.scaleR6(p1, SCALE)
	local head = p1:FindFirstChild("Head")
	if head then
		local headMesh = head:FindFirstChildWhichIsA("SpecialMesh")
		if headMesh then
			headMesh.Scale = headMesh.Scale * FACE_STRETCH
		end
	end

	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2, script.Parent.Name)
	script.Parent:Destroy()
end)
