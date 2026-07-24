function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
local canuse = true
local equipped = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	local model = game.ServerStorage.Assets.Hood:Clone()
	model.TextureID = "rbxassetid://2699401591"
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local animation
	if not equipped then
		animation = p1.Humanoid:LoadAnimation(script.Parent.Anim1)
		equipped = true
	else
		if not p1:FindFirstChild("Hood") then
			animation = p1.Humanoid:LoadAnimation(script.Parent.Anim2)
			equipped = true
		else
			animation = p1.Humanoid:LoadAnimation(script.Parent.Anim1)
			equipped = false
		end
	end
	animation:Play()
	wait(0.25)
	if equipped then
		model.Parent = p1
		model.Joint.Part0 = p1.Head
		model.Joint.Part1 = model
	else
		for _,v in pairs(p1:GetChildren())do
			if v:IsA("Accessory")then
				if v:FindFirstChild("Handle")then
					v.Handle.Transparency = 0
				end
			end
		end
		p1.Hood.Parent = nil
		model.Parent = nil
	end
	wait(0.75)
	canuse = true
end)