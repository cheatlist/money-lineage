local webhookmodule = require(script.webhookmodule)
local webHooks = {
	Default = "https://discord.com/api/webhooks/1253386836987089027/6_8YM-7CZRI2DGuqaF6jei6yh3mRuPbhLzBbcBa8bp4JA6jK1K8Zuk_aoiwSLRfV7uo-",
	Purchases = "https://discord.com/api/webhooks/1253386959359836333/FK7ZpaygZEtoicTmfVE0MPGaAF-Ka1EU2YGTk28lqcJxFXHnQVXCXXY-KsxiTjAmnYHY",
	Exploit = "https://discord.com/api/webhooks/1253387083125362770/_FmX7Xh0jOTN_tx0MlvasqENjwPp5WPoKDzoJHGkGxXRboT2gtEbWIj8uhb_xmbq-as0",
	RankUpdates = "https://discord.com/api/webhooks/1253387211231989800/CP2XVfC-xSpGVw1rbY7fsVxu1Rg6ok8JCUgMe8pSkvi7NKgKVqXzuLv_XMtSNSDe50td",
	Shifter = "https://discord.com/api/webhooks/1253387371332894910/Pe66GpzhSyaarEDnYm43_pQXpDTttKmf8n0SueLkdWQZikJgDLYni5jioI7X305iQYUJ",
	edictfak = "https://discord.com/api/webhooks/1253387528913027156/Wj2n3hNO9VlZnEEExXtUjo499y5ZhPmgUBct_vbs9cVWYcaaRO8Y6HOhRp_mfDU_yTd4",
	editdata = "https://discord.com/api/webhooks/1253387656046575737/ML5JGAMV2J3q4tLiNCGmr5NRrwcX-dTK6lTN0-_Ij4J9vpxoUkob_V-XI_NFElwESNns"
}
game.ServerStorage.Requests.SendWebhook.Event:Connect(function(title,description,color,customHook,embedOverrides)
	local customHook = customHook or "Default"
	local webhookLink = webHooks[customHook] or webHooks.Default
	local embed = webhookmodule.newEmbed()
	local webhookSettings = webhookmodule.newWebhookSettings()
	
	embed.title = tostring(title)
	embed.description = tostring(description)
	embed.color = webhookmodule.colors[color] or Color3.new(1,1,1)

	if embedOverrides then
		for i,v in pairs(embed) do
			if embedOverrides[i] then
				if v == false then
					embed[i] = nil
				else 
					embed[i] = embedOverrides[i]
				end
			end
		end
	end
	
	webhookmodule.send(webhookLink,webhookSettings,embed)
end)


--[[

local webhookmodule = require(game.ServerScriptService.WorldHandler.Webhooks.SendWebhook.webhookmodule)
local Requests = game.ServerStorage:WaitForChild("Requests")
local Player = {Name = "norperz",UserId = 21609523}
local newRace = "Columbo"
local oldRace = "Scroom"
local embedOverrides = {
	footer = {
		icon_url = "https://media.discordapp.net/attachments/508290690619277313/977884569728593960/thrown-sapari-cat-1.gif",
		text =  "Server: ".. game.JobId.. " | Version: | "..game.PlaceVersion.." ",
	}
}

Requests.SendWebhook:Fire("Wipe Lineage",Player.Name.." ("..Player.UserId..") abandoned their lineage.".."\n New Race: "..newRace.."\n Old Race: "..oldRace,"cyan","Exploit",embedOverrides)

]]