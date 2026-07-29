local module = {}

function module.send(player, text, duration)
	if not player then
		return
	end
	-- No longer Studio-asset-debt (2026-07-29): Alert used to be assumed as a Studio-placed
	-- RemoteEvent and just skipped if missing - but send() is called from many places throughout
	-- the codebase (mogging results, artifact conflicts, etc.), and plain dot-notation on a
	-- missing one throws, which would have propagated up and potentially aborted whatever caller
	-- invoked send() partway through. Creating it at runtime if missing (a server script creating
	-- a RemoteEvent under ReplicatedStorage replicates to clients exactly like a Studio-placed
	-- one) removes the dependency on manual Studio placement entirely, not just the crash risk.
	local requestsFolder = game.ReplicatedStorage.Requests
	local alertEvent = requestsFolder:FindFirstChild("Alert")
	if not alertEvent then
		alertEvent = Instance.new("RemoteEvent")
		alertEvent.Name = "Alert"
		alertEvent.Parent = requestsFolder
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
