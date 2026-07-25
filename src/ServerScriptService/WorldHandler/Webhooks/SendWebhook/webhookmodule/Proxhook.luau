--!strict
--
--[[


██████╗░██████╗░░█████╗░██╗░░██╗██╗░░██╗░█████╗░░█████╗░██╗░░██╗
██╔══██╗██╔══██╗██╔══██╗╚██╗██╔╝██║░░██║██╔══██╗██╔══██╗██║░██╔╝
██████╔╝██████╔╝██║░░██║░╚███╔╝░███████║██║░░██║██║░░██║█████═╝░
██╔═══╝░██╔══██╗██║░░██║░██╔██╗░██╔══██║██║░░██║██║░░██║██╔═██╗░
██║░░░░░██║░░██║╚█████╔╝██╔╝╚██╗██║░░██║╚█████╔╝╚█████╔╝██║░╚██╗
╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░░╚════╝░╚═╝░░╚═╝


Discription : A Proxy module for using webhooks, Default proxy is 'Hyra.io'.

Credits :
	
	StyledDev (roblox.com/users/2391664934/profile) - [For this module]
	samueIox (roblox.com/users/121647898/profile) - [For Hyra.io]

Check out Proxhook on the devforum :
	https://devforum.roblox.com/t/proxhook-a-module-for-proxying-discord-webhooks/1505544

Aswell as Hyra : 
	https://devforum.roblox.com/t/discord-webhook-proxy/1500688

--]]
--
------------------------------------------------
--[[				Constants				]]--
------------------------------------------------
--
local Http = game:GetService("HttpService") --> Service used for sending & receiving http requests over the internet.
--
local Url : string = "https://webhook.newstargeted.com/api/webhooks/%s/%s" --> Hyra Proxy Url, Which will be further modified.
--https://webhook.lewisakura.moe/api/webhooks/%s/%s
local ContentType = Enum.HttpContentType.ApplicationJson
--
------------------------------------------------
--[[				  Types					]]--
------------------------------------------------
--
type Dictionary<Type> = {[string] : Type}
type Array<Type> = {[number] : Type}
type Table<Type> = {[any] : Type}
type Dataset = string | Table<any>
--
------------------------------------------------
--[[				  Stats					]]--
------------------------------------------------
--
--//  Stores the information required
--//  to work with the rate limit.
local RateLimit : Dictionary<number> = {
	--
	Reset = 0, --> When this rate limiting window will reset.
	Limit = 0xf, --> How many requests in this window you have remaining.
	Retry = 0  --> The amount of seconds you have left on the rate limit.
	--
}
--
--//  Requests caught up in the Rate limit will be
--//  stored in 'Cache' until the rate limit is over.
local Cache : Array<Array<string>> = {}
--
------------------------------------------------
--[[				Functions				]]--
------------------------------------------------
--
--//  Formats & posts a http request given 2 arguments  //--
function Post(Destination : string, Data : string)-- : Dictionary<any>
	--
	--//  Post the converted 'Data' to the 'Destination' and then return the response  //--
	--return (Http:PostAsync(Destination, Data, ContentType, true))
	return (Http:PostAsync(Destination, Data))
	--
end
--
--//  Sends the remaining requests stored in 'Cache' //--
function UpdateCache() : nil
	--
	--//  <@Left> : The remaining requests that did not
	--//  		  make it will be put back into 'Cache'.
	local Left : Array<Array<string>> = {}
	--
	--//  Cycle through the remaining requests  //--
	for _, Data : Array<string> in ipairs(Cache) do
		task.wait(1/30)
		--
		--//  Check if we are under the rate limit  //--
		if (0 < RateLimit.Limit) then
			--
			--//  Unpack the request and post it to
			--//  the cached 'Destination'.
			-- : Dictionary<any>
			local Response = Post(unpack(Data)) --> Example Request : '{Destination : string, Data : string}'
			--
			if (Response ~= "") then
				--
				--//  Create a direct reference to the headers given in the response  //--
				local Headers : Dictionary<any> = Response.Headers
				--
				--//  Update rate limit stats based off headers  //--
				RateLimit.Reset = Headers["x-ratelimit-reset"]
				RateLimit.Limit = Headers["x-ratelimit-remaining"]
				--
				--//  check if a response body was provided  //--
				if (Response.Body ~= "") then
					--
					--//  if so, decode body from json to a table  //--
					local Decoded : Dictionary<any> = Http:JSONDecode(Response.Body)
					--
					--//  Update rate limit stat based off the response body  //--
					RateLimit.Retry = type(Decoded.retry_after) == "number" and Decoded.retry_after or 0
					--
				end
				--
			end
			--
			--//  If we are over the rate limit //--
		else
			--
			--//  Add Request back to 'Cache' to
			--//  be sent the next update session.
			table.insert(Left, Data)
			--
		end
		--
	end
	--
	--//  Update 'Cache' to contain the remaining requests  //--
	Cache = Left
	--
	--// Return a nil value to
	--// make the type-annotation valid.
	return (nil)
	--
end
--
--//  
function Push(Id : string | number, Token : string, Data : Dataset) : boolean
	--
	--//  <@FormattedUrl> : Format url so it may be used to proxy requests  //--
	local FormattedUrl : string = Url:format(Id, Token)
	--
	--//  Pass through a pcall to catch error that
	--//  may occur when sending an http request.
	local Success : boolean, Error : string | nil = pcall(function()
		--
		--//  <@Processed> : Convert Data into a string if it's not already  //--
		local Processed : string = type(Data) == "string" and Data or Http:JSONEncode(Data)
		--
		--//  Add Request to cache to be managed further  //--
		table.insert(Cache, {FormattedUrl, Processed})
		--
		--//  Update Cache to send remaining & new requests.
		UpdateCache()
		--
	end)
	--
	if (Error) then warn(("Proxhook : %s"):format(Error)) end
	--
	--//  Return a boolean value
	--//  to indecate the success
	--//  and to make this function valid.
	return (Success)
	--
end
--
------------------------------------------------
--[[				End Module				]]--
------------------------------------------------
--
return (Push)
--