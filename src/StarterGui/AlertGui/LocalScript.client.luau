local TweenService = game:GetService("TweenService")
local Requests = game.ReplicatedStorage:WaitForChild("Requests")

local DEFAULT_DURATION = 6
local FADE_TIME = 0.25

local screenGui = script.Parent

local container = Instance.new("Frame")
container.Name = "AlertContainer"
container.AnchorPoint = Vector2.new(0.5, 0)
container.Position = UDim2.new(0.5, 0, 0, 12)
container.Size = UDim2.new(0.3, 0, 0, 0)
container.AutomaticSize = Enum.AutomaticSize.Y
container.BackgroundTransparency = 1
container.Parent = screenGui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(280, 0)
sizeConstraint.MaxSize = Vector2.new(480, math.huge)
sizeConstraint.Parent = container

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = container

local nextOrder = 0

local function dismiss(frame, label, stroke)
	local absoluteHeight = frame.AbsoluteSize.Y
	frame.AutomaticSize = Enum.AutomaticSize.None
	frame.Size = UDim2.new(1, 0, 0, absoluteHeight)

	local collapseTween = TweenService:Create(frame, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
	})
	TweenService:Create(label, TweenInfo.new(FADE_TIME * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(stroke, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Transparency = 1,
	}):Play()
	collapseTween:Play()
	collapseTween.Completed:Wait()
	frame:Destroy()
end

local function createAlert(text, duration)
	nextOrder += 1
	local order = nextOrder

	local frame = Instance.new("Frame")
	frame.Name = "Alert"
	frame.LayoutOrder = order
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(235, 175, 70)
	stroke.Thickness = 1.5
	stroke.Transparency = 1
	stroke.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 14)
	padding.PaddingRight = UDim.new(0, 14)
	padding.Parent = frame

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextTransparency = 1
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Text = tostring(text)
	label.Parent = frame

	TweenService:Create(frame, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.1,
	}):Play()
	TweenService:Create(stroke, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0.4,
	}):Play()
	TweenService:Create(label, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	}):Play()

	task.delay(duration or DEFAULT_DURATION, function()
		dismiss(frame, label, stroke)
	end)
end

Requests:WaitForChild("Alert").OnClientEvent:Connect(function(text, duration)
	createAlert(text, duration)
end)
