local module = {}
local char = script.Parent.Parent

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(char, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge", "Stun", "ReturnStun", "Action", "Blocking", "SpellBlocking"},
		presentTagBlocks = {"Unconscious", "Knocked"},
	})
end

local squireModule = require(game.ServerStorage.SpellEffects.Squire.SquireModule)

local en = true

module.Active = function(char,play,currentprop)
	if en == false then return end
	if ActionCheck() then return end
	
	en = false
	squireModule.summon(char, "Forge")
	task.wait(1)
	en = true
end

module.Active2 = function(char,play,currentprop)
	if en == false then return end
	if ActionCheck() then return end
	
	en = false
	squireModule.summon(char, "Furnace")
	task.wait(1)
	en = true
end

return module
