local Player = script.Parent.Parent.Parent
local Character = Player.Character
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 1,
	})
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

script.Parent.Activated:Connect(function()
	if not Cooldown then
		if ActionCheck(Character) then
			return
		end
		Cooldown = true
		task.delay(30, function()
			Cooldown = false
		end)
		local WindupAnimation = Character.Humanoid:LoadAnimation(script.Parent.Animations.WindUp)
		WindupAnimation.Priority = Enum.AnimationPriority.Action4
		WindupAnimation:Play()
		WindupAnimation:AdjustSpeed(0.25)
		task.wait(0.2)
		WindupAnimation:AdjustSpeed(0.75)
		task.wait(0.3)
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
				if not Nearest:FindFirstChild("FireHit") then
					Nearest.HumanoidRootPart:FindFirstChild("FireHit"):Clone().Parent = Nearest
				end
				Nearest:SetAttribute('LastShoulder', Now)
				local Stun = Instance.new("Accessory")
				Stun.Name = "Stun"
				Stun.Parent = Nearest
				local Action = Instance.new("Accessory")
				Action.Name = "Action"
				Action.Parent = Character
				task.wait()
				Nearest.Humanoid.AutoRotate = false; Character.Humanoid.AutoRotate = false
				Anchor(Character, true)
				Nearest.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -1, 0) * CFrame.Angles(0, math.pi, 0)
				Anchor(Nearest, true)
				Nearest.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -1, 0) * CFrame.Angles(0, math.pi, 0)
				local ThrowingAnimation = Character.Humanoid:LoadAnimation(script.Parent.Animations.Throwed)
				local ThrownAnimation = Nearest.Humanoid:LoadAnimation(script.Parent.Animations.BeingThrowed)
				ThrowingAnimation:Play(); ThrownAnimation:Play()
				task.wait(0.1)
				ThrowingAnimation:AdjustSpeed(0)
				ThrownAnimation:AdjustSpeed(0)
				task.wait(0.1)
				ThrowingAnimation:AdjustSpeed(1)
				ThrownAnimation:AdjustSpeed(1)
				ThrowingAnimation:GetMarkerReachedSignal("pause"):Connect(function()
					local Hit = false
					Nearest.HumanoidRootPart.CFrame = Character["Left Arm"].CFrame * CFrame.Angles(0, math.pi, 0)
					Nearest.Humanoid.AutoRotate = false; Character.Humanoid.AutoRotate = false
					if not Hit then
						Hit = true
						for i = 1,4 do
							local v58 = Instance.new("Accessory")
							v58.Name = "Stun"
							v58.Parent = Character
							game.Debris:AddItem(v58, 0.2)
							local truefalse = false
							local falsetrue = false
							if i == 1 then
								truefalse = true
							end
							if i == 4 then
								falsetrue = true
								local v9 = Instance.new("Accessory");
								v9.Name = "SuperStrength";
								v9.Parent = Character.Boosts;
								game:GetService("Debris"):AddItem(v9,0.3)
							end
							if truefalse == false then
								Nearest.HumanoidRootPart.Firesound:Play()
							end
						game.ServerStorage.Requests.TagHumanoid:Fire(Player.Character, Nearest, {
							physical = truefalse, 
							sword = truefalse,
							noparry = true,
							blockbreak = false,
							noenchant = true,
							sigilflame = true,
							damage = 1,
							knockback = falsetrue
							})
							if i==4 then
								ThrowingAnimation:AdjustSpeed(1); ThrownAnimation:AdjustSpeed(1)
								ThrownAnimation:Stop()
								Nearest.Humanoid.AutoRotate = true; Character.Humanoid.AutoRotate = true
								Anchor(Nearest); Anchor(Character)
								Stun:Destroy()
							end
							if i~= 4 then
								task.wait(0.2)
							end
						end
					end
				end)
			end
		end
		
	end
end)