local v1 = {}
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked"},
	})
end
function Anchor(Target, Statement)
	if Statement then
		game.CollectionService:AddTag(Target, "FreezeRoot")
	else
		game.CollectionService:RemoveTag(Target, "FreezeRoot")
	end
end
function ray(p1, p2, p3, p4)
	local v3, v4, v5 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).lookVector * p3), { l__Parent__1, workspace.Live, workspace.Terrain })
	return v3, v4, v5
end
local u2 = true
local l__TweenService__3 = game:GetService("TweenService")
local u4 = require(game.ServerScriptService.Modules.EffectModule)
local u5 = require(game.ServerScriptService.Modules.HitDetection)
function v1.Active(p5, p6, anims, p7)
	if ActionCheck() then
		return
	end
	if not u2 then
		return
	end
	if p5:FindFirstChild("RecentDash") then
		return
	end
	u2 = false
	local l__HumanoidRootPart__6 = p5:FindFirstChild("HumanoidRootPart")
	local plr = game.Players:GetPlayerFromCharacter(p5)
	game.ReplicatedStorage.Requests.ClearDashVelo:FireClient(plr)
	local v7 = p5.Humanoid:LoadAnimation(script.Parent.preparejump)
	v7:Play()
	local v8 = script.Parent.LightningS:Clone()
	v8.Parent = p7
	v8:Play()
	game.Debris:AddItem(v8,2.8)
	--[[if p5.HumanoidRootPart:FindFirstChild("DodgeVel") then
		task.wait(14)
		u2 = true 
		return
	end]]
	local v10 = Instance.new("Accessory")
	v10.Name = "Action"
	v10.Parent = p5
	game.Debris:AddItem(v10,0.3)
	task.wait(0.3)
	
	local v11 = p5.Humanoid:LoadAnimation(script.Parent.finishjump)
	local v12 = p5.Humanoid:LoadAnimation(script.Parent.midjump)
	if not p5:FindFirstChild("Stun")and not p5:FindFirstChild("RecentDash")then
		v7:Stop()
		v12:Play()
		local v13 = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(v13, "AllowedBM")
		v13.maxForce = Vector3.new(0, math.huge, 0)
		v13.velocity = Vector3.new(0, 140, 0)
		v13.Parent = l__HumanoidRootPart__6
		game.Debris:AddItem(v13,0.35)
		local v14 = Instance.new("Accessory")
		v14.Name = "NoFall"
		v14.Parent = p5
		game.Debris:AddItem(v14,4)
		local cancelat = false
		local stuncheck = p5.ChildAdded:Connect(function(child)
			if child.Name == "Stun" then
				cancelat = true
			end
		end)
		task.delay(0.44, function()
			stuncheck:Disconnect()
		end)
		task.wait(0.5)
		local mousepos = _G.MouseData(plr)
		if not mousepos then
			cancelat = true
		end
		local hit = mousepos.Hit
		if(hit.Position - plr.Character.HumanoidRootPart.Position).Magnitude>2000 then
			cancelat = true
		end
		if cancelat == true then task.wait(14) u2 = true return end
		
		local hit = mousepos.Hit
		p5.Torso.Velocity = Vector3.new(0, 0, 0)
		Anchor(p5, true)
		local l__CFrame__15 = l__HumanoidRootPart__6.CFrame
		--local v16,v17,v18 = ray(l__HumanoidRootPart__6.Position,l__HumanoidRootPart__6.CFrame*CFrame.new(0,-1,-1).p,1000,p5)
		if cancelat == false then
			v12:Stop()
			Anchor(p5, true)
			local ts = game:GetService("TweenService")
			ts:Create(plr.Character.HumanoidRootPart,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{CFrame = plr.Character.HumanoidRootPart.CFrame}):Play()
			v11:Play()
			v11:GetMarkerReachedSignal("USEIT"):Connect(function()
				local part = Instance.new("Part")
				part.CFrame = hit
				part.Transparency = 1
				part.Anchored = true
				game.Debris:AddItem(part,2)
				l__HumanoidRootPart__6.CleaveCharge:Play()
				l__HumanoidRootPart__6.TemplarCleaver:Emit()
				local ring = game.ReplicatedStorage.Assets.LightningDrop:Clone()
				ring.BrickColor = BrickColor.new'White'
				ring.STRIKE:Destroy()
				ring.Position = part.Position
				local PL: PointLight = game.ReplicatedStorage.Assets.ElectricLight:Clone()
				PL.Color = Color3.new(1,1,1)
				PL.Parent = ring
				ring.Parent = workspace.Thrown
				task.spawn(function()
					local tween = game.TweenService:Create(ring,TweenInfo.new(0.375),{
						Size = Vector3.new(65,20,20),
						Transparency = 1,
					})
					tween:Play()
					tween.Completed:Wait()
					ring.Transparency = 1
					game.Debris:AddItem(ring,2.8)
				end)
				u5.magnitudeCheck(p5,ring.Position,40,{
					mana = true,
					damage = 2,
					physical = true,
					noparry = false,
					aoe = true,
					move = "Solan's Blessing"
				},false,true)
			end)
			Anchor(p5)
			local v28 = Instance.new("Accessory")
			v28.Name = "Action"
			v28.Parent = p5
			game.Debris:AddItem(v28,1)
		end
	end
	task.wait(14)
	u2 = true
end
return v1