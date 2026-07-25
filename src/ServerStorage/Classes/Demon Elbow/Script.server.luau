function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	spawn(function()
		if ActionCheck(p1)then
			return
		end
		if not canuse then
			return
		end
		canuse = false
		local p2 = game.Players:GetPlayerFromCharacter(p1)
		local HumanoidRootPart = p1.HumanoidRootPart
		local v1 = Instance.new("Accessory")
		v1.Name = "Action"
		v1.Parent = p1
		game.Debris:AddItem(v1,0.8)
		p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
		p1.Humanoid:UnequipTools()
		local effects = {}
		for _,v in pairs(p1.Torso:GetChildren())do
			if v:IsA("Motor6D")then
				local v1 = game.ReplicatedStorage.Assets.ParticleArm:Clone()
				local weld1 = Instance.new("Weld")
				weld1.Parent = v1
				weld1.Part0 = v1
				v1.CFrame = v.Part1.CFrame
				weld1.Part1 = v.Part1
				weld1.C1 = CFrame.new(0.25,0,0)
				v1.TestTrail.Lifetime = 0.5
				v1.TestTrail.Color = ColorSequence.new(Color3.fromRGB(170, 0, 0))
				v1.TestTrail.Enabled = true
				v1.Parent = workspace.Thrown
				table.insert(effects,v1)
			end
		end
		for _,v in pairs(p1.Torso:GetChildren())do
			if v:IsA("Motor6D")then
				local v1 = game.ReplicatedStorage.Assets.ParticleArm:Clone()
				local weld1 = Instance.new("Weld")
				weld1.Parent = v1
				weld1.Part0 = v1
				v1.CFrame = v.Part1.CFrame
				weld1.Part1 = v.Part1
				weld1.C1 = CFrame.new(-0.25,0,0)
				v1.TestTrail.Color = ColorSequence.new(Color3.fromRGB(170, 0, 0))
				v1.TestTrail.Enabled = true
				v1.Parent = workspace.Thrown
				table.insert(effects,v1)
			end
		end
		local cancel = false
		task.wait(0.4)
		if p1:FindFirstChild("NoDam")then
			cancel = true
		end
		task.wait(0.4)
		if p1:FindFirstChild("NoDam")then
			cancel = true
		end
		if not cancel then
			u3.SMag({
				user = p1,
				range = 50,
				length = 5,
				width = 14,
				height = 14,
				origin = HumanoidRootPart.CFrame,
				tags = {
					physical = true,
					damage = 90,
					strongknockback = true,
					fist = true,
					sparks = true,
					bypassfischdodge = true,
					blockallsides = true,
					iselbow = true,
					move = "Demon Elbow"
				};
			});
			local ignore = {workspace.Live,workspace.Thrown}
			local direction = Vector3.new(0,0,-50)
			local rayrotation = HumanoidRootPart.CFrame.LookVector*50
			local cframe = HumanoidRootPart.CFrame*CFrame.new(direction.x,0,direction.z)
			local ray = Ray.new(HumanoidRootPart.CFrame.p,rayrotation)
			local Hit,Pos,Normal = workspace.FindPartOnRayWithIgnoreList(workspace,ray,ignore)
			local newpos = cframe.p
			if Hit and Hit.CanCollide then
				newpos = Pos
			end
			p1:SetPrimaryPartCFrame(CFrame.new(newpos.X, newpos.Y, newpos.Z))
			HumanoidRootPart.LightStrike1:Play()
			local ring = game.ReplicatedStorage.Assets.Ring:Clone()
			ring.Color = Color3.fromRGB(170, 0, 0)
			ring.Size = Vector3.new(2.5,0.01,2.5)
			ring.Parent = workspace.Thrown
			ring.Position = newpos
			ring.Transparency = 0.6
			local tween = game.TweenService:Create(ring,TweenInfo.new(0.125),{
				Size = Vector3.new(8,0.01,8)
			}):Play()
			task.wait()
			for _,v in pairs(effects)do
				v.TestTrail.Enabled = false
				game.Debris:AddItem(v,1)
			end
			task.wait(0.17)
			ring:Destroy()
		else
			for _,v in pairs(effects)do
				v.TestTrail.Enabled = false
				game.Debris:AddItem(v,1)
			end
		end
		task.wait(12)
		canuse = true
	end)
end)