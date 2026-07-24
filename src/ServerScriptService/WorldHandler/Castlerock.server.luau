wait(1)
local FindPartOnRayWithWhitelist = workspace.FindPartOnRayWithWhitelist
local TweenService = game:GetService("TweenService")
if not workspace:FindFirstChild'Turrets'then
	return warn("CR isn't enabled!")
end
local a = workspace.Turrets:GetDescendants()
local FindFirstChild = game.FindFirstChild
local GetChildren = game.GetChildren
local Live = workspace.Live
local Map = workspace.Map
local wrap = coroutine.wrap
local Turrets = {}
local Range: number = 110

local function lanniseffect(v)
	local c = v:Clone()
	c:ClearAllChildren()
	c.Anchored = true
	c.Material = "Neon"
	c.CanCollide = false
	c.Color = Color3.fromRGB(255,255,220)
	c.Parent = workspace.Thrown
	TweenService:Create(c,TweenInfo.new(1.5),{Transparency = 1,CFrame = c.CFrame * CFrame.new(math.random(2,5),math.random(2,5),math.random(2,5))*CFrame.Angles(math.random(-360,360),math.random(-360,360),math.random(-360,360))}):Play()
	game.Debris:AddItem(c,1.6)
end

local function create(name,deletetime,parent)
	if not parent then
		return
	end
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	if deletetime then
		game.Debris:AddItem(i,deletetime)
	end
	return i
end

for _,v in pairs(a)do
	if v.Name == "Sentry"then
		table.insert(Turrets,v)
	end
end

local function ResetTurret(turret)
	local ShootPoint = turret.Gun.ShootPoint
	ShootPoint.ChargeSound:Stop()
	ShootPoint.Beam.Attachment1 = nil
	ShootPoint.ParticleEmitter.Enabled = false
	turret.Gun.Body.SmokeAttach.ParticleEmitter.Enabled = false
	turret.Info.State.Value = "INACTIVE"
	turret.Info.Target.Value = nil
	turret.Info.Charge.Value = 0
end

local function UpdateTurret(turret,v)
	ResetTurret(turret)
	local root = v.HumanoidRootPart
	local ShootPoint = turret.Gun.ShootPoint
	local Info = turret.Info
	local norp = false
	local maxcharge: number = 100
	if Info:FindFirstChild("norpTurret") then
		norp = true
		maxcharge = 15
	end
	Info.Target.Value = v
	Info.State.Value = "ACTIVE"
	Info.LastTargeted.Value = tick()
	ShootPoint.ChargeSound:Play()
	ShootPoint.ParticleEmitter.Enabled = true
	if v.HumanoidRootPart:FindFirstChild("RootAttachment") then
		ShootPoint.Beam.Attachment1 = v.HumanoidRootPart.RootAttachment
		end
	while true do
		Info.Charge.Value+=2.75
		if Info.Charge.Value>=maxcharge then
			Info.Charge.Value = 0
			ShootPoint.FireSound:Play()
			ShootPoint.ChargeSound:Stop()
			ShootPoint.ParticleEmitter.Enabled = false
			Info.State.Value = "COOLDOWN"
			Info.Target.Value = nil
			local hitcframe = root.CFrame
			local distance = (root.Position-turret.Gun.ShootPoint.Position)
			local laser = script.Laser:Clone()
			laser.Size = Vector3.new(distance.Magnitude,0,0)
			laser.CFrame = CFrame.new(ShootPoint.Position,root.Position)*CFrame.Angles(0,math.pi/2,0)*CFrame.new(distance.Magnitude*2,0,0)
			laser.Parent = workspace.Thrown
			game.Debris:AddItem(laser, 3)
			TweenService:Create(laser,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size = Vector3.new(distance.Magnitude*4,0.5,0.5),Transparency = 0}):Play()
			if FindFirstChild(v,"CurseBlocking")then
				root.SpellBlock:Play()
				root.Orb.Transparency = 0
				TweenService:Create(root.Orb,TweenInfo.new(0.5),{Transparency = 0.75}):Play()
				if FindFirstChild(v,"SpellParry") then
					Info.State.Value = "BROKEN"
					turret.Gun.Body.SmokeAttach.ParticleEmitter.Enabled = true
					task.spawn(function()
						if not norp then
							task.wait(60)
						else
							task.wait(15)
						end
						ResetTurret(turret)
					end)
				end
			else
				local Player = game.Players:GetPlayerFromCharacter(v)
				if Player then
					--create("Danger",false,Player)
					_G.Death(Player,nil,nil,norp)
				end
				v.Humanoid.Health = 0
				--v:BreakJoints()
				root.SpellDeath:Play()
				task.wait()
				coroutine.wrap(function()
					for i,bruh in pairs(v:GetChildren()) do
						if bruh:IsA("Shirt") or bruh:IsA("Pants") then
							bruh:Destroy()
						end
						if bruh:IsA("Part") or bruh:IsA("BasePart") then
							local dec = bruh:FindFirstChildOfClass("Decal")
							if dec then
								dec:Destroy()
							end
							local bv = Instance.new("BodyVelocity")
							game.CollectionService:AddTag(bv,"AllowedBM")
							bv.Velocity = Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
							bv.Parent = bruh
							bruh.Material = Enum.Material.Neon
							local tweenInfo02 = TweenInfo.new(1.25,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
							local tween02 = TweenService:Create(bruh,tweenInfo02,{Transparency=1,Color=Color3.new()})
							tween02:Play()
						end
					end
				end)()
			end
			task.spawn(function()
				task.wait(0.1)
				TweenService:Create(laser,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size = Vector3.new(distance.Magnitude*4,0,0),Transparency = 1}):Play()
			end)
			wait()
			--if explosion then
				local Explosion = script.Explosion:Clone()
				Explosion:SetPrimaryPartCFrame(hitcframe)
				Explosion.Parent = workspace.Thrown
				Explosion.Ball.Sound:Play()
				Explosion.SmokeParticle.ParticleEmitter:Emit(20)
				TweenService:Create(Explosion.Ball.Mesh,TweenInfo.new(0.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Scale = Vector3.new(1,1,1)}):Play()
				TweenService:Create(Explosion.Ring.Mesh,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Scale = Vector3.new(80,80,48)}):Play()
				TweenService:Create(Explosion.Ball,TweenInfo.new(0.3),{Transparency = 1}):Play()
				TweenService:Create(Explosion.Ring,TweenInfo.new(0.6),{Transparency = 1}):Play()
				game.Debris:AddItem(Explosion,2)
			--end
			ShootPoint.Beam.Attachment1 = nil
			if norp == false then
				wait(4)
			end
			if Info.State.Value~="BROKEN"then
				Info.State.Value = "INACTIVE"
			end
			return
		end
		wait(0.05)
		local distance = (root.Position-turret.Gun.ShootPoint.Position)
		if distance.Magnitude<Range then
			local ray = Ray.new(turret.Gun.ShootPoint.Position,distance*Range)
			local hit = FindPartOnRayWithWhitelist(workspace,ray,{Live,Map})
			if hit then
				if hit.Parent == v or hit.Parent.Parent == v then
				else
					ResetTurret(turret)
					break
				end
			end
		else
			ResetTurret(turret)
			return
		end
	end
end

local touchdb = false

workspace.Map.TeleportIn.Touched:Connect(function(v)
	if touchdb then
		return
	end
	if FindFirstChild(v.Parent,"HumanoidRootPart")then
	else
		return
	end
	touchdb = true
	if not FindFirstChild(v.Parent,"INCR")then
		--[[
		task.spawn(function()
			game.ServerStorage.Requests.SendWebhook:Fire(
				"Ban",
				v.Parent.Name.." got banned for entering CR without talking to the eagle",
				"red"
			)
			v.Parent.Humanoid:Destroy()
			wait()
			v.Parent:Destroy()
		end)]]--
		wait(0.2)
		touchdb = false
		return
	end
	local z = Instance.new("Vector3Value")
	z.Name = "TPSafe"
	z.Value = Vector3.new(5789.401,340.393,640.247)
	z.Parent = v.Parent
	game.Debris:AddItem(z, 1.5)
	v.Parent:PivotTo(CFrame.new(5789.401,340.393,640.247))
	wait(0.2)
	touchdb = false
end)

workspace.Map.TeleportOut.Touched:Connect(function(v)
	if not FindFirstChild(v.Parent,"HumanoidRootPart")then
		return
	end
	if touchdb then
		return
	end
	touchdb = true
	local z = Instance.new("Vector3Value")
	z.Name = "TPSafe"
	z.Value = workspace.WorldEater.Position
	z.Parent = v.Parent
	game.Debris:AddItem(z, 1.5)
	v.Parent:PivotTo(workspace.WorldEater.CFrame)
	wait(0.3)
	touchdb = false
end)

--local RCP: RaycastParams = Instance.new'RaycastParams' ????
local RCP = RaycastParams.new()
RCP.FilterDescendantsInstances = {Live,Map}
RCP.IgnoreWater = true
RCP.FilterType = Enum.RaycastFilterType.Whitelist
local function TurretCheck(turret)
	if turret.Info.State.Value=="BROKEN"then
		return
	end
	if turret.Info.State.Value=="COOLDOWN"then
		return
	end
	if turret.Info.State.Value=="ACTIVE"then
		return
	end
	if turret.Info.Target.Value then
		return
	end
	local norp: boolean = false
	if turret.Info:FindFirstChild("norpTurret") then
		norp = true
	end
	for Indx: number, NPC in ipairs(GetChildren(Live))do
		local HRP = NPC:FindFirstChild('HumanoidRootPart')
		local Hum = NPC:FindFirstChild'Humanoid'
		if (FindFirstChild(NPC,"INCR")or norp) and HRP and Hum and Hum.Health > 0 then
			if NPC:FindFirstChild("ForceField") then
				continue
			end
			local distance: Vector3 = (HRP.Position - turret.Gun.ShootPoint.Position)
			if distance.Magnitude < Range then
				local hit: RaycastResult = workspace:Raycast(turret.Gun.ShootPoint.Position, distance * Range, RCP)
				if hit then
					local Inst = hit.Instance
					if Inst.Parent == NPC or Inst.Parent.Parent == NPC then
						if norp then 
							local safefromnorp: boolean = false
							local plr = game.Players:GetPlayerFromCharacter(NPC)
							if plr and plr.Backpack:FindFirstChild("nObRequirement") and not _G.FriendlyFire then
								safefromnorp = true
							end
							if safefromnorp then
								continue
							end
						end
						task.spawn(UpdateTurret, turret, NPC)
					end
				end
			end
		end
	end
end

while true do
	task.wait(0.5)
	for Indx, Turret in pairs(Turrets)do
		task.spawn(TurretCheck, Turret)
	end
end