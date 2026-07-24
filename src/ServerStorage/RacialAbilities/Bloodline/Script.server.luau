function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if not Parent:FindFirstChild("Humanoid")then
		return true
	end
	if not Parent:FindFirstChild("HumanoidRootPart")then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
local canuse = true
script.Parent.Activated:Connect(function()
	if not canuse then
		return
	end
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1:FindFirstChild("ResGlobalCD") then
		return
	end
	if p1:FindFirstChild("Unconscious") and not game:GetService("CollectionService"):HasTag(p1, "BeingExecuted") then
		canuse = false
		local p2 = game.Players:GetPlayerFromCharacter(p1)
		local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
		game.ReplicatedStorage.Requests.AngryHaseldan:FireClient(p2)
		local v1 = Instance.new("Accessory")
		v1.Name = "HaseldanDamageMultiplier"
		v1.Parent = p1
		game.Debris:AddItem(v1,30)
		local v2 = Instance.new("Accessory")
		v2.Name = "SuperStrength"
		v2.Parent = p1
		game.Debris:AddItem(v2,30)
		local v3 = Instance.new("Accessory")
		v3.Name = "RageCooldown"
		v3.Parent = p1
		game.Debris:AddItem(v3,300)
		local v4 = Instance.new("Accessory")
		v4.Name = "ResGlobalCD"
		v4.Parent = p1
		game.Debris:AddItem(v4,300)
		for _,v in pairs(p1:GetChildren())do
			if v.Name == "Knocked"or v.Name == "Unconscious"or v.Name == "Action"or v.Name == "NoDam"then
				v:Destroy()
			end
		end
		if data.Ascended.Value ~= true then
			task.delay(30, function()
				if not p1:FindFirstChild("Grabbed") and not game:GetService("CollectionService"):HasTag(p1, "BeingExecuted") then
					local folder1 = Instance.new("Accessory")
					folder1.Name = "Unconscious"
					folder1.Parent = p1
					local folder1 = Instance.new("Accessory")
					folder1.Name = "Knocked"
					folder1.Parent = p1
					task.delay(5, function()
						for _,v in pairs(p1:GetChildren())do
							if v.Name == "Knocked"or v.Name == "Unconscious"or v.Name == "Action"or v.Name == "NoDam"then
								v:Destroy()
							end
						end
					end)
				end
			end)
		end
		p1.Humanoid.Health += 40
		p1.HumanoidRootPart.SCREAM1:Play()
		wait(300)
		canuse = true
	end
end)