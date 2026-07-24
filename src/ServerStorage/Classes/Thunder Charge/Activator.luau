local v1 = {}
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked"},
	})
end
local v3 = tick()
local l__TweenService__4 = game:GetService("TweenService")
function buffCheck(p1)
	coroutine.wrap(function()
		if l__Parent__1:FindFirstChild("SigilBuff") then
			l__Parent__1.SigilBuff:Destroy()
		end
		for i,v in pairs(p1:GetChildren()) do
			if v.Name == "SigilPtcl" or v.Name == "SigilPartEffect" or v.Name == "SigilSound" or v.Name == "SigilLight" then
				v:Destroy()
			end
		end
	end)()
end
local u2 = true
function v1.Active(p2, p3, p4, p5)
	task.spawn(function()
		if ActionCheck() then
			return
		end
		if p2:FindFirstChild("SigilBuff") and p2:FindFirstChild("SigilBuff").Value == "Thunder" then
			return
		end
		if p2.Cooldowns:FindFirstChild("Thunder Charge") then
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Thunder Charge"
		CD.Value = 5
		CD.Parent = p2.Cooldowns
		game.Debris:AddItem(CD, 5)
		u2 = false
		local l__HumanoidRootPart__5 = p2.HumanoidRootPart
		if not p3.Backpack:FindFirstChild("ChargeMastery") then
			local v6 = Instance.new("Accessory")
			v6.Name = "HeavyAttack"
			v6.Parent = p2
			game:GetService("Debris"):AddItem(v6, 1)
			local v7 = Instance.new("Accessory")
			v7.Name = "NoJump"
			v7.Parent = p2
			game:GetService("Debris"):AddItem(v7, 1)
			local v8 = Instance.new("Accessory")
			v8.Name = "Action"
			v8.Parent = p2
			game:GetService("Debris"):AddItem(v8, 1.2)
			p2.Humanoid:LoadAnimation(script.Parent:FindFirstChild("Animation")):Play()
			wait(0.5)
		end
		local v9 = Instance.new("Accessory")
		v9.Name = "Sigil"
		v9.Parent = p2
		game:GetService("Debris"):AddItem(v9, 30)
		buffCheck(p5)
		if p5.Parent == p2:FindFirstChild("Hilt") then
			local v10 = Instance.new("StringValue")
			v10.Name = "SigilBuff"
			v10.Value = "Thunder"
			v10.Parent = p2
			game:GetService("Debris"):AddItem(v10, 30)
		end
		local v11 = p5:Clone()
		v11:ClearAllChildren()
		v11.Name = "SigilPartEffect"
		v11.Size = p5.Size + Vector3.new(0.2, 0.2, 0.2)
		v11.BrickColor = BrickColor.new("Fog")
		v11.Material = Enum.Material.Neon
		v11.Reflectance = 1
		v11.Transparency = 0.9
		v11.Parent = p5
		local v12 = Instance.new("Weld")
		v12.Parent = v11
		v12.Part0 = v11
		v12.Part1 = p5
		game.Debris:AddItem(v11, 30)
		local primarywep = game.ServerStorage.PlayerData[p3.Name].PrimaryWeapon.Value
		local att = nil
		local att2 = nil
		for i,v in pairs(script.Parent.Part:GetChildren()) do
			local v13 = v:Clone()
			v13.Parent = p5

			if primarywep == "SealedSword" then
				if v13.Name == "A0" then
					v13.Position = Vector3.new(-0.008, 0.003, 1.18)
					v13.Orientation = Vector3.new(-90, 91.423, 0)
					att = v13
				elseif v13.Name == "A1" then
					v13.Position = Vector3.new(-0.112, 0.016, -3.02)
					v13.Orientation = Vector3.new(-90, 91.423, 0)
					att2 = v13
				end
			elseif primarywep == "WraithSword" then
				if v13.Name == "A0" then
					v13.Position = Vector3.new(1.158, 0.003, 0.002)
					v13.Orientation = Vector3.new(-90, 179.766, 0)
					att = v13
				elseif v13.Name == "A1" then
					v13.Position = Vector3.new(-3.779, 0.016, -0.018)
					v13.Orientation = Vector3.new(-90, 179.766, 0)
					att2 = v13
				end
			else
				if v13.Name == "A0" then
					att = v13
				elseif v13.Name == "A1" then
					att2 = v13
				end
			end

			v13.Name = "SigilPtcl"
			game.Debris:AddItem(v13, 30)
		end
		
		for i,v in pairs(att:GetChildren()) do
			v.Attachment1 = att2
		end
		
		local v14 = script.Parent:FindFirstChild("LightningLoop"):Clone()
		v14.Name = "SigilSound"
		v14.Parent = p5
		v14:Play()
		game.Debris:AddItem(v14, 30)
		if not p5:FindFirstChild("LightningHit") then
			script.Parent:FindFirstChild("LightningHit"):Clone().Parent = p5
		end
		spawn(function()
			wait(5)
			u2 = true
		end)
	end)
end
return v1