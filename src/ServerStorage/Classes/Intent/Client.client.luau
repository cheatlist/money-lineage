local Player = game.Players.LocalPlayer
local Character = Player.Character

local Tool = script.Parent
local intentGUI = script:WaitForChild("Watched")

local RANGE = 100

function record(char)
	local watched = char:FindFirstChild("Watched")
	if watched then return end
	
	local hrp = Character:WaitForChild("HumanoidRootPart")
	local ehrp = char:WaitForChild("HumanoidRootPart")
	
	local eye = intentGUI:clone()
	local display = eye.Tool
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then
		display.Text = tool.Name
	end
	
	eye.Parent = workspace.Thrown
	eye.Adornee = ehrp
	
	char.ChildAdded:connect(function(object)
		if object.ClassName == "Tool" then
			display.Text = object.Name
		end
	end)
	
	char.ChildRemoved:connect(function(object)
		if object.ClassName == "Tool" then
			display.Text = ""
		end
	end)
	
	Character.Humanoid.Died:Connect(function(player)
		for i,v in pairs(game.Workspace.Thrown:GetChildren()) do
			if v.Name == "Watched" then
				spawn(function()
					game.TweenService:Create(v.Tool,TweenInfo.new(0.25),{TextTransparency = 1}):Play()
					wait(0.25)
					v:Destroy()
				end)
			end
		end
	end)
	
	spawn(function()
		while true do
			ehrp = char:FindFirstChild("HumanoidRootPart")
			eye.Adornee = ehrp
			if ehrp and (hrp.Position - ehrp.Position).Magnitude < RANGE then
				game.TweenService:Create(display,TweenInfo.new(0.25),{TextTransparency = 0}):Play()
			else
				game.TweenService:Create(display,TweenInfo.new(0.25),{TextTransparency = 1}):Play()
			end
			wait(0.5)
		end
	end)
end

for i, v in pairs(game.Workspace.Live:GetChildren()) do
	if v.Name ~= Player.Name then
		spawn(function()
			record(v)
		end)
	end
end

workspace.Live.ChildAdded:Connect(function(char)
	record(char)
end)

script.Sound:Play()