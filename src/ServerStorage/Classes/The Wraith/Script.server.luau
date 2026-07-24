function sub(...)
	coroutine.wrap(...)()
	
end
function Anchor(Target, Statement)
	if Statement then
		local RootFreezing = Instance.new("Accessory")
		RootFreezing.Name = "FreezeRoot"
		RootFreezing.Parent = Target
	else
		for i,v in pairs(Target:GetChildren()) do
			if v.Name == "FreezeRoot" then
				v:Destroy()
			end
		end
	end
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","NoDam","ReturnStun","Action","Blocking","ActiveCast","Unconscious","Knocked","Grabbing"},
	})
end
local canuse = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	local hum = p1.Humanoid
	local player = game.Players:GetPlayerFromCharacter(p1)
	if not canuse then
		canuse = true
		local mousepos = _G.MouseData(player)
		if not mousepos then
			canuse = false
			return
		end
		local hit = mousepos.Hit
		if(hit.Position - player.Character.HumanoidRootPart.Position).Magnitude>225 then
			canuse = false
			return
		end
		local stunadded = nil
		local stunned = false
		local stun = Instance.new("Accessory")
		stun.Parent = player.Character
		stun.Name = "Action"
		game.Debris:AddItem(stun,1.5)
		stunadded = player.Character.ChildAdded:Connect(function(t)
			if t.Name == "Stun" or t.Name == "Knocked" or t.Name == "Unconscious" or t.Name == "Action" then
				stunned = true
			end
		end)
		task.delay(1.5, function()
			stunadded:Disconnect()
		end)
		local wraith = game.ServerStorage.Assets.shadowwarp:Clone()
		wraith.Parent = workspace.Thrown
		wraith.CFrame = player.Character.HumanoidRootPart.CFrame-Vector3.new(0,3,0)
		wraith.Shadows.Enabled = true
		coroutine.wrap(function()
			wait(1)
			wraith.Shadows.Enabled = false
		end)()
		game.Debris:AddItem(wraith,2)
		if mousepos and mousepos.Target then
			local wraith = game.ServerStorage.Assets.shadowwarp:Clone()
			wraith.Parent = workspace.Thrown
			wraith.CFrame = hit
			wraith.Shadows.Enabled = true
			coroutine.wrap(function()
				wait(0.7)
				wraith.Shadows.Enabled = false
			end)()
			game.Debris:AddItem(wraith,2)
			local Sun_Direction = game.Lighting:GetSunDirection()
			if p1:FindFirstChild('HumanoidRootPart') then
				local Ray_ = Ray.new(hit.p, Sun_Direction * 5000)
				local list = {workspace.Live, workspace.AreaMarkers,workspace.Thrown}
				local Part = workspace:FindPartOnRayWithIgnoreList(Ray_, list)
				if Part and not stunned then
					local tpCheck = Instance.new("BoolValue")
					tpCheck.Name = "TPSafe"
					tpCheck.Parent = player.Character
					game.Debris:AddItem(tpCheck, 5);
					wait(1)
					local ts = game:GetService("TweenService")
					ts:Create(player.Character.HumanoidRootPart,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{CFrame = player.Character.HumanoidRootPart.CFrame - Vector3.new(0,6,0)}):Play()
					wait(0.5)
					if not stunned then
						player.Character.Head.CFrame = hit
					end
						ts:Create(player.Character.HumanoidRootPart,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0,6,0)}):Play()
					wait(0.5)
                 
				end
			end
		end
		wait(0.5)
		canuse = false
	end
end)