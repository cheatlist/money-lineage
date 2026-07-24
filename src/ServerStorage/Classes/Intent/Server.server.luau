local tool = script.Parent
local play = script.Parent.Parent.Parent
local char = play.Character
local tagHumanoid = game.ServerStorage.Requests.TagHumanoid

local en = true

local clientScript = tool.Client
local clientScript2 = tool.Client2

tool.Activated:Connect(function()
	if en == false then return end
	
	if char:FindFirstChild("Action") then return end
	
	local hum = char:FindFirstChild("Humanoid")
	local root = hum and char:FindFirstChild("HumanoidRootPart")
	if not root or hum.Health == 0 then return end

	local playerFolder = game.ServerStorage.PlayerData:FindFirstChild(play.Name)
	if not playerFolder then return end
	
	en = false
	
	local vision = char:FindFirstChild("IntentVision")
	if vision then
		vision:Destroy()
		local clientCleanup = clientScript2:Clone()
		clientCleanup.Parent = char
		clientCleanup.Disabled = false
	else
		local clientEffect = clientScript:Clone()
		clientEffect.Name = "IntentVision"
		clientEffect.Parent = char
		clientEffect.Disabled = false
	end

	wait(3)
	en = true
end)