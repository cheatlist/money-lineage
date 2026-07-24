local spell = {}
function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local hitDetection = require(game.ServerScriptService.Modules.HitDetection)
spell.upperbound = 90
spell.lowerbound = 70
spell.signs = 5
spell.cost = 0
local spell2 = {}
spell2.upperbound = 30
spell2.lowerbound = 20
spell2.signs = 0
spell2.cost = 20



local spelleffect = game.ServerStorage.SpellEffects.Slowed
function spell:Activate(char, castSuccess, currentprop)
	if game.CollectionService:HasTag(char, "Casting") or char:FindFirstChild("ActiveCast") then
		return
	end
	local mana = char.Mana
	local play = game.Players:GetPlayerFromCharacter(char)
	local manacolor = game.ServerStorage.PlayerData[play.Name].ManaColor.Value
	if castSuccess == 0 then
		if char:FindFirstChild("EndCast") then
			return
		end
		game.ReplicatedStorage.Requests.ClientSprint:FireClient(play)
		do
			local h = Instance.new("Folder")
			h.Name = "ActiveCast"
			h.Parent = char
			mana.Value = math.max(mana.Value - spell.cost, 0)
			local speedboost = Instance.new("IntValue")
			speedboost.Name = "SpeedBoost"
			speedboost.Value = -12
			speedboost.Parent = char.Boosts
			char.HumanoidRootPart.PerfectCast:Play()
			local bal = game.ServerStorage.Assets.HandHoldSlow:Clone()
			bal.Parent = game.Workspace.Thrown
			local anim = char.Humanoid:LoadAnimation(script.RightPoint)
			if currentprop then
				anim = char.Humanoid:LoadAnimation(script.BookPoint)
			end
			anim:Play()
			local sound = spelleffect.Sound:Clone()
			sound.Parent = bal
			sound:Play()
			local attachPoint = char["Right Arm"]
			local attachC1 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
			if not currentprop then
				attachC1 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
			end
			local w = Instance.new("Weld")
			sub(function()
				w.Name = "Weld"
				w.Part0 = attachPoint
				w.Part1 = bal
				w.Parent = bal
				w.C1 = attachC1
			end)
			local root = char.HumanoidRootPart
			local cancelled = char:FindFirstChild("EndCast") or char:FindFirstChild("Stun") or game.CollectionService:HasTag(char, "Knocked") or game.CollectionService:HasTag(char, "Unconscious")
			local target
			local r = Instance.new("IntValue")
			r.Name = "PondusHold"
			r.Value = 1
			local slowdebuff = Instance.new("IntValue")
			slowdebuff.Name = "SpeedBoost"
			slowdebuff.Value = -12
			local swingslow = Instance.new("NumberValue")
			swingslow.Name = "AttackSpeedBoost"
			swingslow.Value = 0.75
			local slowedparticle = spelleffect.Particle:Clone()
			local sealanim
			repeat
				if not target then
					local closestdist
					local dotAngle = math.rad(15)
					local breathDirection = root.CFrame.lookVector
					local breathOrigin = root.Position
					local castTo = {}
					for _, ch in pairs(workspace.Live:children()) do
						if ch ~= char and ch:IsA("Model") then
							local hum = ch and ch:FindFirstChild("Humanoid")
							local hrp = hum and hum.RootPart
							local rootPos = hrp.Position
							local direc = rootPos - breathOrigin
							if dotAngle >= math.acos(breathDirection:Dot(direc.unit)) and direc.magnitude < 40 then
								local playerData = game.ServerStorage.PlayerData[play.Name]
								local targData = game.ServerStorage.PlayerData:FindFirstChild(ch.Name)
								if targData then
									targData = targData
									if playerData.LastName.Value == "" or playerData.LastName.Value ~= targData.LastName.Value then
										table.insert(castTo, ch)
									end
								end
							end
						end
					end
					for i, v in pairs(castTo) do
						local dist = (v.HumanoidRootPart.Position - root.Position).Magnitude
						if not target or target and closestdist > dist then
							target = v
							closestdist = dist
						end
					end
					if target then
						sealanim = target.Humanoid:LoadAnimation(script.AnimHold)
						if target:FindFirstChild("PondusHold") then
							target.PondusHold.Value = target.PondusHold.Value + 1
							if target.PondusHold.Value >= 3 then
								sealanim:Play()
							end
						else
							r.Parent = target
						end
						slowdebuff.Parent = target.Boosts
						swingslow.Parent = target.Boosts
						slowedparticle.Parent = target.Torso
					end
				else
					local dist = (target.HumanoidRootPart.Position - root.Position).Magnitude
					local scale = math.min(1.25, math.max(0.75, dist / 50))
					slowdebuff.Value = -12 * scale
					swingslow.Value = 0.75 * scale
				end
				cancelled = char.Mana.Value <= 0 or char:FindFirstChild("EndCast") or char:FindFirstChild("Stun") or game.CollectionService:HasTag(char, "Knocked") or game.CollectionService:HasTag(char, "Unconscious")
				wait()
			until cancelled
			sub(function()
				if target and target:FindFirstChild("PondusHold") then
					for i, v in pairs(target.Humanoid:GetPlayingAnimationTracks()) do
						if v.Name == "AnimHold" then
							v:Stop()
							v:Destroy()
						end
					end
					target.PondusHold.Value = target.PondusHold.Value - 1
					if target.PondusHold.Value <= 0 then
						target.PondusHold:Destroy()
					end
				end
				slowdebuff:Destroy()
				swingslow:Destroy()
				h:Destroy()
				speedboost:Destroy()
				bal.OrbParticle.Enabled = false
				anim:Stop()
				slowedparticle.Enabled = false
				bal.PointLight.Enabled = false
				wait(1.5)
				slowedparticle:Destroy()
				w:Destroy()
				bal:Destroy()
			end)
		end
	elseif castSuccess == 1 then
		do
			local slowdebuff = Instance.new("IntValue")
			slowdebuff.Name = "SpeedBoost"
			slowdebuff.Value = -12
			slowdebuff.Parent = char.Boosts
			local swingslow = Instance.new("NumberValue")
			swingslow.Name = "AttackSpeedBoost"
			swingslow.Value = 0.75
			swingslow.Parent = char.Boosts
			local sound = spelleffect.Sound:Clone()
			sound.Parent = char.HumanoidRootPart
			sound:Play()
			local slowedparticle = spelleffect.Particle:Clone()
			slowedparticle.Parent = char.Torso
			game.Debris:AddItem(slowdebuff, 10)
			game.Debris:AddItem(swingslow, 10)
			game.Debris:AddItem(sound, 10)
			game.Debris:AddItem(slowedparticle, 10)
			sub(function()
				wait(9)
				slowedparticle.Enabled = false
			end)
		end
	else
		char.HumanoidRootPart.Diffusion:Play()
		if currentprop and currentprop:FindFirstChild("Backfire") then
			currentprop.Backfire.Color = ColorSequence.new(Color3.new(manacolor.r, manacolor.g, manacolor.b))
			currentprop.Backfire:Emit(15)
		end
	end
end
function spell:Deactivate(char, play)
	local f = Instance.new("Folder")
	f.Name = "EndCast"
	f.Parent = char
	game:GetService("Debris"):AddItem(f, 2)
end
function spell2:Activate(char, castSuccess, currentprop, upgradedSpells)
	if game.CollectionService:HasTag(char, "Casting") then
		return
	end
	if not upgradedSpells[script.Parent.Name] then
		return
	end
	local play = game.Players:GetPlayerFromCharacter(char)
	local manacolor = game.ServerStorage.PlayerData[play.Name].ManaColor.Value
	local mana = char.Mana
	local play = game.Players:GetPlayerFromCharacter(char)
	local playerFolder = play and game.ServerStorage.PlayerData:FindFirstChild(play.Name)
	local manacolor = playerFolder and playerFolder.ManaColor.Value
	local mouse
	pcall(function()
		mouse = _G.MouseData(play)
	end)
	if not mouse then
		return
	end
	local HRP = manacolor and char:FindFirstChild("HumanoidRootPart")
	if not HRP then
		return
	end
	if castSuccess == 0 then
		char.HumanoidRootPart.PerfectCast:Play()
		do
			local anim = char.Humanoid:LoadAnimation(script.SnapAnim1)
			anim:Play()
			wait(0.2)
			local bal = game.ReplicatedStorage.Assets.HandHoldCeleri:Clone()
			bal.IllusionArm.Enabled = false
			bal.Parent = game.Workspace.Thrown
			bal.Snap:Play()
			bal.IllusionSnap:Emit(100)
			local attachPoint = char["Right Arm"]
			local attachC1 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
			if not currentprop then
				attachC1 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
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
			hitDetection.aoeCombatTag(char, char.Torso.Position, 20)
			for i, v in pairs(game.Workspace.Live:GetChildren()) do
				if (v.Torso.Position - char.Torso.Position).magnitude <= 15 and v ~= char then
					do
						local slowdebuff = Instance.new("IntValue")
						slowdebuff.Name = "SpeedBoost"
						slowdebuff.Value = -12
						slowdebuff.Parent = v.Boosts
						local swingslow = Instance.new("NumberValue")
						swingslow.Name = "AttackSpeedBoost"
						swingslow.Value = 0.75
						swingslow.Parent = v.Boosts
						local pho = Instance.new("IntValue")
						pho.Name = "PondusHold"
						pho.Value = 1
						local kneelanim = v.Humanoid:LoadAnimation(script.AnimHold)
						if v:FindFirstChild("PondusHold") then
							v.PondusHold.Value = v.PondusHold.Value + 1
							if 3 <= v.PondusHold.Value then
								kneelanim:Play()
							end
							v:FindFirstChild("PondusHold").Changed:connect(function()
								if v.PondusHold.Value < 3 then
									kneelanim:Stop()
								end
							end)
							spawn(function()
								wait(10)
								if v:FindFirstChild("PondusHold") then
									v.PondusHold.Value = v.PondusHold.Value - 1
									if v.PondusHold.Value <= 0 then
										v:Destroy()
									end
								end
							end)
						else
							pho.Parent = v
						end
						local sound = spelleffect.Sound:Clone()
						sound.Parent = v.HumanoidRootPart
						sound:Play()
						local slowedparticle = spelleffect.Particle:Clone()
						slowedparticle.Parent = v.Torso
						game:GetService("Debris"):AddItem(sound, 10)
						game:GetService("Debris"):AddItem(slowedparticle, 10)
						game:GetService("Debris"):AddItem(slowdebuff, 10)
						game:GetService("Debris"):AddItem(swingslow, 10)
						game:GetService("Debris"):AddItem(pho, 90)
					end
				end
			end
		end
	else
		local slowdebuff = Instance.new("IntValue")
		slowdebuff.Name = "SpeedBoost"
		slowdebuff.Value = -12
		slowdebuff.Parent = char.Boosts
		local swingslow = Instance.new("NumberValue")
		swingslow.Name = "AttackSpeedBoost"
		swingslow.Value = 0.75
		swingslow.Parent = char.Boosts
		local sound = spelleffect.Sound:Clone()
		sound.Parent = char.HumanoidRootPart
		sound:Play()
		local slowedparticle = spelleffect.Particle:Clone()
		slowedparticle.Parent = char.Torso
		game:GetService("Debris"):AddItem(sound, 10)
		game:GetService("Debris"):AddItem(slowedparticle, 10)
		game:GetService("Debris"):AddItem(slowdebuff, 10)
		game:GetService("Debris"):AddItem(swingslow, 10)
	end
end
spell.alternate = spell2
return spell
