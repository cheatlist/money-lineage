local Player = script.Parent.Parent.Parent
local Character = Player.Character
function ActionCheck(Parent)
	if Parent:FindFirstChild("EquipWarmup") then
		return true
	end
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
	if Parent.Humanoid.Health<1 then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
local Debris = game:GetService("Debris")
local Cooldown = false
function Anchor(Target, Statement)
	if Statement then
		game.CollectionService:AddTag(Target, "FreezeRoot")
	else
		game.CollectionService:RemoveTag(Target, "FreezeRoot")
	end
end
local function Nearest(Origin, User)
	local High = 12
	local Target = nil
	for i, v in pairs(workspace.Live:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= User and not v:FindFirstChild("ForceField") then
			if v.Humanoid.Health > 0 then
				local Formula = (v:WaitForChild("HumanoidRootPart").Position - Origin).Magnitude <= High
				Formula = Formula and (User.HumanoidRootPart.CFrame:inverse() * v.HumanoidRootPart.CFrame).Z < 0 
				Formula = Formula and math.abs((User.HumanoidRootPart.CFrame:Inverse() * v.HumanoidRootPart.CFrame).X) <= 7
				Formula = Formula and math.abs((User.HumanoidRootPart.CFrame:Inverse() * v.HumanoidRootPart.CFrame).Y) <= 5
				if Formula then
					local High = (v:WaitForChild("HumanoidRootPart").Position - Origin).Magnitude
					Target = v
				end
			end
		end
	end
	return Target
end

local serverstorage = game:GetService("ServerStorage")
script.Parent.Activated:Connect(function()
	if not Cooldown then
		if ActionCheck(Character) then
			return
		end
		Cooldown = true
		local playerdata = serverstorage.PlayerData:FindFirstChild(Character.Name)
		if playerdata then
			if playerdata.Race.Value == "Ashiin" and playerdata.Ascended.Value == true then
				task.delay(15, function()
					Cooldown = false
				end)
			else
				task.delay(25, function()
					Cooldown = false
				end)
			end
		end
		local WindupAnimation = Character.Humanoid:LoadAnimation(script.Parent.Animations.WindUp)
		WindupAnimation.Priority = Enum.AnimationPriority.Action4
		WindupAnimation:Play()
		WindupAnimation:AdjustSpeed(0.25)
		wait(0.2)
		WindupAnimation:AdjustSpeed(0.75)
		wait(0.3)
		if not Character:FindFirstChild("Knocked") and not Character:FindFirstChild("Unconscious") then
			if Nearest(Character.HumanoidRootPart.Position, Character) then
				
				local Nearest = Nearest(Character.HumanoidRootPart.Position, Character)
				if Nearest:FindFirstChild("Knocked") then
					return
				end
				if Nearest:FindFirstChild("Immortal") then
					return
				end
				if Nearest:FindFirstChild("IFRAME") then
					return
				end
				for i = 1, 2 do
					local Descendants = Character.HumanoidRootPart:GetChildren()
					if i == 2 then
						Descendants = Nearest.HumanoidRootPart:GetChildren()
					end
					for ind, val in pairs(Descendants) do
						if val:IsA("BodyVelocity") then
							val:Destroy()
						end
					end
				end
				Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
				Nearest.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
				local NearestPlayer = game:GetService("Players"):GetPlayerFromCharacter(Nearest)
				if not NearestPlayer then NearestPlayer = Nearest end
				local LastCD: number = Nearest:GetAttribute('LastShoulder') or 0
				local Now: number = os.clock()
				if Now - LastCD < 6 then
					Cooldown = false
					return
				end
				Nearest:SetAttribute('LastShoulder', Now)
				local Stun = Instance.new("Accessory")
				Stun.Name = "Stun"
				Stun.Parent = Nearest
				local Action = Instance.new("Accessory")
				Action.Name = "Action"
				Action.Parent = Character
				wait()
				Nearest.Humanoid.AutoRotate = false; Character.Humanoid.AutoRotate = false
				Anchor(Character, true)
				Nearest.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -1, 0) * CFrame.Angles(0, math.pi, 0)
				Anchor(Nearest, true)
				Nearest.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -1, 0) * CFrame.Angles(0, math.pi, 0)
				local ThrowingAnimation = Character.Humanoid:LoadAnimation(script.Parent.Animations.Throwed)
				local ThrownAnimation = Nearest.Humanoid:LoadAnimation(script.Parent.Animations.BeingThrowed)
				ThrowingAnimation:Play(); ThrownAnimation:Play()
				wait(0.1)
				ThrowingAnimation:AdjustSpeed(0)
				ThrownAnimation:AdjustSpeed(0)
				wait(0.1)
				ThrowingAnimation:AdjustSpeed(1)
				ThrownAnimation:AdjustSpeed(1)
				local LengthTick = tick()
				local Hit = false
				while true do
					if tick() - LengthTick > 0.55 then
						if not Hit then
							Hit = true
							pcall(function() Nearest.HumanoidRootPart.Smashing:Play() end)
							game.ServerStorage.Requests.TagHumanoid:Fire(Player.Character, Nearest, {
								physical = true,
								noparry = true,
								blockbreak = true,
								manabreaker = true,
								noenchant = true,
								damage = 12,
								fist = true,
								blacksmithm1 = true,
							})
						end
					end
					if tick() - LengthTick > 0.85 then
						break
					end
					Nearest.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame - (Character.HumanoidRootPart.CFrame.LookVector * (-2 + ((tick() - LengthTick)/0.7 * 6))) + Character.HumanoidRootPart.CFrame.RightVector * (0 + ((tick() - LengthTick)/0.3 * 1))
					Nearest.Humanoid.AutoRotate = false; Character.Humanoid.AutoRotate = false
					Anchor(Nearest, true); Anchor(Character, true)
					ThrowingAnimation.TimePosition = (tick() - LengthTick)/0.55 * 0.3
					ThrownAnimation.TimePosition = (tick() - LengthTick)/0.55 * 0.25
					Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
					Nearest.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
					wait(0.1)
				end
				ThrowingAnimation:AdjustSpeed(0); ThrownAnimation:AdjustSpeed(0)
				Action:Destroy()
				wait(0.15)
				ThrowingAnimation:AdjustSpeed(1); ThrownAnimation:AdjustSpeed(1)
				Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
				Nearest.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
				Nearest.Humanoid.AutoRotate = true; Character.Humanoid.AutoRotate = true
				Anchor(Nearest); Anchor(Character)
				Stun:Destroy()
			end
		end
		
	end
end)