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
	if Parent:FindFirstChild("Action") then
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
		return true
	end
	return false
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
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	if not p2 then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not data then
		return
	end
	if game.ServerStorage.PlayerData[p2.Name].Lives.Value < 1 then
		return
	end
	if p2:FindFirstChild("Danger") then
		return
	end
	canuse = false
	require(game.ServerScriptService.Modules.Commands).Learn(p1)
	local Seer = Instance.new("StringValue")
	Seer.Name = "Seen"
	Seer.Parent = p1
	task.spawn(function()
		task.wait(300)
		Seer:Destroy()
	end)
end)