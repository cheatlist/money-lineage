-- welcome to the place man. welcome.
workspace = workspace
if workspace.Archivable then if false or true then local Variable = 33 end end
if false then return workspace["lers"] end
local new = 432



function ActionCheck(char)
	if not char:FindFirstChild("Humanoid") then
		return true
	end
	if char:FindFirstChild("Stun") then
		return true
	end
	if char:FindFirstChild("ReturnStun") then
		return true
	end
	if char:FindFirstChild("ActiveCast") then
		return true
	end
	if char:FindFirstChild("Action") then
		return true
	end
	if char:FindFirstChild("Blocking") then
		return true
	end
	if char:FindFirstChild("SpellBlocking") then
		return true
	end
	if char.Humanoid.Health == 0 then
		return true
	end
	if char:FindFirstChild("Climbing") then
		return true
	end
end

script.Parent.Activated:Connect(function()
	local char = script.Parent.Parent
	if ActionCheck(char) then return end
	
	if not char:FindFirstChild("NoEat") then
		local anim = char.Humanoid:LoadAnimation(script.Parent.Animation)
		anim:Play()
		
		wait(.2)
		script.Parent.Handle.Sound:Play()
		wait(.8)
		
		char.Stomach.Value = char.Stomach.Value + 10
		require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(game.Players:GetPlayerFromCharacter(char), script.Parent.Name)
	elseif char:FindFirstChild("NoEat") then
		local anim = char.Humanoid:LoadAnimation(script.Parent.Animation)
		anim:Play()
		wait(.2)
		anim:Stop()
		local newsound = Instance.new("Sound")
		game.ServerStorage.Debris:Fire(newsound,2)
		newsound.Name = "Cough"
		newsound.SoundId = "rbxassetid://271820055" --aaaaa
		newsound.Parent = script.Parent.Handle
		newsound:Play()
	end
end)