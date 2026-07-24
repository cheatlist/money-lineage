local v1 = {}
function sub(...)
	coroutine.wrap(...)()
end
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true
	end
	if l__Parent__1:FindFirstChild("NoAttack") then
		return true
	end
	if l__Parent__1:FindFirstChild("Charge") and not l__Parent__1.Artifacts:FindFirstChild("Unwavering Focus") then
		return true
	end
	if l__Parent__1:FindFirstChild("Stun") then
		return true
	end
	if l__Parent__1:FindFirstChild("NoDam") then
		return true
	end
	if l__Parent__1:FindFirstChild("ReturnStun") then
		return true
	end
	if l__Parent__1:FindFirstChild("Action") then
		return true
	end
	if l__Parent__1:FindFirstChild("Blocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("SpellBlocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("Unconscious") then
		return true
	end
	if l__Parent__1:FindFirstChild("Knocked") then
		return true
	end
	if l__Parent__1:FindFirstChild("HeavyAttack") then
		return true
	end
	if l__Parent__1:FindFirstChild("LightAttack") then
	else
		return
	end
	return true
end
local u2 = true
local u3 = false
local l__ComboTimer__4 = l__Parent__1:WaitForChild("ComboTimer")
local l__Combo__5 = l__Parent__1:WaitForChild("Combo")
local u6 = false
local u7 = require(game.ServerScriptService.Modules.HitDetection)
function v1.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return
	end
	if p1:FindFirstChild("Grabbing") then
		return
	end
	if p1:FindFirstChild("Knocked") then
		return
	end
	if p1:FindFirstChild("NoAttack") then
		return
	end
	if p1:FindFirstChild("Rolling") then
		return
	end
	if p1:FindFirstChild("NoDam") then
		return
	end
	if not u2 then
		return
	end
	if p1:FindFirstChild("Stun") then
		return
	end
	u3 = false
	if p4:FindFirstChild("Poison") then
		u3 = true
	end
	local l__Value__3 = p4.Stats.Speed.Value
	u2 = false
	local v4 = 0.2 - l__Value__3
	for _,v9 in pairs(p1.Boosts:GetChildren())do
		if v9.Name == "AttackSpeedBoost" then
			v4 = v4 / v9.Value
		end	
	end
	local v10 = tick() - l__ComboTimer__4.Value
	if 0.5 + v4 <= v10 then
		l__Combo__5.Value = 1
	end
	if 0.5 + v4 <= v10 and v10 <= 0.8 + v4 then
		u2 = true
		return
	end
	l__ComboTimer__4.Value = tick()
	local v11 = p1.Humanoid:LoadAnimation(p3["Katana" .. l__Combo__5.Value])
	local v12 = 1 + l__Value__3
	if game.CollectionService:HasTag(p1, "BrokenArm") and l__Combo__5.Value < 6 then
		v12 = 0.5 + l__Value__3
	end
	if game.CollectionService:HasTag(p1, "Armless") and l__Combo__5.Value < 6 then
		v12 = 0.5 + l__Value__3
	end
	v11:Play(0.1, 1, v12 * 1.45)
	local l__HumanoidRootPart__8 = p1.HumanoidRootPart
	v11:GetMarkerReachedSignal("swing"):Connect(function()
		p4.TestTrail.Enabled = true
		l__HumanoidRootPart__8.KatanaSlash:Play()
	end)
	v11:GetMarkerReachedSignal("lastframe"):Connect(function()
		p4.TestTrail.Enabled = false
	end)
	local v13 = Instance.new("Accessory")
	v13.Name = "LightAttack"
	v13.Parent = p1
	game:GetService("Debris"):AddItem(v13, 0.2 + v4)
	local v14 = Instance.new("Accessory")
	v14.Name = "NoJump"
	v14.Parent = p1
	game:GetService("Debris"):AddItem(v14, 0.5 + v4)
	wait(0.1 / v12)
	if p1:FindFirstChild("Stun") then
		u2 = true
		return
	end
	l__Combo__5.Value = l__Combo__5.Value + 1
	if l__Combo__5.Value >= 5 then
		u6 = true
		l__Combo__5.Value = 1
	end
	if not p1:FindFirstChild("Stun") and not p1:FindFirstChild("NoDam") then
		u7.magnitudeCheck(p1, l__HumanoidRootPart__8.Position, p4.Stats.Length.Value, {
			physical = true, 
			damage = p4.Stats.Damage.Value, 
			katana = true, 
			slash = true, 
			poison = u3 or (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1), 
			knockback = u6,
			blade = true,
		}, true)
	end
	if u6 then
		local v15 = Instance.new("Accessory")
		v15.Name = "Action"
		v15.Parent = p1
		game:GetService("Debris"):AddItem(v15, 0.6 / v12)
		u6 = false
		wait(0.2)
	end
	u2 = true
end
local u9 = false
local u10 = 1
function v1.Active2(p5, p6, p7, p8)
	if p5:FindFirstChild("Grabbing") then
		return
	end
	if ActionCheck() then
		return
	end
	if p5:FindFirstChild("NoAttack") then
		return
	end
	if u9 == true then
		return
	end
	if game.CollectionService:HasTag(p5, "Knocked") then
		return
	end
	if not u2 then
		return
	end
	if p8:FindFirstChild("Poison") then
		u3 = true
	end
	local l__Value__16 = p8.Stats.Length.Value
	local l__Value__17 = p8.Stats.Damage.Value
	local v18 = 1 + p8.Stats.Speed.Value --
	local l__HumanoidRootPart__19 = p5.HumanoidRootPart
	u9 = true
	local v20 = Instance.new("Accessory")
	v20.Name = "HeavyAttack"
	v20.Parent = p5
	game:GetService("Debris"):AddItem(v20, 1.2)
	local v21 = Instance.new("Accessory")
	v21.Name = "NoJump"
	v21.Parent = p5
	game:GetService("Debris"):AddItem(v21, 1.2)
	u2 = false
	if tick() - l__ComboTimer__4.Value > 5 then
		u10 = 1
	end
	local v22 = l__HumanoidRootPart__19.AkumaEmit:Clone()
	l__ComboTimer__4.Value = tick()
	local v23 = p5.Humanoid:LoadAnimation(p7.KatanaHeavy)
	v23:Play()
	v23:AdjustSpeed(2)
	v23:GetMarkerReachedSignal("swing"):Connect(function()
		p8.TestTrail.Enabled = true
		l__HumanoidRootPart__19.HeavySlash:Play()
	end)
	v23:GetMarkerReachedSignal("lastframe"):Connect(function()
		p8.TestTrail.Enabled = false
	end)
	if u10 == 1 then
		v22.Parent = p5["Right Arm"]
		v22.Enabled = true
	end
	l__HumanoidRootPart__19.Greatswordcharge:Play()
	game:GetService("Debris"):AddItem(v22, 0.5)
	wait(0.2)
	v23:AdjustSpeed(0)
	wait(0.2 / v18)
	v23:AdjustSpeed(2 * v18)
	wait(0.1 / v18)
	local v24 = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(v24,"AllowedBM")
	v24.Name = "ForwardVelocity"
	v24.MaxForce = Vector3.new(80000, 0, 80000)
	v24.Velocity = l__HumanoidRootPart__19.CFrame.lookVector.unit * 125
	v24.Parent = l__HumanoidRootPart__19
	game.Debris:AddItem(v24, 0.15)
	local v25 = Instance.new("Accessory")
	v25.Name = "Action"
	v25.Parent = p5
	game:GetService("Debris"):AddItem(v25, 0.5 / v18)
	for v26 = 1, 3 do
		wait(0.1)
		if p5:FindFirstChild("Stun") then
			game.Debris:AddItem(v24, 0.001)
			break
		end
		if p5:FindFirstChild("COUNTERED") then
			game.Debris:AddItem(v24, 0.001)
			break
		end
		if p5:FindFirstChild("NoDam") then
			game.Debris:AddItem(v24, 0.001)
			break
		end
		if u7.magnitudeCheck(p5, l__HumanoidRootPart__19.Position, l__Value__16, {
			damage = l__Value__17, 
			physical = true, 
			katana = true, 
			slash = true, 
			knockback = true, 
			blockbreak = true,
			blade = true,
			poison = (p5:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
			},true) then
			game.Debris:AddItem(v24, 0.001)
			break
		end
	end
	l__Combo__5.Value = 1
	u6 = false
	u2 = true
	wait(1)
	u9 = false
end
return v1