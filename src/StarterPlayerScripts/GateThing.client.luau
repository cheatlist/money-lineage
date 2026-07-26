local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local GateRequest = ReplicatedStorage.Requests.GateLocationRequest
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TIMEOUT = 20 -- seconds before auto-cancel
local ACTION_NAME = "GateLocationInput"

-- ContextActionService Sink alone isn't enough to stop "/" from also opening Roblox's own chat
-- bar - that binding lives in a CoreScript we can't out-prioritize reliably. Instead, actually
-- disable the default chat input while our prompt is up, covering both chat systems this repo
-- might be running: TextChatService (disable its ChatInputBarConfiguration) or legacy Chat
-- (disable the Chat CoreGui). Restored the moment the prompt resolves.
local function setDefaultChatEnabled(enabled)
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		local inputBar = TextChatService:FindFirstChild("ChatInputBarConfiguration")
		if inputBar then
			inputBar.Enabled = enabled
		end
	else
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, enabled)
		end)
	end
end

GateRequest.OnClientInvoke = function(locationNames)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GateUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 360, 0, 96)
	frame.Position = UDim2.new(0.5, -180, 0.5, -48)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 22)
	title.Position = UDim2.new(0, 8, 0, 6)
	title.BackgroundTransparency = 1
	title.Text = "GATE — press / then type a destination (or 'cancel')"
	title.TextColor3 = Color3.fromRGB(220, 220, 220)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextWrapped = true
	title.Parent = frame

	local hint = Instance.new("TextLabel")
	hint.Size = UDim2.new(1, -16, 0, 18)
	hint.Position = UDim2.new(0, 8, 0, 28)
	hint.BackgroundTransparency = 1
	hint.Text = #locationNames > 0 and table.concat(locationNames, ", ") or ""
	hint.TextColor3 = Color3.fromRGB(150, 150, 150)
	hint.TextWrapped = true
	hint.Font = Enum.Font.Gotham
	hint.TextSize = 11
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -16, 0, 30)
	box.Position = UDim2.new(0, 8, 1, -38)
	box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	box.TextColor3 = Color3.fromRGB(220, 220, 220)
	box.PlaceholderText = "Press / to type here... (e.g. 'tundra 7')"
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.ClearTextOnFocus = false
	box.Text = ""
	box.Parent = frame
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

	local result = nil
	local resolved = false
	local function resolve(value)
		if resolved then
			return
		end
		resolved = true
		result = value
	end

	box.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			resolve({ text = box.Text })
		end
	end)

	setDefaultChatEnabled(false)

	-- Bound at High priority + Sink: with the default chat input disabled above, this is now the
	-- only thing listening for "/" - pressing it focuses our textbox.
	ContextActionService:BindActionAtPriority(ACTION_NAME, function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			box:CaptureFocus()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Slash)

	task.delay(TIMEOUT, function()
		resolve({ text = "cancel" })
	end)

	while not resolved do
		task.wait(1 / 30)
	end

	ContextActionService:UnbindAction(ACTION_NAME)
	setDefaultChatEnabled(true)
	screenGui:Destroy()
	return result
end
