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
	if p1:FindFirstChild("NOLDROP")then
		return
	end
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Lightning Drop") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Lightning Drop"
	CD.Value = 10
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 10)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	local HumanoidRootPart = p1.HumanoidRootPart
	local Humanoid = p1.Humanoid
	local v2 = Instance.new("Accessory")
	v2.Name = "NoFall"
	v2.Parent = p1
	game.Debris:AddItem(v2,4)
	local effects = {}
	local function addelectric(part)
		local v1 = game.ReplicatedStorage.Assets.Electric:Clone()
		if data.Skills.Value:find("TheThunderstorm") then
			v1.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
		elseif data.Skills.Value:find("TheCalmbeforethestorm") then
			v1.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		elseif data.Skills.Value:find("TheLightning") then
			v1.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
		end
		--	v1.Color = ColorSequence.new(p2.Backpack.ManaColor.Value)
		v1.Parent = part
		table.insert(effects,v1)
	end
	for _,v in pairs(p1.Torso:GetChildren())do
		if v:IsA("Motor6D")then
			for i=1,2 do
				addelectric(v.Part1)
			end
		end
	end
	HumanoidRootPart.LightningHit:Play()
	for i=1,2 do
		addelectric(p1.Torso)
	end
	wait()
	local ignore = {workspace.Live,workspace.Thrown}
	local direction = Vector3.new(0,-3000,0)
	local cframe = HumanoidRootPart.CFrame*CFrame.new(direction)
	local ray = Ray.new(HumanoidRootPart.CFrame.p,direction)
	local Hit,Pos,Normal = workspace.FindPartOnRayWithIgnoreList(workspace,ray,ignore)
	if (Pos-HumanoidRootPart.Position).Magnitude > 16 then
		local v3 = Instance.new("Accessory")
		v3.Name = "TPSafe"
		v3.Parent = p1
		game.Debris:AddItem(v3,2)
		local v1 = Instance.new("Accessory")
		v1.Name = "Action"
		v1.Parent = p1
		game.Debris:AddItem(v1,2)
		local v2 = Instance.new("Accessory")
		v2.Name = "HeavyAttack"
		v2.Parent = p1
		game.Debris:AddItem(v2,2)
		wait()
		p1:SetPrimaryPartCFrame(CFrame.new(Pos)*CFrame.new(0,5,0))
		u3.magnitudeCheck(p1,HumanoidRootPart.Position,15,{
			mana = true,
			manastop = true,
			damage = 25,
			manaknockupself = true,
			canspellcounter = true,
			aoe = true,
			move = "Lightning Drop"
		},false,true)
		local dropanimation = p1.Humanoid:LoadAnimation(script.Parent.Anim)
		dropanimation:Play()
		local ring = game.ReplicatedStorage.Assets.LightningDrop:Clone()
		if data.Skills.Value:find("TheThunderstorm") then
			ring.Color = Color3.fromRGB(255, 255, 0)
			ring.PointLight.Color = Color3.fromRGB(255, 255, 0)
		elseif data.Skills.Value:find("TheCalmbeforethestorm") then
			ring.Color = Color3.fromRGB(255, 255, 255)
			ring.PointLight.Color = Color3.fromRGB(255, 255, 255)
		elseif data.Skills.Value:find("TheLightning") then
			ring.Color = Color3.fromRGB(85, 0, 255)
			ring.PointLight.Color = Color3.fromRGB(85, 0, 255)
		end
		--ring.Color = p2.Backpack.ManaColor.Value
		--ring.PointLight.Color = p2.Backpack.ManaColor.Value
		ring.STRIKE:Play()
		ring.Position = Pos
		ring.Parent = workspace.Thrown
		local electriclight = game.ReplicatedStorage.Assets.ElectricLight:Clone()
		if data.Skills.Value:find("TheThunderstorm") then
			electriclight.Color = Color3.fromRGB(255, 255, 0)
		elseif data.Skills.Value:find("TheCalmbeforethestorm") then
			electriclight.Color = Color3.fromRGB(255, 255, 255)
		elseif data.Skills.Value:find("TheLightning") then
			electriclight.Color = Color3.fromRGB(85, 0, 255)
		end
		electriclight.Parent = ring
		--ring.ElectricLight.Color = p2.Backpack.ManaColor.Value
		task.spawn(function()
			local tween = game.TweenService:Create(ring,TweenInfo.new(0.25),{
				Size = Vector3.new(65,20,20),
				Transparency = 1,
			})
			tween:Play()
			tween.Completed:Wait()
			ring.Size = Vector3.new(65,1,1)
			ring.Transparency = 0.8
			local tween = game.TweenService:Create(ring,TweenInfo.new(0.25),{
				Size = Vector3.new(65,20,20),
				Transparency = 1,
			})
			tween:Play()
			tween.Completed:Wait()
			ring.Transparency = 1
			game.Debris:AddItem(ring,2.8)
			wait(1.25)
			dropanimation:Stop()
			ring.PointLight.Enabled = false
		end)
	else
		if data.Skills.Value:find("TheCalmbeforethestorm") then
			Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims.AcroFlip):Play()
			
			local BodyVelocity = Instance.new("BodyVelocity")
			game:GetService("CollectionService"):AddTag(BodyVelocity, "AllowedBM")
			BodyVelocity.Parent = HumanoidRootPart
			BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
			BodyVelocity.Velocity = Vector3.new(0, 80, 0)
			game.Debris:AddItem(BodyVelocity, 0.01)
			
			task.wait(0.5)
			
			local v3 = Instance.new("Accessory")
			v3.Name = "TPSafe"
			v3.Parent = p1
			game.Debris:AddItem(v3,2)
			local v1 = Instance.new("Accessory")
			v1.Name = "Action"
			v1.Parent = p1
			game.Debris:AddItem(v1,2)
			local v2 = Instance.new("Accessory")
			v2.Name = "HeavyAttack"
			v2.Parent = p1
			game.Debris:AddItem(v2,2)
			wait()
			p1:SetPrimaryPartCFrame(CFrame.new(Pos)*CFrame.new(0,5,0))
			u3.magnitudeCheck(p1,HumanoidRootPart.Position,15,{
				mana = true,
				manastop = true,
				damage = 25,
				manaknockupself = true,
				canspellcounter = true,
				aoe = true,
				move = "Lightning Drop"
			},false,true)
			local dropanimation = p1.Humanoid:LoadAnimation(script.Parent.Anim)
			dropanimation:Play()
			local ring = game.ReplicatedStorage.Assets.LightningDrop:Clone()
			if data.Skills.Value:find("TheThunderstorm") then
				ring.Color = Color3.fromRGB(255, 255, 0)
				ring.PointLight.Color = Color3.fromRGB(255, 255, 0)
			elseif data.Skills.Value:find("TheCalmbeforethestorm") then
				ring.Color = Color3.fromRGB(255, 255, 255)
				ring.PointLight.Color = Color3.fromRGB(255, 255, 255)
			elseif data.Skills.Value:find("TheLightning") then
				ring.Color = Color3.fromRGB(85, 0, 255)
				ring.PointLight.Color = Color3.fromRGB(85, 0, 255)
			end
			--ring.Color = p2.Backpack.ManaColor.Value
			--ring.PointLight.Color = p2.Backpack.ManaColor.Value
			ring.STRIKE:Play()
			ring.Position = Pos
			ring.Parent = workspace.Thrown
			local electriclight = game.ReplicatedStorage.Assets.ElectricLight:Clone()
			if data.Skills.Value:find("TheThunderstorm") then
				electriclight.Color = Color3.fromRGB(255, 255, 0)
			elseif data.Skills.Value:find("TheCalmbeforethestorm") then
				electriclight.Color = Color3.fromRGB(255, 255, 255)
			elseif data.Skills.Value:find("TheLightning") then
				electriclight.Color = Color3.fromRGB(85, 0, 255)
			end
			electriclight.Parent = ring
			--ring.ElectricLight.Color = p2.Backpack.ManaColor.Value
			task.spawn(function()
				local tween = game.TweenService:Create(ring,TweenInfo.new(0.25),{
					Size = Vector3.new(65,20,20),
					Transparency = 1,
				})
				tween:Play()
				tween.Completed:Wait()
				ring.Size = Vector3.new(65,1,1)
				ring.Transparency = 0.8
				local tween = game.TweenService:Create(ring,TweenInfo.new(0.25),{
					Size = Vector3.new(65,20,20),
					Transparency = 1,
				})
				tween:Play()
				tween.Completed:Wait()
				ring.Transparency = 1
				game.Debris:AddItem(ring,2.8)
				wait(1.25)
				dropanimation:Stop()
				ring.PointLight.Enabled = false
			end)
		end
	end
	p1.Humanoid:UnequipTools()
	wait(1.25)
	for _,v in pairs(effects)do
		game.Debris:AddItem(v,0)
	end
	task.wait(10)
	canuse = true
end)