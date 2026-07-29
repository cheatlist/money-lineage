local module = {}

function module.send(player, text, duration)
	if not player then
		return
	end
	game.ReplicatedStorage.Requests.Alert:FireClient(player, text, duration)
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
