game.Players.PlayerAdded:Connect(function(player)
	local conn
	local function onchar(Character)
		if conn then conn:Disconnect() end
		local recentAdds = {}
		conn = Character.ChildAdded:Connect(function(ch)
			if not recentAdds[ch] then
				recentAdds[ch] = {Amt = 1, last = tick()}
			else
				if tick() - recentAdds[ch].last <= .01 then
					recentAdds[ch].Amt += 1
					recentAdds[ch].last = tick()
					if recentAdds[ch].Amt >= 25 then
						Character:Destroy()
						player:Kick("you suck so bad")
					end
				else
					recentAdds[ch] = {Amt = 1, last = tick()}
				end
			end
		end)
	end
	
	if player.Character then onchar(player.Character) end
	player.CharacterAdded:Connect(onchar)
end)