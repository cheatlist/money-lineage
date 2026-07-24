local module = {}
local char = script.Parent.Parent

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(char, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast"},
		presentTagBlocks = {"Unconscious","Knocked"},
	})
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
