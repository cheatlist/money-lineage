local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OptionPickerRequest = ReplicatedStorage.Requests:WaitForChild("OptionPickerRequest")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

OptionPickerRequest.OnClientInvoke = function(payload)
	local title = payload.title or "Choose"
	local options = payload.options or {}
	local timeout = payload.timeout or 10

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "OptionPickerUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 320, 0, 260)
	frame.Position = UDim2.new(0.5, -160, 0.5, -130)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 36)
	titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.Parent = frame
	Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 8)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -16, 1, -92)
	scroll.Position = UDim2.new(0, 8, 0, 44)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = frame

	local listLayout = Instance.new("UIListLayout", scroll)
	listLayout.Padding = UDim.new(0, 4)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0, 80, 0, 28)
	cancelBtn.Position = UDim2.new(1, -88, 1, -36)
	cancelBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
	cancelBtn.Text = "Cancel"
	cancelBtn.TextColor3 = Color3.new(1, 1, 1)
	cancelBtn.Font = Enum.Font.GothamBold
	cancelBtn.TextSize = 13
	cancelBtn.Parent = frame
	Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)

	local result = nil
	local resolved = false
	local function resolve(key)
		if resolved then
			return
		end
		resolved = true
		result = { key = key }
	end

	for _, option in ipairs(options) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 28)
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		btn.Text = option.label
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.Parent = scroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		btn.MouseButton1Click:Connect(function()
			resolve(option.key)
		end)
	end

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
	end)
	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)

	cancelBtn.MouseButton1Click:Connect(function()
		resolve(nil)
	end)

	task.delay(timeout, function()
		resolve(nil)
	end)

	while not resolved do
		task.wait(1 / 30)
	end

	screenGui:Destroy()
	return result
end
