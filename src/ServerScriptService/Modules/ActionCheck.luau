--[[
	Shared move-guard check, replacing the ~130 near-duplicate local `ActionCheck()`/`ActionCheck(Parent)`
	functions that used to be copy-pasted across ServerStorage/Classes/*/ (CLAUDE.md refactor item 4).

	Every one of the original copies boiled down to the same shape: an ordered set of state-tag
	Instance names to FindFirstChild-check, where finding one means the move is blocked. Variants also
	required an Instance to be PRESENT (e.g. "Humanoid" must exist), checked a CollectionService tag
	instead of a child Instance, or checked a numeric Humanoid.Health threshold (either strict `< N` or
	`<= N`, the latter covering the `Health == 0` idiom since Health is never negative). This module
	expresses all of those with one function so call sites keep their exact original behavior by passing
	back their own check list, not by this module deciding what "the" guard should be.

	Each move file keeps a small local wrapper with the same name/shape as its original ActionCheck, e.g.:

		local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
		local function ActionCheck(Parent)
			return ActionCheckModule(Parent, {
				presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
			})
		end

	so every other line in that file that calls `ActionCheck(...)` is untouched.

	One unconditional check was added on top of that (2026-07-27, Charming Stone artifact): a
	"Charmed" child on Parent always blocks, regardless of the caller's own options list, since this
	is meant to universally stop skill/ability use for every one of the 118 files routed through this
	module without editing each one's presentBlocks. The 12 move files with their own local
	ActionCheck (see CLAUDE.md Moves section) do NOT get this for free.
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

	if Parent:FindFirstChild("Charmed") then
		return true
	end

	if Parent:FindFirstChild("Humanoid") then
		if options.healthBelow and Parent.Humanoid.Health < options.healthBelow then
			return true
		end
		if options.healthAtOrBelow and Parent.Humanoid.Health <= options.healthAtOrBelow then
			return true
		end
	end

	if options.presentBlocks then
		for _, name in ipairs(options.presentBlocks) do
			if Parent:FindFirstChild(name) then
				return true
			end
		end
	end

	if options.presentTagBlocks then
		for _, tag in ipairs(options.presentTagBlocks) do
			if game.CollectionService:HasTag(Parent, tag) then
				return true
			end
		end
	end

	return
end

return ActionCheck
