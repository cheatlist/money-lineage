local Proxhook = require(script.Proxhook)
local httpService = game:GetService("HttpService")
local embedModule = {}

embedModule.colors = {}
embedModule.colors.aqua = 0x00FFFF
embedModule.colors.black = 0x000000
embedModule.colors.blue = 0x0000FF
embedModule.colors.fuchsia = 0xFF00FF
embedModule.colors.grey = 0x808080
embedModule.colors.green = 0x008000
embedModule.colors.lime = 0x00FF00
embedModule.colors.maroon = 0x800000
embedModule.colors.navy = 0x000080
embedModule.colors.olive = 0x808000
embedModule.colors.purple = 0x800080
embedModule.colors.red = 0xFF0000
embedModule.colors.Money = 0xC0C0C0
embedModule.colors.teal = 0x008080
embedModule.colors.white = 0xFFFFFF
embedModule.colors.yellow = 0xFFFF00
embedModule.colors.cyan = 0x7b90db

function embedModule.getISO8601Timestamp()
	-- CREDITS: https://www.roblox.com/users/17828104
	-- CREDITS: https://devforum.roblox.com/u/rogchamp
	-- MODIFIED: I have modified the origional code.

	local osDate = os.date("!*t")
	local year = osDate["year"]
	local month = string.format("%0" .. 2 .. "i", osDate["month"])
	local day = string.format("%0" .. 2 .. "i", osDate["day"])
	local hour = string.format("%0" .. 2 .. "i", osDate["hour"])
	local min = string.format("%0" .. 2 .. "i", osDate["min"])
	local second = string.format("%0" .. 2 .. "i", osDate["sec"])	

	return year .. "-" .. month .. "-" .. day .. "T" .. hour .. ":" .. min .. ":" .. second .. "Z"
end

function embedModule.newFooter()
	return {
		icon_url = "",
		text = "",
	};
end

function embedModule.newThumbnail()
	return {
		url = "",
	};
end

function embedModule.newImage()
	return {
		url = "",
	};
end

function embedModule.newAuthor()
	return {
		name = "",
		url = "",
		icon_url = "",
	};
end

function embedModule.newField()
	return {
		name = "",
		value = "",
		inline = false,
	};
end

function embedModule.newEmbed()
	return {
		title = "",
		description = "",
		url = "",
		color = 0,
		timestamp = embedModule.getISO8601Timestamp(),
		footer = embedModule.newFooter(),
		thumbnail = embedModule.newThumbnail(),
		image = embedModule.newImage(),
		author = embedModule.newAuthor(),
		fields = {},
	};
end

function embedModule.newWebhookSettings()
	return {
		content = nil,
		username = nil,
		avatar_url = nil,
		tts = false,
	};
end

function embedModule.send(url, webhookSettings, embed)
	local httpPacket

	pcall(function() local _1 = webhookSettings pcall(function() local _2 = _1 _1 = nil httpPacket = _2 end) end)

	httpPacket.embeds = {embed}
	local channel,hook
	local s = string.split(url,"/")
	channel = s[6]
	print(channel)
	hook = s[7]
	print(hook)
	return Proxhook(channel,hook,webhookSettings)
end

return embedModule