local Helpers = require(script.Parent.Parent.Helpers)
local addToxinStack = Helpers.addToxinStack

-- TheToxin (Faceless poison path): everything the attacker deals is nerfed except Septic
-- Burst, so the path only pays off once poison stacks (see Helpers.addToxinStack/
-- getToxinStackCount) are amplifying damage taken on the enemy and/or getting popped.
local function ApplyFacelessPathProcs(character, enemy, info, playerdata)
	if not (playerdata and playerdata.Skills.Value:find("TheToxin")) then
		return
	end
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
end

return ApplyFacelessPathProcs
