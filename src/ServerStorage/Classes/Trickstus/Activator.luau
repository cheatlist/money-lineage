local spell = {}
-- Invisibility Spell
function sub(...)
    coroutine.wrap(...)()
end

local TweenService = game:GetService("TweenService")
local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local hitDetection = require(game.ServerScriptService.Modules.HitDetection)

spell.upperbound = 70
spell.lowerbound = 30
spell.signs = 2
spell.cost = 10

local spell2 = {}
spell2.upperbound = 50
spell2.lowerbound = 30
spell2.signs = 0
spell2.cost = 100

local spelleffect = game.ServerStorage.SpellEffects.SpeedUp
function spell:Activate(char,castSuccess,currentprop)
	if game.CollectionService:HasTag(char,"Casting") or char:FindFirstChild("ActiveCast") then return end
	
	local mana = char.Mana
	local play = game.Players:GetPlayerFromCharacter(char)
	local manacolor = game.ServerStorage.PlayerData[play.Name].ManaColor.Value
	
	if castSuccess == 0 then
		if char:FindFirstChild("EndCast") then return end
		local h = Instance.new("Accessory")
		h.Name = "ActiveCast"
		h.Parent = char
		
		mana.Value = math.max(mana.Value-spell.cost,0)
		
		local speedboostz = Instance.new("IntValue")
		speedboostz.Name = "SpeedBoost"
		speedboostz.Value = -12
		speedboostz.Parent = char.Boosts
		
		char.HumanoidRootPart.PerfectCast:Play()
		
		local bal = game.ReplicatedStorage.Assets.HandHoldIllusion2:Clone()
		game.ServerStorage.Debris:Fire(bal,70)
		bal.Parent = game.Workspace.Thrown
		bal.Hit:Play()
		local anim = char.Humanoid:LoadAnimation(script.RightPoint)
		if currentprop then
			anim = char.Humanoid:LoadAnimation(script.BookPoint)
		end
		anim:Play()
		anim:AdjustSpeed(.5)

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
		end)
		
		local root = char.HumanoidRootPart
		
		local cancelled = char:FindFirstChild("EndCast") or char:FindFirstChild("Stun") or game.CollectionService:HasTag(char,"Knocked") or game.CollectionService:HasTag(char,"Unconscious")
		local target = nil
		
		local confusion = script.Parent.LocalScript:Clone()
		confusion.Name = "ConfuseScript"
		
		local camflip = Instance.new("Accessory")
		camflip.Name = "CamFlip"
						
		repeat 
			if not target then
				-- Get closest target
				local closestdist = nil
				
				local dotAngle = math.rad(15)
			
				local breathDirection = root.CFrame.lookVector
				local breathOrigin = root.Position
				local castTo = {}
				
				for _,ch in pairs(workspace.Live:children()) do
					if ch ~= char and ch:IsA("Model") then
						local hum = ch and ch:FindFirstChild("Humanoid")
						local hrp = hum and hum.RootPart

						if hrp then
							local rootPos = hrp.Position
							local direc = rootPos - breathOrigin
									
							if math.acos(breathDirection:Dot(direc.unit)) <= dotAngle then
								if direc.magnitude < 40 then
									
									local playerData = game.ServerStorage.PlayerData[play.Name]
									local targData = game.ServerStorage.PlayerData:FindFirstChild(ch.Name)
									
									if targData then
										if playerData.LastName.Value == "" or playerData.LastName.Value ~= targData.LastName.Value then
											table.insert(castTo,ch)
										end
									end
									
								end
							end
						end
					end
				end
				
				for i,v in pairs(castTo) do
					local dist = (v.HumanoidRootPart.Position-root.Position).Magnitude
					if not target or (target and dist < closestdist) then
						target = v
						closestdist = dist
					end
				end
				
				if target then
					-- target selected.
				if not game.ServerStorage.PlayerData:FindFirstChild(target.Name) then return end
					if game.ServerStorage.PlayerData[target.Name].Race.Value ~= "Lich" and game.ServerStorage.PlayerData[target.Name].Race.Value ~= "Dzin" and not game.Players[target.Name].Backpack:FindFirstChild("MentalBlock") then
				
							
					camflip.Parent = target
					
					confusion.Parent = target
					confusion.Disabled = false
					local sound = bal.Hit:Clone()
					sound.Parent = target.Head
					sound:Play()
			
					
					local animz = target.Humanoid:LoadAnimation(script.Confused)
					animz:Play()
					animz:AdjustSpeed(.35)
					
					sub(function()
						while target and target~=nil do
							wait(.5)
						end
						
						camflip:Destroy()
				
				
					animz:Stop()
					sound:Destroy()
					end)
				end
				end
			else
				local dist = (target.HumanoidRootPart.Position-root.Position).Magnitude
					local dist = (target.HumanoidRootPart.Position-root.Position).Magnitude
				local scale = math.min(1.25,math.max(0.75,dist/50))
				
			end
			
			cancelled = char.Mana.Value <= 0 or char:FindFirstChild("EndCast") or char:FindFirstChild("Stun") or game.CollectionService:HasTag(char,"Knocked") or game.CollectionService:HasTag(char,"Unconscious") or not char:FindFirstChild("Trickstus")
			wait()
		until cancelled
		
		speedboostz:Destroy()
		
		sub(function()
			target = nil
			
			h:Destroy()
		
		
			anim:Stop()
			--bal.Hit:Stop()
			bal.IllusionArm.Enabled = false
			
			--[[ char:FindFirstChild("Action") then
				char.Action:Destroy()
			end
			
			if char.Boosts:FindFirstChild("SpeedBoost") then
				char.Boosts.SpeedBoost:Destroy()
			end]]
			
			bal.PointLight.Enabled = false
			wait(1.5)
		
			w:Destroy()
			bal:Destroy()
		end)
	elseif castSuccess == 1 then	
		local h = Instance.new("Accessory")
		h.Name = "CamFlip"
		h.Parent = char
		local f = script.Parent.LocalScript:Clone()
		f.Name = "ConfuseScript"
		f.Parent = char
		f.Disabled = false
		
		local anim = char.Humanoid:LoadAnimation(script.Confused)
		anim:Play()
		anim:AdjustSpeed(.35)
		
	
		local r = game.ReplicatedStorage.Assets.HandHoldIllusion2.Hit:Clone()
		r.Parent = char.Head
		r:Play()
		
		sub(function()
			wait(15)
	
			r:Destroy()
			h:Destroy()
		
			anim:Stop()
		end)
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
	
	local play = game.Players:GetPlayerFromCharacter(char)
	if not play.Backpack:FindFirstChild("IllusionMastery") then return end
	
	local mana = char.Mana
	
	local playerFolder = play and game.ServerStorage.PlayerData:FindFirstChild(play.Name)
	local manacolor = playerFolder and playerFolder.ManaColor.Value
	
	local HRP = manacolor and char:FindFirstChild("HumanoidRootPart")
	if not HRP then return end
	
	if castSuccess == 0 then
		sub(function()
			char.HumanoidRootPart.PerfectCast:Play()
			local anim = char.Humanoid:LoadAnimation(script.Snap)
			anim:Play()
			wait(.2)
			
			local bal = game.ReplicatedStorage.Assets.HandHoldIllusion2:Clone()
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
			
			hitDetection.aoeCombatTag(char,char.Torso.Position,30) -- COMBAT TAG THE VICTIMS
			for i,v in pairs(game.Workspace.Live:GetChildren()) do
				if (v.Torso.Position-char.HumanoidRootPart.Position).Magnitude <= 25 and v~= char and not v:FindFirstChild("ConfuseScript") and game.ServerStorage.PlayerData:FindFirstChild(v.Name) and game.ServerStorage.PlayerData[v.Name].Data.Race.Value ~= "Lich" and game.ServerStorage.PlayerData[v.Name].Data.Race.Value ~= "Dzin" and not game.Players[v.Name].Backpack:FindFirstChild("MentalBlock") then
					local eplayfolder = game.ServerStorage.PlayerData[v.Name]
					if (eplayfolder.LastName.Value == "" or (eplayfolder.LastName.Value ~= playerFolder.LastName.Value)) then
						
						
						local h = Instance.new("Accessory")
						h.Name = "CamFlip"
						h.Parent = v
						local f = script.Parent.LocalScript:Clone()
						f.Name = "ConfuseScript"
						f.Parent = v
						f.Disabled = false
						
						local anim = v.Humanoid:LoadAnimation(script.Confused)
						anim:Play()
						anim:AdjustSpeed(.35)
						
					
						local r = game.ReplicatedStorage.Assets.HandHoldIllusion2.Hit:Clone()
						r.Parent = v.Head
						r:Play()
						
						sub(function()
							wait(15)
							bal:Destroy()
							h:Destroy()
							r:Destroy()
							anim:Stop()
						end)
						
					end
				end
			end
		end)
	else
		if char:FindFirstChild("ConfuseScript") then return end
	
		local f = script.Parent.LocalScript:Clone()
		f.Name = "ConfuseScript"
		f.Parent = char
		f.Disabled = false
		local anim = char.Humanoid:LoadAnimation(script.Confused)
		anim:Play()
		anim:AdjustSpeed(.35)
		
		
		local h = Instance.new("Accessory")
		h.Name = "CamFlip"
		h.Parent = char
	
		local r = game.ReplicatedStorage.Assets.HandHoldIllusion2.Hit:Clone()
		r.Parent = char.Head
		r:Play()
		
		sub(function()
			wait(15)
			r:Destroy()
	
			h:Destroy()
			anim:Stop()
		end)
	end
end

spell.alternate = spell2
return spell