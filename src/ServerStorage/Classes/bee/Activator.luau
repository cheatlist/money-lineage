local module = {}
local char = script.Parent.Parent

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local hitDetection = require(game.ServerScriptService.HitDetection)

local function ActionCheck(Parent)
	if Parent:FindFirstChild("EquipWarmup") then
		return true
	end
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
	if Parent.Humanoid.Health<1 then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end

local timer = tick()

local Blocking = false
local on = 1
local combo = 1
local en = true
local Punching = false
local ender = false
local cooler = false
local one = 1

local ts = game:GetService("TweenService")


local Rignorelist = {game.Workspace.Live}

function ray(startpos, endpos, dis, partt)
	local test = Ray.new(startpos, CFrame.new(startpos,endpos).lookVector * dis) 
	--local  hit,pos,sf = game.Workspace:FindPartOnRay(test,partt)   
	local  hit,pos,sf = game.Workspace:FindPartOnRayWithIgnoreList(test,Rignorelist)
	return hit,pos,sf
end

module.Active = function(char,play,currentprop)
	if en == false then return end
	if game.CollectionService:HasTag(char,"Knocked") then return end
	if ActionCheck(char) then return end
	en = false
	local f = Instance.new("Accessory")
	f.Name = "Action"
	f.Parent = char
	char.HumanoidRootPart.SpearEmit:Emit(30)

	game.ServerStorage.Debris:Fire(f,1)
	char.HumanoidRootPart.DragonCrusher:Emit(1)

	local anim = char.Humanoid:LoadAnimation(script.Parent.Anim)
	anim:Play()
	
	anim:GetMarkerReachedSignal("jump"):Connect(function()
		local boost = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(boost,"AllowedBM")
		boost.maxForce = Vector3.new(0, math.huge, 0)
		boost.Velocity = Vector3.new(0, 30, 0)
		boost.Parent = char.HumanoidRootPart
		game.ServerStorage.Debris:Fire(boost,.2)
	end)
	
	anim:GetMarkerReachedSignal("stab"):Connect(function()
		local boost = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(boost,"AllowedBM")
		boost.maxForce = Vector3.new(math.huge, math.huge, math.huge)
		boost.Velocity = char.HumanoidRootPart.CFrame.LookVector * 75 + Vector3.new(0, -40, 0)
		boost.Parent = char.HumanoidRootPart
		game.ServerStorage.Debris:Fire(boost,.1)
		
		char.HumanoidRootPart.SpearSlash:Play()
		
		--[[
		local assets = game.ServerStorage.Assets.Trident

		local dragonwing1 = assets.RightWing:Clone()
		game.ServerStorage.Debris:Fire(dragonwing1,1)
		dragonwing1.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(5,0,1)
		dragonwing1.Transparency = 1
		dragonwing1.Parent = game.Workspace
		local dragonwing2 = assets.LeftWing:Clone()
		game.ServerStorage.Debris:Fire(dragonwing2,1)
		dragonwing2.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(-5,0,1)
		dragonwing2.Transparency = 1
		dragonwing2.Parent = game.Workspace

		dragonwing1.CFrame = dragonwing1.CFrame * CFrame.Angles(math.rad(90), math.rad(180), math.rad(0))
		dragonwing2.CFrame = dragonwing2.CFrame * CFrame.Angles(math.rad(90), math.rad(180), 0)

		local twing = TweenInfo.new(.2,Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tt1 = ts:Create(dragonwing1,twing,{Transparency = .75}):Play()
		local tt2 = ts:Create(dragonwing2,twing,{Transparency = .75}):Play()
		wait(.1)
		local twing = TweenInfo.new(.2,Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tt1 = ts:Create(dragonwing1,twing,{CFrame=dragonwing1.CFrame*CFrame.new(2,2,0)*CFrame.Angles(0,0,-math.rad(45))}):Play()
		local tt2 = ts:Create(dragonwing2,twing,{CFrame=dragonwing2.CFrame*CFrame.new(-2,2,0)*CFrame.Angles(0,0,math.rad(45))}):Play()
		wait(.2)
		local twing = TweenInfo.new(.4,Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tt1 = ts:Create(dragonwing1,twing,{Transparency = 1}):Play()
		local tt2 = ts:Create(dragonwing2,twing,{Transparency = 1}):Play()
		]]


		char.HumanoidRootPart.Swing:Play()
		local root = char.HumanoidRootPart
		local pkt = {physical=true,spear=true,manabreaker=true,slash=true,damage=40,knockback=true,spearcrusher=true}

		if not char:FindFirstChild("Stun") then
			hitDetection.magnitudeCheck(char,root.Position,11,pkt,true)		
		end
	end)

	wait(1)
	en = true
end

return module
