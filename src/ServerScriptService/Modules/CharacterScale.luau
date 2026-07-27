--[[
	Manual R6 character resizing. `Humanoid.BodyHeightScale`/`BodyWidthScale`/`BodyDepthScale`/
	`HeadScale` don't exist on this game's Humanoid (confirmed live - not just unused, the
	properties themselves error), so uniform scaling has to be done the pre-scale-API R6 way:
	resize every BasePart directly, then rescale each Motor6D's C0/C1 *position* (not rotation)
	by the same factor so the joints stay lined up instead of the limbs drifting apart or
	overlapping. Scans all Motor6Ds under the character rather than hardcoding joint names/
	locations, so accessories welded on via their own Motor6D (rare, but some do this for
	animation) get their offset scaled too instead of ending up floating at the old distance.
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
		if joint:IsA("Motor6D") then
			joint.C0 = scalePosition(joint.C0, factor)
			joint.C1 = scalePosition(joint.C1, factor)
		end
	end
end

return module
