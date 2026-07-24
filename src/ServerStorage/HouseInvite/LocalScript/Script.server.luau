script.Parent.RemoteEvent.OnServerEvent:Connect(function(p)
	if p~=script.Parent.Parent.Parent.Parent then
		return
	end
	if script.Parent.Parent.HouseName.Value~=""then
		game.ServerStorage.Requests.JoinHouse:Invoke(p,script.Parent.Parent.HouseName.Value)
	end
end)