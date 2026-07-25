--// extreme#3007

local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local serverScriptService = game:GetService("ServerScriptService")
local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")
local debris = game:GetService("Debris")
local workspace = game:GetService("Workspace")

local thrown = workspace:WaitForChild("Thrown")
local assets = replicatedStorage:WaitForChild("Assets")
local serverStoragePlayerData = serverStorage:WaitForChild("PlayerData")
local serverStorageRequests = serverStorage:WaitForChild("Requests")
local tagHumanoid = serverStorageRequests:WaitForChild("TagHumanoid")

local noTempLoss = {"DevZse", "extremescoolgnav"}

local module = {}

function removeTag(instance, tag)
	if collectionService:HasTag(instance, tag) then
		collectionService:RemoveTag(instance, tag)
	end
end

function clearTable(table)
	for i, v in pairs(table) do
		table.remove(table, i)
	end
end

function module.changeTemperature(character, max, add)
	local temperature = character:FindFirstChild("Temperature")
	local player = players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local playerData = serverStoragePlayerData:FindFirstChild(player.Name)
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	local humanoidrootpart = character:FindFirstChild("HumanoidRootPart")
	
	if not (playerData or temperature) or playerData.Race.Value == "Lich" or table.find(noTempLoss, player.Name) or (playerData.Ascended.Value == true and playerData.Race.Value == "Rigan") or character:FindFirstChildWhichIsA("ForceField") or not humanoid or not humanoidrootpart then
		return
	end
	
	local defaultParticle = "Sweat"
	local particleTable = {}
	
	if temperature.Value <= -0.25 and not collectionService:HasTag(character, "noCold") then
		collectionService:AddTag(character, "noCold")
		task.delay(5, removeTag, character, "noCold")
		
		local coldBreath = assets.ColdBreath:Clone()
		task.delay(0.15, function()
			coldBreath.Enabled = false
		end)
		coldBreath.Parent = character.Head.FaceFrontAttachment
		coldBreath.Enabled = true
		debris:AddItem(coldBreath, coldBreath.Lifetime.Max)
	end
	
	if temperature.Value >= 0.25 and not collectionService:HasTag(character, "sweating") then
		collectionService:AddTag(character, "sweating")
		task.delay(5, removeTag, character, "sweating")
		
		clearTable(particleTable)
		if playerData.Race == "Gaian" then
			defaultParticle = "STEAM"
			table.insert(particleTable, "Right Arm")
			table.insert(particleTable, "Left Arm")
		else
			table.insert(particleTable, "Head")
		end
		
		for _, v in pairs(character:GetChildren()) do
			if table.find(particleTable, v.Name) then
				local particle = assets[defaultParticle]:Clone()
				particle.Parent = v
				particle.Enabled = true
				debris:AddItem(particle, 5)
			end
		end
	end
	
	if max > 0 then
		if temperature.Value < max then
			if temperature.Value + add > max then
				temperature.Value = max
			else
				temperature.Value += add
			end
		elseif temperature.Value > max and temperature.Value < 1 then
			if temperature.Value - add < max then
				temperature.Value = max
			else
				temperature.Value -= add
			end
		end
	elseif max < 0 then
		if temperature.Value > max then
			temperature.Value -= add
		end
	elseif max == 0 then
		if temperature.Value < 0 then
			temperature.Value += add
		else
			temperature.Value -= add
		end
	end
	
	if temperature.Value >= 1 then
		
		if not string.find(string.lower(playerData.Injuries.Value), "heat") then
			temperature.Value = 0.75
			playerData.Injuries.Value..=",heat"
			humanoidrootpart.Injure:Emit(2)
			humanoidrootpart.Injury:Play()
		else
			local danger = Instance.new("Folder")
			danger.Name = "Danger"
			danger.Parent = player
			debris:AddItem(danger, 60)
			
			tagHumanoid:Fire(character, character, {burn = true, nododge = true, downbypass = true})
		end
		
	elseif temperature.Value <= -1 then
		
		if not string.find(string.lower(playerData.Injuries.Value), "frostbite") then
			temperature.Value = -0.75
			playerData.Injuries.Value..=",Frostbite"
			humanoidrootpart.Injure:Emit(2)
			humanoidrootpart.Injury:Play()
		elseif not character:FindFirstChild("Grabbed") then
			local danger = Instance.new("Folder")
			danger.Name = "Danger"
			danger.Parent = player
			debris:AddItem(danger, 30)

			if character:FindFirstChild("Knocked") or character:FindFirstChild("Unconscious") or character:FindFirstChild("NoStun") then
				return
			end
			humanoid.Health -= humanoid.MaxHealth*0.02
			if humanoid.Health <= 5 then
				local frozenCharacter = Instance.new("Model")
				frozenCharacter.Name = "Frozen" .. character.Name
				frozenCharacter.Parent = thrown
				debris:AddItem(frozenCharacter, 60)
				
				for _, v in pairs(character:GetChildren()) do
					if v:IsA("BasePart") then
						local clone = v:Clone()
						clone.Anchored = true
						clone.CanCollide = true
						clone.Material = Enum.Material.Ice
						clone.Color = Color3.fromRGB(159, 173, 192)
						clone.Parent = frozenCharacter
						v.Transparency = 1
						v.CanCollide = false
					elseif v:IsA("Decal") then
						v:Destroy()
					end
				end
				
				_G.Death(player)
			end
		end
	end
end

return module