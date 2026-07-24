local module = {}

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local dangerHandler = require(game.ServerScriptService.Modules.DangerHandler)
local TweenService = game:GetService("TweenService")

local WALK_RANGE = 15
local ATTACK_RANGE = 10
local NO_CLOSER = 5
local GROUPING_RANGE = 20
local AGGRO_DISTANCE = 50 
local SHRIEK_DISTANCE = 100 
local CHASE_DISTANCE = 100
local TORCH_RANGE = -1
local COLUBRAS = 9144458
local COLUBRAS_ALLIES = {
	["151239872"]=true
}

module.setup = function(char)
	local hum = char.Humanoid
	hum.StateChanged:connect(function(old,new)
		if new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Ragdoll then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end

local TweenService = game:GetService("TweenService")
module.die = function(char)
	local HRP = char.HumanoidRootPart
	HRP.PerfectCast:Play()
	for i,v in pairs(HRP:FindFirstChild("Attachment"):GetChildren()) do
		task.spawn(function()
			task.wait(v:GetAttribute("EmitDelay"))
			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end
	for i,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			TweenService:Create(v, TweenInfo.new(2.5),{Transparency = 1}):Play()
		elseif v:IsA("Decal") then
			TweenService:Create(v, TweenInfo.new(2.5),{Transparency = 1}):Play()
		elseif v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end

	task.wait(2.5)
	char:Destroy()
end

module.think = function(char)
	local hum = char:FindFirstChild("Humanoid")
	if not hum then
		return
	end
	
	hum:Move(Vector3.new(math.random(-100,100),0,math.random(-100,100)))
end

module.Walk = function(char,onoff,tracks)
	local hum = char.Humanoid

	if onoff then		
		if not tracks["Walk"].IsPlaying then
			tracks["Walk"]:Play()
		end	
	else
		tracks["Walk"]:Stop()
	end
end

return module
