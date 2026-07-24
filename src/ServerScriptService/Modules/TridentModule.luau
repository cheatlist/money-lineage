local module = {}

function module.wieldTrident(player)
	local trident_is_primary = false
	local spear_equipped = false
	local to_return = false
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(tostring(player))
	if playerdata then
		if playerdata.PrimaryWeapon.Value == "Pronged Mythril Spear" then
			trident_is_primary = true
		end
	end
	local char = player.Character
	if char then
		if char:FindFirstChild("HasSpear") then
			spear_equipped = true
		end
	end
	if trident_is_primary and spear_equipped then
		to_return = true
	end
	return to_return
end

return module