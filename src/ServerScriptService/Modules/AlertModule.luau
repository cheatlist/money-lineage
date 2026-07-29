local module = {}

function module.send(player, text, duration)
	if not player then
		return
	end
	-- Defensive FindFirstChild (2026-07-29): Alert is Studio-only asset debt that may not exist
	-- yet - this is called from many places throughout the codebase (mogging results, artifact
	-- conflicts, etc.), and plain dot-notation on a missing RemoteEvent throws, which would have
	-- propagated up and potentially aborted whatever caller invoked send() partway through.
	local alertEvent = game.ReplicatedStorage.Requests:FindFirstChild("Alert")
	if not alertEvent then
		return
	end
	alertEvent:FireClient(player, text, duration)
end

-- Sends the same alert to every currently-connected player (added 2026-07-29, for the Chad-rank
-- server-wide announcements) - just module.send looped over game.Players:GetPlayers(), no new
-- RemoteEvent needed since it's the same per-player Alert firing underneath.
function module.broadcast(text, duration)
	for _, player in ipairs(game.Players:GetPlayers()) do
		module.send(player, text, duration)
	end
end

return module
