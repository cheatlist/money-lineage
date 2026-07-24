local spell = {}
-- Ignite Spell
function sub(...)
    coroutine.wrap(...)()
end
 
local TweenService = game:GetService("TweenService")
local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local hitDetection = require(game.ServerScriptService.Modules.HitDetection)

spell.upperbound = 95
spell.lowerbound = 80
spell.signs = 3
spell.cost = 0

local spell2 = {}
spell2.upperbound = 90
spell2.lowerbound = 70
spell2.signs = 0
spell2.cost = 20

local spelleffect = game.ServerStorage.SpellEffects.Antimagic
function spell:Activate(char,castSuccess,currentprop)
	if game.CollectionService:HasTag(char,"Casting") or char:FindFirstChild("ActiveCast") then return end

	local mana = char.Mana
	local play = game.Players:GetPlayerFromCharacter(char)
	local manacolor = game.ServerStorage.PlayerData[play.Name].ManaColor.Value
	
	if castSuccess == 0 then
		if char:FindFirstChild("EndCast") then return end
		game.ReplicatedStorage.Requests.StopSprint:FireClient(play)
		
		local h = Instance.new("Accessory")
		h.Name = "ActiveCast"
		h.Parent = char
		
		mana.Value = math.max(mana.Value-spell.cost,0)
		
		local speedboost = Instance.new("Accessory")
		speedboost.Name = "Action"
		
		speedboost.Parent = char
		
		char.HumanoidRootPart.PerfectCast:Play()
		
		local anim = char.Humanoid:LoadAnimation(script.Animation)
		if currentprop then
			anim = char.Humanoid:LoadAnimation(script.Animation)
		end
		anim:Play()
		
		local startCF = char["Right Arm"].CFrame * CFrame.new(0,-1.2,0)* CFrame.Angles(0,0,math.rad(180))
				
		local cancelled = char:FindFirstChild("EndCast") or char:FindFirstChild("Stun") or game.CollectionService:HasTag(char,"Knocked") or game.CollectionService:HasTag(char,"Unconscious")
		
		local field = spelleffect.Field:Clone()
		field.CFrame = startCF
		field.Sound:Play()
		field.Parent = game.Workspace.Thrown
		game.ServerStorage.Debris:Fire(field,25) -- JUST IN CASE
		TweenService:Create(field,TweenInfo.new(2.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Size=Vector3.new(160,160,160)}):Play()
		
		task.spawn(function()
			task.wait(2.5)
			h:Destroy()
			speedboost:Destroy()
			anim:Stop()		
		end)	
		
		local tags = {}
		task.spawn(function()
			while field do 
				for _,ch in pairs(game.Workspace.Live:GetChildren()) do
					if ch ~= char and ch:FindFirstChild("Torso") and ch:FindFirstChild("Humanoid") then
						if game.ServerStorage.PlayerData:FindFirstChild(ch.Name) and (game.ServerStorage.PlayerData:FindFirstChild(char.Name).LastName.Value == "" or  game.ServerStorage.PlayerData:FindFirstChild(ch.Name).LastName.Value ~= game.ServerStorage.PlayerData:FindFirstChild(char.Name).LastName.Value) then
							local posdiff = (ch.Torso.Position - field.Position).Magnitude

							if posdiff <= field.Size.X/2 then
								if not ch:FindFirstChild("ContrariumTag") then
									local tag = Instance.new("ObjectValue")
									tag.Name = "ContrariumTag"
									tag.Value = field
									tag.Parent = ch
									game.ServerStorage.Debris:Fire(tag,25) -- JUST IN CASE
									table.insert(tags,tag)

									if ch:FindFirstChild("ActiveCast") then
										local endcast = Instance.new("Accessory")
										endcast.Name = "EndCast"
										endcast.Parent = ch
										game.ServerStorage.Debris:Fire(endcast,2)
									end
								end
							else
								for _,tag in pairs(ch:GetChildren()) do
									if tag.Name == "ContrariumTag" and tag:IsA("ObjectValue") and tag.Value == field then
										tag:Destroy()
									end
								end
							end				
						end				
					end
				end

				for _,thr in pairs(game.Workspace.Thrown:GetChildren()) do
					if thr.Name == "Orion" and thr:FindFirstChild("Torso") and not thr:FindFirstChild("ContrariumTag") then
						local posdiff = (thr.Torso.Position - field.Position).Magnitude

						if posdiff <= field.Size.X/2 then
							local tag = Instance.new("ObjectValue")
							tag.Name = "ContrariumTag"
							tag.Value = field
							tag.Parent = thr
							table.insert(tags,tag)
						end
					elseif thr.Name == "OrderField" and thr:FindFirstChild("Summoned") and not thr:FindFirstChild("ContrariumTag") then
						local posdiff = (thr.Position - field.Position).Magnitude

						if posdiff <= field.Size.X/2 then
							local tag = Instance.new("ObjectValue")
							tag.Name = "ContrariumTag"
							tag.Value = field
							tag.Parent = thr
							table.insert(tags,tag)
						end
					end
				end
				wait()
			end
		end)
		task.wait(5)
		sub(function()			
			for i,v in pairs(tags) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			TweenService:Create(field.Sound,TweenInfo.new(2.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Volume = 0}):Play()	
			TweenService:Create(field,TweenInfo.new(2.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Size=Vector3.new(0,0,0)}):Play()
			field.Attachment.OrbParticle.Enabled = false
			game.ServerStorage.Debris:Fire(field,2.5)
		end)
	elseif castSuccess == 1 then	
		local tag = Instance.new("ObjectValue")
		tag.Name = "ContrariumTag"
		tag.Parent = char
		game.ServerStorage.Debris:Fire(tag,5)	
	else
		char.HumanoidRootPart.Diffusion:Play()
		if currentprop and currentprop:FindFirstChild("Backfire") then
			currentprop.Backfire.Color = ColorSequence.new(Color3.new(manacolor.r,manacolor.g,manacolor.b))
			currentprop.Backfire:Emit(15)
		end
	end
end

function spell:Deactivate(char,play)
	local f = Instance.new("Accessory")
	f.Name = "EndCast"
	f.Parent = char
	
	game.ServerStorage.Debris:Fire(f,2)
end

function spell2:Activate(char,castSuccess,currentprop,upgradedSpells)
	if game.CollectionService:HasTag(char,"Casting") then return end
	if not upgradedSpells[script.Parent.Name] and char.Name~="Ragoozer" then return end
	
	local mana = char.Mana
	local play = game.Players:GetPlayerFromCharacter(char)
	local playerFolder = play and game.ServerStorage.PlayerData:FindFirstChild(play.Name)
	local manacolor = playerFolder and playerFolder.ManaColor.Value
	local mouse
	pcall(function()
		mouse = require(game.ServerStorage.Modules.RemoteLib).getMouse(play)
	end)
	
	if not mouse then return end
	local HRP = manacolor and char:FindFirstChild("HumanoidRootPart")
	if not HRP then return end
	if castSuccess == 0 then
		
		char.HumanoidRootPart.PerfectCast:Play()
		local anim = char.Humanoid:LoadAnimation(script.Snap)
		anim:Play()
		
		wait(.2)
		
		local bal = game.ReplicatedStorage.Assets.HandHoldContr:Clone()
		bal.IllusionArm.Enabled = false
		bal.Parent = game.Workspace.Thrown
		bal.Snap:Play()
		bal.IllusionSnap:Emit(100)
		
		local tinfo = TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true)
		TweenService:Create(bal.PointLight,tinfo,{Range=20}):Play()
		
		local ring = game.ServerStorage.Assets.ContrarRing:Clone()
		ring.Position = char.Torso.Position
		ring.Parent = workspace.Thrown
		TweenService:Create(ring,tinfo,{Size=Vector3.new(40,0.5,40)}):Play()
		game.ServerStorage.Debris:Fire(ring,0.5)
		
		
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
		
		hitDetection.aoeCombatTag(char,char.Torso.Position,25) -- COMBAT TAG THE VICTIMS
		
		for i,v in pairs(game.Workspace.Live:GetChildren()) do
			if (v.HumanoidRootPart.Position-char.HumanoidRootPart.Position).magnitude<=20 and v~=char and not v:FindFirstChild("ContrariumTag") and not (v:FindFirstChild("MonsterInfo") and v.MonsterInfo.Master.Value == char) then
				if game.ServerStorage.PlayerData:FindFirstChild(v.Name) and (game.ServerStorage.PlayerData:FindFirstChild(char.Name).LastName.Value == "" or  game.ServerStorage.PlayerData:FindFirstChild(v.Name).LastName.Value ~= game.ServerStorage.PlayerData:FindFirstChild(char.Name).LastName.Value) and v ~= char then
					local tag = Instance.new("ObjectValue")
					tag.Name = "ContrariumTag"
					tag.Parent = v
					game.ServerStorage.Debris:Fire(tag,10)

					if v:FindFirstChild("ActiveCast") then
						local endcast = Instance.new("Accessory")
						endcast.Name = "EndCast"
						endcast.Parent = v
						game.ServerStorage.Debris:Fire(endcast,2)
					end
				end 
			end
		end
		
		for _,thr in pairs(game.Workspace.Thrown:GetChildren()) do
			if thr.Name == "Orion" and thr:FindFirstChild("Torso") and not thr:FindFirstChild("ContrariumTag") then
				local posdiff = (thr.Torso.Position - char.HumanoidRootPart.Position).Magnitude
				
				if posdiff <= 20 then
					local tag = Instance.new("ObjectValue")
					tag.Name = "ContrariumTag"
					tag.Value = nil
					tag.Parent = thr
				end
			elseif thr.Name == "OrderField" and thr:FindFirstChild("Summoned") and not thr:FindFirstChild("ContrariumTag") then
				local posdiff = (thr.Position - char.HumanoidRootPart.Position).Magnitude
					
				if posdiff <= 20 then
					local tag = Instance.new("ObjectValue")
					tag.Name = "ContrariumTag"
					tag.Value = nil
					tag.Parent = thr
				end
			end
		end
	else	
		local tag = Instance.new("ObjectValue")
		tag.Name = "ContrariumTag"
		tag.Parent = char
		game.ServerStorage.Debris:Fire(tag,5)
	end
end

spell.alternate = spell2

return spell