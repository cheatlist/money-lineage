local assets = game.ServerStorage.Assets
local TweenService = game:GetService("TweenService")
local hitdet = require(game.ServerScriptService.Modules.HitDetection)
local Debris = game:GetService("Debris")
local module = {}
local cd = false
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(p1)
	return ActionCheckModule(p1, {
		presentBlocks = {"Stun","ReturnStun","ActiveCast","Action","Blocking","Climbing"},
		healthAtOrBelow = 0,
	})
end

module.Active = function(v3,player, p4, p5)
	if ActionCheck(v3)then
		return
	end
	if v3.Cooldowns:FindFirstChild("Brandish") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Brandish"
	CD.Value = 15
	CD.Parent = v3.Cooldowns
	game.Debris:AddItem(CD, 15)
	local flame = false
	if v3:FindFirstChild("VanguardBuff") then
		flame = true
	end
	local hrp = v3.HumanoidRootPart
	if not flame then
		local crossSweep = v3.Humanoid:LoadAnimation(script.Parent.crossSweep)
		crossSweep:Play()
		local stun = Instance.new("Accessory")
		stun.Name = "Action"
		stun.Parent = v3
		v3.HumanoidRootPart.AkumaEmit:Emit(26)
		crossSweep.KeyframeReached:Connect(function(keyframeName)
			if keyframeName == "swing1Start" or keyframeName == "swing2Start" then
				local woosh = script.Parent.wooshswing:Clone()
				woosh.Parent = hrp
				woosh:Play()
				Debris:AddItem(woosh, 1)
				hrp["Swing" .. (keyframeName == "swing1Start" and "1" or "2")].Effect:Emit(1)
				hrp["Dirt" .. (keyframeName == "swing1Start" and "1" or "2")].wooshy:Emit(8)
				hitdet.magnitudeCheck(v3, hrp.Position, 12, {
					stun:Destroy(),
					physical = true,
					sword = true,
					damage = 12,
					move = "Brandish"
				}, nil, false)
			end
		end)
		stun:Destroy()
		--_G.System.Event:FireClient(game.Players:GetPlayerFromCharacter(v3), "SetCDIndicator", {script.Parent.Name, 15})
		task.wait(15)
		cd = false
	else
		local windup = v3.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims.VgM2Windup)
		local slice = v3.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims.VgM2Slice)
		windup:Play()
		hrp.Ignition:Play()
		local stun = Instance.new("Accessory")
		stun.Name = "Action"
		stun.Parent = v3
		hrp.atch.ptcl:Emit(20)
		if p5 then
			if p5:FindFirstChild("AzureFx") then
				if p5:FindFirstChild("AzureFx"):FindFirstChild("swooshy") then
					p5:FindFirstChild("AzureFx"):FindFirstChild("swooshy").Enabled = true
				end
			end
		end

		task.wait(0.40)
		hrp.teleport.ring:Emit(1)
		hrp.teleport.ringside:Emit(1)
		hrp.teleport.texture:Emit(1)
		task.wait(0.15)
		windup:Stop()
		local te = Instance.new("Folder");
		te.Name = "TPSafe";
		te.Parent = v3;
		local v8 = nil
		for _,v13 in pairs(workspace.Live:GetChildren()) do
			local v14 = v13:IsA("Model") and v13 or nil
			if v14 and v14:FindFirstChild("Humanoid") and v14:FindFirstChild("HumanoidRootPart") and v14 ~= v3 and not v14:FindFirstChild("Hitboxes") and (hrp.Position - v14.HumanoidRootPart.Position).magnitude <= 50 and (hrp.CFrame:inverse() * v14.HumanoidRootPart.CFrame).Z < 0 then
				v8 = v14
				break
			end
		end
		if v8 then
			local tp = v8.HumanoidRootPart.Position + Vector3.new(0, 0, -1)
			v3:SetPrimaryPartCFrame(CFrame.new(tp))
			slice:Play()
			if p5:FindFirstChild("AzureFx"):FindFirstChild("swooshy") then
				p5:FindFirstChild("AzureFx"):FindFirstChild("swooshy").Enabled = false
			end
			stun:Destroy()
			te:Destroy()
			game.ServerStorage.Requests.TagHumanoid:Fire(v3,v8,{
				physical = true,
				knockback = true,
				sword = true,
				damage = 17.5,
				vanguardflame = true,
				move = "Brandish",
				blockbreak = true
			})
			hrp.powerslash:Play()
		else
			if p5 then
				p5:FindFirstChild("AzureFx").swooshy.Enabled = false
			end
			te:Destroy()
			stun:Destroy()
		end
		--_G.System.Event:FireClient(game.Players:GetPlayerFromCharacter(v3), "SetCDIndicator", {script.Parent.Name, 15})
		task.wait(15)
		cd = false
	end
end

return module
