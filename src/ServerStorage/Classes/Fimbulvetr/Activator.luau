local v1 = {}
function sub(...)
	coroutine.wrap(...)()
end
v1.upperbound = 92
v1.lowerbound = 84
v1.signs = 10
v1.cost = 40
local v2 = {
	upperbound = 80, 
	lowerbound = 70, 
	signs = 0, 
	cost = 20
}
local spell2 = {}
spell2.upperbound = 80
spell2.lowerbound = 70
spell2.signs = 0
spell2.cost = 20
function radrandom(p1, p2)
	return math.rad(math.random(p1, p2))
end
local l__GreatWinter__1 = game.ServerStorage.SpellEffects.GreatWinter
local u2 = require(game.ServerScriptService.Modules.EffectModule)
local l__TweenService__3 = game:GetService("TweenService")
local u4 = require(game.ServerScriptService.Modules.HitDetection)
local l__TagHumanoid__5 = game.ServerStorage.Requests.TagHumanoid
function v1.Activate(p3, p4, p5, p6)
	local v3 = nil
	if game.CollectionService:HasTag(p4,"Casting")then
		return
	end
	if game.CollectionService:HasTag(p4,"FIMBULCD")then
		return
	end
	v3 = p4.Mana
	local v4 = game.Players:GetPlayerFromCharacter(p4)
	game.CollectionService:AddTag(p4,"FIMBULCD")
	local l__Value__5 = game.ServerStorage.PlayerData[v4.Name].ManaColor.Value
	local u6 = _G.MouseData(v4)
	if not u6 then
		game.CollectionService:RemoveTag(p4,"FIMBULCD")
		return
	end
	spawn(function()
		task.wait(12)
		game.CollectionService:RemoveTag(p4,"FIMBULCD")
	end)
	task.spawn(function()
		if p5 == 0 then
			if (u6.Hit.p - p4.Torso.Position).Magnitude >= 600 then
				return
			end
			v3.Value = math.max(v3.Value - v1.cost, 0)
			p4.HumanoidRootPart.PerfectCast:Play()
			local v6 = l__GreatWinter__1.TenebrisBlueFast:Clone()
			game.Debris:AddItem(v6, 10)
			v6.ParticleEmitter.Enabled = false
			v6.CFrame = CFrame.new(u6.Hit.p.X, u6.Hit.p.Y, u6.Hit.p.Z) * CFrame.new(0, 105, 0)
			v6.Parent = game.Workspace
			local v7 = l__GreatWinter__1.GlassMask:Clone()
			game.Debris:AddItem(v7, 5)
			v7.CFrame = v6.CFrame * CFrame.new(0, v7.Size.Y / 2 + 1, 0)
			v7.Parent = game.Workspace
			local v8
			if p6 then
				v8 = p6.CFrame * CFrame.new(0, 2, 0)
			else
				v8 = p4["Right Arm"].CFrame
			end
			u2.Lightning(v8.p, v6.Position, 0.2, 8, "Pastel blue-green")
			v6.ParticleEmitter.Enabled = true
			v6.Open:Play()
			wait(1)
			local v9 = l__GreatWinter__1.FullChain:Clone()
			game.Debris:AddItem(v9, 3)
			v9.Parent = game.Workspace
			v9.CFrame = v6.CFrame * CFrame.new(0, v9.Size.Y / 2, 0) * CFrame.Angles(0, 0, math.rad(180))
			local v10 = l__TweenService__3:Create(v9, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = v9.CFrame * CFrame.new(0, v9.Size.Y, 0)
			}):Play()
			v9.Shoot:Play()
			v9.LoopSound2:Play()
			wait(0.5)
			v9.LoopSound2:Stop()
			v9.LandHit:Play()
			local v11 = CFrame.new(u6.Hit.p.X, u6.Hit.p.Y, u6.Hit.p.Z) * CFrame.new(0, 20, 0)
			local v12 = 25
			if game.ServerStorage.PlayerData:FindFirstChild(p4.Name) and game.ServerStorage.PlayerData[p4.Name].Race.Value == "Rigan" then
				v12 = v12 * 1.25
			end
			for _,v17 in pairs(game.Workspace.Live:GetChildren())do
				local v18 = v17:IsA("Model") and v17 or nil
				if v18 and v18:FindFirstChild("Humanoid") and v18:FindFirstChild("HumanoidRootPart") and (v11.Position - v18.HumanoidRootPart.Position).magnitude <= 45 then
					spawn(function()
						spawn(function()
							l__TagHumanoid__5:Fire(p4, v17, {
								mana = true, 
								damage = v12, 
								manaknockupself = 90, 
								curse = true,
								fimbul = true,
								move = "Fimbulvetr"
							})
						end)
					end)
				end		
			end
			local v19 = Vector3.new(88.188, 61.3, 86.772)
			local v20 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local v21 = l__GreatWinter__1.IceRing:Clone()
			game.Debris:AddItem(v21, 6)
			v21.CanCollide = false
			spawn(function()
				wait(0.8)
				v21.CanCollide = true
			end)
		--[[
		spawn(function()
			local v22 = v21.CFrame * CFrame.new(0, 30, 0)
			wait(15)
			for v23 = 1, 8 do
				local v24 = l__GreatWinter__1.IcePiece:Clone()
				game.Debris:AddItem(v24, 2)
				v24.Size = Vector3.new(math.random(3, 6), math.random(6, 12), math.random(3, 6))
				v24.CFrame = v22 * CFrame.new(math.random(-30, 30), math.random(-20, 10), math.random(-30, 30)) * CFrame.Angles(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
				v24.Parent = game.Workspace
			end
		end)
		]]
			v21.Size = Vector3.new(1, 0.8, 1)
			v21.CFrame = CFrame.new(u6.Hit.p.X, u6.Hit.p.Y, u6.Hit.p.Z)
			v21.Parent = game.Workspace
			v21.Burst:Play()
			local v25 = l__TweenService__3:Create(v21, v20, {
				Size = v19, 
				CFrame = v21.CFrame * CFrame.new(0, v19.Y / 2 - 15, 0) * CFrame.Angles(math.rad(-16), 0, 0)
			}):Play()
			wait(1)
			local v26 = l__TweenService__3:Create(v9, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = v9.CFrame * CFrame.new(0, -v9.Size.Y, 0)
			}):Play()
			v9.LoopSound2:Play()
			game.Debris:AddItem(v9.LoopSound2, 1)
			wait(2)
			v6.ParticleEmitter.Enabled = false
			v6.Open.PlaybackSpeed = 1.5
			v6.Open:Play()
			local v27 = {}
		else
			if v3.Value - v1.cost <= 0 then
				v3.Value = 0
			else
				v3.Value = v3.Value - v1.cost
			end
			spawn(function()
				l__TagHumanoid__5:Fire(p4, p4, {
					mana = true, 
					damage = 15, 
					manaknockupself = 90, 
					curse = true,
					move = "Fimbulvetr"
				})
				local v28 = l__GreatWinter__1.IceCase:Clone()
				v28.CFrame = p4.HumanoidRootPart.CFrame
				v28.Parent = p4
				local v29 = Instance.new("Motor6D")
				v29.Part0 = p4.Torso
				v29.Part1 = v28
				v29.Parent = v28
				game.Debris:AddItem(v28, 1.5)
				wait(1.5)
				l__TagHumanoid__5:Fire(p4, p4, {
					mana = true, 
					damage = 15, 
					manaknockupself = true, 
					curse = true, 
					downbypass = true,
					move = "Fimbulvetr"
				})
			end)
		end
	end)
end
local spelleffect = game.ServerStorage.SpellEffects.GreatWinter
local effmod = require(game.ServerScriptService.Modules.EffectModule)		
function spell2:Activate(char,castSuccess,currentprop,upgradedSpells)
	if game.CollectionService:HasTag(char,"Casting") then return end

	local mana = char.Mana
	local play = game.Players:GetPlayerFromCharacter(char)
	local playerFolder = play and game.ServerStorage.PlayerData:FindFirstChild(play.Name)
	local manacolor = playerFolder and playerFolder.ManaColor.Value

	if not upgradedSpells[script.Parent.Name] and play.Name ~= "Melon_Sensei" then return end


	local mouse
	pcall(function()
		mouse = require(game.ServerStorage.Modules.RemoteLib).getMouse(play)
	end)

	if not mouse then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if castSuccess == 0 or play.Name == "Melon_Sensei" then
		if (mouse.Hit.p-char.Torso.Position).Magnitude>=600 then return end

		local action = Instance.new("Accessory") 
		action.Parent = char
		action.Name = "Action"
		game.ServerStorage.Debris:Fire(action,0.5)

		char.Humanoid:LoadAnimation(script.FimbulSnap):Play()
		wait(0.2)

		local bal = game.ReplicatedStorage.Assets.HandHoldIcey:Clone()
		bal.IllusionArm.Enabled = false
		bal.Parent = game.Workspace.Thrown
		bal.Snap:Play()
		bal.IllusionSnap:Emit(100)

		local attachPoint = char["Right Arm"]

		local attachC1 = CFrame.new(0,-1.2,0)*CFrame.Angles(0,0,math.rad(180))
		if not currentprop then
			attachC1 = CFrame.new(0,-1.2,0)*CFrame.Angles(0,0,math.rad(180))
		end

		local w = Instance.new("Weld")
		sub(function()
			w.Name = "Weld"
			w.Part0 = attachPoint
			w.Part1 = bal
			w.Parent = bal
			w.C1 = attachC1
			wait(1)
			bal:Destroy()
		end)



		local tene = spelleffect.TenebrisBlueFast:Clone()
		game.ServerStorage.Debris:Fire(tene,10)

		tene.CFrame = CFrame.new(mouse.Hit.p.X,mouse.Hit.p.Y,mouse.Hit.p.Z) * CFrame.new(0,50,0)
		tene.ParticleEmitter.Enabled = true
		tene.Open:Play()
		tene.Parent = workspace.Thrown

		effmod.Lightning(char["Right Arm"].Position,tene.Position,.2,8,"Pastel blue-green")

		wait(0.25)

		local radius = 20
		local duration = 5

		local timeStart = os.time()

		game.ReplicatedStorage.Requests.HailStorm:FireAllClients(tene.CFrame,20,duration)

		local live = workspace.Live:GetChildren()
		local conn = workspace.Live.ChildAdded:Connect(function()
			live = workspace.Live:GetChildren()
		end)
		local conn2 = workspace.Live.ChildRemoved:Connect(function()
			live = workspace.Live:GetChildren()
		end)

		local pkt = {mana=true,damage=6,curse=true,move = "Fimbulvetr"}

		repeat
			for _,ochar in pairs(live) do
				if ochar:FindFirstChild("HumanoidRootPart") then
					local oroot = ochar.HumanoidRootPart
					local isInRange = (Vector3.new(oroot.Position.X,tene.Position.Y,oroot.Position.Z) - tene.Position).Magnitude < radius

					if isInRange then
						local posDiff = tene.Position.y - oroot.Position.y
						if posDiff > 0 then
							local ray = Ray.new(oroot.Position,Vector3.new(0,posDiff,0))
							local rPart = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Live,workspace.Thrown,workspace.AreaMarkers,workspace.MonsterSpawns})

							if not rPart then
								l__TagHumanoid__5:Fire(char,ochar,pkt)
							end
						end
					end
				end
			end


			wait(0.8)
		until os.time() - timeStart > duration

		conn:disconnect()
		conn2:disconnect()

		tene.ParticleEmitter.Enabled = false
		tene:Destroy()
	else
		if mana.Value - v1.cost <= 0 then
			mana.Value = 0
		else
			mana.Value = mana.Value - v1.cost
		end
		spawn(function()
			l__TagHumanoid__5:Fire(char,char,{mana=true,damage=15,manaknockupself=90,curse=true,move = "Fimbulvetr"})
			local freeze = spelleffect.IceCase:Clone()
			freeze.CFrame = char.HumanoidRootPart.CFrame
			freeze.Parent = char

			pcall(function()
				freeze.Burst.PlayOnRemove = true
			end)

			local w = Instance.new("Motor6D")
			w.Part0 = char["Torso"]
			w.Part1 = freeze
			w.Parent = freeze
			game.ServerStorage.Debris:Fire(freeze,1.5)
			wait(1.5)
			l__TagHumanoid__5:Fire(char,char,{mana=true,damage=10,manaknockupself=true,curse=true,downbypass=true,move = "Fimbulvetr"})
		end)
	end
end
v1.alternate = spell2
return v1