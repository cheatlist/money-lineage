function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 5,
	})
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
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local anim = p1.Humanoid:LoadAnimation(script.Parent.Anim)
	local door = nil
	local range = 8
	for i,v in pairs(workspace.Doors:children()) do
		if (math.abs((v.Position.X - HumanoidRootPart.Position.X)) < range and math.abs((v.Position.Z - HumanoidRootPart.Position.Z)) < range) and not v:FindFirstChild("BeingOpened") then
				door = v
			end
	end
	if door then
		if door:FindFirstChild('LockedVal') and not door:FindFirstChild("Opened") and not door:FindFirstChild("BeingOpened") then
			local stun = Instance.new("Folder")
			stun.Name = "Action"
			stun.Parent = p1
			local Opening = Instance.new("Folder")
			Opening.Name = "BeingOpened"
			Opening.Parent = door
			anim:Play()
			local sound = HumanoidRootPart.Lockpick:Clone()
			sound.Parent = HumanoidRootPart
			sound:Play()
			game.Debris:AddItem(sound,3)
			local stunadded = nil
			local stunned = false
			stunadded = p2.Character.ChildAdded:Connect(function(t)
				if t.Name == "Action" or t.Name == "Unconscious" then
					stunned = true
				end
			end)
			wait(3)
			Opening:Destroy()
			anim:Stop()
			stunadded:Disconnect()
			if not stunned then
				door:FindFirstChild('LockedVal').Value = not door:FindFirstChild('LockedVal').Value
			end
			stun:Destroy()
		end
	end
	wait(0.4)
	canuse = true
end)