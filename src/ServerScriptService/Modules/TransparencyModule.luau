local module = {}

local TweenService = game:GetService("TweenService")
local Blacklist = {IsShifted = true}

function module.gradualTransparency(Character,Reset,Transparency,Time)
	local Character_Descendants= Character:GetDescendants()
	for Index = 1,#Character_Descendants do
		local Object = Character_Descendants[Index]
		if Object:IsA("BasePart") and Object.Transparency ~= 1 and not Blacklist[Object.Name] then
			TweenService:Create(Object,TweenInfo.new(Time,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Transparency = Transparency}):Play()
			task.delay(Time,function()
				Object.Transparency = Reset
			end)
		end
	end
end

return module