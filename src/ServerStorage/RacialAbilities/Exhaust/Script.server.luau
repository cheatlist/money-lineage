function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local u3 = require(game.ServerScriptService.Modules.HitDetection)
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
	if Parent:FindFirstChild("Action") and not Parent:FindFirstChild("Planted") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
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
local canuse = true
local TagHumanoid = game.ServerStorage.Requests.TagHumanoid
local CollectionService = game.CollectionService
script.Parent.Activated:Connect(function()
	local Character = script.Parent.Parent --p1
	
	if not canuse then
		return
	end
	local Player = game.Players:GetPlayerFromCharacter(Character) --p2

	local data = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
	
	local info = {
		physical = true,
		fist = true,
		knockback = true,
		manaknockupself = true, 
		bypassblock = true,
		ignoreblock = true,
		damage = 10,
		downbypass = true,
		burn = true,
		injury = "heat",
		aoe = true,
		exhaust = true,
		mana = true
	}
	
	if CollectionService:HasTag(Character,"Decomposing") then
		canuse = false
		task.delay(20, function()
			canuse = true
		end)
		local SpraySound = script.SprayS:Clone()
		local SprayPart = script.SprayP:Clone()
		SprayPart.Parent = Character:WaitForChild("Head")
		SprayPart.Enabled = true
		SpraySound.Parent = Character:WaitForChild("HumanoidRootPart")
		SpraySound:Play()
		task.wait(0.6)
		u3.magnitudeCheck(Character,Character.HumanoidRootPart.Position,13,info)
		task.wait(1.35-0.6)
		--game.Debris:AddItem(Action,.8)
		SpraySound:Destroy()
		SprayPart.Enabled = false
		task.wait(.7)
		SprayPart:Destroy()
	end	
	
end)