local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Requests = ReplicatedStorage:WaitForChild("Requests")
local TagHumanoid = ServerStorage:WaitForChild("Requests"):WaitForChild("TagHumanoid")
local Modules = ServerScriptService:WaitForChild("Modules")
local Create = require(Modules:WaitForChild("Create"))
local TerminationModule = require(game.ServerScriptService.Modules.TerminationModule)

--[[
for i,v in pairs(workspace:GetChildren()) do
	if v.Name == "TERRABORDER" then
		PhysicsService:SetPartCollisionGroup(v,"TERRA_BORDER")
	end
end
--]]

local function create(name,deletetime,parent)
	if (name == "Knocked" or name == "Unconscious") and (parent:FindFirstChild("WakingUp") or game.CollectionService:HasTag(parent, "GettingUp")) then
		return
	end
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	if (name == "Knocked" and game.Players:FindFirstChild(parent.Name)) and game.ServerStorage.PlayerData[parent.Name].Injuries.Value:find("BrokenRib") then
		if deletetime then
			game.Debris:AddItem(i, deletetime * 1.25)
		end
		for i,v in pairs(parent:GetChildren()) do
			if v.Name == "Knocked" then
				if deletetime then
					game.Debris:AddItem(v, deletetime * 1.25)
				end
			end
		end
	elseif name == "Knocked" then
		if deletetime then
			game.Debris:AddItem(i, deletetime)
		end
		for i,v in pairs(parent:GetChildren()) do
			if v.Name == "Knocked" then
				if deletetime then
					game.Debris:AddItem(v, deletetime)
				end
			end
		end
	else
		if deletetime then
			game.Debris:AddItem(i, deletetime)
		end
	end
	return i
end

local function GetSurface(position,object)
	local surfaces = {
		back = object.CFrame * CFrame.new(0, 0, object.Size.Z);
		front = object.CFrame * CFrame.new(0, 0, -object.Size.Z);
		top = object.CFrame * CFrame.new(0, object.Size.Y, 0);
		bottom = object.CFrame * CFrame.new(0, -object.Size.Y, 0);
		right = object.CFrame * CFrame.new(object.Size.X, 0, 0);
		left = object.CFrame * CFrame.new(-object.Size.X, 0, 0);
	}
	local surface = "back"
	for side, cframe in pairs (surfaces) do
		surface = ((position - cframe.Position).Magnitude > (position - surfaces[surface].Position).Magnitude and surface or side)
	end
	return surface
end

local function StartBurn(Part)
	if not Part:IsA("BasePart") then
		return
	end
	local Character = Part.Parent
	if not Character then
		return
	end
	if string.find(string.lower(tostring(Character)),"terra serpent") then
		return
	end
	task.spawn(function()
		if not Character:FindFirstChild("BurnTouchCD") then
			local CD = Instance.new("Accessory")
			CD.Name = "BurnTouchCD"
			CD.Parent = Character
			game:GetService("Debris"):AddItem(CD,0.5)
			if Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
				TagHumanoid:Fire(Character,Character,{burn = true,nododge = true,downbypass = true})
			end
		end
	end)
end

local function FireKill(Part,Color,DoesKill)
	if not Part:IsA("BasePart") then
		return
	end
	local Character = Part.Parent
	if not Character then
		return
	end
	if not DoesKill then
		return
	end
	if string.find(string.lower(tostring(Character)),"terra serpent") then
		return
	end
	if not Character:FindFirstChild("KillFireTouchCD") then
		local CD = Instance.new("Accessory")
		CD.Name = "KillFireTouchCD"
		CD.Parent = Character
		game:GetService("Debris"):AddItem(CD,1)
		local Hum = Character:FindFirstChild("Humanoid")
		if Hum and Hum.Health > 0 and not(Character:FindFirstChild("KillFire"))then
			local Info = {burn = true,nododge = true,downbypass = true}
			if Color then
				Info.burncolor = Color
			end
			TagHumanoid:Fire(Character,Character,Info)
			Create("Knocked",nil,Character)
			Create("Danger",nil,Character)
			Create("KillFire",nil,Character)
			task.delay(2, function()
				if Hum.Health > 0 then
					_G.Death(Character)
				end
			end)
		end
	end
end
local function PoisonBrick(Part)
	local Character = Part.Parent:FindFirstChild("HumanoidRootPart") and Part.Parent or Part.Parent.Parent:FindFirstChild("HumanoidRootPart") and Part.Parent.Parent 
	if not Character then
		return
	end
	if Character:FindFirstChild("MonsterInfo") then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(Character.Name)
	if not data then
		return
	end
	if Character:FindFirstChild("PoisonPitCD") then
		return
	end
	TagHumanoid:Fire(Character, Character, {poison = true, nohitanim = true, nododge = true})
	Create("PoisonPitCD", 0.05, Character)
end
local function KillLava(Part)
	if not Part:IsA("BasePart") then
		return
	end
	local Character = Part.Parent
	if not Character then
		return
	end
	if string.find(string.lower(tostring(Character)),"terra serpent") then
		return
	end
	if string.find(string.lower(Part.Name), 'handhold') then
		return
	end
	task.spawn(function()
		if not Character:FindFirstChild("KillLavaTouchCD") then
			local CD = Instance.new("Accessory")
			CD.Name = "KillLavaTouchCD"
			CD.Parent = Character
			game:GetService("Debris"):AddItem(CD,1)
			if Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 and not Character:FindFirstChild("Dead") then
				if Character.Humanoid.Health > 0 then
					_G.Death(Character)
					Create("Dead",nil,Character)
					for i,v in pairs(Character:GetChildren()) do
						if v:IsA("Clothing") then
							v:Destroy()
						end
						if v:IsA("BasePart") then
							v.Material = Enum.Material.Slate
							game:GetService("TweenService"):Create(v,TweenInfo.new(3),{Size = Vector3.new(0,0,0)}):Play()
						end
					end
				end
			end
		end
	end)
end

local function KillBrick(Part)
	if not Part:IsA("BasePart") then
		return
	end
	local Character = Part.Parent
	if not Character then
		return
	end
	task.spawn(function()
		if not Character:FindFirstChild("KillBrickTouchCD") then
			local CD = Instance.new("Accessory")
			CD.Name = "KillBrickTouchCD"
			CD.Parent = Character
			game:GetService("Debris"):AddItem(CD,1)
			if Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 and not Character:FindFirstChild("Dead") then
				if Character.Humanoid.Health > 0 then
					_G.Death(Character)
					Create("Dead",nil,Character)
				end
			end
		end
	end)
end

for i,v in pairs(workspace.Map:GetChildren()) do
	if v.Name == "OrderField" then
		v.Touched:Connect(function(Part)
			local Character = Part.Parent
			if not Character then
				return
			end
			if Part.Parent:FindFirstChild("Humanoid") and Part.Parent:FindFirstChild("HumanoidRootPart") then
				task.spawn(function()
					local PlayerData = ServerStorage:WaitForChild("PlayerData"):FindFirstChild(Character.Name)
					if not PlayerData then
						return
					end
					local Alignment = PlayerData.Alignment.Value
					if GetSurface(Character.HumanoidRootPart.Position,v) == "back" then
						Alignment = 10
						for i,v in pairs(Character:GetChildren()) do
							if v:IsA("BasePart") then
								PhysicsService:SetPartCollisionGroup(v, "WeDontCollide")
							end
						end
					end
					if Alignment >= 1 then
						if Character:FindFirstChild("NoPass") then
							return
						else
							local NoPassField = Instance.new("Accessory")
							NoPassField.Name = "NoPass"
							NoPassField.Parent = Character
							game:GetService("Debris"):AddItem(NoPassField,1)
							Character.HumanoidRootPart.MoneyEmit:Emit(15)
							Character.HumanoidRootPart.Ordersound:Play()
							return
						end
					end
					if Character:FindFirstChild("NoPass") or Character:FindFirstChild("Grabbed") then
						return
					end
					if PlayerData.Alignment.Value < 0 then
						for i,v in pairs(Character:GetChildren()) do
							if v:IsA("BasePart") then
								PhysicsService:SetPartCollisionGroup(v, "PlayersThatCollide")
							end
						end
					else
						for i,v in pairs(Character:GetChildren()) do
							if v:IsA("BasePart") then
								PhysicsService:SetPartCollisionGroup(v, "WeDontCollide")
							end
						end
					end
					local NoPassField = Instance.new("Accessory")
					NoPassField.Name = "NoPass"
					NoPassField.Parent = Character
					game:GetService("Debris"):AddItem(NoPassField,1)
					Character.HumanoidRootPart.SLAMJAM:Play()
					Character.HumanoidRootPart.MoneyEmit:Emit(15)

					TagHumanoid:Fire(Character,Character,{
						mana = true, 
						manaknockupself = true, 
						damage = 5, 
						noblock = true
					})
				end)

			end
		end)
	end
end

for i,v in pairs(workspace.Map:GetChildren())do
	if v.Name == "Fire" then
		v.Touched:Connect(StartBurn)
	elseif v.Name == "KillBrick" then
		v.Touched:Connect(KillBrick)
	elseif v.Name == "PitKillBrick" then
		v.Touched:Connect(function(Part)
			if Part and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
				local Character = Part.Parent
				local Player = game.Players:GetPlayerFromCharacter(Character)
				if Character and Player then
					if ServerStorage.PlayerData[Player.Name].Skills.Value:find("ArdorCalls") then
						local TPSafe = Instance.new("Vector3Value")
						TPSafe.Name = "TPSafe"
						TPSafe.Value = game.ServerStorage.ABYSSTP.CFrame.Position
						TPSafe.Parent = Character
						game:GetService("Debris"):AddItem(TPSafe,1)
						Character:SetPrimaryPartCFrame(game.ServerStorage.ABYSSTP.CFrame)
					else
						KillBrick(Part)
					end
				end
			end
		end)
	elseif v.Name == "ArdorianKillbrick" then
		v.Touched:Connect(function(Part)
			if Part and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
				local Character = Part.Parent
				local Player = game.Players:GetPlayerFromCharacter(Character)
				if Character and Player then
					if not ServerStorage.PlayerData[Player.Name].Skills.Value:find("ArdorCalls") then
						KillBrick(Part)
					end
				end
			end
		end)
	elseif v.Name:find("Lava") then
		v.Touched:Connect(KillLava)
	elseif v.Name:find("AscensionTP") then
		v.Touched:Connect(function(Part)
			if Part and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
				local HS = game:GetService("HttpService")
				local data = game.ServerStorage.PlayerData:FindFirstChild(Part.Parent.Name) or nil
				local StoryMarker = HS:JSONDecode(data.StoryMarker.Value)
				if data and (data.IsUltra.Value == true or data.Hybrid.Value ~= "") then
					if not Part.Parent:FindFirstChild("NoMirror") then
						if not StoryMarker["Ascension"] or (StoryMarker["Ascension"] and not StoryMarker["Ascension"]["NoAs'endo"] == true) then
							local TPSafe = Instance.new("StringValue")
							TPSafe.Name = "TPSafe"
							TPSafe.Value = ""
							TPSafe.Parent = Part.Parent
							game.Debris:AddItem(TPSafe,1.5)
							Part.Parent.HumanoidRootPart.CFrame = workspace.AscensionTPBrick.CFrame
							local CD = Instance.new("Accessory")
							CD.Name = "NoMirror"
							CD.Parent = Part.Parent
							game:GetService("Debris"):AddItem(CD,1)
						else
							KillLava(Part)
						end
					end
				else
					KillLava(Part)
				end
			end
		end)
	elseif v.Name == "KillFire" then
		v.Touched:Connect(function(Part)
			if Part and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
				if v:FindFirstChild("FireColor") then
					create("Knocked", 3, Part.Parent)
					FireKill(Part,v.FireColor.Value,true)
				elseif v.Color == Color3.fromRGB(163, 162, 165) then
					local PlayerData = ServerStorage:WaitForChild("PlayerData"):FindFirstChild(Part.Parent.Name)
					if PlayerData then
						if PlayerData.Race.Value == "Seraph" then
							create("Knocked", 3, Part.Parent)
							FireKill(Part,nil,false)
						else
							create("Knocked", 3, Part.Parent)
							FireKill(Part,nil,true)
						end
					end
				else
					create("Knocked", 3, Part.Parent)
					FireKill(Part,nil,true)
				end
			end
		end)
	elseif v.Name == "SpectralFire" then
		v.Touched:Connect(function(Part)
			create("Knocked", 3, Part.Parent)
			FireKill(Part,(Color3.fromRGB(255,255,255)))
		end)
	elseif v.Name == "PoisonField" then
		v.Touched:Connect(function(Part)
			PoisonBrick(Part)
		end)
	elseif v.Name == "KillFireHealing" then
		v.Touched:Connect(function(Part)
			if Part and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
				if v:FindFirstChild("FireColor") then
					create("Knocked", 3, Part.Parent)
					FireKill(Part,v.FireColor.Value,true)
				elseif v.Color == Color3.fromRGB(163, 162, 165) then
					local PlayerData = ServerStorage:WaitForChild("PlayerData"):FindFirstChild(Part.Parent.Name)
					if PlayerData then
						if PlayerData.Race.Value == "Seraph" then
							create("Knocked", 3, Part.Parent)
							FireKill(Part,nil,false)
						else
							local StoryMarker = game:GetService("HttpService"):JSONDecode(PlayerData.StoryMarker.Value)
							if StoryMarker["StartedHealer"] == "Cleansing" then
								local StoryMarker = game:GetService("HttpService"):JSONDecode(PlayerData.StoryMarker.Value)
								StoryMarker["StartedHealer"] = "CompletedHealerEdict"
								PlayerData.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
								game.ServerStorage.Requests.SendWebhook:Fire(
									"Edict Obtainment",
									Part.Parent.Name.." has obtained the Healer Edict",
									"cyan",
									"edictfak"
								)
							end
							create("Knocked", 3, Part.Parent)
							FireKill(Part,nil,true)
						end
					end
				else
					create("Knocked", 3, Part.Parent)
					FireKill(Part,nil,true)
				end
			end
		end)
	end
end

for i,x in pairs(workspace.Seats:GetChildren())do
	if x.Name == "MirrorPair"then
		for i,v in pairs(x:GetChildren()) do
			if v.Name == "Mirror" then
				if v:FindFirstChild("In") then
					v.In.Touched:Connect(function(Part)
						task.spawn(function()
							if Part.Parent:FindFirstChild("Humanoid") and Part.Parent:FindFirstChild("HumanoidRootPart") and not Part.Parent:FindFirstChild("NoMirror") and not Part.Parent:FindFirstChild("Grabbing") then
								local CD = Instance.new("Accessory")
								CD.Name = "NoMirror"
								CD.Parent = Part.Parent
								game:GetService("Debris"):AddItem(CD,4)
								local Player = game.Players:GetPlayerFromCharacter(Part.Parent)
								if Player.Backpack:FindFirstChild("WraithTraining") then
									local TPSafe = Instance.new("Vector3Value")
									TPSafe.Name = "TPSafe"
									TPSafe.Value = v.Parent:FindFirstChild("Out",true).Position
									TPSafe.Parent = Part.Parent
									game.Debris:AddItem(TPSafe,2)
									Part.Parent:PivotTo(v.Parent:FindFirstChild("Out",true).CFrame)
								end
							end
						end)
					end)
				end
				if v:FindFirstChild("Out") then
					v.Out.Touched:Connect(function(Part)
						task.spawn(function()
							if Part.Parent:FindFirstChild("Humanoid") and Part.Parent:FindFirstChild("HumanoidRootPart") and not Part.Parent:FindFirstChild("NoMirror") and not Part.Parent:FindFirstChild("Grabbing") then
								local CD = Instance.new("Accessory")
								CD.Name = "NoMirror"
								CD.Parent = Part.Parent
								game:GetService("Debris"):AddItem(CD,3)
								local Player = game.Players:GetPlayerFromCharacter(Part.Parent)
								if Player.Backpack:FindFirstChild("WraithTraining") then
									local TPSafe = Instance.new("Vector3Value")
									TPSafe.Name = "TPSafe"
									TPSafe.Value = v.Parent:FindFirstChild("In",true).Position
									TPSafe.Parent = Part.Parent
									game.Debris:AddItem(TPSafe,1.5)
									Part.Parent:PivotTo(v.Parent:FindFirstChild("In",true).CFrame)
								end
							end
						end)
					end)
				end

				-- Mirror ClickDetector (2026-07-28): 'You can look at yourself'. If the
				-- looker has the new self-image-misunderstanding injury, ANY injury, or an
				-- existing facial scar marking, looking triggers Termination on themselves
				-- instead of the normal branch below. Otherwise, Black Pill holders get a
				-- temporary Confidence buff from seeing their bigger reflection.
				local MirrorClick = Instance.new("ClickDetector")
				MirrorClick.MaxActivationDistance = 12
				MirrorClick.Parent = v
				MirrorClick.MouseClick:Connect(function(Player)
					local Character = Player.Character
					if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then
						return
					end
					if Character:FindFirstChild("MirrorLookCD") then
						return
					end
					local MLCD = Instance.new("Accessory")
					MLCD.Name = "MirrorLookCD"
					MLCD.Parent = Character
					game.Debris:AddItem(MLCD, 2)
					local Data = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
					if not Data then
						return
					end
					local hasBadSelfImage = Data.Injuries.Value:find("self image misunderstanding") ~= nil
					local hasInjuries = Data.Injuries.Value ~= ""
					local hasScars = Data.FacialMark.Value ~= "None" and Data.FacialMark.Value ~= ""
					if hasBadSelfImage or hasInjuries or hasScars then
						TerminationModule.trigger(Character)
						return
					end
					if Data.Artifact.Value == "Black Pill" and Character:FindFirstChild("Boosts") then
						local confidenceSpeed = Instance.new("NumberValue")
						confidenceSpeed.Name = "SpeedBoost"
						confidenceSpeed.Value = 2
						confidenceSpeed.Parent = Character.Boosts
						game.Debris:AddItem(confidenceSpeed, 300)
						local confidenceAtk = Instance.new("NumberValue")
						confidenceAtk.Name = "AttackSpeedBoost"
						confidenceAtk.Value = 1.1
						confidenceAtk.Parent = Character.Boosts
						game.Debris:AddItem(confidenceAtk, 300)
						local marker = Instance.new("Accessory")
						marker.Name = "Confidence"
						marker.Parent = Character
						game.Debris:AddItem(marker, 300)
					end
				end)
			end
		end
	end
end