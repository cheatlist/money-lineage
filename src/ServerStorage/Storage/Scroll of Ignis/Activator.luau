local v1 = {}
local playerdata = game.ServerStorage.PlayerData
local v10 = require(game.ServerScriptService.WorldHandler.Dialogues.DialogueHandler.ModuleScript)
local remote = game.ReplicatedStorage.Requests.DialogueNoNPCClient
local no = false
local talking = {}
local commands = require(game.ServerScriptService.Modules.Commands)
-- LastScroll is a "pending spell-replace choice" flag - every scroll's very first check blocks
-- entirely while it's non-empty. It used to only ever get cleared by successfully finishing the
-- SpellChange dialogue, so cancelling, disconnecting, or otherwise not completing it left it stuck
-- forever, permanently bricking every future scroll for that player. Cancelling now clears it too
-- (DialogueHandler's exit()), but this timeout is a second, independent safety net so a stuck value
-- always self-heals within a minute no matter how it happens to get stuck.
local function triggerReplace(v2, player, spellName)
	playerdata[v2.Name].LastScroll.Value = spellName
	remote:FireClient(player)
	task.delay(60, function()
		if playerdata:FindFirstChild(v2.Name) and playerdata[v2.Name].LastScroll.Value == spellName then
			playerdata[v2.Name].LastScroll.Value = ""
		end
	end)
end
function v1.Active(v2)
	if no == true or table.find(string.split(playerdata[v2.Name].Spells.Value,","),"Ignis") or playerdata[v2.Name].LastScroll.Value ~= "" then
		return
	end
	local player = game.Players:GetPlayerFromCharacter(v2)
	
	local allski = string.split(playerdata[v2.Name].Spells.Value, ",")
	local soulsnaps = {}
	for i,v in pairs(allski) do
		if v ~= "" then
			table.insert(soulsnaps, v)
		end
	end
	local toreturn = nil
	if table.find(allski,"Ignis") then return end
	if table.find(_G.MageClasses, playerdata[v2.Name].Class.Value) or table.find(_G.MageClasses, playerdata[v2.Name].Hybrid.Value) then
		if #soulsnaps == 4 then
			triggerReplace(v2, player, "Ignis")
		else
			playerdata[v2.Name].Spells.Value = playerdata[v2.Name].Spells.Value.."Ignis,"
			commands.Learn(player)
		end
	else
		if #soulsnaps == 3 then
			triggerReplace(v2, player, "Ignis")
		else
			playerdata[v2.Name].Spells.Value = playerdata[v2.Name].Spells.Value.."Ignis,"
			commands.Learn(player)
		end
	end
	--playerdata[v2.Name].Skills.Value = playerdata[v2.Name].Skills.Value..",Armis"
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
end
return v1