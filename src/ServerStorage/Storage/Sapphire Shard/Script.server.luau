local collectionservice = game:GetService("CollectionService")
local serverstorage = game:GetService("ServerStorage")
local serverscriptservice = game:GetService("ServerScriptService")
local assets = serverstorage:WaitForChild("Assets")
local requests = serverstorage:WaitForChild("Requests")
local hitdetection = require(serverscriptservice.Modules.HitDetection)

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

script.Parent.Activated:Connect(function()
	local char = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(char)
	local humanoid = char:FindFirstChild("Humanoid")
	local humrp = char:FindFirstChild("HumanoidRootPart")
	if ActionCheck(char) then
		return
	end
	if not humanoid then
		return
	end
	if not humrp then
		return
	end
	if (not player.Backpack:FindFirstChild("Shardcaster")) then
		return
	end
	if char:FindFirstChild("Shardcasted") then
		return
	end
	local cd = Instance.new("Accessory")
	cd.Name = "Shardcasted"
	cd.Parent = char
	game:GetService("Debris"):AddItem(cd,15)
	local handlecframe = script.Parent.Handle.CFrame
	local clonedhandle = script.Parent.Handle:Clone()
	clonedhandle.Anchored = true
	game:GetService("Debris"):AddItem(clonedhandle,2)
	humanoid:UnequipTools()
	clonedhandle.Parent = game.Workspace.Thrown
	local shardsparticle = assets.ShardParticle:Clone()
	shardsparticle.Parent = clonedhandle
	shardsparticle.Color = ColorSequence.new(Color3.fromRGB(16,42,219))
	local shardsound = assets.ShardSound:Clone()
	shardsound.Parent = clonedhandle
	shardsound:Play()
	local humpos = humrp.Position
	task.wait(0.75)
	game:GetService("TweenService"):Create(clonedhandle,TweenInfo.new(.75),{Transparency = 1}):Play()
	task.wait(0.5)
	shardsparticle.Enabled = false
	local snowflake = assets.Snowflake:Clone()
	snowflake.Parent = game.Workspace.Thrown
	snowflake.Position = humpos
	snowflake.Sound:Play()
	game:GetService("Debris"):AddItem(snowflake,1)
	game:GetService("TweenService"):Create(snowflake,TweenInfo.new(0.5),{Size = Vector3.new(1.5,60,60),Transparency = 1}):Play()
	hitdetection.magnitudeCheck(char,snowflake.Position,35,{
		damage = 12,
		blacksmithfreeze = true,
		aoe = true,
		noenchant = true,
	},false,true)
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(player, script.Parent.Name)
end)