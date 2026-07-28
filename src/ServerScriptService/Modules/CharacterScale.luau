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
]]

local module = {}

local PART_NAMES = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}

local function scalePosition(cf, factor)
	return CFrame.new(cf.Position * factor) * (cf - cf.Position)
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
			local handle = accessory:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				handle.Size = handle.Size * factor
				local mesh = handle:FindFirstChildWhichIsA("SpecialMesh")
				if mesh then
					mesh.Scale = mesh.Scale * factor
				end
			end
		end
	end
end

return module
