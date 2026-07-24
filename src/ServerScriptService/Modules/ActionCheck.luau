--[[
	Shared move-guard check, replacing the ~130 near-duplicate local `ActionCheck()`/`ActionCheck(Parent)`
	functions that used to be copy-pasted across ServerStorage/Classes/*/ (CLAUDE.md refactor item 4).

	Every one of the original copies boiled down to the same shape: an ordered set of state-tag
	Instance names to FindFirstChild-check, where finding one means the move is blocked. A few variants
	also required an Instance to be PRESENT (e.g. "Humanoid" must exist) or checked a numeric
	Humanoid.Health threshold instead of a tag. This module expresses all of those with one function so
	call sites keep their exact original behavior by passing back their own check list, not by this
	module deciding what "the" guard should be.

	Each move file keeps a small local wrapper with the same name/shape as its original ActionCheck, e.g.:

		local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
		local function ActionCheck(Parent)
			return ActionCheckModule(Parent, {
				presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
			})
		end

	so every other line in that file that calls `ActionCheck(...)` is untouched.
]]

local function ActionCheck(Parent, options)
	options = options or {}

	if options.absentBlocks then
		for _, name in ipairs(options.absentBlocks) do
			if not Parent:FindFirstChild(name) then
				return true
			end
		end
	end

	if options.healthBelow and Parent:FindFirstChild("Humanoid") and Parent.Humanoid.Health < options.healthBelow then
		return true
	end

	if options.presentBlocks then
		for _, name in ipairs(options.presentBlocks) do
			if Parent:FindFirstChild(name) then
				return true
			end
		end
	end

	return
end

return ActionCheck
