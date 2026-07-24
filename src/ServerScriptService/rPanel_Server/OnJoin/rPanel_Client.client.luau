local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players: Players = game:GetService("Players")
local UserInputService: UserInputService = game:GetService("UserInputService")
local GuiService: GuiService = game:GetService("GuiService")
local PolicyService: PolicyService = game:GetService("PolicyService")
local VoiceChatService: VoiceChatService = game:GetService("VoiceChatService")
local LocalizationService: LocalizationService = game:GetService("LocalizationService")
local LocalPlayer: Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local rPanelFolder: Folder = ReplicatedStorage:WaitForChild("rPanel_ReplicatedStorage", 2e5)
local rPanelRemote: RemoteEvent = rPanelFolder:WaitForChild("rPanel", 2e5)

local Language = "None"
local Region = "None"
local ThirteenPlus = false
local VC = false

local function GetPlatform()
	if (GuiService:IsTenFootInterface()) then
		return "Console"
	elseif (UserInputService.VREnabled) then
		return "VR"
	elseif (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) then
		return "Mobile"
	else
		return "Desktop"
	end
end

local Success, LanguageTranslator = pcall(function()
	return LocalizationService:GetTranslatorForPlayer(LocalPlayer)
end)

if Success and LanguageTranslator then
	Language = LanguageTranslator.LocaleId
end

local Success, Reg = pcall(function()
	return LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
end)

if Success and Reg then
	Region = Reg
end

local Success, PolicyInfo = pcall(function()
	return PolicyService:GetPolicyInfoForPlayerAsync(LocalPlayer)
end)

if Success and PolicyInfo then
	ThirteenPlus = PolicyInfo.AreAdsAllowed
end

local Success, VCEnabled = pcall(function()
	return VoiceChatService:IsVoiceEnabledForUserIdAsync(LocalPlayer.UserId)
end)

if Success and VCEnabled then
	VC = VCEnabled
end

rPanelRemote:FireServer({Method = "Init", Language = Language, Region = Region, ThirteenPlus = ThirteenPlus, VC = VC, Platform = GetPlatform()})

script:Destroy()