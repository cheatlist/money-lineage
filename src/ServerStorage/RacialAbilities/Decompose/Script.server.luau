function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")

local function RayCast(origin, dir, ignoreParameter, visualize)
	if visualize or _G.Debug then
		local dist = dir.Magnitude
		local p = Instance.new("Part")
		p.Material = Enum.Material.ForceField
		game.Debris:AddItem(p, 50)
		p.Size = Vector3.new(0.4, 0.4, 1)
		p.CanCollide = false
		p.Anchored = true
		p.Color = Color3.fromRGB(math.random(-255,255),math.random(1,255),math.random(1,255))
		p.Transparency = 0.6
		p.CFrame = CFrame.new(origin, origin+dir)
		local m = Instance.new("BlockMesh", p)
		m.Scale = Vector3.new(1, 1, dist*.95)
		m.Offset = Vector3.new(0, 0, -dist/2)

		p.Parent = workspace.Thrown
	end

	local t = {	}
	for i, v in next, ignoreParameter or {} do
		table.insert(t, v)
	end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = t
	raycastParams.IgnoreWater = true
	return workspace:Raycast(origin,dir,raycastParams)
	--return workspace:FindPartOnRayWithIgnoreList(Ray.new(origin, dir), t)
end

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
	if Parent:FindFirstChild("Action") and not Parent:FindFirstChild("Planted") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
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
	else
		return
	end
	return true
end
local canuse = true
local currentUsage = {}
script.Parent.Activated:Connect(function()
	local Character = script.Parent.Parent --p1
	local ignorelist2 = {}
	for i,v in pairs(Character:GetDescendants()) do
		table.insert(ignorelist2, v)
	end
	
	if not canuse then
		return
	end
	
	local Player = game.Players:GetPlayerFromCharacter(Character) --p2
	local data = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
	local Whitelist = {Enum.Material.Grass,Enum.Material.Wood,Enum.Material.WoodPlanks}
	local Hours = data.DaysSurvived.Value
		table.insert(Whitelist,Enum.Material.Fabric)
		table.insert(Whitelist,Enum.Material.Sand)
		table.insert(Whitelist,Enum.Material.Concrete)
		table.insert(Whitelist,Enum.Material.Slate)
		table.insert(Whitelist,Enum.Material.Cobblestone)
	local stomach = Character.Stomach
	local multiplier = math.clamp(data.DaysSurvived.Value / 25, 0.5, 1.5)
	local stomachMultiplier = math.clamp(data.DaysSurvived.Value / 25, 1, 1.75)
	if Character:FindFirstChild("indecomposevibing") then
		canuse = false
		Character.indecomposevibing:Destroy()
		if currentUsage.Animation then
			local Anim = currentUsage.Animation
			Anim:Play(0.100000001,1,0)
			Anim:AdjustSpeed(0)
			Anim.TimePosition = Anim.Length - .9
			Anim:AdjustSpeed(-2)
			local deb256 = Instance.new("Accessory")
			deb256.Name = "HyperArmor"
			deb256.Parent = Character
			task.wait(1.4)
			deb256:Destroy()
			game.CollectionService:RemoveTag(Character,"Decomposing")
			if Character:FindFirstChild("Hardened") then
				Character.Hardened:Destroy()
			end
			for i,v in pairs(Character:GetChildren()) do
				if v.Name == "Planted" or v.Name == "Stun" or v.Name == "Action" then
					v:Destroy()
				end
			end
			if currentUsage.ToDestroy then
				for _,v in pairs(currentUsage.ToDestroy) do
					v:Destroy()
				end
			end
		end
	elseif not Character:FindFirstChild("indecomposevibing") then
		if ActionCheck(Character)then
			return
		end
		canuse = false
		local startcf = Character.HumanoidRootPart.CFrame
		local ray = RayCast(startcf.Position, Vector3.new(0, -5,0), {workspace.Live, workspace.Thrown,workspace.Thrown, Character:FindFirstChild'ScroomHead', ignorelist2}, false)
		if ray and ray.Instance then
			if not table.find(Whitelist, ray.Material) or Character.Humanoid.FloorMaterial == Enum.Material.Air then
				canuse = true			
				return
			end
		else
			canuse = true
			return
		end
		local Anim = Character.Humanoid:LoadAnimation(script.Animation)
		local antibaba = Instance.new("Accessory")
		antibaba.Name = "antiwakeup"
		antibaba.Parent = Character
		local antibaba3 = Instance.new("Accessory")
		antibaba3.Name = "indecomposevibing"
		antibaba3.Parent = Character
		local regenboost = Instance.new("NumberValue")
		regenboost.Name = "HealthRegen"
		local deb1 = Instance.new("Accessory")
		deb1.Name = "Planted"
		local deb2 = Instance.new("Accessory")
		deb2.Name = "HeavyAttack"
		local deb256 = Instance.new("Accessory")
		deb256.Name = "HyperArmor"
		local deb3 = Instance.new("Accessory")
		deb3.Name = "FreezeRoot"
		deb1.Parent = Character
		deb2.Parent = Character
		deb3.Parent = Character
		deb256.Parent = Character
		local deb25 = Instance.new("Accessory")
		deb25.Name = "decomposingrn"
		deb25.Parent = Character
		game.CollectionService:AddTag(Character,"Decomposing")
		if game.ServerStorage.PlayerData[Player.Name].Race.Value == "Metascroom"or game.ServerStorage.PlayerData[Player.Name].Race.Value=='Navaran' then
			local harden = Instance.new("Accessory")
			harden.Name = "Hardened"
			harden.Parent = Character
		end
		local conn
		local ClickDetect = Instance.new("ClickDetector")
		ClickDetect.MaxActivationDistance = 24
		ClickDetect.Parent = Character.Head
		local lastclick = 0
		local headshake = Character.Humanoid:LoadAnimation(script["2"])
		conn = ClickDetect.MouseClick:Connect(function()
			if tick() - lastclick > 2 then
				headshake:Play()
				lastclick = tick()
			end
		end)
		Anim:Play()
		Anim:AdjustSpeed(1)
		task.wait(2.3)
		deb256:Destroy()
		antibaba:Destroy()
		deb25:Destroy()
		Anim:AdjustSpeed(0)
		currentUsage = {ToDestroy = {regenboost, deb1, deb2, deb3, ClickDetect}, Animation = Anim}
		regenboost.Parent = Character:FindFirstChild("Boosts")
		task.spawn(function()
			repeat 
				task.wait(.5)
				if game.Lighting.ClockTime >= 17.6 or game.Lighting.ClockTime <= 6.3 then
					stomach.Value += 4
					regenboost.Value = 3
				else
					regenboost.Value = 2
					stomach.Value += 2
				end
			until not regenboost or regenboost.Parent ~= Character:FindFirstChild("Boosts")
			conn:Disconnect()
		end)
	end
	canuse = true
end)