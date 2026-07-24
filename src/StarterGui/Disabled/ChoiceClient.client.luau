local LocalPlayer = game.Players.LocalPlayer
local Communicate = script.Parent:FindFirstChild("Communicate")

local Choices = script.Parent:WaitForChild("Main"):GetChildren()
for Index = 1,#Choices do
	local Object = Choices[Index]
	if Object:IsA("TextButton") then
		Object.Activated:Connect(function()
			if tostring(Object) ~= "Cancel" then
				Communicate:FireServer("MakeChoice",tostring(Object))
			else
				Communicate:FireServer("Cancel")
			end
		end)
	end
end