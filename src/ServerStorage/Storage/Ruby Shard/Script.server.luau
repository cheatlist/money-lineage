local collectionservice = game:GetService("CollectionService")
local serverstorage = game:GetService("ServerStorage")
local serverscriptservice = game:GetService("ServerScriptService")
local assets = serverstorage:WaitForChild("Assets")
local requests = serverstorage:WaitForChild("Requests")
local hitdetection = require(serverscriptservice.Modules.HitDetection)
local commands = require(game.ServerScriptService.Modules.Commands)
local wait = task.wait
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
function DownVelocity(Fireball, Velo, Character, GroundLevel)
	local toreach = Fireball.Position.Y - 40
	game:GetService("TweenService"):Create(Fireball, TweenInfo.new(1), {
  Position = Vector3.new(Fireball.Position.X,toreach - 10,Fireball.Position.Z)}):Play()
	task.spawn(function()
	while true do
			if Fireball.Position.Y <= GroundLevel + 1 then
				break
		end
	wait(0.1)
		end
		local info = {damage = 15, aoe = true, burn = true, curse = true, downbypass = true, noenchant = true, knockback = true, specialrag = 2, rubyshard = true, mana = true}
		hitdetection.magnitudeCheck(Character, Fireball.Position, 15, info)
		Fireball.Explosion:Emit(80)
		Fireball.Firesound2:Play()
		Fireball.Anchored = true
		end)
end
script.Parent.Activated:Connect(function()
	local char = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(char)
	local humanoid = char:FindFirstChild("Humanoid")
	local humrp = char:FindFirstChild("HumanoidRootPart")
	local Housename: string = player.leaderstats.LastName.Value
	if ActionCheck(char) then
		return
	end
	if not humanoid then
		return
	end
	if not humrp then
		return
	end
	if not player.Backpack:FindFirstChild("Shardcaster") then
		return
	end
	if char:FindFirstChild("Shardcasted") then
		return
	end
	if game.ServerStorage.PlayerData[char.Name].Class.Value ~= "Lapidarist" then
		return
	end
	local cd = Instance.new("Accessory")
	cd.Name = "Shardcasted"
	cd.Parent = char
	game:GetService("Debris"):AddItem(cd,15)
	local handlecframe = script.Parent.Handle.CFrame
	local clonedhandle = script.Parent.Handle:Clone()
	clonedhandle.Anchored = true
	game:GetService("Debris"):AddItem(clonedhandle,1)
	humanoid:UnequipTools()
	clonedhandle.Parent = game.Workspace.Thrown
	local shardsparticle = assets.ShardParticle:Clone()
	shardsparticle.Parent = clonedhandle
	shardsparticle.Color = ColorSequence.new(Color3.fromRGB(151, 0, 0))
	local shardsound = assets.ShardSound:Clone()
	shardsound.Parent = clonedhandle
	shardsound:Play()
	
	wait(1)
	local groundDistanceRay = Ray.new(char.HumanoidRootPart.Position, Vector3.new(0, -500, 0))
	local part, position = workspace:FindPartOnRayWithIgnoreList(groundDistanceRay, {workspace.Live, workspace.Thrown})

	local groundDistance = (char.HumanoidRootPart.Position - position).Magnitude
	local groundy = char.HumanoidRootPart.Position.Y - groundDistance
	local limit = humrp.Position.Y + 40
	local current = humrp.Position

	for i = 1,5 do
		local currentrandom = math.random(1, 4)
		
		for i = 1,4 do
			local fireball = game.ServerStorage.SpellEffects.FireWhip.Fireball:Clone()
	fireball.Size = Vector3.new(4.5,4.5,4.5)
			fireball.Firesound:Play()
			game.Debris:AddItem(fireball, 2)
			fireball.Parent = workspace.Thrown
			if currentrandom == i then
			
		for i,v in pairs(workspace.Live:GetChildren()) do
					if v ~= char and (Housename == "" or  game.Players:GetPlayerFromCharacter(v).leaderstats.LastName.Value ~= Housename)  and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - current).Magnitude <= 50 then
						
						fireball.CFrame = CFrame.new(v.HumanoidRootPart.Position.X, v.HumanoidRootPart.Position.Y + 40, v.HumanoidRootPart.Position.Z)
					
						DownVelocity(fireball, v.HumanoidRootPart.Position.Y + limit, char, groundy)
					else
						
						fireball.CFrame = CFrame.new(current.X + math.random(-50, 50), limit, current.Z + math.random(-50, 50))
						DownVelocity(fireball, limit, char, groundy)
					end
				end
			else
				
				fireball.CFrame = CFrame.new(current.X + math.random(-50, 50), limit, current.Z + math.random(-50, 50))
				DownVelocity(fireball, limit, char, groundy)
			end
		
wait(0.25)
			end
		wait(.5)
	end
	commands.RemoveFromInventory(player, script.Parent.Name)
	end)