local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

function Check(parent)
	local conds = {"Stun", "NoDam", "RetStun", "Act", "Block", "SpellBlock", "Cast", "Uncon", "Knock", "Imm"}
	for _, cond in ipairs(conds) do
		if parent:FindFirstChild(cond) then
			return true
		end
	end
	return false
end

local spd = 150
local rotSpd = 5
local cd = 0.95

local Throwing = false

local function Clone(pos)
	local temp = ReplicatedStorage.Assets.sf.FT:FindFirstChild("Pool")
	if not temp then return end

	local cl = temp:Clone()
	cl.Parent = workspace.Thrown
	Instance.new("Folder", cl).Name = script.Parent.Parent.Name
	Debris:AddItem(cl, 60)
	if not cl.PrimaryPart then return end

	cl:SetPrimaryPartCFrame(CFrame.new(pos))
	cl.PrimaryPart.Orientation = Vector3.new(0, 0, 90)

	local water = cl:FindFirstChild("Water", true)
	local fx = cl:FindFirstChild("FXPart", true)

	if fx then
		fx.Orientation = Vector3.new(0, 0, -0.365)
		for _, d in ipairs(fx:GetDescendants()) do
			if d:IsA("ParticleEmitter") or d:IsA("Light") or d:IsA("Beam") then
				d.Enabled = true
			end
		end
	end

	if water then
		water.Size = Vector3.new(0.25, 0.25, 0.25)
		local tween = TweenService:Create(water, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0.25, 30, 30)})

		tween.Completed:Connect(function()
			if fx then
				for _, d in ipairs(fx:GetDescendants()) do
					if d:IsA("ParticleEmitter") or d:IsA("Light") or d:IsA("Beam") then
						d.Enabled = true
					end
				end    
			end
		end)

		if fx then
			for _, att in ipairs(fx:GetDescendants()) do
				if att:IsA("Beam") then
					if att.Name == "Beam" then
						att.CurveSize0 = 0.1
						att.CurveSize1 = 0.1
						local tweenBeam = TweenService:Create(att, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CurveSize0 = 20, CurveSize1 = 20})
						tweenBeam:Play()
					else
						att.CurveSize0 = 0.1
						att.CurveSize1 = 0.1
						local tweenBeam = TweenService:Create(att, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CurveSize0 = -20, CurveSize1 = -20})
						tweenBeam:Play()
					end
				elseif att:IsA("Attachment") then
					local origCFrame = att.WorldCFrame
					att.WorldCFrame = CFrame.new(water.Position)
					local tweenAtt = TweenService:Create(att, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {WorldCFrame = origCFrame})
					tweenAtt:Play()
				end
			end
		end
		fx.Parent.Water.PoolLoop:Play()
		tween:Play()
		
		tween.Completed:Connect(function()
			Throwing = false
		end)
	end
end

local function Throw(ball, target)
	local start = ball.Position
	local height = 15
	local dist = (target - start).Magnitude
	local time = dist / spd

	local path = {}
	local numSteps = 45
	for t = 0, 1, 1 / numSteps do
		local pos = start:Lerp(target, t)
		local heightAdj = 4 * height * t * (1 - t)
		pos = pos + Vector3.new(0, heightAdj, 0)
		table.insert(path, pos)
	end

	local tweens = {}
	local foamTweens = {}
	local tweenTime = time / numSteps
	for i = 1, #path - 1 do
		local tween = TweenService:Create(ball, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Position = path[i + 1]})
		table.insert(tweens, tween)

		local foam = ball:FindFirstChild("Foam")
		if foam then
			local foamTween = TweenService:Create(foam, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Position = path[i + 1]})
			table.insert(foamTweens, foamTween)
		end
	end

	local function Play(index)
		if index > #tweens then
			ball:Destroy()
			Clone(target)
			local splash = game.ReplicatedStorage.Assets.sf.FT.splashvfx:Clone()
			splash.Parent = workspace.Thrown
			splash.Position = target
			splash.Splash:Play()

			for _, d in ipairs(splash:GetDescendants()) do
				if d:IsA("ParticleEmitter") then
					d.Enabled = true 
				end
			end
			task.wait(.15)
			for _, d in ipairs(splash:GetDescendants()) do
				if d:IsA("ParticleEmitter") then
					d.Enabled = false 
				end
			end
			Debris:AddItem(splash, 2.5)
			return
		end
		tweens[index]:Play()
		foamTweens[index]:Play()
		tweens[index].Completed:Connect(function() Play(index + 1) end)
	end

	Play(1)
end

local function Weld(char, part)
	local root = char:WaitForChild("HumanoidRootPart")
	part.CFrame = root.CFrame
	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = part
	weld.C0 = root.CFrame:inverse() * part.CFrame
	weld.Parent = root
	return weld
end

local function Rotate(spheres)
	return RunService.Stepped:Connect(function(_, dt)
		local angle = math.rad(rotSpd * dt * 60)
		local rot = CFrame.Angles(0, angle, 0)
		for _, sphere in ipairs(spheres) do
			local weld = sphere:FindFirstChild("roost")
			local foam = sphere:FindFirstChild("Foam")
			if weld and foam then
				weld.C0 = weld.C0 * rot
				local motor = foam:FindFirstChildWhichIsA("Motor6D")
				if motor then
					local randRot = CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2)
					motor.C0 = motor.C0 * randRot
				end
			end
		end
	end)
end

local function Spawn(spheres)
	local sphereList = {}
	for _, name in ipairs({"Ball1", "Ball2", "Ball3"}) do
		local sphere = spheres:FindFirstChild(name)
		if sphere then
			table.insert(sphereList, sphere)
			sphere.Transparency = 1
		end
	end

	coroutine.wrap(function()
		for i, sphere in ipairs(sphereList) do
			local attach = sphere:FindFirstChild("centerAtch")
			local effect = attach and attach:FindFirstChild("Appear")
			if effect then
				if i == 1 then wait(0.1) end
				effect:Emit(100)
				spheres.roost.Appear:Play()
			end
			sphere.Transparency = 0.2
			sphere.foamyy.Enabled = true
			sphere.water.Enabled = true
			sphere.waterytrail.Enabled = true
			sphere.Foam.Transparency = 0
			wait(cd)
		end
	end)()

	return sphereList
end

local tool = script.Parent
local spheres = nil
local rotConn = nil
local canUse = true
tool.Activated:Connect(function()
	if Check(script.Parent.Parent) then
		return
	end
	if tool.Parent.Cooldowns:FindFirstChild("Fisherman's Trap") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Fisherman's Trap"
	CD.Value = 20
	CD.Parent = tool.Parent.Cooldowns
	game.Debris:AddItem(CD, 20)
	if Throwing == true then
		return
	end
	local player = Players:GetPlayerFromCharacter(tool.Parent)
	if player and player:IsA("Player") then
		local char = player.Character or player.CharacterAdded:Wait()
		local temp = ReplicatedStorage.Assets.sf.FT:FindFirstChild("FoamSpheres")

		if not temp then return end

		if not spheres and not char:FindFirstChild("FoamSpheres") then
			local foamSpheres = temp:Clone()
			foamSpheres.Parent = char
			local roost = foamSpheres:FindFirstChild("roost")
			if not roost then return end

			Weld(char, roost)
			roost.WaterLoop:Play()
			spheres = Spawn(foamSpheres)
			rotConn = Rotate(spheres)
		else
			local allSpawned = true
			for _, sphere in ipairs(spheres) do
				if sphere.Transparency == 1 then
					allSpawned = false
					break
				end
			end
			if allSpawned and Throwing == false then
				local mouseData = _G.MouseData(player)
				local mouseTarget = mouseData.Target
				if mouseTarget and mouseTarget.Name == "Water" and mouseTarget.Parent.Name == "Pool" then
					return
				end
				local nearParts = workspace:FindPartsInRegion3(Region3.new(mouseData.Hit.Position - Vector3.new(25, 25, 25), mouseData.Hit.Position + Vector3.new(25, 25, 25)), nil, math.huge)
				for _, part in ipairs(nearParts) do
					if part.Name == "Water" and part.Parent and part.Parent.Name == "Pool" then
						return
					end
				end
				if mouseData and mouseData.Hit then
					local mousePos = mouseData.Hit.Position
					local dist = (char.HumanoidRootPart.Position - mousePos).Magnitude
					
					if dist <= 50 then
						Throwing = true
						local index = math.random(1, #spheres)
						local selected = spheres[index]

						local weld = selected:FindFirstChildWhichIsA("Weld")
						if weld then
							selected.Foam.FM.Enabled = false
							weld:Destroy()
						end
						Throw(selected, mousePos)

						table.remove(spheres, index)

						if #spheres == 0 then
							spheres = nil                            
							canUse = false
							task.spawn(function()
								char.FoamSpheres.roost.WaterLoop:Stop()
								wait(6)
								char:FindFirstChild("FoamSpheres"):Destroy()
								wait(12)
								canUse = true
							end)
							if rotConn then
								rotConn:Disconnect()
								rotConn = nil
							end
						end
					end
				end
			end
		end
	end
end)
