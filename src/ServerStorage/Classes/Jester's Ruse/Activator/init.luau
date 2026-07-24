local l__Parent__1 = script.Parent
local l__Parent__2 = l__Parent__1.Parent
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__TweenService__4 = game:GetService("TweenService")
local v5 = require(game.ServerScriptService.Modules.HitDetection)
function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__6 = game:GetService("TweenService")
function ActionCheck(p1)
	if not p1:FindFirstChild("Humanoid") then
		return true
	end
	if p1:FindFirstChild("Climbing") then

	else
		return
	end
	return true
end
local v7 = {}
local u1 = true
function v7.Active(p2, p3, p4, p5)
	local v8 = nil
	if game.ReplicatedStorage:FindFirstChild("TIMEERASEDBY") then
		return
	end
	if ActionCheck(p2) then
		return
	end
	if not u1 then
		return
	end
	u1 = false
	local l__Humanoid__10 = p2.Humanoid
	local l__HumanoidRootPart__11 = p2.HumanoidRootPart
	local v12 = Instance.new("Accessory")
	v12.Name = "Action"
	v12.Parent = p2
	if not _G.Debris then repeat task.wait() until _G.Debris end
_G.Debris:AddItem(v12, 0.5)
	local v13 = l__Parent__1.Windup:Clone()
	v13.Parent = l__HumanoidRootPart__11
	v13:Play()
	if not _G.Debris then repeat task.wait() until _G.Debris end
_G.Debris:AddItem(v13, 3)
	local v14 = 0
	while true do
		v14 = v14 + wait()
		v8 = p2:FindFirstChild("Stun") or game.CollectionService:HasTag(p2, "Knocked")
		if v14 >= 1 then
			break
		end
		if v8 then
			break
		end	
	end
	if not v8 then
		local v16 = Instance.new("Accessory")
		v16.Name = "ErasingTime"
		v16.Parent = p2
		if not _G.Debris then repeat task.wait() until _G.Debris end
		_G.Debris:AddItem(v16,8)
		local antikill = Instance.new("Folder",v19)
		antikill.Name = "NoKill"
		if not _G.Debris then repeat task.wait() until _G.Debris end
		_G.Debris:AddItem(antikill,120)
		local v17 = Instance.new("ObjectValue")
		v17.Name = "TIMEERASEDBY"
		v17.Value = p2
		v17.Parent = game.ReplicatedStorage
		if not _G.Debris then repeat task.wait() until _G.Debris end
		_G.Debris:AddItem(v17,8)
		for _,v22 in pairs(workspace.Live:GetChildren())do
			if v22:FindFirstChild("HumanoidRootPart") and (v22.HumanoidRootPart.Position - l__HumanoidRootPart__11.Position).Magnitude <= 100 and game.Players:GetPlayerFromCharacter(v22) then
				local v27 = script.ERASURE:Clone()
				v27.Parent = v22
				v27.Disabled = false
				if v22~=p2 then
					local plr = game.Players:GetPlayerFromCharacter(v22)
					game.ReplicatedStorage.Requests.JesterRuse:FireClient(plr,8)
					local abc = Instance.new("Accessory")
					abc.Name = "Action"
					abc.Parent = v22
					if not _G.Debris then repeat task.wait() until _G.Debris end
					_G.Debris:AddItem(abc,8)

					local abc = Instance.new("Accessory")
					abc.Name = "TimeEraseVictim"
					abc.Parent = v22
					if not _G.Debris then repeat task.wait() until _G.Debris end
					_G.Debris:AddItem(abc,8)
					
					local abc = Instance.new("Accessory")
					abc.Name = "MustSprint"
					abc.Parent = v22
					if not _G.Debris then repeat task.wait() until _G.Debris end
					_G.Debris:AddItem(abc,8)
				end
			end		
		end
		lastused = tick()
	end
	local cdd = 100
	local plrrr = game.Players:GetPlayerFromCharacter(p2)
	game.ReplicatedStorage.Requests.CooldownIndicator:FireClient(plrrr,cdd,script.Parent.Name)
	wait(100)
	u1 = true
end
return v7