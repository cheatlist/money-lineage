local tool = script.Parent
local event = game.ReplicatedStorage.MouseData

local tween_connection = nil

local hitdet = require(game.ServerScriptService.Modules.HitDetection)

local cd = false

local ts = game:GetService("TweenService")

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(p1)
	return ActionCheckModule(p1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Stun","ReturnStun","ActiveCast","Action","Immortal","Knocked","Blocking","SpellBlocking","Climbing"},
		healthAtOrBelow = 0,
	})
end

local state = false
local bv
local flame
local plr
local mouseaimscript
local vg
local vg2
local humanoid
local hrp
local hilt
local sword1
local sword
local throw_anim
local catch_anim
local crash_anim
local flip_anim
local jump_anim
local stun
local Flight
local fall
local ap
local char

tool.Activated:Connect(function()
	if state then
		task.spawn(function()
			state = false
			local aiming_at, isClicked = event:InvokeClient(plr), false
			if aiming_at then
				local between = aiming_at.Hit.Position - hrp.Position
				if between.Magnitude < 250 then
					if (aiming_at.Hit.Position.Y - 4) < hrp.Position.Y then
						isClicked = true
					end
				end
			end
			if isClicked then
				if not isClicked then return end
				if not flame then
					bv:Destroy()
					ts:Create(hrp, TweenInfo.new(.4, Enum.EasingStyle.Linear), {CFrame = CFrame.new(aiming_at.Hit.Position)}):Play()

					catch_anim:Stop()

					flip_anim:Play()
					print(vg.BC.Shock)
					vg.BC.Shock.Launch.Parent = sword1
					sword1.Launch:Play()

					catch_anim:Stop()
					task.wait(0.4)

					flip_anim:Stop()
					crash_anim:Play()

					local Hit, Pos, Normal = workspace:FindPartOnRayWithIgnoreList(Ray.new(hrp.CFrame.Position, Vector3.new(0.5, -4, 0)), {workspace.Live, workspace.Thrown})
					task.wait(0.15)

					vg.BC.rocky.Parent = hrp
					hrp.rocky.Weld.Part0 = hrp
					
					for _, desc in ipairs(hrp.rocky:GetDescendants()) do
						if desc:IsA("ParticleEmitter") then
							local EMC = tonumber(desc.Name)
							if EMC then
								desc:Emit(EMC)
							end
						end
					end

					hitdet.magnitudeCheck(char, hrp.Position, 30, {
						physical = true,
						sword = true,
						knockback = true,
						damage = 20,
						aoe = true,
						blockbreak = true,
						move = "Blade Crash"
					}, nil, false)

					hrp.Crash:Play()
					task.wait(0.5)
					coroutine.wrap(function()
						task.wait(3)
						hrp.rocky:Destroy()
					end)()
					sword1.Launch:Destroy()
					stun:Destroy()
					fall:Destroy()
					Flight:Destroy()
					ap:Destroy()
					crash_anim:Stop()
					vg:Destroy()
					vg2:Destroy()
				else
					bv:Destroy()
					ts:Create(hrp, TweenInfo.new(.4, Enum.EasingStyle.Linear), {CFrame = CFrame.new(aiming_at.Hit.Position)}):Play()
					catch_anim:Stop()

					flip_anim:Play()

					vg2.BC.airspinbuff.BeamL.Parent = sword1
					vg2.BC.airspinbuff.BeamR.Parent = sword1
					vg2.BC.airspinbuff.ShardsR.Parent = sword1
					vg2.BC.airspinbuff.ShardsL.Parent = sword1
					vg2.BC.airspinbuff.a0.Parent = sword1
					vg2.BC.airspinbuff.a1.Parent = sword1
					vg2.BC.airspinbuff.ptcl.Parent = sword1
					for i, v in pairs(vg2.BC.airspinbuff:GetChildren()) do
						if v.Name == "fires1" then
							v.Parent = sword1
							task.delay(.4, function()
								v:Destroy()
							end)
						end
					end
					sword1.BeamL.Attachment0 = sword1.a0
					sword1.BeamR.Attachment0 = sword1.a0
					sword1.ShardsR.Attachment0 = sword1.a0
					sword1.ShardsL.Attachment0 = sword1.a0
					sword1.BeamL.Attachment1 = sword1.a1
					sword1.BeamR.Attachment1 = sword1.a1
					sword1.ShardsR.Attachment1 = sword1.a1
					sword1.ShardsL.Attachment1 = sword1.a1
					sword1.BeamL.Enabled = true
					sword1.BeamR.Enabled = true
					sword1.ShardsR.Enabled = true
					sword1.ShardsL.Enabled = true
					game.Debris:AddItem(sword1.BeamL, .3)
					game.Debris:AddItem(sword1.BeamR, .3)
					game.Debris:AddItem(sword1.ShardsL, .3)
					game.Debris:AddItem(sword1.ShardsR, .3)

					vg.BC.Shock.Launch.Parent = sword1
					sword1.Launch:Play()

					catch_anim:Stop()
					task.wait(0.3)
					sword1.a0:Destroy()
					sword1.a1:Destroy()
					sword1.ptcl:Destroy()

					flip_anim:Stop()
					crash_anim:Play()

					local Hit, Pos, Normal = workspace:FindPartOnRayWithIgnoreList(Ray.new(hrp.CFrame.Position, Vector3.new(0.5, -4, 0)), {workspace.Live, workspace.Thrown})
					task.wait(0.2)
					flip_anim:Stop()
					local cr = vg2.BC.AzureCrack
					cr.Crack.Position = hrp.Position

					cr.Parent = workspace.Thrown

					hrp.charge2:Play()
					for i, v in pairs(cr:GetChildren()) do
						if v.Name == "crackglow" then
							ts:Create(v.Decal1, TweenInfo.new(.5, Enum.EasingStyle.Linear), {Transparency = 0}):Play()
							ts:Create(v.Decal2, TweenInfo.new(.5, Enum.EasingStyle.Linear), {Transparency = 0}):Play()
						end
					end

					task.wait(0.4)

					for i, v in pairs(cr:GetChildren()) do
						if v.Name == "crackglow" then
							ts:Create(v.Decal1, TweenInfo.new(.5, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
							ts:Create(v.Decal2, TweenInfo.new(.5, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
						end
					end

					local exp = vg2.BC.explosion
					exp.Position = hrp.Position
					exp.Parent = workspace.Thrown
					exp.smash.firey:Emit(40)
					exp.above.winds:Emit(12)
					exp.center.Dots:Emit(40)
					exp.center.Smoke2:Emit(40)
					exp.explosion1:Play()
					exp.explosion2:Play()
					game.Debris:AddItem(exp, 2)
					game.Debris:AddItem(cr, 3)

					hitdet.magnitudeCheck(char, hrp.Position, 30, {
						sword = true,
						knockback = true,
						blockbreak = true,
						damage = 17.5,
						vanguardflame = true,
						injury = "heat",
						azurepunc = true,
						aoe = true,
						move = "Blade Crash",
						physical = true
					}, nil, false)

					task.wait(.3)
					flip_anim:Stop()
					sword1.Launch:Destroy()
					stun:Destroy()
					fall:Destroy()
					Flight:Destroy()
					ap:Destroy()
					crash_anim:Stop()
					vg:Destroy()
					vg2:Destroy()
					state = false
				end
			end
			--_G.System.Event:FireClient(game.Players:GetPlayerFromCharacter(char), "SetCDIndicator", {script.Parent.Name, 15})
			task.wait(15)
			cd = false
		end)
	end

	char = tool.Parent
	
	if char.Cooldowns:FindFirstChild("Blade Crash") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Blade Crash"
	CD.Value = 15
	CD.Parent = char.Cooldowns
	game.Debris:AddItem(CD, 15)

	if ActionCheck(char) then
		return
	end

	cd = true

	flame = false
	if char:FindFirstChild("VanguardBuff") then
		flame = true
	end

	plr = game.Players:GetPlayerFromCharacter(char)

	mouseaimscript = char:FindFirstChild("mouseaim")

	vg = game.ReplicatedStorage.Assets.vg:Clone()
	vg2 = game.ReplicatedStorage.Assets.vg:Clone()

	humanoid = char:WaitForChild("Humanoid")
	hrp = char:WaitForChild("HumanoidRootPart")

	local UserInputService = game:GetService("UserInputService")

	hilt = char:WaitForChild("Hilt")
	sword1 = hilt:WaitForChild(game.ServerStorage.PlayerData[plr.Name].PrimaryWeapon.Value)
	sword = sword1:Clone()
	sword.Parent = workspace.Thrown

	throw_anim = humanoid.Animator:LoadAnimation(script.Throw)
	catch_anim = humanoid.Animator:LoadAnimation(script.Catch)
	crash_anim = humanoid.Animator:LoadAnimation(script.Crash)
	flip_anim = humanoid.Animator:LoadAnimation(script.Flip)
	jump_anim = humanoid.Animator:LoadAnimation(script.Jump)

	throw_anim:Play()

	hrp.Throw:Play()

	hrp.AkumaEmit:Emit(26)

	hrp.Greatswordcharge:Play()

	stun = Instance.new("Folder")
	stun.Name = "Action"
	stun.Parent = char

	Flight = Instance.new("Folder")
	Flight.Name = "FlightOk"
	Flight.Parent = char

	fall = Instance.new("Folder")
	fall.Name = "NoFall"
	fall.Parent = char

	ap = Instance.new("Folder")
	ap.Name = "APAllow"
	ap.Parent = char
	
	task.wait(0.2)

	jump_anim:Play()

	hrp.Jump:Play()

	sword.PropWeld.Enabled = false
	sword.CFrame = hrp.CFrame * CFrame.new(1, 2.7, -1.4) * CFrame.Angles(0, 80, 0)
	sword.Spin:Play()
	if not flame then
		vg.BC.airspin.BeamL.Parent = sword
		vg.BC.airspin.BeamR.Parent = sword
		vg.BC.airspin.ShardsR.Parent = sword
		vg.BC.airspin.ShardsL.Parent = sword
		vg.BC.airspin.a0.Parent = sword
		vg.BC.airspin.a1.Parent = sword
		sword.BeamL.Attachment0 = sword.a0
		sword.BeamR.Attachment0 = sword.a0 -- // ima make this cleaner latr
		sword.ShardsR.Attachment0 = sword.a0
		sword.ShardsL.Attachment0 = sword.a0
		sword.BeamL.Attachment1 = sword.a1
		sword.BeamR.Attachment1 = sword.a1
		sword.ShardsR.Attachment1 = sword.a1
		sword.ShardsL.Attachment1 = sword.a1
		sword.BeamL.Enabled = true
		sword.BeamR.Enabled = true
		sword.ShardsR.Enabled = true
		sword.ShardsL.Enabled = true
	else
		vg.BC.airspinbuff.BeamL.Parent = sword
		vg.BC.airspinbuff.BeamR.Parent = sword
		vg.BC.airspinbuff.ShardsR.Parent = sword
		vg.BC.airspinbuff.ShardsL.Parent = sword
		vg.BC.airspinbuff.a0.Parent = sword
		vg.BC.airspinbuff.a1.Parent = sword
		vg.BC.airspinbuff.ptcl.Parent = sword
		for i, v in pairs(vg.BC.airspinbuff:GetChildren()) do
			if v.Name == "fires1" then
				v.Parent = sword
				task.delay(.6, function()
					v:Destroy()
				end)
			end
		end
		sword.BeamL.Attachment0 = sword.a0
		sword.BeamR.Attachment0 = sword.a0
		sword.ShardsR.Attachment0 = sword.a0
		sword.ShardsL.Attachment0 = sword.a0
		sword.BeamL.Attachment1 = sword.a1
		sword.BeamR.Attachment1 = sword.a1
		sword.ShardsR.Attachment1 = sword.a1
		sword.ShardsL.Attachment1 = sword.a1
		sword.BeamL.Enabled = true
		sword.BeamR.Enabled = true
		sword.ShardsR.Enabled = true
		sword.ShardsL.Enabled = true
	end

	ts:Create(sword, TweenInfo.new(.3, Enum.EasingStyle.Linear), {Position = hrp.Position + Vector3.new(0, 47, 0) + (hrp.CFrame.LookVector * 10)}):Play()

	local spin_tween = ts:Create(sword, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Orientation = Vector3.new(sword.Orientation.X, sword.Orientation.Y, -360)})
	spin_tween:Play()

	tween_connection = spin_tween.Completed:Connect(function()
		spin_tween:Play()
	end)

	task.wait(0.4)

	ts:Create(hrp, TweenInfo.new(.2, Enum.EasingStyle.Linear), {CFrame = CFrame.new(hrp.Position + Vector3.new(0, 47, 0) + hrp.CFrame.LookVector * 10)}):Play()

	task.wait(0.2)

	bv = Instance.new("BodyVelocity")
	game:GetService("CollectionService"):AddTag(bv, "AllowedBM")
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.Parent = hrp

	sword.Spin:Stop()

	sword.BeamL:Destroy()
	sword.BeamR:Destroy()
	sword.ShardsR:Destroy()
	sword.ShardsL:Destroy()
	sword.a0:Destroy()
	sword.a1:Destroy()
	if flame then
		sword.ptcl:Destroy()
	end

	tween_connection:Disconnect()

	jump_anim:Stop()

	catch_anim:Play()

	catch_anim.KeyframeReached:Connect(function(key)
		if key == "Finished" then
			--print("anim event!")
			state = false
			if sword:FindFirstChild("Attachmentz") then
				sword.Attachmentz.shing:Play()
				sword.Attachmentz.squashstar:Emit(1)
			end
			bv:Destroy()
			hrp.CancelAttach.CancelPtcl:Emit(10)
			local puncb = Instance.new("Folder")
			puncb.Name = "BladeCrashCancelBuff"
			puncb.Parent = char
			game.Debris:AddItem(puncb, 8)
			flip_anim:Stop()
			fall:Destroy()
			ap:Destroy()
			stun:Destroy()
			Flight:Destroy()
			vg:Destroy()
			vg2:Destroy()
			task.wait(15)
			cd = false
		end
	end)

	hrp.Catch:Play()

	sword:Destroy()

	state = true
end)
