--[[
	ATKisTaken
	All Right Reserved
]]

local HttpService = game:GetService("HttpService")

local firebase = {}
firebase.__index = firebase

function firebase.init(identifer, auth, entrypoint)
	local mt = setmetatable({
		_url = string.format("https://%s.firebaseio.com", identifer);
		_auth = auth,
		_entryPoint = entrypoint,
	}, firebase)
	return mt
end

function firebase:Get(documentend, extra)
	local data
	local s,e = pcall(function()
		data = HttpService:RequestAsync(
			{
				Url = self:_UrlGen(self._url, self._auth, documentend, extra or {}),
				Method = "GET",
			}
		)
	end)
	if s then return HttpService:JSONDecode(data["Body"]) else warn(e) end
end

function firebase:Put(documentend, body, extra)
	local data
	local s,e = pcall(function()
		data = HttpService:RequestAsync(
			{
				Url = self:_UrlGen(self._url, self._auth, documentend, extra or {}),
				Method = "PUT",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = HttpService:JSONEncode(body)
			}
		)
	end)
	if s then return data else warn(e) end
end

function firebase:Patch(documentend, body, extra)
    local data
    local s,e = pcall(function()
        data = HttpService:RequestAsync(
            {
				Url = self:_UrlGen(self._url, self._auth, documentend, extra or {}),
                Method = "PATCH",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(body)
            }
        )
    end)
    if s then return data else warn(e) end
end

function firebase:_UrlGen(url, auth, documentend, extra)
	local extraString = "auth="..auth
	for param, value in pairs(extra) do
		extraString = extraString..string.format("&%s=%s", param, value)
	end
	if self._entryPoint then
		return string.format("%s/%s.json?%s", url.."/"..self._entryPoint, documentend, extraString)
	else
		return string.format("%s/%s.json?%s", url, documentend, extraString)
	end
end

return firebase