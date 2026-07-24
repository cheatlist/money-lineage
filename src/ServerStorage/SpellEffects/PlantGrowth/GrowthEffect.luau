local roots = game.ServerStorage.SpellEffects.PlantGrowth.Roots
local handhold = game.ReplicatedStorage.Assets.HandHoldNature
local snapanim = game.ServerStorage.NPCAnims.Snap2
local module = {}
function module.snapEffect(character)
	character.Humanoid:LoadAnimation(snapanim):Play()
	local nature = handhold:Clone()
	local weld = Instance.new("Weld")
	weld.Part0 = character["Right Arm"]
	weld.Part1 = nature
	weld.Parent = nature
	nature.Parent = workspace.Thrown
	nature.Snap:Play()
	nature.Shards:Emit(13)
	game.Debris:AddItem(nature,1)
end
function module.rootCharacter(target,character,spell,idk,idk2,idk3)
	if target:FindFirstChild("Knocked")then
		return
	end
	if spell == "Verdien"and not target:FindFirstChild("VerdienCooldown")then
		spawn(function()
			local root = roots:Clone()
			root.CFrame = target.HumanoidRootPart.CFrame*CFrame.new(0,-2.5,0)
			root.Size = root.Size*Vector3.new(0.9,0.65,0.9)
			root.Weld.Part0 = target.HumanoidRootPart
			--root.Weld.C0 = CFrame.new(0,-0.8,0)
			root.Weld.C1 = CFrame.new(0,2.2,0)
			root.Parent = workspace.Thrown
			game.TweenService:Create(root,TweenInfo.new(0.5),{CFrame = root.CFrame*CFrame.new(0,2,0)*CFrame.Angles(0,math.rad(240),0),Size = root.Size*Vector3.new(idk2*1.1,idk2*1.1,idk2*1.1)}):Play()
			root.Crackling:Play()
			root.CFrame = root.CFrame*CFrame.new(0,-1.2,0)
			target.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame*CFrame.new(0,1,0)
			wait()
			local v1 = Instance.new("Accessory")
			v1.Name = "FreezeRoot"
			v1.Parent = target
			game.Debris:AddItem(v1,3)
			local v2 = Instance.new("Accessory")
			v2.Name = "Action"
			v2.Parent = target
			local v3 = Instance.new("Accessory")
			v3.Name = "VerdienCooldown"
			v3.Parent = target
			game.Debris:AddItem(v3,10)
			wait(0.5)
			local v4 = tick()
			while wait(0.1)do
				if tick()-v4>1 then
					break
				end
				if target:FindFirstChild("NoDam")then
					v1:Destroy()
					break
				end
				if character:FindFirstChild("NoDam")then
					v1:Destroy()
					break
				end
			end
			root.Weld:Destroy()
			game.TweenService:Create(root,TweenInfo.new(0.5),{CFrame = root.CFrame*CFrame.new(0,-4,0)*CFrame.Angles(0,math.rad(-240),0),Size = root.Size*Vector3.new(0.95,0.8,0.95)}):Play()
			root.Crackling:Stop()
			root.Crackling.TimePosition = 0.4
			root.Crackling:Play()
			wait(0.25)
			if v1 and v1.Parent then
				v1:Destroy()
			end
			v2:Destroy()
			wait(0.3)
			root.Transparency = 1
			wait(0.25)
			root:Destroy()
		end)
	end
end
function module.fadeInStart(v)
	if not v:IsA("Model")then
		v.Transparency = 1
		v.UsePartColor = true
		game.TweenService:Create(v,TweenInfo.new(1),{Transparency = 0}):Play()
	else
		for _,b in pairs(v:GetDescendants())do
			if b:IsA'PartOperation'then
				b.Transparency = 1
				b.UsePartColor = true
				game.TweenService:Create(b,TweenInfo.new(1),{Transparency = 0}):Play()
			end
		end
	end
	return 1
end
function module.fadeInSuccess(v)
	spawn(function()
		wait(1)
		if not v:IsA("Model")then
			v.UsePartColor = false
			if v:FindFirstChild("Shards")then
				v.Shards:Emit(6)
			end
		else
			for _,b in pairs(v:GetChildren())do
				if b:IsA'PartOperation'then
					b.UsePartColor = false
					if b:FindFirstChild("Shards")then
						b.Shards:Emit(6)
					end
				end
			end
		end
	end)
	return 0.5
end
function module.fadeOut(v,timer)
	spawn(function()
		wait(timer)
		if not v:IsA("Model")then
			v.Shards:Emit(6)
			v.Transparency = 1
		else
			for _,b in pairs(v:GetChildren())do
				if b:FindFirstChild'Shards'then
					b.Shards:Emit(6)
				end
				if b:IsA'BasePart'then
					b.Transparency = 1
				end
			end
		end
		game.Debris:AddItem(v,2)
	end)
end
function module.onGrass(character)
	if tostring(character.Humanoid.FloorMaterial)=="Grass"then
		return true
	end
	return false
end
return module