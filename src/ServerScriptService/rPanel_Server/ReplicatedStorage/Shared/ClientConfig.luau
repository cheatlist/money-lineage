local ClientConfig = {}

ClientConfig.Badges = {
	["Premium"] = {
		Icon = "rbxasset://textures/ui/PlayerList/PremiumIcon@3x.png",
		Callback = function(Caller: Player, Player: Player)
			return Player.MembershipType == Enum.MembershipType.Premium
		end,
	},
	["Friend"] = {
		Icon = "rbxasset://textures/ui/PlayerList/FriendIcon@3x.png",
		Callback = function(Caller: Player, Player: Player)
			if Caller == Player then
				return true
			end
			local Success, IsFriendsWith = pcall(function()
				return Player:IsFriendsWith(Caller.UserId)
			end)
			if not Success then
				return false
			end
			return IsFriendsWith
		end,
	},
	["Developer"] = {
		Icon = "rbxasset://textures/ui/PlayerList/developer@3x.png",
		Callback = function(Caller: Player, Player: Player)
			local GroupRank = Player:GetAttribute("GroupRank")
			if GroupRank then
				return GroupRank >= 252
			end
			return false
		end,
	},
	["RobloxAdmin"] = {
		Icon = "rbxasset://textures/ui/RobloxNameIcon.png",
		Callback = function(Caller: Player, Player: Player)
			return Player:GetAttribute("RobloxAdmin")
		end,
	},
	["StarCreator"] = {
		Icon = "rbxassetid://16457524322",
		Callback = function(Caller: Player, Player: Player)
			return Player:GetAttribute("StarCreator")
		end,
	},
	["Verified"] = {
		Icon = "rbxasset://textures/ui/VerifiedBadgeNameIcon.png",
		Callback = function(Caller: Player, Player: Player)
			warn(Player.Name, Player.HasVerifiedBadge)
			return Player.HasVerifiedBadge
		end,
	},
	["VoiceChat"] = {
		Icon = "rbxasset://textures/ui/VoiceChat/SpeakerLight/Unmuted0@3x.png",
		Callback = function(Caller: Player, Player: Player)
			return Player:GetAttribute("VC")
		end,
	}
}

ClientConfig.MenuKeybind = Enum.KeyCode.F4

return ClientConfig
