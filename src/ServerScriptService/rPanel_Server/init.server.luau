for _,v in script:GetChildren() do
	if v:IsA("Folder") then
		local Success, FoundParent = pcall(function()
			return game:GetService(v.Name)
		end)
		if not Success then
			FoundParent = game:FindFirstChild(v.Name)
		end
		if not FoundParent then
			continue
		end
		v.Name = string.format('%s_%s', "rPanel", v.Name)
		v.Parent = FoundParent
		
		for _, Child in v:GetChildren() do
			if Child:IsA("Script") or Child:IsA("LocalScript") then
				Child.Enabled = true
			end
		end
	end
end

local OnJoin = script:WaitForChild("OnJoin")
local rPanel_Client = OnJoin:WaitForChild("rPanel_Client")
local rPanel_Gui = OnJoin:WaitForChild("rPanel_Gui")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Config = require(script:WaitForChild("Config"))
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("rPanel_ReplicatedStorage")
local Shared = require(ReplicatedStorageFolder:WaitForChild("Shared"))
local rPanelRemote: RemoteEvent = ReplicatedStorageFolder:WaitForChild("rPanel")

local function PlayerAdded(Player: Player)
	local PlayerGui = Player:WaitForChild("PlayerGui", 255)
	if PlayerGui then
		local ClientClone = rPanel_Client:Clone()
		ClientClone.Parent = PlayerGui
		ClientClone.Enabled = true
		local StarCreator = Shared:IsStarCreator(Player)
		local RobloxAdmin = Shared:IsRobloxAdmin(Player)

		if Config.RankMethod == "Group" then
			local GroupRank = Shared:GetGroupRank(Config.Group, Player)
			local GroupRole = Shared:GetGroupRole(Config.Group, Player)
			local FoundRank = Config.Ranks[GroupRank]
			if FoundRank then
				local FoundPermissions = Config.Permissions[FoundRank]
				if FoundPermissions then
					local ExplorerPermissions = {}
					if table.find(FoundPermissions, "Explorer") then
						table.insert(ExplorerPermissions, "Explorer")
					end
					if table.find(FoundPermissions, "ExplorerWrite") then
						table.insert(ExplorerPermissions, "ExplorerWrite")
					end
					if table.find(FoundPermissions, "ExplorerServer") then
						table.insert(ExplorerPermissions, "ExplorerServer")
					end
					if #ExplorerPermissions >= 1 then
						Player:SetAttribute("ExplorerPermissions", HttpService:JSONEncode(ExplorerPermissions))
					end
				end
				local GuiClone = rPanel_Gui:Clone()
				GuiClone.Parent = PlayerGui
				GuiClone:WaitForChild("rPanel_Gui_LocalScript").Enabled = true
			end
			Player:SetAttribute("GroupRank", GroupRank)
			Player:SetAttribute("GroupRole", GroupRole)
		end

		Player:SetAttribute("StarCreator", StarCreator)
		Player:SetAttribute("RobloxAdmin", RobloxAdmin)
		
		Player:SetAttribute("Playtime", os.time())

		while Player do
			Player:SetAttribute("Ping", math.round(Shared:GetPing(Player)))
			task.wait(4)
		end
	end
end

Players.PlayerAdded:Connect(PlayerAdded)

for i,v in Players:GetPlayers() do
	PlayerAdded(v)
end

rPanelRemote.OnServerEvent:Connect(function(Player, Table)
	if Table.Method == "Init" then
		Player:SetAttribute("Language", Table.Language)
		Player:SetAttribute("Region", Table.Region)
		Player:SetAttribute("ThirteenPlus", Table.ThirteenPlus)
		Player:SetAttribute("VC", Table.VC)
		Player:SetAttribute("Platform", Table.Platform)
	elseif Table.Method == "GetActions" then
		local GroupRank = Player:GetAttribute("GroupRank")
		if not GroupRank then
			return 
		end
		local FoundRank = Config.Ranks[GroupRank]
		if FoundRank then
			local FoundPermissions = Config.Permissions[FoundRank]
			if FoundPermissions then
				if table.find(FoundPermissions, "All") then
					local Cmds = {}
					for i,v in ReplicatedStorageFolder.Commands:GetChildren() do
						table.insert(Cmds, v.Name)
					end
					rPanelRemote:FireClient(Player, {Actions = Cmds, Method = "ActionList"})
					return
				end
				rPanelRemote:FireClient(Player, {Actions = FoundPermissions, Method = "ActionList"})
				return
			end
		end
		return 
	end
end)

workspace:SetAttribute("Age", os.time())

require(script:WaitForChild("InGameExplorer"))()