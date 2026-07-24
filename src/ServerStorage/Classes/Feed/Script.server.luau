local dangerHandler = require(game.ServerScriptService.Modules.DangerHandler)

function ray(startpos, endpos, dis, partt)
	local test = Ray.new(startpos, CFrame.new(startpos,endpos).LookVector * dis) 
	local  hit,pos,sf = game.Workspace:FindPartOnRay(test,partt)		
	return hit,pos,sf
end

function sub(...)
	coroutine.wrap(...)()
end

local physicsService = game:GetService("PhysicsService")

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	local char = script.Parent.Parent
	return ActionCheckModule(char, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Stun","ReturnStun","ActiveCast","Action","Blocking","SpellBlocking","Climbing"},
		presentTagBlocks = {"Knocked"},
		healthAtOrBelow = 0,
	})
end

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local en = false
script.Parent.Activated:Connect(function()
	if ActionCheck() then return end
	local char = script.Parent.Parent
	local play = game.Players:GetPlayerFromCharacter(char)
	local playerFolder = game.ServerStorage.PlayerData:FindFirstChild(char.Name)
	local root = char.HumanoidRootPart
	local hum = char.Humanoid

	if char:FindFirstChild("Executing") then return end
	if ActionCheck() then return end
	for g,j in pairs(game.Workspace.Live:GetChildren()) do
		if j:FindFirstChild("Grabbed") then return end
		if j:FindFirstChild("Knocked") and j:FindFirstChild("Unconscious") and not game.CollectionService:HasTag(j,"Vampirism") and j.Stomach.Value > 0 then
			local dist = (root.Position-j.HumanoidRootPart.Position).magnitude
			if dist <= 5 then
				local root = root
				local eroot = j.HumanoidRootPart
				local cTorso = char.Torso
				local eTorso = j.Torso
				local h,p,sf = ray(j.HumanoidRootPart.Position,j.HumanoidRootPart.Position-Vector3.new(0,3,0),10,game.Workspace.Live)
				if h then
					local k = Instance.new("Accessory")
					k.Name = "Executing"
					k.Parent = char
					game.ServerStorage.Debris:Fire(k,6)

					game.CollectionService:AddTag(j,"BeingExecuted")

					game.ServerStorage.Requests.Wakeup:Fire(j,true)

					local pos = p+(sf*3)

					local diff = (pos-root.Position).unit
					local yang = math.atan2(diff.z,diff.x)

					hum.AutoRotate = false
					sub(function()
						wait(.35)
						j.Humanoid.AutoRotate = false	
					end)

					eroot.Anchored = true


					local eDanger = dangerHandler:getEntity(j)
					if eDanger then
						eDanger:createTag(play.Name..":Drain",{damage=math.huge})
					end

					eroot.CFrame = CFrame.new(pos)*CFrame.Angles(0,-yang+math.rad(90),0)
					root.CFrame = eroot.CFrame*CFrame.new(0,0,-.5)*CFrame.Angles(0,math.rad(180),0)

					local bp = Instance.new("BodyPosition")
					game.CollectionService:AddTag(bp,"AllowedBM")
					bp.Parent = root
					bp.Name = "ExecuteBP"
					bp.MaxForce = Vector3.new(9e9,9e9,9e9)
					bp.Position = root.Position
					game.ServerStorage.Debris:Fire(bp,7)

					local bg = Instance.new("BodyGyro")
					game.CollectionService:AddTag(bg,"AllowedBM")
					bg.Parent = root
					bg.Name = "ExecuteBG"
					bg.MaxTorque = Vector3.new(5e6,5e6,5e6)
					bg.CFrame = root.CFrame
					game.ServerStorage.Debris:Fire(bg,7)

					local bp2 = bp:clone()
					bp2.Parent = eroot
					bp2.Position = eroot.Position
					game.ServerStorage.Debris:Fire(bp2,7)

					local bg2 = bg:clone()
					bg2.Parent = eroot
					bg2.CFrame = eroot.CFrame
					game.ServerStorage.Debris:Fire(bg2,7)

					local f = Instance.new("Accessory")
					f.Name = "Action"
					f.Parent = char
					local e = Instance.new("Accessory")
					e.Name = "Action"
					e.Parent = j


					local executeanim
					if script:FindFirstChild("Drain") then
						executeanim = hum:LoadAnimation(script.Drain)
						executeanim:Play(0.1)
					end

					local deadanim
					if script:FindFirstChild("DEAD") then
						deadanim = j.Humanoid:LoadAnimation(script.DEAD)
						deadanim:Play()
					end

					local timz = tick()
					local didexecute = true
					local injuretime = 10

					en = true


					local enemyFolder = game.ServerStorage.PlayerData:FindFirstChild(j.Name)
					local enemyRace = enemyFolder.Race.Value

					if enemyRace == "Seraph" or enemyRace == "Phoenix" then
						tagHumanoid:Fire(j,char,{mana=true,whitemanaburn=true,damage=70})	
						local f = Instance.new("Accessory")
						f.Name = "Stun"
						f.Parent = char
						game.ServerStorage.Debris:Fire(f,1.2)
					elseif enemyFolder.Artifact.Value == "PhoenixFeather" then
						tagHumanoid:Fire(j,char,{mana=true,burn=true,damage=5})	
						local f = Instance.new("Accessory")
						f.Name = "Stun"
						f.Parent = char
						game.ServerStorage.Debris:Fire(f,1.2)
					elseif enemyRace == "Scroom" then
						tagHumanoid:Fire(j,char,{mana=true,poison=true,damage=10})	
						local f = Instance.new("Accessory")
						f.Name = "Stun"
						f.Parent = char
						game.ServerStorage.Debris:Fire(f,1.2)
					elseif enemyRace == "Gaian" or enemyRace == "Lich" or enemyRace == "Metascroom" or enemyRace == "Dullahan" then
						tagHumanoid:Fire(j,char,{mana=true,damage=2})	
						local f = Instance.new("Accessory")
						f.Name = "Stun"
						f.Parent = char
						game.ServerStorage.Debris:Fire(f,1.2)
					end


					repeat 
						wait(.5)


						root.PotionPour:Play()
						char.Stomach.Value = char.Stomach.Value + 4

						j.Stomach.Value = j.Stomach.Value - 4
						if not j.Head:FindFirstChild("BloodHit") then
							j.HumanoidRootPart.BloodHit:Clone().Parent = j.Head
						elseif j.Head:FindFirstChild("BloodHit") then
							j.Head.BloodHit:Emit(10)
						end

						if j.Stomach.Value <= 0 then break end

						if hum.Health <= 0 or char:FindFirstChild("Stun") or game.CollectionService:HasTag(char,"Knocked") or game.CollectionService:HasTag(char,"Unconscious") or char:FindFirstChild("EndDrain") then
							didexecute = false
							break
						end
					until tick()-timz >= injuretime or not j.Parent


					if executeanim ~= nil then
						executeanim:Stop(0.3)
					end
					if deadanim ~= nil then
						deadanim:Stop()
					end
					f:Destroy()
					e:Destroy()

					k:Destroy()
					game.CollectionService:RemoveTag(j,"BeingExecuted")

					hum.AutoRotate = true
					j.Humanoid.AutoRotate = true

					bp:Destroy()
					bg:Destroy()
					bp2:Destroy()
					bg2:Destroy()
					eroot.Anchored = false

					if didexecute == true then
						local canHeal = {"brokenrib","brokenleg","brokenarm","cataract","blackeye","burn","chestgash","blind"}



						local injTab = game.HttpService:JSONDecode(playerFolder.Injuries.Value)
						local RNG = Random.new()

						for i = 1,#canHeal do
							local pick = canHeal[RNG:NextInteger(1,#canHeal)]
							if injTab[pick] then
								injTab[pick] = nil
								break
							end
						end

						playerFolder.Injuries.Value = game.HttpService:JSONEncode(injTab)


						local jplay = game.Players:GetPlayerFromCharacter(j)
						local jFolder = jplay and game.ServerStorage.PlayerData:FindFirstChild(jplay.Name)
						if jFolder then
							if jFolder.Lives.Value <= 1 then
								game.ServerStorage.Requests.Injure:Invoke(jplay,"vampirism",true)
							end

							if playerFolder.Alignment.Value > -3 then
								playerFolder.Alignment.Value = playerFolder.Alignment.Value - 10
							end
						end
					end

					playerFolder.Feeds.Value += 1

					eDanger:removeTag(play.Name..":Drain")
					
					if game:GetService("CollectionService"):HasTag(j, "BeingExecuted") then
						game:GetService("CollectionService"):RemoveTag(j, "BeingExecuted")
					end

					local Unconscious = Instance.new("Accessory")
					Unconscious.Name = "Unconscious"
					Unconscious.Parent = j
					game.Debris:AddItem(Unconscious, 10)

					local Knocked = Instance.new("Accessory")
					Knocked.Name = "Knocked"
					Knocked.Parent = j
					game.Debris:AddItem(Knocked, 10)
					return
				end
			end
		end
	end
end)