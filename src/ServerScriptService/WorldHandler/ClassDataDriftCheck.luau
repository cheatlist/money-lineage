--[[
	Lightweight startup check for class-name drift (CLAUDE.md refactor item 6). Now that GameLoaded and
	DialogueHandler both read from the single ClassData.luau module, the main class tables can't drift
	from each other anymore -- but a few OTHER independently-maintained class-name lists still exist
	(the sort of thing that caused the DragonBloodUpgrade bug this session started from). This checks
	those against ClassData's actual `.class` string values and warns (does not error/block startup) if
	one references a class string ClassData doesn't produce.

	Call once at server startup, e.g. from GameLoaded/init.server.luau right after `_G.MageClasses` is set:
		require(script.ClassDataDriftCheck)(_G.MageClasses, "_G.MageClasses")
]]

local ClassData = require(script.Parent.ClassData)

local function knownClassStrings()
	local known = {}
	for key, entry in pairs(ClassData.classdata) do
		known[key] = true
		if entry.class then
			known[entry.class] = true
		end
	end
	return known
end

return function(list, listName)
	local known = knownClassStrings()
	for _, name in ipairs(list) do
		if not known[name] then
			warn(("ClassDataDriftCheck: %s contains %q, which does not match any ClassData key or .class value -- likely drifted, verify it's still intended."):format(listName, name))
		end
	end
end
