local Commands = require(game.ServerScriptService.Modules.Commands)
local TweenService = game:GetService("TweenService")
local Stuns = {
	"LightAttack",
	"Stun",
	"NoDam",
	"Action",
	"Knocked",
	"Unconscious",
	"Immortal",
	"Grabbed",
	"ActiveCast",
	"SpellBlocking"
}

local function ActionCheck(p1): boolean
	for _: number, Stun: string in ipairs(Stuns)do
		if p1:FindFirstChild(Stun)then
			return true
		end
	end
	return false
end

local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent

	if ActionCheck(p1)then
		return
	end

	if not canuse then
		return
	end

	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	local emulate_sound = script.Sound:Clone()
	emulate_sound.Parent = p1.HumanoidRootPart
	if not p2 then
		return
	end

	if not data then
		return
	end

	if not(data.Race.Value == "LesserNavaran")and not(data.Race.Value == "Navaran")then
		return
	end
	local u4 = _G.MouseData(p2)
	if not u4 or not u4.Target or not u4.Target.Parent then
		return
	end
	if not u4.Target.Parent:FindFirstChild("Humanoid")then
		return
	end
	if u4.Target.Parent.Parent ~= workspace.Live then
		return
	end

	canuse = false
	local target = u4.Target.Parent
	local tocopy = target.LastUsed.Value
	
	local function Learn()
		task.spawn(function()
			emulate_sound:Play()
			local sphere = Instance.new("Part")
			sphere.Anchored = true
			sphere.CanCollide = false
			sphere.Color = Color3.fromRGB(242, 243, 243)
			sphere.Transparency = 1
			sphere.Material = Enum.Material.Neon
			sphere.Size = Vector3.new(0.001,0.001,0.001)
			local specialmesh = Instance.new("SpecialMesh")
			specialmesh.Parent = sphere
			specialmesh.MeshType = Enum.MeshType.Sphere
			sphere.Parent = workspace.Thrown
			sphere.CFrame = target.HumanoidRootPart.CFrame
		--[[
		
		game:GetService("TweenService"):Create(sphere,TweenInfo.new(0.1),{Size = Vector3.new(3,3,3)}):Play()
		game:GetService("TweenService"):Create(sphere,TweenInfo.new(0.1),{Size = Vector3.new(0.001, 0.001, 0.001)}):Play()
		
		]]
			local sphere2 = Instance.new("Part")
			sphere2.Anchored = true
			sphere2.CanCollide = false
			sphere2.Color = Color3.fromRGB(242, 243, 243)
			sphere2.Transparency = 0
			sphere2.Material = Enum.Material.Neon
			sphere2.Size = Vector3.new(2.3,2.3,2.3)
			local specialmesh = Instance.new("SpecialMesh")
			specialmesh.Parent = sphere2
			specialmesh.MeshType = Enum.MeshType.Sphere
			sphere2.Parent = workspace.Thrown
			sphere2.CFrame = p1.HumanoidRootPart.CFrame
			--game:GetService("TweenService"):Create(sphere2,TweenInfo.new(0.2),{Size = Vector3.new(3,3,3)}):Play()
			local att1 = Instance.new("Attachment")
			local att2 = Instance.new("Attachment")
			att1.Parent = sphere
			att2.Parent = sphere2
			local beam = game.ServerStorage.Assets.Emulation.Beam:Clone()
			beam.Parent = sphere
			beam.Attachment0 = att1
			beam.Attachment1 = att2
			wait(0.1)
			sphere2.Transparency = 1
			sphere.Transparency = 1
			game.Debris:AddItem(sphere2,1)
			game.Debris:AddItem(sphere,1)
		--[[
		
				game:GetService("TweenService"):Create(sphere2,TweenInfo.new(0.3),{Size = Vector3.new(0.001, 0.001, 0.001),Transparency = 1}):Play()
		game:GetService("TweenService"):Create(sphere,TweenInfo.new(0.3),{Size = Vector3.new(0.001, 0.001, 0.001),Transparency = 1}):Play()
		
		]]
			wait(0.5)
			beam.Enabled = false
		end)
	end
	

	if tocopy~=""then
		local tool = game.ServerStorage.Classes:FindFirstChild(tocopy)
		if tool and not tool:FindFirstChild("NoCopy")then
			if data.Emulated.Value~=tool.Name then
				Learn()
				data.Emulated.Value = tool.Name
				--Commands.Learn(p2)
				Commands.UpdateSkills(p2)
			end
		elseif data.Race.Value == "Navaran" then
			if tool then
				if not string.find(data.Skills.Value, tool.Name) then
					Learn()
					data.Skills.Value ..= ","..tool.Name
					--Commands.Learn(p2)
					Commands.UpdateSkills(p2)
				end	
			end
		end
	end
	wait(5)
	canuse = true
end)