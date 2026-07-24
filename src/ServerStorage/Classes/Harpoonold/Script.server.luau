local tool = script.Parent
local play = script.Parent.Parent.Parent
local char = play.Character

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local hitDetection = require(game.ServerScriptService.Modules.HitDetection)

function sub(...)
	coroutine.wrap(...)()
end

function ActionCheck()
	if not char:FindFirstChild("Humanoid") then
		return true
	end
	if char:FindFirstChild("Charge") then
		return true
	end
	if char:FindFirstChild("Stun") then
		return true
	end
	if char:FindFirstChild("ReturnStun") then
		return true
	end
	if char:FindFirstChild("Action") then
		return true
	end
	if char:FindFirstChild("Blocking") then
		return true
	end
	if char:FindFirstChild("SpellBlocking") then
		return true
	end
	if char:FindFirstChild("ActiveCast") then
		return true
	end
	if game.CollectionService:HasTag(char,"Unconscious") then
		return true
	end
	if game.CollectionService:HasTag(char,"Knocked") then
		return true
	end
	if char:FindFirstChild("Immortal") then 
		return true
	end
end

function ClosestPointOnPart(Part, Point)
	local Transform = Part.CFrame:pointToObjectSpace(Point) -- Transform into local space
	local HalfSize = Part.Size * 0.5
	return Part.CFrame * Vector3.new( -- Clamp & transform into world space
		math.clamp(Transform.x, -HalfSize.x, HalfSize.x),
		math.clamp(Transform.y, -HalfSize.y, HalfSize.y),
		math.clamp(Transform.z, -HalfSize.z, HalfSize.z)
	)
end

local ts = game:GetService("TweenService")
local assets = game.ServerStorage.Assets.Trident
local tridentModule = require(game.ServerScriptService.Modules.TridentModule)

local en = true
local anim = nil
local chargeStart = nil
local attFolder = nil
local thrown = false

local CHARGE_TIME = 0.8
local MIN_DISTANCE = 25
local MAX_DISTANCE = 125
local PROJECTILE_RADIUS = 5
local PROJECTILE_SPEED = 100
local CHARGED_SPEED_BONUS = 50
local DAMAGE_BONUS = 15
local COOLDOWN = 10

char.Humanoid:LoadAnimation(script.Parent.Anim)

tool.Activated:Connect(function()

	if en == false then return end
	if ActionCheck() then return end
	if not tridentModule.wieldTrident(play) then return end

	en = false

	attFolder = Instance.new("Accessory", char)
	attFolder.Name = "HeavyAttack"

	chargeStart = tick()

	anim = char.Humanoid:LoadAnimation(script.Parent.Anim)
	anim:Play()
	anim:AdjustSpeed(0.15 / CHARGE_TIME)

	anim:GetMarkerReachedSignal("charged"):Connect(function()
		if not thrown then
			char.HumanoidRootPart.SpearEmit:Emit(20)
			anim:AdjustSpeed(0)
		end
	end)
	while not thrown do -- interruptable
		if char:FindFirstChild("Stun") or not char:FindFirstChild("Harpoon") then
			thrown = true
			chargeStart = nil
			anim:Stop()
			attFolder:Destroy()

			sub(function()
				wait(COOLDOWN)
				en = true
				thrown = false
			end)
		end
		wait()
	end
end)

tool.Deactivated:Connect(function()
	if en then return end
	if thrown then return end
	if chargeStart == nil then return end

	thrown = true
	local chargeRatio = math.min(1, (tick() - chargeStart) / CHARGE_TIME)
	chargeRatio = math.max(chargeRatio, MIN_DISTANCE / MAX_DISTANCE)
	chargeStart = nil
	anim:AdjustSpeed(1)
	attFolder:Destroy()

	sub(function()
		wait(COOLDOWN)
		en = true
		thrown = false
	end)

	local mouse
	pcall(function()
		mouse = require(game.ServerStorage.Modules.RemoteLib).getMouse(play)
	end)
	if not mouse then return end

	local root = char.HumanoidRootPart

	local f = Instance.new("Accessory")
	f.Name = "Action"
	f.Parent = char
	game.ServerStorage.Debris:Fire(f,0.8)

	local bg = Instance.new("BodyGyro")
	game.CollectionService:AddTag(bg,"AllowedBM")
	bg.P = 5e4
	bg.MaxTorque = Vector3.new(0,5e6,0)
	bg.CFrame = CFrame.new(root.Position, mouse.Hit.p)
	bg.Parent = root
	game.ServerStorage.Debris:Fire(bg, 0.5)

	anim:GetMarkerReachedSignal("throw"):Connect(function()
		char.HumanoidRootPart.SpearSlash:Play() 
		local pWeapon = game.ServerStorage.PlayerData[play.Name].Data.PrimaryWeapon.Value
		local currentprop = char:FindFirstChild(pWeapon, true)
		if currentprop then
			currentprop.Transparency = 1
			sub(function()
				wait(0.3)
				ts:Create(currentprop, TweenInfo.new(0.3), {Transparency = 0}):Play()
			end)
		end
		local copy = game.ServerStorage.Weapons[pWeapon]:Clone()
		copy.CanCollide = false
		copy.Anchored = true
		copy.Position = char.Hilt.Position

		local xzDiff = ((mouse.Hit.p * Vector3.new(1, 0, 1)) - (copy.Position * Vector3.new(1, 0, 1))).Magnitude
		local maxYdiff = xzDiff / 2
		local targetPos
		if math.abs(mouse.Hit.p.Y - copy.Position.Y) > maxYdiff then
			targetPos = mouse.Hit.p * Vector3.new(1, 0, 1) + copy.Position * Vector3.new(0, 1, 0) + Vector3.new(0, maxYdiff, 0)
		else
			targetPos = mouse.Hit.p
		end
		local targetCFrame = CFrame.new(copy.Position, targetPos)
		if (targetPos - copy.Position).Magnitude > chargeRatio * MAX_DISTANCE then
			targetPos = copy.Position + targetCFrame.LookVector * chargeRatio * MAX_DISTANCE
		end
		copy.CFrame = targetCFrame * CFrame.Angles(0, math.pi, 0)
		copy.Parent = workspace.Thrown
		local dist = (targetPos - copy.Position).Magnitude
		local speed = PROJECTILE_SPEED + (chargeRatio == 1 and CHARGED_SPEED_BONUS or 0)
		local travelTime = dist / speed
		ts:Create(copy, TweenInfo.new(travelTime), {Position = targetPos}):Play()

		sub(function()
			wait(travelTime - 0.25)
			ts:Create(copy, TweenInfo.new(0.25), {Transparency = 1}):Play()
			wait(math.min(travelTime, 0.25))
			local bubbles = assets.BubbleAura:Clone()
			bubbles.Parent = copy
			bubbles.Enabled = false
			bubbles:Emit(50)
			game.Debris:AddItem(copy, 3)
		end)

		sub(function()
			local damage = copy.Stats.Damage.Value + DAMAGE_BONUS
			local start = tick()
			local hit = {}
			while tick() - start < travelTime do
				for i, v in pairs(workspace.Live:GetChildren()) do
					if not hit[v] and char ~= v then
						local ehrp = v:FindFirstChild("HumanoidRootPart")
						if ehrp then
							local cp = ClosestPointOnPart(copy, ehrp.Position)
							local distance = (cp - ehrp.Position).Magnitude		
							if distance < PROJECTILE_RADIUS then 
								hit[v] = true
								local pkt = {physical=true,spear=true,slash=true,damage=damage,blade=true,move = "Harpoon"}
								tagHumanoid:Fire(char,v,pkt)	
							end
						end
					end
				end
				wait()
			end
		end)
	end)
end)
