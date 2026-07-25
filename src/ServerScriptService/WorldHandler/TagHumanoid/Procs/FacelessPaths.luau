local Helpers = require(script.Parent.Parent.Helpers)
local addToxinStack = Helpers.addToxinStack

local function ApplyFacelessPathProcs(character, enemy, info, playerdata)
	if not playerdata then
		return
	end
	if playerdata.Skills.Value:find("TheToxin") then
		-- TheToxin (Faceless poison path): everything the attacker deals is nerfed except
		-- Septic Burst, so the path only pays off once poison stacks (see
		-- Helpers.addToxinStack/getToxinStackCount) are amplifying damage taken on the enemy
		-- and/or getting popped.
		if info.damage and info.move ~= "Septic Burst" then
			info.damage *= 0.7
		end
		if info.move == "Ethereal Strike" then
			-- reworked into a poison injection: dumps a big chunk of stacks in one hit
			-- instead of the old flat 20%-max-health burst
			addToxinStack(enemy)
			addToxinStack(enemy)
			addToxinStack(enemy)
		elseif info.move == "Lethality" then
			-- each flurry hit stacks poison instead of relying on Lethality's own raw damage
			addToxinStack(enemy)
		end
	elseif playerdata.Skills.Value:find("TheMaster") then
		-- TheMaster path: Ethereal Strike no longer ragdolls - it's a combo starter/extender
		-- now, a light poke that stuns + gently pushes instead. The damage-% reduction and
		-- dropping the `knockback` Info flag both live in Ethereal Strike's own script; this
		-- just adds the Stun + gentle push on a landed hit.
		if info.move == "Ethereal Strike" and enemy:FindFirstChild("HumanoidRootPart") then
			Helpers.create("Stun", 0.8, enemy)
			local bv = Instance.new("BodyVelocity")
			game.CollectionService:AddTag(bv, "AllowedBM")
			bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			bv.Velocity = (enemy.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Unit * 20 + Vector3.new(0, 8, 0)
			bv.Parent = enemy.HumanoidRootPart
			game.Debris:AddItem(bv, 0.2)
		end
	end
end

return ApplyFacelessPathProcs
