local assets = game.ServerStorage.Assets
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local module = {}
local cd = false
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(p1)
	return ActionCheckModule(p1, {
		presentBlocks = {"Stun", "ReturnStun", "ActiveCast", "Action", "Blocking", "Climbing"},
		healthAtOrBelow = 0,
	})
end
function Anchor(Target, Statement)
	if Statement then
		local RootFreezing = Instance.new("Accessory")
		RootFreezing.Name = "FreezeRoot"
		RootFreezing.Parent = Target
	else
		for i,v in pairs(Target:GetChildren()) do
			if v.Name == "FreezeRoot" then
				v:Destroy()
			end
		end
	end
end

local function Nearest(Origin, User)
	local High = 15
	local Target = nil
	for i, v in pairs(workspace.Live:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= User and not v:FindFirstChild("ForceField") then
			if v.Humanoid.Health > 0 then
				local Formula = (v:WaitForChild("HumanoidRootPart").Position - Origin).Magnitude <= High
				Formula = Formula and (User.HumanoidRootPart.CFrame:inverse() * v.HumanoidRootPart.CFrame).Z < 0 
				Formula = Formula and math.abs((User.HumanoidRootPart.CFrame:Inverse() * v.HumanoidRootPart.CFrame).X) <= 6
				Formula = Formula and math.abs((User.HumanoidRootPart.CFrame:Inverse() * v.HumanoidRootPart.CFrame).Y) <= 5
				if Formula then
					local High = (v:WaitForChild("HumanoidRootPart").Position - Origin).Magnitude
					Target = v
				end
			end
		end
	end
	return Target
end

module.Active = function(v3,player, guh, wep)
	if ActionCheck(v3)then
		return
	end
	if v3.Cooldowns:FindFirstChild("Puncture") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Puncture"
	CD.Value = 15
	CD.Parent = v3.Cooldowns
	game.Debris:AddItem(CD, 15)
	cd = true
	local flame = false
	if v3:FindFirstChild("VanguardBuff") then
		flame = true
	end
	local divisor = 1
	if v3:FindFirstChild("BladeCrashCancelBuff") then
		divisor = 2
		v3:FindFirstChild("BladeCrashCancelBuff"):Destroy()
	end

	local assets = game.ReplicatedStorage.Assets.vg.Puncture:Clone()
	game.Debris:AddItem(assets, 7)
	if flame then
		local buff = assets.puncWindupBUFF:Clone()
		local stun = Instance.new("Folder")
		stun.Name = "Action"
		stun.Parent = v3
		local amin = v3.Humanoid:LoadAnimation(script.Parent.Windup)
		amin:Play()
		buff.start.Parent = v3.HumanoidRootPart
		v3.HumanoidRootPart.start:Play()
		buff.Parent = game.Workspace.Thrown
		buff.RootWeld.Part1 = buff
		buff.RootWeld.Part0 = wep
		buff.Beam42.Attachment0 = wep.Point
		buff.Beam43.Attachment0 = wep.Point
		buff.Beam44.Attachment0 = wep.Point
		buff.Beamfire22.Attachment0 = wep.Point
		buff.Beamfire2.Attachment0 = wep.Point
		buff.Beamfire.Attachment0 = wep.Point
		buff.Beam42.Attachment1 = buff.A2
		buff.Beam43.Attachment1 = buff.A3
		buff.Beam44.Attachment1 = buff.A1
		buff.Beamfire22.Attachment1 = buff.A6
		buff.Beamfire2.Attachment1 = buff.A5
		buff.Beamfire.Attachment1 = buff.A4
		wait(.3 / divisor)
		amin:Stop()
		v3.Humanoid:LoadAnimation(script.Parent.stabber):Play()
		local v2 = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(v2,"AllowedBM")
		v2.MaxForce = Vector3.new(80000,0,80000)
		v2.Velocity = v3.HumanoidRootPart.CFrame.lookVector.unit*110
		v2.Name = "ForwardVelocity"
		v2.Parent = v3.HumanoidRootPart
		game:GetService("Debris"):AddItem(v2, 0.6)
		local anim = v3.Humanoid:LoadAnimation(script.Parent.hold)
		anim:Play()
		-- womp womp
		for i = 1,6 do
			u3.magnitudeCheck(v3, v3.HumanoidRootPart.Position, 8,{
				damage = 15,
				knockback = true,
				vanguardflame = true,
				azurepunc = true,
				move = "Puncture"
			})
			wait(.1)
		end
		game.Debris:AddItem(v3.HumanoidRootPart.start,5)
		buff:Destroy()
		anim:Stop()
		stun:Destroy()
		assets:Destroy()
	else 
		v3.HumanoidRootPart.AkumaEmit:Emit(26)-- i did before you copier
		local stun = Instance.new("Folder")
		stun.Name = "Action"
		stun.Parent = v3
		game.Debris:AddItem(stun, 0.7/ divisor)
		local lol10 = v3.Humanoid:LoadAnimation(script.Parent.Windup) --like is 0.7 good or needs more/less
		lol10:Play() 
		local puncWindup = assets.puncWindupNobuff:Clone()
		puncWindup.Parent = wep
		puncWindup.RootWeld.Part0 = wep
		puncWindup.RootWeld.Part1 = puncWindup
		puncWindup.Beam2.Attachment0 = wep.Point
		puncWindup.Beam3.Attachment0 = wep.Point
		puncWindup.Beam4.Attachment0 = wep.Point
		puncWindup.Beam2.Attachment1 = puncWindup.A2
		puncWindup.Beam3.Attachment1 = puncWindup.A3
		puncWindup.Beam4.Attachment1 = puncWindup.A4
		game.Debris:AddItem(puncWindup,.7/divisor)
		task.wait(0.7 / divisor)
		puncWindup:Destroy()
		lol10:Stop()--hmmm
		v3.HumanoidRootPart.Greatswordcharge:Play();
		local lolstab = v3.Humanoid:LoadAnimation(script.Parent.stabber)--gg
		lolstab:Play()
		local v2 = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(v2,"AllowedBM")
		v2.MaxForce = Vector3.new(80000,0,80000)
		v2.Velocity = v3.HumanoidRootPart.CFrame.lookVector.unit*100 -- my key board was bugging shhh
		v2.Name = "ForwardVelocity"-- you dont its how you add velocity
		v2.Parent = v3.HumanoidRootPart
		game:GetService("Debris"):AddItem(v2, 0.15)
		wait(0.1)
		v3.HumanoidRootPart.ShineStab:Play()
		if not v3:FindFirstChild("Knocked") and not v3:FindFirstChild("Unconscious") then
			if Nearest(v3.HumanoidRootPart.Position, v3) then
				local Nearest = Nearest(v3.HumanoidRootPart.Position, v3)
				if Nearest:FindFirstChild("Knocked") then
					return
				end
				for i, v in pairs(Nearest.Humanoid:GetPlayingAnimationTracks()) do
					if v.Priority == Enum.AnimationPriority.Action then
						v.Priority = Enum.AnimationPriority.Movement
					end
				end

				for i = 1, 2 do
					local Descendants = v3.HumanoidRootPart:GetChildren()
					if i == 2 then
						Descendants = Nearest.HumanoidRootPart:GetChildren()
					end
					for ind, val in pairs(Descendants) do
						if val:IsA("BodyVelocity") then
							val:Destroy()
						end
					end
				end
				if lolstab.IsPlaying then
					lolstab:Stop()
				end
				local NearestPlayer = game:GetService("Players"):GetPlayerFromCharacter(Nearest) 
				if not NearestPlayer then NearestPlayer = Nearest end	
				local Stun = Instance.new("Accessory")
				Stun.Name = "Stun"
				Stun.Parent = Nearest
				local Action = Instance.new("Accessory")
				Action.Name = "Action"
				Action.Parent = v3
				wait()
				Nearest.Humanoid.AutoRotate = false; v3.Humanoid.AutoRotate = false
				Nearest.HumanoidRootPart.CFrame = v3.HumanoidRootPart.CFrame 
				local lol = Instance.new("Weld")
				lol.Name = 'gqoekgoqeg'
				lol.Part0 = Nearest.HumanoidRootPart
				lol.Part1 = wep
				lol.C1 = CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(90))
				lol.Parent = Nearest
				Nearest.HumanoidRootPart.attachment.impact:Emit(2)
				Nearest.HumanoidRootPart.attachment.needles:Emit(15)
				Nearest.HumanoidRootPart.attachment.needles:Emit(1)
				local lol5 = Nearest.Humanoid:LoadAnimation(script.Parent.Impaled)
				Nearest.HumanoidRootPart.Bloodimpact:Play()
				lol5:Play()
				local bloodHit = assets.BloodHit:Clone()
				bloodHit.Parent = Nearest.HumanoidRootPart
				bloodHit.Enabled = true
				local lol98 = v3.Humanoid:LoadAnimation(script.Parent.hold)
				lol98:Play()
				wait(1)
				bloodHit.Enabled = false
				lol98:Stop()
				wait()
				v3.Humanoid:LoadAnimation(script.Parent.THROW):Play()
				wait(0.48)
				bloodHit:Destroy()
				lol:Destroy()
				v3.Humanoid.AutoRotate = true
				Nearest.Humanoid.AutoRotate = true
				lol5:Stop()
				Stun:Destroy()
				Action:Destroy()
				game.ServerStorage.Requests.TagHumanoid:Fire(v3, Nearest, {
					physical = true,
					noparry = true,
					blockbreak = true,
					manabreaker = true,
					damage = 20,
					fist = true,
					knockback = true,
					move = "Puncture"
				})
			end
		end
	end
	assets:Destroy()
	--_G.System.Event:FireClient(game.Players:GetPlayerFromCharacter(v3), "SetCDIndicator", {script.Parent.Name, 15})
	wait(15)
	cd = false
end
return module