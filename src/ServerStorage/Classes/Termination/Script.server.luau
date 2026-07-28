local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local TerminationModule = require(game.ServerScriptService.Modules.TerminationModule)

local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun", "NoDam", "ReturnStun", "Action", "Blocking", "SpellBlocking", "ActiveCast", "Unconscious", "Knocked", "Immortal", "Grabbed"},
	})
end

script.Parent.Activated:Connect(function()
	local character = script.Parent.Parent
	if ActionCheck(character) then
		return
	end
	TerminationModule.trigger(character)
end)
