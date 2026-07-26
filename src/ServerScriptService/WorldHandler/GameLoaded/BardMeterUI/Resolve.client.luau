local Client = game:GetService("Players").LocalPlayer
local Character = Client.Character or Client.CharacterAdded:Wait()
local BardCombo = Character:WaitForChild("BardCombo")

repeat
	task.wait(1/30)
until not Character:FindFirstChild("NotLoaded")

local Bar = script:FindFirstAncestorOfClass("ScreenGui"):FindFirstChildOfClass("Frame"):FindFirstChildOfClass("Frame"):FindFirstChildOfClass("Frame")
local Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function AdjustBar()
	local Clamped = math.clamp(BardCombo.Value / 4, 0, 1)
	game:GetService("TweenService"):Create(Bar, Info, {
		Size = UDim2.new(Clamped, 0, 1, 0)
	}):Play()
end

task.spawn(AdjustBar)

BardCombo.Changed:Connect(AdjustBar)