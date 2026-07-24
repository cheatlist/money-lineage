local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Doors, Live, DoorCD, CD = workspace.Doors, workspace.Live, {}, {}

function ActionCheck(Character)
	if Character:FindFirstChild("Stun") then
		return true
	end
	if Character:FindFirstChild("ReturnStun") then
		return true
	end
	if Character:FindFirstChild("ActiveCast") then
		return true
	end
	if Character:FindFirstChild("Action") then
		return true
	end
	if Character:FindFirstChild("Blocking") then
		return true
	end
	if Character:FindFirstChild("Climbing") then
		return true
	end
	return false
end

local RealDoors = {}
for i,v in pairs(Doors:GetChildren()) do
	table.insert(RealDoors, {
		Door = v;
		RealPosition = v.Position;
	})

	if v.Name == "Gate" and v:FindFirstChild("Lock") then
		local LockedVal = v.LockedVal
		local LockSound = v.Lock.Lock
		v.Lock.ClickDetector.MouseClick:Connect(function()
			LockedVal.Value = not LockedVal.Value
			LockSound:Play()
		end)
	end
end

local function RemoveCD(Door, s)
	task.delay(s, function()
		CD[Door] = nil
	end)
end

ReplicatedStorage.Requests.DoorAction.OnServerEvent:Connect(function(Player)
	local Character = Player.Character
	if not Character or Character.Parent ~= Live or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then
		return
	end

	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")	
	if ActionCheck(Character) == false and not DoorCD[Character] and HumanoidRootPart then
		for i,v in pairs(RealDoors) do
			if (HumanoidRootPart.Position - v.RealPosition).Magnitude <= v.Door.Size.Y + 0.25  and not CD[v.Door] then
				local Door = v.Door
				CD[Door] = true
				if not DoorCD[Character] then
					DoorCD[Character] = true
					task.delay(0.5, function()
						DoorCD[Character] = nil
					end)
				end
               
				local State, Progress, Scale = Door.State, Door.Progress, Door.Scale
				if State.Value == false then
					if Door:FindFirstChild("LockedVal") and Door.LockedVal.Value == true then
						CD[Door] = nil
						return
					end

					if Door.Name == "SpeakeasyDoor" then
						local DoorToChar = HumanoidRootPart.Position - Door.Position
						if DoorToChar:Dot(Door.CFrame.LookVector) <= 0 then
							Door.Open:Play()
							TweenService:Create(Door, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
								CFrame = (Door.CFrame * CFrame.Angles(0, math.rad(90), 0) + Door.CFrame.LookVector * -Door.Size.X / 2 + Door.CFrame.RightVector * Door.Size.X / 2)
							}):Play();
							RemoveCD(Door, 0.35);
						else
							Door.Knock:Play()
							coroutine.wrap(function()
								task.wait(1)
								Door.Open:Play()
								TweenService:Create(Door, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
									CFrame = (Door.CFrame * CFrame.Angles(0, math.rad(90), 0) + Door.CFrame.LookVector * -Door.Size.X / 2 + Door.CFrame.RightVector * Door.Size.X / 2)
								}):Play();
								RemoveCD(Door, 0.35);
							end)()
							if game.ServerStorage.PlayerData[HumanoidRootPart.Parent.Name].Alignment.Value < 0 then
								Door.Open:Play()
								TweenService:Create(Door, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
									CFrame = (Door.CFrame * CFrame.Angles(0, math.rad(90), 0) + Door.CFrame.LookVector * -Door.Size.X / 2 + Door.CFrame.RightVector * Door.Size.X / 2)
								}):Play();
							end
						end
					else
						Door.Open:Play()
					end

					if Door.Name == "Gate" then
						TweenService:Create(Door, TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							CFrame = (Door.CFrame + Door.CFrame.UpVector * Door.Size.Y)
						}):Play();
						RemoveCD(Door, 0.9);
					elseif Door.Name == "Door" then
						TweenService:Create(Door, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							CFrame = (Door.CFrame * CFrame.Angles(0, math.rad(90), 0) + Door.CFrame.LookVector * -Door.Size.X / 2 + Door.CFrame.RightVector * Door.Size.X / 2)
						}):Play();
						RemoveCD(Door, 0.35);
					elseif Door.Name == "ScroomKey" and Character:FindFirstChild("Scroom Key") then
						TweenService:Create(Door, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							CFrame = (Door.CFrame * CFrame.Angles(0, math.rad(90), 0) + Door.CFrame.LookVector * -Door.Size.X / 2 + Door.CFrame.RightVector * Door.Size.X / 2)
						}):Play();
						RemoveCD(Door, 0.35);
					end
				else
					if Door:FindFirstChild("LockedVal") and Door.LockedVal.Value == true then
						CD[Door] = nil
						return
					end
					Door.Close:Play()
					if Door.Name == "Gate" then
						TweenService:Create(Door, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							CFrame = (Door.CFrame - Door.CFrame.UpVector * Door.Size.Y)
						}):Play();
						RemoveCD(Door, 0.3);
					elseif Door.Name == "Door" or Door.Name == "SpeakeasyDoor" then
						TweenService:Create(Door, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							CFrame = (Door.CFrame * CFrame.Angles(0, math.rad(-90), 0) - Door.CFrame.LookVector * -Door.Size.X / 2 - Door.CFrame.RightVector * -Door.Size.X / 2)
						}):Play();
						RemoveCD(Door, 0.35);
					elseif Door.Name == "ScroomKey" and Character:FindFirstChild("Scroom Key") then
						TweenService:Create(Door, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							CFrame = (Door.CFrame * CFrame.Angles(0, math.rad(-90), 0) - Door.CFrame.LookVector * -Door.Size.X / 2 - Door.CFrame.RightVector * -Door.Size.X / 2)
						}):Play();
						RemoveCD(Door, 0.35);
					end
				end
				State.Value = not State.Value
			end
		end
	end
end)

game.ReplicatedStorage.Requests.ThrowPot.OnServerEvent:Connect(function(Player) -- you're an idiot arda -- legit gonna murder you bro don't fucking come to turkey
	local Character = workspace.Live:FindFirstChild(Player.Name)
	if not Character  then
		return
	end
	local Data = game.ServerStorage.PlayerData[Player.Name]
	Player = game.Players[Player.Name]
	if Character:FindFirstChild("POTCD") then
		return
	end
	if Player.Name ~= "" then
		return
	end
	local tool = Character:FindFirstChildOfClass("Tool")
	if not tool then
		return
	end
	local anim = Character.Humanoid:LoadAnimation(Character.HumanoidRootPart.Snap2)
	anim:AdjustSpeed(0)
	anim:Play()	
	anim.TimePosition = anim.Length - 0.05
	anim:AdjustSpeed(0)

	local cancel = false
	local detect = Character.ChildAdded:Connect(function(child)
		if child.Name == "NoDam" then
			anim:Stop()
			cancel = true
		end
	end)
	task.wait(1.8)
	detect:Disconnect()
	task.wait(0.2)
	if cancel then
		return
	end
	local tool = Character:FindFirstChildOfClass("Tool")
	if tool then
		local toolname = tool.Name
		if not string.find(tool.Name, "Cure") and tool:FindFirstChild("PoisonValue") then
			local s = Instance.new("Folder")
			s.Name = "POTCD"
			s.Parent = Character
			game.Debris:AddItem(s, 5)
			local severity = tool.PoisonValue.Value
			local poisonseverity = tool.PoisonValue.Value
			local symptomps = {}
			if poisonseverity >= 25 then
				table.insert(symptomps, "ManaStop")
			end
			if poisonseverity >= 50 then
				table.insert(symptomps, "Slowness")
			end
			if poisonseverity >= 75 then
				table.insert(symptomps, "Weakness")
			end
			if poisonseverity >= 100 then
				table.insert(symptomps, "Demise")
			end
			if poisonseverity >= 120 then
				table.remove(symptomps, table.find(symptomps, "Demise"))
				table.insert(symptomps, "Hallucination")
			end
			require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(Player, toolname)
			tool:Destroy()
			for i,v in pairs(workspace.Live:GetChildren()) do
				if v ~= Character and v:FindFirstChild("HumanoidRootPart") and (Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 25 then
					for i = 1,#symptomps do
						game.ServerStorage.Requests.TagHumanoid:Fire(Character, v, {disease = symptomps[i], mana = true})
					end
				end
			end
		end
	end
end)