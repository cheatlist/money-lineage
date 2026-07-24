local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local userInputService = game:GetService("UserInputService")
local remote = game.ReplicatedStorage:WaitForChild("Input")
local tweenService = game:GetService("TweenService")

local function owner(pool)
	return pool:FindFirstChildOfClass("Folder") and pool:FindFirstChildOfClass("Folder").Name == player.Name
end

local function tween(billboardGui)
	local tweenInfo = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Bounce, 
		Enum.EasingDirection.Out 
	)
	local tweenGoal = {Size = UDim2.new(0, 0, 0, 0)}
	return tweenService:Create(billboardGui, tweenInfo, tweenGoal)
end

local function press(input)
	if input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.C then
		for _, pool in pairs(workspace.Thrown:GetChildren()) do
			if pool.Name == "Pool" and owner(pool) then
				if mouse.Target == pool.Water then
					remote:FireServer(input.KeyCode.Name, pool)
					local water = pool:FindFirstChild("Water")
					if water and water:FindFirstChildOfClass("BillboardGui") then
						local billboardGui = water:FindFirstChildOfClass("BillboardGui")
						local bounceTween = tween(billboardGui)
						bounceTween:Play()
					end
				end
			end
		end
	end
end

userInputService.InputBegan:Connect(press)

local function bill(pool)
	local water = pool:WaitForChild("Water")
	if water and water:FindFirstChildOfClass("BillboardGui") then
		local folder = pool:FindFirstChildOfClass("Folder")
		if folder then
			if folder.Name == player.Name then
				water.BillboardGui.Enabled = true
			end
		end	
	end
end

workspace.Thrown.ChildAdded:Connect(function(child)
	if child.Name == "Pool" then
		bill(child)
	end
end)
