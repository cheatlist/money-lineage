local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GateRequest = ReplicatedStorage.Requests.ObserveRequest
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TIMEOUT = 10 -- seconds before auto-cancel

local gm = game.Workspace.Parent
local del = gm.Destroy
local playsound = Instance.new("Sound").Play;
local OverlayGui = playerGui:WaitForChild("OverlayGui")
local seerOverlay = OverlayGui.Seer
local TS = game:GetService("TweenService")
local tweencreate = TS.Create;
local seerBlinded = false

GateRequest.OnClientInvoke = function(locationNames)
	-- Build the ScreenGui
	if locationNames == "DESTROY" then
		playerGui:FindFirstChild("OBSERVEUI"):Destroy()
		return
	end
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "OBSERVEUI"
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

	local DRAGGABILITY = Instance.new("UIDragDetector")
	DRAGGABILITY.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 36)
	title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	title.Text = "SELECT A PLAYER TO OBSERVE"
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
		btn.Text = name.displayName
		btn.TextColor3 = Color3.new(1,1,1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.Parent = scroll

		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		btn.MouseButton1Click:Connect(function()
				local targetPlayer = game.Players:FindFirstChild(name.name)
				local targetChar = targetPlayer and targetPlayer.Character
				if targetPlayer 
					and targetChar 
					and targetChar:FindFirstChild("Head") 
					and not targetPlayer.Backpack:FindFirstChild("ObserveBlock") 
					and not targetChar.Boosts:FindFirstChild("ObserveBlock") 
					and not targetChar:FindFirstChild("in green room") 
				then
					if targetPlayer.Backpack:FindFirstChild("Watchful") then
						seerBlinded = true

						seerOverlay.Visible = true
						tweencreate(TS, seerOverlay, TweenInfo.new(0.5), {
							BackgroundTransparency = 0
						}):Play()
						wait(1)

						local eye = seerOverlay.Eye:Clone()
						eye.Parent = seerOverlay

						tweencreate(TS, eye.Sound, TweenInfo.new(1), {
							Volume = 2
						}):Play()
						playsound(eye.Sound)

						eye.Visible = true
						eye:TweenSizeAndPosition(UDim2.new(0, 500, 0, 500), UDim2.new(0.5, -250, 0.5, -175), 
							Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2)
						wait(1)

						tweencreate(TS, eye.Sound, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
						tweencreate(TS, eye, TweenInfo.new(0.5), {
							ImageTransparency = 1
						}):Play()
						wait(0.4)
						tweencreate(TS, seerOverlay, TweenInfo.new(0.5), {
							BackgroundTransparency = 1
						}):Play()
						wait(0.5)

						seerOverlay.Visible = false
						del(eye)

						wait(2)
						seerBlinded = false
					else
						game.Workspace.CurrentCamera.CameraSubject = targetChar.Head
					end
			end
		end)
	end

	-- Auto-size the scroll canvas
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
	end)
	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)

	-- Wait until resolved

	return result
end