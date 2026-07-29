local module = {}

function module.send(player, text, duration)
	if not player then
		return
	end
	game.ReplicatedStorage.Requests.Alert:FireClient(player, text, duration)
end

return module
