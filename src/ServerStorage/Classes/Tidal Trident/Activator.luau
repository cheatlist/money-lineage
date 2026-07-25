local Tidal = {}

function sub(...)
	coroutine.wrap(...)()
end
local u1 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local canuse = true
local canuse2 = true
Tidal.Active = function(p1,p2,p3,p4)
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Tidal Trident") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Tidal Trident"
	CD.Value = 11
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 11)
	canuse = false
	local HumanoidRootPart = p1.HumanoidRootPart
	local WaveRun = p1.Humanoid:LoadAnimation(script.Parent.WaveRide)
	local WaveSter = game:GetService("ReplicatedStorage").Assets.sf.TT.WAVESTER:Clone()
	WaveSter.Parent = p1
	WaveRun:GetMarkerReachedSignal("go"):Connect(function()
		WaveSter.HRP.Part0 = WaveSter
		WaveSter.HRP.Part1 = p1.HumanoidRootPart
		local v2 = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(v2,"AllowedBM")
		v2.MaxForce = Vector3.new(80000,0,80000)
		v2.Velocity = p1.HumanoidRootPart.CFrame.lookVector.unit*44
		v2.Name = "ForwardVelocity"
		v2.Parent = p1.HumanoidRootPart
		game:GetService("Debris"):AddItem(v2, 0.85)
		task.spawn(function()
			for i = 1,6 do
				u1.magnitudeCheck(p1,HumanoidRootPart.Position,11,{
					damage = 2.5,
					noparry = true,
					physical = true,
					spear = true,
					slash = true,
					spearmovestack = true,
					nostun = i == 6 and true or false
				})
				task.wait(0.2)
			end
		end)
	end)
	WaveRun.Stopped:Connect(function()
		WaveSter:Destroy()
	end)
	WaveRun:Play()
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,1.2)
	HumanoidRootPart.SpearEmit:Emit(30)
	HumanoidRootPart.SwordCharge:Play()
	HumanoidRootPart.Swing:Play()
	task.wait(11)
	canuse = true
end

local Table = {
	damage = 7,
	noparry = true,
	physical = true,
	spear = true,
	slash = true,
	blockbreak = true,
}

Tidal.Active2 = function(p1, p2, p3, p4)
	local character = p1
	if ActionCheck(character) then
		return
	end
	if p1.Cooldowns:FindFirstChild("Tidal Trident M2") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Tidal Trident M2"
	CD.Value = 11
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 11)
	canuse2 = false
	local HumanoidRootPart = character.HumanoidRootPart
	local splash = game:GetService("ReplicatedStorage").Assets.sf.TT.ttsplash:Clone()
	game:GetService("Debris"):AddItem(splash, 7)
	splash.Parent = p1
	local WaveRun = character.Humanoid:LoadAnimation(script.Parent.AerialPlunge)
	WaveRun:Play()
	HumanoidRootPart.SpearEmit:Emit(30)
	HumanoidRootPart.SwordCharge:Play()
	HumanoidRootPart.Swing:Play()
	local upw = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(upw,"AllowedBM")
	upw.MaxForce = Vector3.new(0, 80000, 0)
	upw.Velocity = Vector3.new(0, 55, 0)
	upw.Name = "UpwardVelocity"
	upw.Parent = p1.HumanoidRootPart
	task.wait(0.27)
	upw:Destroy()
	local dwn = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(dwn,"AllowedBM")
	dwn.MaxForce = Vector3.new(0, -8000, 0)
	dwn.Velocity = Vector3.new(0, -75, 0)
	dwn.Name = "DownwardVelocity"
	dwn.Parent = p1.HumanoidRootPart
	game:GetService("Debris"):AddItem(dwn, 0.8)
	if character:FindFirstChild("Focus") then
		Table.foamtrident = true
	else
		Table.foamtrident = false
	end
	local debounce = false
	character:WaitForChild("HumanoidRootPart").Touched:Connect(function(hit)
		if debounce then
			return
		end
		debounce = true
		if hit and hit.Parent then
			local hitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if hitHumanoid then
				hitHumanoid.PlatformStand = false
			end
			if hit:IsDescendantOf(game.Workspace) then
				splash.HRP.Part0 = splash
				splash.HRP.Part1 = p1.HumanoidRootPart
				splash.Smashing:Play()
				splash.Splash:Play()
				for i,v in splash.a:GetChildren() do
					v:Emit(10)
				end
				WaveRun:Stop()
				local downwardVelocity = character.HumanoidRootPart:FindFirstChild("DownwardVelocity")
				if downwardVelocity then
					downwardVelocity:Destroy()
				end
				u1.magnitudeCheck(character, HumanoidRootPart.Position, 17, Table)
			end
		end
	end)

	task.wait(11)
	canuse2 = true
end

return Tidal