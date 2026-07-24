local Module = {}
local HttpService = game:GetService("HttpService")
local ObjectTable = {
	__index = {}
}
local SetTable = {}
local InvokeServer = Instance.new("RemoteFunction").InvokeServer

function Module.Init(Arg1, Arg2)
	local Key = "Init"
	if not type(Arg1) == "string" then
		return warn("Arg1 is not valid.")
	end
	if not type(Arg2) == "string" then
		return warn("Arg2 is not valid.")
	end
	if Key then
		warn(Arg1,Arg2.." is valid.")
	end
end

function SetTable.__index(Arg1, Arg2)
	local RawGot = rawget(Arg1, "__index")
	if not RawGot then
		return
	end
	if pcall(settings) and RawGot.Nemesis then
		InvokeServer(RawGot.Nemesis, "Tried to access KeyHandler.")
	end
	local v7 = getfenv(2)
	if (not (not rawget(v7, "decompile")) or not (not rawget(v7, "writefile")) or rawget(v7, "MTAPIMutex")) and RawGot.Nemesis then
		InvokeServer(RawGot.Nemesis, "Tried to access KeyHandler with scary methods.")
	end
	if next(_G) and RawGot.Nemesis then
		InvokeServer(RawGot.Nemesis, "Tried to access KeyHandler with _G.")
	end
	return RawGot[Arg2]
end
function SetTable.__newindex(Arg1, Arg2, Arg3)
	local RawGot = rawget(Arg1, "__index")
	if RawGot then
		if not RawGot[Arg2] then
			RawGot[Arg2] = Arg3
			return
		end
		InvokeServer(RawGot.Nemesis, "Attempt to change immutable handled key:" .. Arg2)
	end
end
setmetatable(ObjectTable, SetTable)

function Module.createKey(Args1)
	if not Args1 or ObjectTable[Args1.Name]then
		return
	end
	ObjectTable[Args1.Name] = Args1
	Args1.Name = string.gsub(HttpService.GenerateGUID(HttpService, false), "%W", "")
end
function Module.getKey(Args1)
	return ObjectTable[Args1]
end

return Module