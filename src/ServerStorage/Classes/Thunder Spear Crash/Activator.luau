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
	if p5:FindFirstChild("RecentDash") then
		return
	end
	if p5.Cooldowns:FindFirstChild("Thunder Spear Crash") then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p5.Name)
	local stormherald = false
	if data.Skills.Value:find("StormHerald") then
		stormherald = true
	end
	local emberwyrm = false
	if data.Skills.Value:find("TheEmberWyrm") then
		emberwyrm = true
	end
	local abyssalwyrm = false
	if data.Skills.Value:find("TheAbyssalWyrm") then
		abyssalwyrm = true
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Thunder Spear Crash"
	CD.Value = 16
	CD.Parent = p5.Cooldowns
	game.Debris:AddItem(CD, 16)
	if stormherald and not p5.Cooldowns:FindFirstChild("Storm Herald Buff CD") then
		local CD = Instance.new("NumberValue")
		CD.Name = "The Storm Herald"
		CD.Value = 10
		CD.Parent = p5.Cooldowns
		game.Debris:AddItem(CD, 10)

		local CD = Instance.new("NumberValue")
		CD.Name = "Storm Herald Buff CD"
		CD.Value = 20
		CD.Parent = p5.Cooldowns
		game.Debris:AddItem(CD, 20)
	elseif emberwyrm and not p5.Cooldowns:FindFirstChild("Ember Wyrm Buff CD") then
		local CD = Instance.new("NumberValue")
		CD.Name = "The Ember Wyrm"
		CD.Value = 10
		CD.Parent = p5.Cooldowns
		game.Debris:AddItem(CD, 10)

		local CD = Instance.new("NumberValue")
		CD.Name = "Ember Wyrm Buff CD"
		CD.Value = 20
		CD.Parent = p5.Cooldowns
		game.Debris:AddItem(CD, 20)
	elseif abyssalwyrm and not p5.Cooldowns:FindFirstChild("Abyssal Wyrm Buff CD") then
		local CD = Instance.new("NumberValue")
		CD.Name = "The Abyssal Wyrm"
		CD.Value = 10
		CD.Parent = p5.Cooldowns
		game.Debris:AddItem(CD, 10)

		local CD = Instance.new("NumberValue")
		CD.Name = "Abyssal Wyrm Buff CD"
		CD.Value = 20
		CD.Parent = p5.Cooldowns
		game.Debris:AddItem(CD, 20)
	end
	u2 = false
	
	local fixingsomething = Instance.new("Folder")
	fixingsomething.Name = "STOPBLOCKING"
	fixingsomething.Parent = p5
	
	local l__HumanoidRootPart__6 = p5:FindFirstChild("HumanoidRootPart")
	if stormherald == true then
		l__HumanoidRootPart__6.Thunderbolt:Play()
	else
		l__HumanoidRootPart__6.LightningHit:Play()
	end
	local plr = game.Players:GetPlayerFromCharacter(p5)
	game.ReplicatedStorage.Requests.ClearDashVelo:FireClient(plr)
	local v7 = p5.Humanoid:LoadAnimation(script.Parent.preparejump)
	v7:Play()
	local v8
	local v9
	if stormherald == true then
		v8 = script.Parent.LightningHerald:Clone()
		v8.Parent = p7
		v8:Play()
		v9 = script.Parent.LightningHeraldP:Clone()
		v9.Parent = p7
	else
		v8 = script.Parent.LightningS:Clone()
		v8.Parent = p7
		v8:Play()
		v9 = script.Parent.LightningP:Clone()
		v9.Parent = p7
	end
	game.Debris:AddItem(v8,2.8)
	game.Debris:AddItem(v9,2.8)
	task.spawn(function()
		task.wait(2.8)
		v9:Destroy()
		v8:Destroy()
	end)
	--[[if p5.HumanoidRootPart:FindFirstChild("DodgeVel") then
		task.wait(14)
		u2 = true 
		return
	end]]
	local v10 = Instance.new("Folder")
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
		local v14 = Instance.new("Folder")
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
		if cancelat == true then task.wait(14) u2 = true return end
		
		p5.Torso.Velocity = Vector3.new(0, 0, 0)
		local l__CFrame__15 = l__HumanoidRootPart__6.CFrame
		local v16,v17,v18 = ray(l__HumanoidRootPart__6.Position,l__HumanoidRootPart__6.CFrame*CFrame.new(0,-1,-1).Position,1000,p5)
		if v16 then
			local v19 = Instance.new("Vector3Value")
			v19.Name = "TPSafe"
			v19.Value = v17
			v19.Parent = p5
			game.Debris:AddItem(v19,4)
			local v20
			if stormherald == true then
				v20 = game.ServerStorage.Assets.HeraldZoom:Clone()
				v20.CFrame = p5.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-45), 0, 0)
				v20.Parent = game.Workspace.Thrown
			else
				v20 = game.ServerStorage.Assets.ThunderZoom:Clone()
				v20.CFrame = p5.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-45), 0, 0)
				if emberwyrm then
					v20.Color = Color3.fromRGB(255, 100, 20)
				elseif abyssalwyrm then
					v20.Color = Color3.fromRGB(90, 30, 130)
				end
				v20.Parent = game.Workspace.Thrown
			end
			game.Debris:AddItem(v20,4)
			local v21 = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local v22 = l__TweenService__3:Create(v20.Mesh, v21, {
				Scale = Vector3.new(0, 0, 30)
			}):Play()
			local v23 = l__TweenService__3:Create(v20, v21, {
				Transparency = 1
			}):Play()
			v12:Stop()
			v11:Play()
			spawn(function()
				if stormherald == true then
					u4.Lightning(v20.Position, v17, 2, 8, "Lilac")
				elseif emberwyrm == true then
					u4.Lightning(v20.Position, v17, 2, 8, "Really red")
				elseif abyssalwyrm == true then
					u4.Lightning(v20.Position, v17, 2, 8, "Royal purple")
				else
					u4.Lightning(v20.Position, v17, 2, 8, "Bright yellow")
				end
			end)
			p5:SetPrimaryPartCFrame(CFrame.new(v17)*CFrame.new(0,5,0))
			local v24
			if stormherald == true then
				v24 = game.ServerStorage.Assets.HeraldZoom:Clone()
				v24.CFrame = CFrame.new(v17)
				v24.Mesh.Scale = Vector3.new(1, 1, 1)
				v24.Parent = game.Workspace.Thrown
			else
				v24 = game.ServerStorage.Assets.ThunderZoom:Clone()
				v24.CFrame = CFrame.new(v17)
				v24.Mesh.Scale = Vector3.new(1, 1, 1)
				if emberwyrm then
					v24.Color = Color3.fromRGB(255, 100, 20)
				elseif abyssalwyrm then
					v24.Color = Color3.fromRGB(90, 30, 130)
				end
				v24.Parent = game.Workspace.Thrown
			end
			game.Debris:AddItem(v24,2)
			local v25 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local v26 = l__TweenService__3:Create(v24.Mesh, v25, {
				Scale = Vector3.new(66, 66, 66)
			}):Play()
			local v27 = l__TweenService__3:Create(v24, v25, {
				Transparency = 1
			}):Play()
			local basedamage = 45
			if stormherald == true or emberwyrm == true or abyssalwyrm == true then
				basedamage *= 1.10
			end
			u5.magnitudeCheck(p5, l__HumanoidRootPart__6.Position,35,{
				mana = true, 
				damage = basedamage, --// 45
				manaknockupself = true, 
				tsc = true,
				noenchant = true,
				curseshieldit = true,
				sigilthunder = true,
				canspellcounter = true,
				aoe = true,
				move = "Thunder Spear Crash"
			},false,false)
			v20.STRIKE:Play()
			local v28 = Instance.new("Folder")
			v28.Name = "Action"
			v28.Parent = p5
			game.Debris:AddItem(v28,2.5)
		end
	end
	wait(2)
	v8:Destroy()
	v9:Destroy()
	v11:Stop()
	fixingsomething:Destroy()
	wait(14)
	u2 = true
end
return v1