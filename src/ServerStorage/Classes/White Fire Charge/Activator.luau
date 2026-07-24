

local v1 = {}
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true
	end
	if l__Parent__1:FindFirstChild("Charge") then
		return true
	end
	if l__Parent__1:FindFirstChild("Stun") then
		return true
	end
	if l__Parent__1:FindFirstChild("ReturnStun") then
		return true
	end
	if l__Parent__1:FindFirstChild("Action") then
		return true
	end
	if l__Parent__1:FindFirstChild("Blocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("SpellBlocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("ActiveCast") then
		return true
	end
	if game.CollectionService:HasTag(l__Parent__1, "Unconscious") then
		return true
	end
	if game.CollectionService:HasTag(l__Parent__1, "Knocked") then

	else
		return
	end
	return true
end
local v3 = tick()
local l__TweenService__4 = game:GetService("TweenService")
function buffCheck(p1)
	if l__Parent__1:FindFirstChild("SigilBuff") then
		l__Parent__1.SigilBuff:Destroy()
	end
	for i,v in pairs(p1:GetChildren()) do
		if v.Name == "SigilPtcl" or v.Name == "SigilPartEffect" or v.Name == "SigilSound" or v.Name == "SigilLight" then
			v:Destroy()
		end
	end
end
local u2 = true
function v1.Active(p2, p3, p4, p5)
	task.spawn(function()
		if game.ServerStorage.PlayerData[p3.Name].PrimaryWeapon.Value ~= "SealedSword" then
			return
		end
		if ActionCheck() then
			return
		end
		if game.ServerStorage.PlayerData[p3.Name].Class.Value ~= 'SigilKnightCommander' and game.ServerStorage.PlayerData[p3.Name].Race.Value ~= 'Navaran'  then
			return
		end
		if game.CollectionService:HasTag(p2, "Knocked") then
			return
		end
		if p2:FindFirstChild("SigilBuff") and p2:FindFirstChild("SigilBuff").Value == "White Fire" then
			return
		end
		if p2.Cooldowns:FindFirstChild("White Fire Charge") then
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "White Fire Charge"
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
			v10.Value = "White Fire"
			v10.Parent = p2
			game:GetService("Debris"):AddItem(v10, 30)
			local v11 = Instance.new("NumberValue")
			v11.Name = "ColdResist"
			v11.Value = 1
			v11.Parent = p2
			game:GetService("Debris"):AddItem(v11, 30)
		end
		local v12 = p5:Clone()
		v12:ClearAllChildren()
		v12.Name = "SigilPartEffect"
		v12.Size = p5.Size + Vector3.new(0.2, 0.2, 0.2)
		v12.BrickColor = BrickColor.new("White")
		v12.Material = Enum.Material.Neon
		v12.Reflectance = 1
		v12.Transparency = 0.85
		v12.Parent = p5
		local v13 = Instance.new("Weld")
		v13.Parent = v12
		v13.Part0 = v12
		v13.Part1 = p5
		game.Debris:AddItem(v12, 30)
		local att = nil
		local att2 = nil
		for i,v in pairs(script.Parent.Part:GetChildren()) do
			local v14 = v:Clone()
			v14.Parent = p5

			if v14.Name == "A0" then
				att = v14
			elseif v14.Name == "A1" then
				att2 = v14
			end

			v14.Name = "SigilPtcl"
			game.Debris:AddItem(v14, 30)
		end
		
		for i,v in pairs(att:GetChildren()) do
			v.Attachment1 = att2
		end
		
		local v15 = script.Parent:FindFirstChild("FireLoop"):Clone()
		v15.Name = "SigilSound"
		v15.Parent = p5
		v15:Play()
		game.Debris:AddItem(v15, 30)
		if not p5:FindFirstChild("FireHit") then
			script.Parent:FindFirstChild("FireHit"):Clone().Parent = p5
		end
		local v16 = script.Parent:FindFirstChild("Light"):Clone()
		v16.Name = "SigilLight"
		v16.Parent = p5
		game.Debris:AddItem(v16, 30)
		wait(5)
		u2 = true
	end)
end
return v1