local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GateRequest = ReplicatedStorage.Requests.GateLocationRequest
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TIMEOUT = 10 -- seconds before auto-cancel

GateRequest.OnClientInvoke = function(locationNames)
	-- Build the ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GateUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 360, 0, 220)
	frame.Position = UDim2.new(0.5, -180, 0.5, -110)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 36)
	title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	title.Text = "GATE — Choose Destination"
	title.TextColor3 = Color3.fromRGB(220, 220, 220)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.Parent = frame
	Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

	-- Scrolling list of location buttons
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -16, 0, 100)
	scroll.Position = UDim2.new(0, 8, 0, 44)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = frame

	local listLayout = Instance.new("UIListLayout", scroll)
	listLayout.Padding = UDim.new(0, 4)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Sub-location input
	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, -16, 0, 18)
	subLabel.Position = UDim2.new(0, 8, 0, 152)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = "Sub-location (optional, name or number):"
	subLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextSize = 11
	subLabel.TextXAlignment = Enum.TextXAlignment.Left
	subLabel.Parent = frame

	local subBox = Instance.new("TextBox")
	subBox.Size = UDim2.new(1, -16, 0, 28)
	subBox.Position = UDim2.new(0, 8, 0, 172)
	subBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	subBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	subBox.PlaceholderText = "Leave blank for random"
	subBox.Font = Enum.Font.Gotham
	subBox.TextSize = 13
	subBox.ClearTextOnFocus = false
	subBox.Text = ""
	subBox.Parent = frame
	Instance.new("UICorner", subBox).CornerRadius = UDim.new(0, 6)

	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0, 80, 0, 28)
	cancelBtn.Position = UDim2.new(1, -88, 1, -36)
	cancelBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
	cancelBtn.Text = "Cancel"
	cancelBtn.TextColor3 = Color3.new(1,1,1)
	cancelBtn.Font = Enum.Font.GothamBold
	cancelBtn.TextSize = 13
	cancelBtn.Parent = frame
	Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)

	-- Resolve promise
	local result = nil
	local resolved = false

	local function resolve(value)
		if resolved then return end
		resolved = true
		result = value
	end

	-- Populate location buttons
	-- Always add "pride" as a special option
	local allNames = {}
	for _, name in ipairs(locationNames) do
		table.insert(allNames, name)
	end

	for _, name in ipairs(allNames) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 28)
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		btn.Text = name
		btn.TextColor3 = Color3.new(1,1,1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.Parent = scroll

		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		btn.MouseButton1Click:Connect(function()
			resolve({ type = "location", name = name, sub = subBox.Text })
		end)
	end

	-- Auto-size the scroll canvas
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
	end)
	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)

	cancelBtn.MouseButton1Click:Connect(function()
		resolve({ type = "cancel" })
	end)

	-- Timeout
	task.delay(TIMEOUT, function()
		resolve({ type = "cancel" })
	end)

	-- Wait until resolved
	while not resolved do
		task.wait()
	end

	screenGui:Destroy()
	return result
end