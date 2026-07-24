local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players: Players = game:GetService("Players")
local TweenService: TweenService = game:GetService("TweenService")
local Lighting: Lighting = game:GetService("Lighting")
local HttpService: HttpService = game:GetService("HttpService")
local RunService: RunService = game:GetService("RunService")
local Chat: Chat = game:GetService("Chat")
local TextChatService: TextChatService = game:GetService("TextChatService")
local UserInputService: UserInputService = game:GetService("UserInputService")
local GuiService: GuiService = game:GetService("GuiService")
local PolicyService: PolicyService = game:GetService("PolicyService")
local VoiceChatService: VoiceChatService = game:GetService("VoiceChatService")
local LocalizationService: LocalizationService = game:GetService("LocalizationService")
local LocalPlayer: Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local rPanelFolder: Folder = ReplicatedStorage:WaitForChild("rPanel_ReplicatedStorage", 2e5)
local rPanelRemote: RemoteEvent = rPanelFolder:WaitForChild("rPanel", 2e5)
local Shared = require(rPanelFolder:WaitForChild("Shared"))
local ClientConfig = require(rPanelFolder:WaitForChild("Shared"):WaitForChild("ClientConfig"))

local ScreenGui: ScreenGui = script.Parent
local Blur: BlurEffect = script:WaitForChild("rPanelBlur")
local Main: Frame = ScreenGui:WaitForChild("Main")
local Frames: {[string]: Frame} = {}
local ServerInfoFrame: Frame = Main:WaitForChild("ServerInfoFrame")
local ProfileFrame: Frame = Main:WaitForChild("ProfileFrame")
local PlayerSelectFrame: Frame = Main:WaitForChild("PlayerSelectFrame")
local ExplorerFrame: Frame = Main:WaitForChild("ExplorerFrame")
local Topbar: Frame = Main:WaitForChild("Topbar")

local PlayerSelectButton: ImageButton = Topbar:WaitForChild("PlayerSelection")
local ReturnButton: ImageButton = Topbar:WaitForChild("Return")
local ServerInfoButton: ImageButton = Topbar:WaitForChild("ServerInfo")
local ExplorerButton: ImageButton = Topbar:WaitForChild("Explorer")

local BaseBadgeEntry: ImageLabel = ProfileFrame:WaitForChild("BadgeBar"):WaitForChild("Verified"):Clone()

local BaseActionEntry: Frame = ProfileFrame:WaitForChild("ActionsFrame"):WaitForChild("Kick"):Clone()

local BasePlayerEntry: Frame = PlayerSelectFrame:WaitForChild("ScrollingFrame"):WaitForChild("Frame"):Clone()
PlayerSelectFrame:WaitForChild("ScrollingFrame"):WaitForChild("Frame"):Destroy()

require(script:WaitForChild("ExplorerClient"))()
local ExplorerShared = require(script:WaitForChild("ExplorerClient"):WaitForChild("Shared"))

local Enabled = false
local EnabledTween: Tween? = nil
local CurrentFrame: string = "ServerInfoFrame"
local SelectedPlayer: string = ""

local function Format(Int)
	return string.format("%02i", Int)
end

local function ConvertToHMS(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	return Format(Hours)..":"..Format(Minutes)..":"..Format(Seconds)
end

local function ChangeFrame()
	for i,v in Frames do
		if i == CurrentFrame then
			v.Visible = true
		else
			v.Visible = false
		end
	end
	if ExplorerFrame.Visible then
		ExplorerShared.ToolEnabled:set(true)	
	else
		ExplorerShared.ToolEnabled:set(false)
	end
end

local function ListActions(Actions)
	for i,v in ProfileFrame:WaitForChild("ActionsFrame"):GetChildren() do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	for i,v in Actions do
		local Module = rPanelFolder:WaitForChild("Commands"):FindFirstChild(v)
		if Module then
			local RequiredModule = require(Module)
			local Entry = BaseActionEntry:Clone()
			Entry.Name = RequiredModule.Name
			Entry:WaitForChild("TextLabel").Text = RequiredModule.Name or "No name specified"
			Entry:WaitForChild("ImageLabel").Image = RequiredModule.Icon or "rbxassetid://0"
			Entry.Parent = ProfileFrame:WaitForChild("ActionsFrame")
		end
	end
end

local function ToggleEnabled()
	Enabled = not Enabled
	LocalPlayer:SetAttribute("MouseLocked", not Enabled)
	if Enabled then
		Main.Visible = true
		Blur.Parent = Lighting
		EnabledTween = TweenService:Create(Main, TweenInfo.new(.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false), {Position = UDim2.new(0,0,0,0)})
		EnabledTween:Play()
	else
		Blur.Parent = script
		EnabledTween = TweenService:Create(Main, TweenInfo.new(.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false), {Position = UDim2.new(-1,0,0,0)})
		EnabledTween.Completed:Once(function(State)
			if State == Enum.PlaybackState.Completed then
				Main.Visible = false
			end
		end)
		EnabledTween:Play()
	end
end

UserInputService.InputBegan:Connect(function(Input, GPE)
	if GPE then
		return
	end
	if Input.KeyCode == ClientConfig.MenuKeybind and (not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)) then
		ToggleEnabled()
	end
end)

ServerInfoButton.MouseButton1Click:Connect(function()
	CurrentFrame = "ServerInfoFrame"
	ChangeFrame()
end)

ReturnButton.MouseButton1Click:Connect(function()
	CurrentFrame = "ServerInfoFrame"
	ChangeFrame()
end)

PlayerSelectButton.MouseButton1Click:Connect(function()
	CurrentFrame = "PlayerSelectFrame"
	ChangeFrame()
end)

ExplorerButton.MouseButton1Click:Connect(function()
	CurrentFrame = "ExplorerFrame"
	ChangeFrame()
end)

Main.Position = UDim2.new(-1, 0, 0, 0)
Frames["ServerInfoFrame"] = ServerInfoFrame
Frames["ProfileFrame"] = ProfileFrame
Frames["PlayerSelectFrame"] = PlayerSelectFrame
Frames["ExplorerFrame"] = ExplorerFrame

task.spawn(function()
	while true do
		if Enabled then
			local CurrentTime = os.time()
			local ServerStart = workspace:GetAttribute("Age")
			
			if ServerStart then
				ServerInfoFrame:WaitForChild("Age").Text = string.format('Age: %s', ConvertToHMS(CurrentTime - ServerStart))
			end
			ServerInfoFrame:WaitForChild("PlayerCount").Text = string.format('Player Count: %d/%d', #Players:GetPlayers(), Players.MaxPlayers)
			
			if CurrentFrame == "ProfileFrame" then
				local FoundPlayer = Players:FindFirstChild(SelectedPlayer)
				if FoundPlayer then
					local Playtime = FoundPlayer:GetAttribute("Playtime") 
					ProfileFrame:WaitForChild("ServerTime").Text = string.format('Playtime: %s', ConvertToHMS(CurrentTime - Playtime))
					
					local Ping = FoundPlayer:GetAttribute("Ping") 
					ProfileFrame:WaitForChild("Ping").Text = string.format('Ping: %dms', Ping or -999)
				end
			end
		end
		task.wait(1)
	end
end)

local function AddBadge(Name: string, Icon: string)
	local Badge = BaseBadgeEntry:Clone()
	Badge.Name = Name
	Badge.Image = Icon
	Badge.ImageRectSize = Vector2.new(1000,1000)
	Badge.Parent = ProfileFrame:WaitForChild("BadgeBar")
end

local function SetupProfileFrame(Player: Player)
	local ThirteenPlus = Player:GetAttribute("ThirteenPlus")
	if ThirteenPlus then
		ProfileFrame:WaitForChild("AgeCheck").Image = "rbxasset://textures/ui/account_over13.png"
	else
		ProfileFrame:WaitForChild("AgeCheck").Image = "rbxasset://textures/ui/account_under13.png"
	end
	ProfileFrame:WaitForChild("ProfilePicture").Image = string.format('https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png', Player.UserId)
	ProfileFrame:WaitForChild("Username").Text = string.format('[%d] %s%s', Player.UserId, Player.Name, (Player.DisplayName ~= '' and string.format(' (%s)', Player.DisplayName)) or '')
	local GroupRole = Player:GetAttribute("GroupRole")
	ProfileFrame:WaitForChild("GroupRole").Text = string.format('Group Role: %s', GroupRole or "None")
	ProfileFrame:WaitForChild("AccountAge").Text = string.format('Account Age: %d Days', Player.AccountAge)
	local Language = Player:GetAttribute("Language") 
	ProfileFrame:WaitForChild("Language").Text = string.format('Lang: %s', Language or "None")
	local Region = Player:GetAttribute("Region") 
	ProfileFrame:WaitForChild("Region").Text = string.format('Region: %s', Region or "None")
	local Platform = Player:GetAttribute("Platform") 
	ProfileFrame:WaitForChild("Platform").Text = string.format('Platform: %s', Platform or "None")
	local Playtime = Player:GetAttribute("Playtime") 
	ProfileFrame:WaitForChild("ServerTime").Text = string.format('Playtime: %s', ConvertToHMS(os.time() - Playtime))
	local Ping = Player:GetAttribute("Ping") 
	ProfileFrame:WaitForChild("Ping").Text = string.format('Ping: %dms', Ping or -999)
	
	for i,v in ProfileFrame:WaitForChild("BadgeBar"):GetChildren() do
		if v:IsA("ImageLabel") then
			v:Destroy()
		end
	end
	
	for i,v in ClientConfig.Badges do
		if v.Callback then
			local Success = v.Callback(LocalPlayer, Player)
			if Success then
				AddBadge(i, v.Icon)
			end
		end
	end
end

local function PlayerAdded(Player: Player)
	local Entry = BasePlayerEntry:Clone()
	Entry:WaitForChild("ProfilePicture").Image = string.format('https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png', Player.UserId)
	-- [1884625253] Ty_Development (Ty Lee)
	Entry:WaitForChild("Name").Text = string.format('[%d] %s%s', Player.UserId, Player.Name, (Player.DisplayName ~= '' and string.format(' (%s)', Player.DisplayName)) or '')
	Entry.Name = Player.Name
	Entry:WaitForChild("SelectButton").MouseButton1Click:Connect(function()
		SelectedPlayer = Player.Name
		CurrentFrame = "ProfileFrame"
		SetupProfileFrame(Player)
		ChangeFrame()
	end)
	Entry.Parent = PlayerSelectFrame:WaitForChild("ScrollingFrame")
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(Player)
	for i,v in PlayerSelectFrame:WaitForChild("ScrollingFrame"):GetChildren() do
		if v.Name == Player.Name then
			v:Destroy()
		end
	end
end)

ExplorerButton.Visible = false
ServerInfoFrame:WaitForChild("ServerId").Text = string.format('ServerId: %s', (RunService:IsStudio() and "Studio") or game.JobId)

for i,v in Players:GetPlayers() do
	PlayerAdded(v)
end

local function SetupExplorerButton()
	local ExplorerPermissions = LocalPlayer:GetAttribute("ExplorerPermissions")
	if ExplorerPermissions then
		local Permissions = HttpService:JSONDecode(ExplorerPermissions)
		if table.find(Permissions, "Explorer") then
			ExplorerButton.Visible = true
		end
		if table.find(Permissions, "ExplorerServer") then
			ExplorerFrame:WaitForChild("Explorer"):WaitForChild("Body"):WaitForChild("TopBar"):WaitForChild("Checkbox").Visible = true
		else
			ExplorerFrame:WaitForChild("Explorer"):WaitForChild("Body"):WaitForChild("TopBar"):WaitForChild("Checkbox").Visible = false
		end
	end
end

LocalPlayer:GetAttributeChangedSignal("ExplorerPermissions"):Once(SetupExplorerButton)
if LocalPlayer:GetAttribute("ExplorerPermissions") then
	SetupExplorerButton()
end

rPanelRemote.OnClientEvent:Connect(function(Tab)
	if Tab.Method == "ActionList" then
		ListActions(Tab.Actions)
	end
end)

rPanelRemote:FireServer({Method = "GetActions"})

ChangeFrame()
