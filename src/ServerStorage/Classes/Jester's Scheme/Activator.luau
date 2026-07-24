local l__Parent__1 = script.Parent
local l__Parent__2 = l__Parent__1.Parent
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__TweenService__4 = game:GetService("TweenService")
function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__5 = game:GetService("TweenService")
function ActionCheck(p1)
	if not p1:FindFirstChild("Humanoid") then
		return true
	end
	if p1:FindFirstChild("Stun") then
		return true
	end
	if p1:FindFirstChild("ReturnStun") then
		return true
	end
	if p1:FindFirstChild("ActiveCast") then
		return true
	end
	if p1:FindFirstChild("Action") then
		return true
	end
	if p1:FindFirstChild("Blocking") then
		return true
	end
	if p1.Humanoid.Health == 0 then
		return true
	end
	if p1:FindFirstChild("Climbing") then
	else
		return
	end
	return true
end
local v6 = {}
local u1 = true
local u2 = require(game.ServerScriptService.Modules.HitDetection)
function v6.Active(p2, p3, p4)
	local v7 = nil
	if ActionCheck(p2) then
		return
	end
	if not u1 then
		return
	end
	local v8 = game.ServerStorage.PlayerData:FindFirstChild(p3.Name)
	u1 = false
	local l__Humanoid__9 = p2.Humanoid
	local l__HumanoidRootPart__10 = p2.HumanoidRootPart
	local v11 = Instance.new("Accessory")
	v11.Name = "Action"
	v11.Parent = p2
	if not _G.Debris then repeat task.wait() until _G.Debris end
_G.Debris:AddItem(v11,0.5)
	local v12 = l__Parent__1.Windup:Clone()
	v12.Parent = l__HumanoidRootPart__10
	v12:Play()
	if not _G.Debris then repeat task.wait() until _G.Debris end
_G.Debris:AddItem(v12,3)
	local v13 = 0
	while true do
		v13 = v13 + wait()
		v7 = p2:FindFirstChild("Stun") or p2:FindFirstChild("Knocked")
		if v13 >= 1 then
			break
		end
		if v7 then
			break
		end	
	end
	if not v7 then
		local v14 = l__Parent__1.Sound:Clone()
		v14.Parent = l__HumanoidRootPart__10
		v14:Play()
		if not _G.Debris then repeat task.wait() until _G.Debris end
_G.Debris:AddItem(v14,3)
		for _,v19 in pairs(workspace.Live:GetChildren())do
			if v19 ~= p2 and v19:FindFirstChild("HumanoidRootPart") and v19:FindFirstChild("Humanoid") and v19.Humanoid.Health > 0 and (l__HumanoidRootPart__10.Position - v19.HumanoidRootPart.Position).Magnitude <= 150 then
				local v20 = Instance.new("Folder",v19)
				v20.Name = "Action"
				if not _G.Debris then repeat task.wait() until _G.Debris end
_G.Debris:AddItem(v20,5)
				local v21 = Instance.new("Folder",v19)
				v21.Name = "TimeStopped"
				if not _G.Debris then repeat task.wait() until _G.Debris end
_G.Debris:AddItem(v21,5)
				local v22 = Instance.new("Folder",v19)
				v22.Name = "Stun"
				if not _G.Debris then repeat task.wait() until _G.Debris end
				_G.Debris:AddItem(v22,5)
				local antikill = Instance.new("Folder",v19)
				antikill.Name = "NoKill"
				if not _G.Debris then repeat task.wait() until _G.Debris end
				_G.Debris:AddItem(antikill,120)
				local v23 = game.Players:GetPlayerFromCharacter(v19)
				if v23 then
					game.ReplicatedStorage.Requests.StopTime:FireClient(v23, false, 5)
					game.ReplicatedStorage.Requests.ScreenFlip:FireClient(v23, false, 5)
				end
			end		
		end
		game.ReplicatedStorage.Requests.StopTime:FireClient(p3, true, 5)
		game.ReplicatedStorage.Requests.ScreenFlip:FireClient(p3, false, 5)
	end
	local ToolName = script.Parent.Name
	local cdd = 100
	local plrrr = game.Players:GetPlayerFromCharacter(p2)
	game.ReplicatedStorage.Requests.CooldownIndicator:FireClient(plrrr,cdd,ToolName)
	wait(100)
	u1 = true
end
return v6