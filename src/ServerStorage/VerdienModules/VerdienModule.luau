local module = {}
module.__index = module;

local VerdienModules, Thrown = script.Parent, workspace.Thrown

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local TagHumanoid = {
	TagHumanoid = function(...)
		ServerStorage.Requests.TagHumanoid:Fire(...)
	end,
}

function module:unfurl(Grass, Seconds)
	if not Seconds or Seconds <= 0 then Seconds = 2 end
	Seconds = 1.5;

	coroutine.wrap(function()
		for i,v in pairs(Grass:GetChildren()) do
			if v.Name == "Petal" then
				local X, Y, Z, toTween = v.Orientation.X, v.Orientation.Y, v.Orientation.Z, Vector3.new(0, 0, 0)

				if Y == 90 and Z == 45 then
					toTween = Vector3.new(0, 90, 0);
				elseif Y == -90 and Z == 45 then
					toTween = Vector3.new(0, -90, 0);
				elseif Y == -180 and Z == 0 then
					toTween = Vector3.new(0, -180, 0);
				elseif Y == 0 and Z == 0 then
					toTween = Vector3.new(0, 0, 0);
				end

				TweenService:Create(v, TweenInfo.new(Seconds), {
					Orientation = toTween
				}):Play();
			end
		end
	end)()

	return Seconds
end

function module:onGrass(Character)
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then return nil end;

	local ray = Ray.new(HumanoidRootPart.CFrame.p, Vector3.new(0, -6, 0))
	local part, endPoint = workspace:FindPartOnRayWithIgnoreList(ray, {Character, workspace.Live, workspace.Thrown}, false, true)

	if not part then return nil end;
	return ((part.Material == Enum.Material.Grass) or false)
end

local function ray(p1, p2, p3, p4) --// thanks rogue :)
	local part, endPoint, w = workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).LookVector * p3), p4);
	return part, endPoint, w;
end;

function module:checkNextHeight(Vectorr1, Vectorr2)
	local Height = Vectorr1 + Vector3.new(0, 6, 0);
	local part, Position, _ = ray(Height, Height - Vector3.new(0, 0.5, 0), 10 + Vectorr2, {workspace.Live, workspace.Thrown});
	return Height.Y - Position.Y;
end;

function module:doSound(Sound)
	Sound:Play();
	task.spawn(function()
		Sound.TimePosition = 0;
		task.wait(2);
		if Sound and Sound.Parent then
			Sound:Stop();
		end;
	end);
end;

function module:sinuousMotion(p13, p14, p15, p16, p17, p18) --// thanks rogue
	task.spawn(function()
		task.wait(math.random());
		local v29 = -p15 * math.sin(math.rad(p13.Orientation.Y));
		local v30 = -p15 * math.cos(math.rad(p13.Orientation.Y));
		p13.Parent = workspace.Thrown;
		p13:SetNetworkOwner(nil);
		local v32 = TweenInfo.new(1 / p16, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
		local v33 = TweenInfo.new(2 / p16, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
		local v34 = 0;
		while true do
			if v34 >= p14 then
				break;
			end;
			local v35 = p13.Position + Vector3.new(v29, p17, v30);
			local v36 = p17 - module:checkNextHeight(v35, p17);
			if (math.abs(math.abs(v36) - 10) < 0.1) then
				p13:Destroy();
				break;
			end;
			if math.abs(math.abs(p17 - module:checkNextHeight(p13.Position + Vector3.new(0, v36, 0) + Vector3.new(5 * v29, p17, 5 * v30), p17)) - 10) < 0.1 then
				p13:Destroy();
				break;
			end;

			TweenService:Create(p13, v32, {
				Position = v35 + Vector3.new(0, v36, 0)
			}):Play();

			task.wait(1 / p16);
			local l__Sound__37 = p13:FindFirstChild("Sound");
			if l__Sound__37 then
				if 0.75 < math.random() then
					module:doSound(l__Sound__37);
				end;
			end;

			for v41, v42 in pairs(workspace.Live:GetChildren()) do
				if (p13.Position - v42.Torso.Position).Magnitude < 16 then
					if v42 ~= p18.Character then				
						TagHumanoid.TagHumanoid(p18.Character, v42, {
							damage = 5,
							poison = true,
							bypassfischdodge = true,
							backblockignore = true,
							floresco = true,
						})
					end;
				end
			end

			TweenService:Create(p13, v33, {
				Position = p13.Position + 2 * Vector3.new(v29, -p17, v30)
			}):Play();
			task.wait(2 / p16);
			TweenService:Create(p13, v32, {
				Position = p13.Position + Vector3.new(v29, p17, v30)
			}):Play();

			task.wait(1 / p16);
			v34 = v34 + 4 / p16;		
		end;
		Debris:AddItem(p13, 0.1);
	end);
end;

function module:fadeOut(ingredient)
	local CantPick = Instance.new("Accessory")
	CantPick.Name = "CantPick"
	CantPick.Parent = ingredient

	if ingredient:FindFirstChild("ClickDetector") then
		ingredient.ClickDetector.MaxActivationDistance = 0
	end

	if ingredient:IsA("Model") then
		for i,v in pairs(ingredient:GetChildren()) do
			coroutine.wrap(function()
				if v:IsA("BasePart") then
					for i = v.Transparency, 0.8, 0.1 do --// perflora transparency
						v.Transparency = i
						task.wait(0.09)
					end
				end
			end)()
		end
	elseif ingredient:IsA("BasePart") then
		for i = ingredient.Transparency, 1, 0.1 do
			ingredient.Transparency = i
			task.wait(0.09)
		end
	end

	if CantPick.Parent then
		CantPick:Destroy()
	end
	return ingredient
end

function module:fadeInStart(ingredient)
	local CantPick = Instance.new("Accessory")
	CantPick.Name = "CantPick"
	CantPick.Parent = ingredient

	if ingredient:FindFirstChild("ClickDetector") then
		ingredient.ClickDetector.MaxActivationDistance = 0
	end

	local PartColor = Color3.fromRGB(0, 0, 0)
	if ingredient:IsA("Model") then
		coroutine.wrap(function()
			for i,v in pairs(ingredient:GetChildren()) do
				task.spawn(function()
					if v:IsA("BasePart") then
						PartColor = v.Color
						for i = 0.9, 0, -0.1 do
							if i < 0.1 then i = 0.1 end
							v.Transparency = i
							v.Color = Color3.fromRGB(100, 255, 100);
							pcall(function()
								v.UsePartColor = true;
							end)
							task.wait(0.09)
						end
						pcall(function()
							v.UsePartColor = false;
						end)
						v.Color = PartColor
					end
				end)
			end

			task.wait(0.9)
			if CantPick.Parent then
				CantPick:Destroy()
			end
		end)()
	else
		PartColor = ingredient.Color
		for i = 0.9, 0, -0.1 do
			if i < 0.1 then i = 0.1 end
			ingredient.Transparency = i
			ingredient.Color = Color3.fromRGB(100, 255, 100);
			pcall(function()
				ingredient.UsePartColor = true;
			end)
			task.wait(0.09)
		end

		if CantPick.Parent then
			CantPick:Destroy()
		end

		pcall(function()
			ingredient.UsePartColor = false;
		end)

		pcall(function()
			ingredient.Color = PartColor
		end)
		ingredient.Color = PartColor
	end
	return ingredient
end

function module:fadeInFail(ingredient)
	ingredient.Transparency = 1
end

function module:fadeInSuccess(ingredient)
	if ingredient:IsA("Model") then
		for i,v in pairs(ingredient:GetChildren()) do
			if v:IsA("BasePart") then
				v.Transparency = 0

				pcall(function()
					v.UsePartColor = false
				end)
			end
		end
	elseif ingredient:IsA("BasePart") then
		ingredient.Transparency = 0
		pcall(function()
			ingredient.UsePartColor = false;
		end)

		if ingredient:FindFirstChild("ClickDetector") then
			ingredient.ClickDetector.MaxActivationDistance = 20
		end

		local Shards = VerdienModules.Shards:Clone()
		Shards.Parent = ingredient
		Shards:Emit(5)
		Debris:AddItem(Shards, 5);
	end
end

function module:grow(Character, isVerdien) --//fixed by vexedtoast moment
	if isVerdien then
		local HumanoidRootPart = Character.HumanoidRootPart
		HumanoidRootPart.Growth:Play()
		for i,v in pairs(workspace.Ingredients:GetChildren()) do
			coroutine.wrap(function()
				if v.Transparency == 1 and v.Name ~= "Frost Princess" then
					if (HumanoidRootPart.Position - v.Position).Magnitude <= 40 then			
						print(v.Name)
						if not v:FindFirstChild("VCD") then
							module:fadeInStart(v)
							local CD = Instance.new("Accessory")
							CD.Name = "VCD"
							CD.Parent = v;
							Debris:AddItem(CD, 10 * isVerdien);

							local Chance = math.random(0, 100);
							print(Chance)
							if Chance <= 60 then
								module:fadeInSuccess(v);
							else
								module:fadeInFail(v);
							end;
						end
					end
				end
			end)()
		end
	end
end

function module:snapEffect(Character, v7)
	local HandHoldNature = VerdienModules.HandHoldNature:Clone()
	HandHoldNature.Anchored = true;
	HandHoldNature.Parent = Thrown
	Debris:AddItem(HandHoldNature, 1);

	local RightArm, HumanoidRootPart, Humanoid = Character:FindFirstChild("Right Arm"), Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
	if not RightArm or not HumanoidRootPart or not Humanoid then
		return;
	end

	local SnapSound, SnapAnimation = VerdienModules.Snap:Clone(), Humanoid:LoadAnimation(VerdienModules.SnapAnimation)
	SnapSound.Parent = HumanoidRootPart
	Debris:AddItem(SnapSound, 2.5);

	SnapAnimation:Play()
	SnapSound:Play()

	--HandHoldNature.Position = RightArm.Position
	HandHoldNature.Position = Vector3.new(RightArm.Position.X, RightArm.Position.Y - 1.75, RightArm.Position.Z)

	coroutine.wrap(function()
		for i,v in pairs(HandHoldNature:GetChildren()) do
			if v.Name == "Shards" then
				v:Emit(6)
			end
		end
	end)()
end

local function Weld(Torso, Roots)
	local Weld = Instance.new("Weld")
	Weld.Part0 = Torso
	Weld.Part1 = Roots
	Weld.Parent = Roots
	Weld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	Weld.C1 = CFrame.new(0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)	
	return Weld
end

local function customTween(Root, step, Action, isVerdien) --// it took me a while to figure this out
	if Root == nil then return end;
	local Heartbeat = RunService.Heartbeat

	local rad, stopVerdien = -Root.Orientation.Y +20, false
	if step == 1 then
		for i = 1, 17 do
			if not Root.Parent then break end
			if isVerdien and isVerdien == true and Action and not Action.Parent then stopVerdien = true break end;

			rad += 20
			Root.CFrame = CFrame.new(Root.Position + Vector3.new(0, 0.245, 0)) * CFrame.Angles(0, math.rad(rad), 0)
			Heartbeat:Wait() task.wait(1/30) --// each step orientation y is +20, +0.245 position
		end
	elseif step == 2 then
		for i = 1, 18 do
			if not Root.Parent then break end
			rad -= 20
			Root.CFrame = CFrame.new(Root.Position - Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, math.rad(rad), 0)
			Heartbeat:Wait() task.wait(1/30)
		end
	end

	return (stopVerdien or false)
end

function module:rootCharacter(Enemy, Character, SpellType, val1, val2, val3)
	local Torso, HumanoidRootPart, Humanoid = Enemy:FindFirstChild("Torso"), Enemy:FindFirstChild("HumanoidRootPart"), Enemy:FindFirstChild("Humanoid")
	if not Torso or not HumanoidRootPart or not Humanoid then
		return;
	end

	if Enemy:FindFirstChild("Knocked") or Humanoid.Health <= 0 or Enemy:FindFirstChild("VerdienCooldown") then
		return;
	end
	local Verdiened = Instance.new("Accessory")
	Verdiened.Name = "Verdiened"
	Verdiened.Parent = Enemy

	local Action = Instance.new("Accessory")
	Action.Name = "Action"
	Action.Parent = Enemy

	local NoJump = Instance.new("Accessory")
	NoJump.Name = "NoJump"
	NoJump.Parent = Enemy

	Debris:AddItem(Verdiened, 1.275)
	Debris:AddItem(Action, 1.275);
	Debris:AddItem(NoJump, 1.275);
	local health = Enemy.Humanoid.Health


	local Roots = nil
	if Humanoid.FloorMaterial ~= Enum.Material.Air then
		Roots = VerdienModules.Roots
		if SpellType == "Floresco" then
			Roots = VerdienModules.RootsVine
		end
		Roots = Roots:Clone();
		Roots.Parent = workspace.Thrown
		Debris:AddItem(Roots, 3, Action)

		if Roots:FindFirstChild("Crackling") then
			Roots.Crackling:Play()
		end
	end

	local Player = Players:GetPlayerFromCharacter(Enemy)
	if Player then
		ReplicatedStorage.Requests.ClearDodgeVels:FireClient(Player)
		Enemy:SetPrimaryPartCFrame(HumanoidRootPart.CFrame)
	end
	local OldPosition, OldCFrame, OldOrientation = HumanoidRootPart.Position, HumanoidRootPart.CFrame, HumanoidRootPart.Orientation

	if Roots ~= nil then
		Roots.CFrame = CFrame.new(OldPosition - Vector3.new(0, 3.82, 0)) * CFrame.Angles(0, math.rad((-OldOrientation.Y)), 0)
	end

	local Stunned, RootWeld = customTween(Roots, 1, Action, SpellType == "Verdien"), nil
	
	
	
	task.wait(1/30)

	if (Stunned == true) then
		if Roots ~= nil and Roots:FindFirstChild("Crackling") then
			Roots.Crackling:Play()
		end

		coroutine.wrap(function()
			customTween(Roots, 2)
		end)()
		return
	else
		if Roots ~= nil and HumanoidRootPart.Parent and Enemy.PrimaryPart then
			Enemy:SetPrimaryPartCFrame(OldCFrame)
			RootWeld = Weld(Torso, Roots)
		end
	end
	
	local detect = Enemy.ChildAdded:Connect(function(child)
		if child.Name == "NoDam" or child.Name == "Stun" then
			if NoJump then
				NoJump:Destroy()
			end
			if Action then
				Action:Destroy()
			end
			if Verdiened then
				Verdiened:Destroy()
			end
			if RootWeld and RootWeld.Parent then
				RootWeld:Destroy()
			end

			if Roots ~= nil and Roots:FindFirstChild("Crackling") then
				Roots.Crackling:Play()
			end

			if SpellType == "Verdien" then
				local VerdienCooldown = Instance.new("Accessory")
				VerdienCooldown.Name = "VerdienCooldown"
				VerdienCooldown.Parent = Enemy
				Debris:AddItem(VerdienCooldown, 5)
			end

			coroutine.wrap(function()
				customTween(Roots, 2)
			end)()
		end
	end)
	task.delay(1.275, function()
		detect:Disconnect()
	end)
	
	task.delay(1.35, function()
		if RootWeld and RootWeld.Parent then
			RootWeld:Destroy()
		

		if Roots ~= nil and Roots:FindFirstChild("Crackling") then
			Roots.Crackling:Play()
		end

		if SpellType == "Verdien" then
			local VerdienCooldown = Instance.new("Accessory")
			VerdienCooldown.Name = "VerdienCooldown"
			VerdienCooldown.Parent = Enemy
			Debris:AddItem(VerdienCooldown, 5)
		end

		coroutine.wrap(function()
			customTween(Roots, 2)
			end)()
		end
	end)
end

return module