local module = {}
function module.getMouse(play)
	return game.ReplicatedStorage.Requests.GetMouse:InvokeClient(play)
end
function module.getMousenew(play)
	return game.ReplicatedStorage.Requests.GetMouse2:InvokeClient(play)
end
return module
