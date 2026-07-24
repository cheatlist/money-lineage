local v1 = {}
function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__2 = game:GetService("TweenService")
v1.upperbound = 100
v1.lowerbound = 90
v1.signs = 0
v1.cost = 100
local v3 = {
	upperbound = 60, 
	lowerbound = 40, 
	signs = 0, 
	cost = 0,
}
function ray(p1, p2, p3, p4)
	local v4, v5, v6 = game.Workspace:FindPartOnRay(Ray.new(p1, CFrame.new(p1, p2).lookVector * p3), p4)
	return v4, v5, v6
end
--local l__Killing__7 = game.ServerStorage.SpellEffects.Killing
function Weld(p5, p6, p7, p8, p9, p10)
	p6.CFrame = p7.CFrame
	local v8 = Instance.new(p5)
	v8.Part0 = p7
	v8.Part1 = p6
	v8.C0 = p8 or CFrame.new()
	v8.C1 = p9 or CFrame.new()
	v8.Parent = p10 and p6 or p7
	return v8
end
local u1 = require(game.ServerScriptService.Modules.HitDetection)
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local cd = false
function v1.Activate(p11, p12, p13, p14)
	if game.CollectionService:HasTag(p12, "Casting") or p12:FindFirstChild("ActiveCast") then
		return
	end
	local l__Mana__9 = p12.Mana
	local v10 = game.Players:GetPlayerFromCharacter(p12)
	if not v10.Backpack:FindFirstChild("CurseAllow") then return end
	local l__Value__11 = v10:FindFirstChildOfClass("Backpack").ManaColor
	local u3 = _G.MouseData(v10)
	if not u3 then
		return
	end
	task.spawn(function()
		if p13 == 0 then
			if p12:FindFirstChild("Charge") then
				p12.Charge:Destroy()
			end
			l__Mana__9.Value = math.max(l__Mana__9.Value - v1.cost, 0)
			local v12 = script.Parent.Charge:Clone()
			v12.Parent = p12.HumanoidRootPart
			game:GetService("Debris"):AddItem(v12, 5)
			local v13 = script.Parent.Fire:Clone()
			v13.Parent = p12.HumanoidRootPart
			game:GetService("Debris"):AddItem(v13, 5)
			local v14 = p12.Humanoid:LoadAnimation(script.MagicSlam)
			v14:Play()
			local v15 = game.ServerStorage.Assets.HandHoldDark:Clone()
			v15.Parent = p12
			Weld("Weld", v15, p12["Right Arm"], CFrame.new(0, -1, 0))
			local v16 = Instance.new("Accessory")
			v16.Name = "ActiveCast"
			v16.Parent = p12
			local v17 = Instance.new("IntValue")
			v17.Name = "SpeedBoost"
			v17.Value = -1
			v17.Parent = p12.Boosts
			game:GetService("Debris"):AddItem(v17, 1.35)
			v12:Play()
			wait(0.4)
			v14:AdjustSpeed(0)
			wait(1)
			v15.OrbEmit:Emit(100)
			v14:AdjustSpeed(1)
			v13:Play()
			if not p12:FindFirstChild("Stun") and not p12:FindFirstChild("NoDam")then
				u1.magnitudeCheck(p12, p12.HumanoidRootPart.Position,15,{
					curse = true,
					mana = true,
					curseeffect = true,
					curseblast = true,
					damage = 25,
					manaknockup = true,
					anticurse = true,
					canspellcounter = true,
					move = "Tenebris"
				},true)
			end
			v16:Destroy()
			v15.OrbParticle.Enabled = false
			wait(2)
			v15:Destroy()
		else
			l__TagHumanoid__2:Fire(p12, p12, {
				curse = true, 
				mana = true,
				curseeffect = true, 
				curseblast = true, 
				damage = 30, 
				manaknockupself = true,
				anticurse = true,
				move = "Tenebris"
			})
		end
	end)
end
local u4 = false
local u5 = {}
function v3.Activate(p15, p16, p17, p18, p19)
	if game.CollectionService:HasTag(p16, "Casting") then
		return
	end
	if cd then
		return
	end
	cd = true
	
	local l__Mana__18 = p16.Mana
	local v19 = game.Players:GetPlayerFromCharacter(p16)
	if not game.ServerStorage.PlayerData[v19.Name].Snaps.Value:find("Tenebris") then return end
	if not v19.Backpack:FindFirstChild("CurseAllow") then return end
	local v20 = game.ServerStorage.PlayerData:FindFirstChild(v19.Name)
	if not v20 then
		return
	end
	if u4 then
		return
	end
	
	local u6 = _G.MouseData(v19)
	if not u6 then
		return
	end
	if u5[1] ~= nil then
		p17 = 0
	end
	local l__Value__21 = v20.Hybrid.Value
	local l__Value__22 = v20.Class.Value
	local v23 = true
	

	task.spawn(function()
		u4 = true
		if p17 == 0 and v23 then

			l__Mana__18.Value = math.max(l__Mana__18.Value - v1.cost, 0)
			if u5[1] == nil then
				local v24 = script.Parent.Charge:Clone()
				v24.Parent = p16.HumanoidRootPart
				game:GetService("Debris"):AddItem(v24, 5)
				for v25 = 1, 4 do
					local v26 = game.ServerStorage.Assets.DarkBall:Clone()
					v26.Firesound2:Play()
					v26.Parent = workspace.Thrown
					table.insert(u5, v26)

					if v25 == 1 then
						Weld("Weld", v26, p16.HumanoidRootPart, CFrame.new(4, 0, 0))
					elseif v25 == 2 then
						Weld("Weld", v26, p16.HumanoidRootPart, CFrame.new(2, 3, 0))
					elseif v25 == 3 then
						Weld("Weld", v26, p16.HumanoidRootPart, CFrame.new(-4, 0, 0))
					elseif v25 == 4 then
						Weld("Weld", v26, p16.HumanoidRootPart, CFrame.new(-2, 3, 0))
					end
					local v27 = {
						curse = true,
						curseeffect = true,
						damage = 30,
						manaknockup = true,
						anticurse = true,
						canspellcounter = true,
						move = "Tenebris"
					}
					wait(0.5)
				end
				u4 = false
			else
				local v28 = {}

				for v29, v30 in pairs(workspace.Live:children()) do
					local l__HumanoidRootPart__31 = v30:FindFirstChild("HumanoidRootPart")
					if l__HumanoidRootPart__31 and l__HumanoidRootPart__31 ~= p16.HumanoidRootPart then
						table.insert(v28, l__HumanoidRootPart__31)
					end
				end
				local v32 = u5[1]
				v32.Weld:Destroy()
				for i,v in pairs(p16.HumanoidRootPart:GetChildren()) do
					if v.Name == "Weld" and v.Part1 == v32 then
						v:Destroy()
					end
				end
				table.remove(u5, 1)
				if u5[1] == nil then
					task.spawn(function()
						wait(5)
						u4 = false
					end)
				else
					task.spawn(function()
						wait(0.4)
						u4 = false
					end)
				end
				v32.Anchored = false
				local v33 = game.ServerStorage.Assets.DarkBallOld.BodyVelocity:Clone()
				v33.Parent = v32
				v32.CFrame = p16.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
				v32.CFrame = CFrame.new(v32.Position, u6.Hit.p)
				v32.Parent = workspace.Thrown
				v32.Firesound:Play()
				v32.BodyVelocity.Velocity = v32.CFrame.lookVector * 50
				v32:SetNetworkOwner(nil)
				local u7 = nil
				u7 = v32.Touched:connect(function(p20)
					if p20 and p20.Parent.Name == p16.Name then
						return
					end
					if p20 and p20:IsDescendantOf(p16) then
						return
					end
					if p20 and p20.Name == v32.Name then
						return
					end
					if p20 and p20:IsDescendantOf(workspace.Terrain) then
						return
					end
					if p20.Parent.Name == "Shadow Buddy" then
						return
					end
					if p20 and (p20.Name == "OrderField" or p20.Name == "OrderBubble") then
						u7:disconnect()
						v32.Anchored = true
						game.Debris:AddItem(v32, 1)
						return
					end
					local v34 = p20.Parent:FindFirstChild("Humanoid") or p20.Parent.Parent:FindFirstChild("Humanoid")
					if not v34 then
						return
					end
					u7:disconnect()
					v32.Anchored = true
					v32.CFrame = v34.Parent.HumanoidRootPart.CFrame
					for v35, v36 in pairs(v32:GetChildren()) do
						if not v36:IsA("Sound") then
							v36:Destroy()
						end
					end
					v32.Transparency = 1
					v32.Firesound5:Play()
					sub(function()

						v32:Destroy()
					end)
					if v34.Parent.HumanoidRootPart:FindFirstChild("DARKPOOF") then
						v34.Parent.HumanoidRootPart.DARKPOOF:Emit(30)
					end
					l__TagHumanoid__2:Fire(p16, v34.Parent, {
						curse = true, 
						curseeffect = true, 
						mana = true,
						damage = 3,
						anticurse = true,
						noenchant = true,
						canspellcounter = true,
						move = "Tenebris"
					})
				end)
				local u8 = 0
				sub(function()
					while true do
						local v37 = nil
						local v38 = 50
						for v39 = 1, #v28 do
							local v40 = v28[v39]
							local l__magnitude__41 = (v40.Position - v32.Position).magnitude
							if l__magnitude__41 < v38 and v40.Parent.Humanoid.Health > 0 then
								v37 = v40
								v38 = l__magnitude__41
							end
						end
						if v37 then
							v33.Velocity = v33.Velocity:Lerp(CFrame.new(v32.Position, v37.Position).lookVector * 50, v38 / 50 / 2)
						end
						u8 = u8 + wait()
						if not v32 then
							break
						end
						if not v32.Parent then
							break
						end
						if u8 >= 5 then
							break
						end
						if v32.Anchored then
							break
						end				
					end
					if u8 >= 5 and v32 then
						v32:Destroy()
					end
				end)

			end
		else
			if u5[1] ~= nil  then
			end

			l__TagHumanoid__2:Fire(p16, p16, {
				curse = true, 
				curseeffect = true, 
				damage = 30, 
				manaknockupself = true,
				anticurse = true,
				noenchant = true,
				move = "Tenebris"
			})
			wait(1)
			u4 = false
		end
		task.wait(1)
		cd=false
	end)

end
v1.alternate = v3
return v1