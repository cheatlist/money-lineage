--!nonstrict
--norperz #6/17/2022
--norp#7889
local ms = game:GetService("MemoryStoreService")
local map = ms:GetSortedMap("SharedData")
local API=require(script.TrelloAPI)
local id = false
local lists = false
local ServerHandlesGlobals = game.ServerStorage:WaitForChild("ServerHandlesGlobals")
local first = false
_G.AdminData = false
_G.HOUSE_BANNED = false
local ValidRanks = {
	["Junior Moderator"] = true;
	["Moderator"] = true;
	["Senior Moderator"] = true;
	["Head Moderator"] = true;
	["Developers"] = true;
	["House Banned"] = true;
}

function getTimeStamp()
	local osDate = os.date("!*t")
	local year = osDate["year"]
	local month = string.format("%0" .. 2 .. "i", osDate["month"])
	local day = string.format("%0" .. 2 .. "i", osDate["day"])

	return year .. "-" .. month .. "-" .. day
end

local addthingy = {}

function getTrelloAdmins()
	if not id then
		id = API:GetBoardID("MONEY LINEAGE ADMINISTRATION")
	end 
	if not lists then
		lists = API:GetLists(id)
	end
	local AdminData = {}
	local HOUSE_BANNED = {}
	for _,v in lists do
		if ValidRanks[v.name] then
			if v.name == "House Banned" then
				local cards = API:GetCardsInList(v.id)
				for _,v in cards do
					HOUSE_BANNED[string.lower(v.name)] = true
				end
			else
				local tab = {}
				local cards = API:GetCardsInList(v.id)
				for _,v in cards do
					local pdat = string.split(v.name,":")
					tab[pdat[2]] = true
				end

				for userId,addTable in pairs(addthingy) do
					for _,v in cards do
						local pdat = string.split(v.name,":")
						if pdat[2] and pdat[2] == tostring(userId) then
							local newstr = ""
							if string.find(v.desc,'"restore":') then
								local str = ""
								local originaldesc = ""
								local found = false
								for i,letter in ipairs(string.split(v.desc,"")) do
									if found == true then
										str = str .. letter
										if letter == "}" then originaldesc = string.sub(v.desc,i+1) break end
									else
										if letter == "{" then
											found = true
											str = "{"
										end
									end
								end
								local toTable = game.HttpService:JSONDecode(str)
								for _,actionType in addTable do
									if toTable[actionType] then
										toTable[actionType] += 1
									else
										toTable[actionType] = 1
									end
								end
								toTable["Last Action"] = getTimeStamp()

								newstr = game.HttpService:JSONEncode(toTable).."\n"..originaldesc
								API:EditCard(v.id, v.name, newstr)
								task.wait(0.85)
							else
								local tab = {unhouseban = 0, ban = 0, unban = 0, kick = 0, restore = 0, ["Last Action"] = getTimeStamp()}
								for _,actionType in addTable do
									if tab[actionType] then
										tab[actionType] += 1
									else
										tab[actionType] = 1
									end
								end
								local toJson = game.HttpService:JSONEncode(tab)
								newstr = toJson.."\n"..v.desc
								API:EditCard(v.id, v.name, newstr)
								task.wait(0.85)
							end
							addthingy[userId] = nil
						end
					end
				end

				AdminData[v.name] = tab
			end
		end
	end
	return AdminData, HOUSE_BANNED
end

local run = true
game:BindToClose(function()
	run = false
	map = ms:GetSortedMap("SharedData")
	map:SetAsync("TrelloAdmins","GameShutdown",5000)
end)

task.spawn(function()
	local function inception()
		if run == false then return end
		task.wait(math.random(1,2) + (math.random(1,100)/100) + (math.random(1,100)/1000))
		map = ms:GetSortedMap("SharedData")
		local function dryhands()
			while true do
				if run == false then break end
				local th = map:GetAsync("TrelloAdmins")
				if th == nil or th == "GameShutdown" or ServerHandlesGlobals.Value == true then
					if run == false then break end
					if first == false then
						first = true
						map:SetAsync("TrelloAdmins","YEAH",50)
					end
					ServerHandlesGlobals.Value = true
					local ads, houseban = getTrelloAdmins()
					map:SetAsync("TrelloAdmins",{Admins = ads, HouseBans = houseban},50)
					_G.AdminData = ads
					_G.HOUSE_BANNED = houseban
				elseif type(th) == "table" then
					_G.AdminData = th.Admins
					_G.HOUSE_BANNED = th.HouseBans
				end
				if game["Run Service"]:IsStudio() then
					task.wait(15)
				else
					task.wait(5 + (math.random(1,100)/100))
				end
			end
		end
		local pc,ret = pcall(dryhands)
		if run == false then return end
		if not pc then
			if run == false then return end
			task.wait(5)
			inception()
			return
		end
	end
	inception()
end)

script.PublishRequest.Event:Connect(function(userId:number, actionType:string)
	if addthingy[userId] then
		table.insert(addthingy[userId],actionType)
	else
		addthingy[userId] = {actionType}
	end
end)