local Config = {}

Config.RankMethod = "Group"

Config.Group = game.CreatorId

Config.Ranks = {
	[255] = "Developer",
	[254] = "Developer",
	[253] = "Developer",
}

Config.Permissions = {
	["Developer"] = {"All", "Explorer", "ExplorerWrite", "ExplorerServer"},
	["Staff"] = {"Kick", "Ban"},
	["Tester"] = {"None"}
}

Config.ExtraUsers = {
	[1884625253] = "Developer", -- Ty_Development, thank you
}

return Config