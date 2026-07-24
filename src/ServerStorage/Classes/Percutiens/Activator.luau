local l__Parent__1 = script.Parent
local v2 = {}
function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__3 = game:GetService("TweenService")
local v4 = require(game.ServerScriptService.Modules.HitDetection)
v2.upperbound = 70
v2.lowerbound = 60
v2.signs = 8
v2.cost = 20
local v5 = {
	upperbound = 80, 
	lowerbound = 70, 
	signs = 0, 
	cost = 20
}
function LIGHTNING(p1, p2, p3, p4, p5, p6, p7,spec)
	local v6 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local l__lookVector__7 = CFrame.new(p1, p2).LookVector
	local v8 = (p1 - p2).magnitude / p3
	local v9 = p1
	local v10 = 1 - 1
	while true do
		local v11 = game.ReplicatedStorage.Assets.LightningPart:Clone()
		if spec then
			v11.Color = Color3.fromRGB(230,230,20)
		end
		v11.FormFactor = "Symmetric"
		v11.Size = Vector3.new(1, 1, 1)
		v11.CanCollide = false
		v11.Transparency = 0.2
		v11.Anchored = true
		v11.Material = Enum.Material.Neon
		local v12 = CFrame.new(p1 + l__lookVector__7 * (v10 * v8), p2 + l__lookVector__7) * CFrame.new(math.random(-100, 100) / 100 * v8 / 2, math.random(-100, 100) / 100 * v8 / 2, 0)
		local l__magnitude__13 = (v12.p - v9).magnitude
		local v14 = Instance.new("BlockMesh", v11)
		v14.Scale = Vector3.new(p5, p5, l__magnitude__13 + p5 / 4)
		v11.CFrame = CFrame.new((v12.p + v9) / 2, v12.p)
		v9 = v12.p
		v11.Parent = workspace
		wait()
		l__TweenService__3:Create(v14, v6, {
			Scale = Vector3.new(p5 * 2, p5 * 2, l__magnitude__13 + p5 / 4)
		}):Play()
		l__TweenService__3:Create(v11, v6, {
			Transparency = 1
		}):Play()
		game.Debris:AddItem(v11, 0.5)
		if 0 <= 1 then
			if v10 < p3 then

			else
				break
			end
		elseif p3 < v10 then
		else
			break
		end
		v10 = v10 + 1	
	end
	spawn(function()
		Boom(p2, p6)
	end)
end
function ray(p8, p9, p10, p11)
	local v15, v16, v17 = workspace:FindPartOnRay(Ray.new(p8, CFrame.new(p8, p9).LookVector * p10), p11)
	return v15, v16, v17
end
function Boom(p12, p13)
	if p13 then
		if p13.Anchored then
			local v18 = Instance.new("Part")
			v18.Transparency = 1
			v18.Anchored = true
			v18.Size = Vector3.new(0, 0, 0)
			v18.CFrame = CFrame.new(p12)
			script.Sound:Clone().Parent = v18
			script.Smoke:clone().Parent = v18
			v18.Parent = game.Workspace
			wait()
			v18.Smoke.Color = ColorSequence.new(p13.Color)
			v18.Sound:Play()
			v18.Smoke:Emit(30)
			game.Debris:AddItem(v18, 9)
		end
	end
end
local l__TagHumanoid__1 = game.ServerStorage.Requests.TagHumanoid
function Lightningblast(p14, p15, p16,spec)
	local l__Character__19 = p14.Character
	local v20 = game.ServerStorage.PlayerData:FindFirstChild(p14.Name)
	if not v20 then
		return
	end
	local u2 = _G.MouseData(p14)
	if not u2 then
		return
	end
	local l__p__21 = p16.p
	local v22 = script.BLAST:Clone()
	v22.Parent = l__Character__19.HumanoidRootPart
	v22:Play()
	game:GetService("Debris"):AddItem(v22, 5)
	l__Character__19.Humanoid.AutoRotate = true
	l__Character__19.HumanoidRootPart.CFrame = CFrame.new(l__Character__19.HumanoidRootPart.Position, l__p__21)
	local v23 = CFrame.new(l__Character__19.HumanoidRootPart.Position, l__p__21)
	local v24 = game.ReplicatedStorage.Assets.Ring:Clone()
	v24.Parent = game.Workspace.Thrown
	v24.CFrame = l__Character__19.HumanoidRootPart.CFrame
	v24.CFrame = CFrame.new(l__Character__19.HumanoidRootPart.Position, l__p__21) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))
	game:GetService("Debris"):AddItem(v24, 0.5)
	l__TweenService__3:Create(v24, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Size = Vector3.new(12, 0.25, 12), 
		Transparency = 1
	}):Play()
	LIGHTNING(l__Character__19["Left Arm"].Position, l__p__21, 10, "red", 1, u2.Target, l__Character__19,spec)
	local l__Magnitude__25 = (l__Character__19.HumanoidRootPart.Position - l__p__21).Magnitude
	local v26 = 25
	if v20.Race.Value ~= "Gaian" then
		if v20.Race.Value == "Metascroom" then
			v26 = v26 * 1.25
		end
	else
		v26 = v26 * 1.25
	end
	for v30,v31 in pairs(game.Workspace.Live:GetChildren())do
		local v32 = v23:inverse() * v31.HumanoidRootPart.CFrame
		if v32.Z < 0 then
			if -l__Magnitude__25 < v32.Z then
				if math.abs(v32.X) < 7 then
					if math.abs(v32.Y) < 7 then
						if v31 ~= l__Character__19 then
							l__TagHumanoid__1:Fire(l__Character__19, v31, {
								mana = true, 
								curse = true, 
								damage = v26, 
								manaknockupself = true, 
								blockbreak = true,
								nododge = true,
								anticurse = true,
								move = "Percutiens"
							})
						end
					end
				end
			end
		end	
	end
end
function v2.Activate(p17, p18, p19, p20)
	if game.CollectionService:HasTag(p18,"Casting") then
		return
	end
	if game.CollectionService:HasTag(p18,"PercCD") then
		return
	end
	if p18:FindFirstChild("Action")then
		return
	end
	local l__Mana__33 = p18.Mana
	local v34 = game.Players:GetPlayerFromCharacter(p18)
	local v35 = game.ServerStorage.PlayerData:FindFirstChild(v34.Name)
	local l__Value__36 = v35.ManaColor.Value
	local u3 = _G.MouseData(v34)
	if not u3 then
		return
	end
	local spec = v34.Name == "PinesFleet"
	game.CollectionService:AddTag(p18,"PercCD")
	spawn(function()
		task.wait(spec and 0 or 1.5)
		game.CollectionService:RemoveTag(p18,"PercCD")
	end)
	local l__Hit__37 = u3.Hit
	if p19 == 0 then
		if not v34.Backpack:FindFirstChild("Fart")then
			p18.Humanoid:LoadAnimation(script.Clap):Play()
		else
			p18.Humanoid:LoadAnimation(script.Clap2):Play()
		end
		local action = Instance.new("Accessory")
		action.Name = "Action"
		action.Parent = p18
		game:GetService("Debris"):AddItem(action,1)
		wait(0.5)
		if (l__Hit__37.p - p18.HumanoidRootPart.Position).magnitude >= 400 then
			p18.HumanoidRootPart.LightningHit:Play()
			for v38 = 1, 2 do
				for v39, v40 in pairs(p18:GetChildren()) do
					if v40:IsA("Part") and (v40.Name == "Right Arm" or v40.Name == "Left Arm") then
						local v41 = game.ReplicatedStorage.Assets.Electric:Clone()
						v41.Parent = v40
						game:GetService("Debris"):AddItem(v41, 1)
					end
				end
			end
		else
			for v42 = -3, 3 do
				local v43 = Instance.new("Part")
				game.ReplicatedStorage.Assets.Electric:Clone().Parent = v43
				v43.Transparency = 1
				v43.Anchored = true
				v43.CanCollide = false
				v43.Parent = game.Workspace.Thrown
				v43.CFrame = p18.HumanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, v42, 0)
				l__TweenService__3:Create(v43, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = v43.CFrame * CFrame.new(0, 0, -10)
				}):Play()
				spawn(function()
					wait(0.25)
					v43:Destroy()
				end)
			end
			Lightningblast(v34, p18.Torso, l__Hit__37,spec)
		end
	else
		local v44 = 25
		if v35.Race.Value == "Gaian" or v35.Race.Value == "Metascroom" then
			v44 = v44 * 1.25
		end
		l__TagHumanoid__1:Fire(p18, p18,{
			mana = true, 
			curse = true, 
			damage = v44, 
			manaknockupself = true, 
			blockbreak = true,
			nododge = true,
			anticurse = true,
			move = "Percutiens"
		})
		p18.HumanoidRootPart.LightningHit:Play()
		for v45 = 1, 2 do
			for v46, v47 in pairs(p18:GetChildren()) do
				if v47:IsA("Part") and (v47.Name == "Right Arm" or v47.Name == "Left Arm") then
					local v48 = game.ReplicatedStorage.Assets.Electric:Clone()
					v48.Parent = v47
					game:GetService("Debris"):AddItem(v48, 1)
				end
			end
		end
	end
end
function v5.Activate(p21, p22, p23, p24, p25)
	if game.CollectionService:HasTag(p22,"Casting")then
		return
	end

	if p22:FindFirstChild("Action")then
		return
	end
	local l__Mana__49 = p22.Mana
	local v50 = game.Players:GetPlayerFromCharacter(p22)
	local v51 = v50 and game.ServerStorage.PlayerData:FindFirstChild(v50.Name)
	if v51 then
		local l__Value__52 = v51.ManaColor.Value
	end
	if not p25[script.Parent.Name]then
		return
	end
	local u4 = _G.MouseData(v50)
	if not u4 then
		return
	end
	local l__Hit__53 = u4.Hit
	if p23 == 0 then
		p22.HumanoidRootPart.PerfectCast:Play()
		p22.Humanoid:LoadAnimation(script.Snap2):Play()
		local v54 = script.Snap:clone()
		v54.Parent = p22.HumanoidRootPart
		v54:Play()
		game.Debris:AddItem(v54, 2)
		wait(0.2)
		if (l__Hit__53.p - p22.HumanoidRootPart.Position).magnitude >= 400 then
			p22.HumanoidRootPart.LightningHit:Play()
			for v55 = 1, 2 do
				for v56, v57 in pairs(p22:GetChildren()) do
					if v57:IsA("Part") and (v57.Name == "Right Arm" or v57.Name == "Left Arm") then
						local v58 = game.ReplicatedStorage.Assets.Electric:Clone()
						v58.Parent = v57
						game:GetService("Debris"):AddItem(v58, 1)
					end
				end
			end
		else
			for v59 = -3, 3 do
				local v60 = Instance.new("Part")
				game.ReplicatedStorage.Assets.Electric:Clone().Parent = v60
				v60.Transparency = 1
				v60.Anchored = true
				v60.CanCollide = false
				v60.Parent = game.Workspace.Thrown
				v60.CFrame = p22.HumanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, v59, 0)
				l__TweenService__3:Create(v60, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = v60.CFrame * CFrame.new(0, 0, -10)
				}):Play()
				spawn(function()
					wait(0.25)
					v60:Destroy()
				end)
			end
			Lightningblast(v50, p22.Torso, l__Hit__53,spec)
		end
	else
		local v61 = 25
		if v51.Race.Value == "Gaian" or v51.Race.Value == "Metascroom" then
			v61 = v61 * 1.25
		end
		l__TagHumanoid__1:Fire(p22, p22,{
			mana = true, 
			curse = true, 
			damage = v61, 
			manaknockupself = true, 
			blockbreak = true,
			nododge = true,
			anticurse = true,
			move = "Percutiens"
		})
		p22.HumanoidRootPart.LightningHit:Play()
		for v62 = 1, 2 do
			for v63, v64 in pairs(p22:GetChildren()) do
				if v64:IsA("Part") and (v64.Name == "Right Arm" or v64.Name == "Left Arm") then
					local v65 = game.ReplicatedStorage.Assets.Electric:Clone()
					v65.Parent = v64
					game:GetService("Debris"):AddItem(v65, 1)
				end
			end
		end
	end
end
v2.alternate = v5
return v2