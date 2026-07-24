local RepS = game:GetService'ReplicatedStorage'
local Https: HttpService = game:GetService("HttpService")
RepS:WaitForChild'Uptime'.Value = os.time()
local function GetServerRegion()
	local Return
	for Indx:number = 1, 6 do
		local Success: boolean, Ret = pcall(Https.GetAsync, Https, 'https://api4.my-ip.io/ip.json')
		if Success then
			Return = Ret
			break
		end
		task.wait(.25 * Indx)
	end
	local Result = Https:JSONDecode(Return)
	local ip = Result.ip
	if Result and ip then
		local location
		local good,bad = pcall(function()
			location = Https:JSONDecode(Https:GetAsync("http://ip-api.com/json/"..ip))
		end)
		if good and location.country and location.regionName then
			return location.country , location.regionName
		else
			warn("fatal error fetching server geo location. error: "..bad)
			return nil, nil
		end
	else
		warn("fatal error fetching server ip")
		return nil, nil
	end
end

while true do
	task.wait(1)
	local r,rr = GetServerRegion()
	if not r then
		continue
	else
		RepS.ServerRegion.Value = r..", "..rr
		break
	end
end