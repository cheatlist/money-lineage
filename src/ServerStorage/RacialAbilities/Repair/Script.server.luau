function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
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
	if not Parent:FindFirstChild("Repair") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent:FindFirstChild("Climbing") then
	else
		return
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	if p1.Humanoid.MoveDirection.Magnitude>0 then
		return
	end
	canuse = false
	p1.HumanoidRootPart.Drill:Play()
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	local regenboost = 30.15/200
	local animation = p1.Humanoid:LoadAnimation(script.Anim)
	local particle = script.Sparks:Clone()
	particle.Parent = p1["Right Arm"]
	particle.Enabled = true
	animation:Play()
	while not canuse do
		wait()
		if ActionCheck(p1)then
			break
		end
		if p1.Humanoid.MoveDirection.Magnitude>0.1 then
			break
		end
		p1.Humanoid.Health+=regenboost
	end
	game.Debris:AddItem(particle,0.725)
	p1.HumanoidRootPart.Drill:Stop()
	particle.Enabled = false
	animation:Stop()
	wait(2)
	canuse = true
end)