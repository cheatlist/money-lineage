local module = {}

local GroupCache = {}
local IconCache = {}

local function GetRankInGroupCached(Player, GroupId)
	if not GroupCache[GroupId] then
		GroupCache[GroupId] = {}
	end
	if GroupCache[GroupId][Player.UserId] and GroupCache[GroupId][Player.UserId].Rank then
		warn("Return cached")
		return GroupCache[GroupId][Player.UserId].Rank
	end
	if not GroupCache[GroupId][Player.UserId] then
		GroupCache[GroupId][Player.UserId] = {}
	end
	local Success, Return = pcall(function()
		return Player:GetRankInGroup(GroupId)
	end)
	if Success then
		GroupCache[GroupId][Player.UserId].Rank = Return
		return Return
	else
		return 0
	end
end

local function GetRoleInGroupCached(Player, GroupId)
	if not GroupCache[GroupId] then
		GroupCache[GroupId] = {}
	end
	if GroupCache[GroupId][Player.UserId] and GroupCache[GroupId][Player.UserId].Role then
		return GroupCache[GroupId][Player.UserId].Role
	end
	if not GroupCache[GroupId][Player.UserId] then
		GroupCache[GroupId][Player.UserId] = {}
	end
	local Success, Return = pcall(function()
		return Player:GetRoleInGroup(GroupId)
	end)
	if Success then
		GroupCache[GroupId][Player.UserId].Role = Return
		return Return
	else
		warn("GetRoleInGroupCached Failed", Player.Name, Return)
		return 0
	end
end

function module:PlayerLeaving(Player)
	if IconCache[Player.UserId] then
		IconCache[Player.UserId] = nil
	end
	for _,Group in GroupCache do
		for UserId, Entry in Group do
			if UserId == Player.UserId then
				Group[UserId] = nil
			end
		end
	end
end

function module:IsStarCreator(Player)
	return GetRankInGroupCached(Player, 4199740) ~= 0
end

function module:IsRobloxAdmin(Player)
	return GetRankInGroupCached(Player, 1200769) ~= 0
end

function module:GetGroupRole(GroupId, Player)
	return GetRoleInGroupCached(Player, GroupId)
end

function module:GetGroupRank(GroupId, Player)
	return GetRankInGroupCached(Player, GroupId)
end

function module:GetPing(Player)
	return math.round(Player:GetNetworkPing() * 2000)
end

function module:AddIcon(Player)
	
end

function module:RemoveIcon(Player)
	
end

function module:Open()
	
end

function module:Close()
	
end

return module
