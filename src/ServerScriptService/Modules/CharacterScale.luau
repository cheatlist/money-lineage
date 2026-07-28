--[[
	Manual R6 character resizing. `Humanoid.BodyHeightScale`/`BodyWidthScale`/`BodyDepthScale`/
	`HeadScale` don't exist on this game's Humanoid (confirmed live - not just unused, the
	properties themselves error), so uniform scaling has to be done the pre-scale-API R6 way:
	resize every BasePart directly, then rescale each joint's C0/C1 *position* (not rotation) by
	the same factor so the joints stay lined up instead of the limbs drifting apart or
	overlapping. Scans all Motor6D/Weld joints under the character rather than hardcoding joint
	names/locations - covers both the body's own Motor6Ds and accessories, which in this game are
	mostly attached via a plain Weld baked in from Studio at authoring time (Weld added alongside
	Motor6D 2026-07-28 - the original Motor6D-only scan silently missed most accessories' offsets,
	since Motor6D-attached accessories turned out to be the rare case, not the common one).

	2026-07-28: also resizes each Accessory's own Handle (and its SpecialMesh.Scale, if any) by
	the same factor, so accessories actually get physically bigger/smaller along with the rig
	instead of just moving out to a rescaled attachment point at their original size (this is
	the actual "accessories scale with the rig" fix - the Weld/Motor6D scaling above only moves
	the attachment point, it doesn't touch the accessory's own size).

	2026-07-28 (later same day): race-specific hair/accessories are attached asynchronously by
	`Commands.UpdateAppearance` (a `task.spawn` inside it, `Modules/Commands/init.luau` ~line 149),
	itself called from `GameLoaded/init.server.luau` - a completely separate script from
	`CharacterHandler/init.server.luau` (which is where `scaleR6` gets called for the new height
	system) with no execution-order guarantee between the two. `scaleR6` only scales whatever
	Accessories are already parented to the character *at the moment it runs* - if hair attaches
	afterward, it's never touched, and stays at its original (unscaled) size while the body is
	already bigger, reading as "hair too small," worse the bigger the character rolled. See
	`module.watchForLateAccessories` below for the fix.
]]

local module = {}

local PART_NAMES = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}

local function scalePosition(cf, factor)
	return CFrame.new(cf.Position * factor) * (cf - cf.Position)
end

local function scaleAccessory(accessory, factor)
	local handle = accessory:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		handle.Size = handle.Size * factor
		local mesh = handle:FindFirstChildWhichIsA("SpecialMesh")
		if mesh then
			mesh.Scale = mesh.Scale * factor
		end
	end
end

function module.scaleR6(character, factor)
	for _, name in ipairs(PART_NAMES) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			part.Size = part.Size * factor
		end
	end
	for _, joint in pairs(character:GetDescendants()) do
		if joint:IsA("Motor6D") or joint:IsA("Weld") then
			joint.C0 = scalePosition(joint.C0, factor)
			joint.C1 = scalePosition(joint.C1, factor)
		end
	end
	for _, accessory in ipairs(character:GetChildren()) do
		if accessory:IsA("Accessory") then
			scaleAccessory(accessory, factor)
		end
	end
end

-- Scales any Accessory added to `character` *after* this is called, by the same `factor` an
-- earlier `scaleR6(character, factor)` call already applied to the body - covers hair/accessories
-- that attach asynchronously later in the spawn sequence (see the module comment above). Safe to
-- leave connected for the character's whole life: it only ever touches real Accessory instances
-- with a Handle (cosmetic wearables), never the many state-flag Accessory objects this codebase
-- uses as markers (Stun, Knocked, etc. never have a Handle child, so scaleAccessory no-ops on them).
function module.watchForLateAccessories(character, factor)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Accessory") then
			scaleAccessory(child, factor)
		end
	end)
end

return module
