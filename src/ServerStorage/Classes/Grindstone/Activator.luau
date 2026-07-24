local module = {}
local char = script.Parent.Parent

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid

function ActionCheck()
	if not char:FindFirstChild("Humanoid") then
		return true
	end
	if char:FindFirstChild("Charge") then
		return true
	end
	if char:FindFirstChild("Stun") then
		return true
	end
	if char:FindFirstChild("ReturnStun") then
		return true
	end
	if char:FindFirstChild("Action") then
		return true
	end
	if char:FindFirstChild("Blocking") then
		return true
	end
	if char:FindFirstChild("SpellBlocking") then
		return true
	end
	if char:FindFirstChild("ActiveCast") then
		return true
	end
	if game.CollectionService:HasTag(char,"Unconscious") then
		return true
	end
	if game.CollectionService:HasTag(char,"Knocked") then
		return true
	end
end

local squireModule = require(game.ServerStorage.SpellEffects.Squire.SquireModule)

local en = true

module.Active = function(char,play,currentprop)
	if en == false then return end
	if ActionCheck() then return end

	local summoned = char:FindFirstChild("Summoned") 
	local grindstoneOut = summoned and summoned.Value == "Grindstone"
	
	en = false 
	
	if not grindstoneOut then
		squireModule.summon(char, "Grindstone")
	else
		squireModule.grind(char)
	end
	
	wait(1)
	en = true
end

return module
