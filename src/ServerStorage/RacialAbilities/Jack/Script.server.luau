local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
local function DoAccessories(Player)
	local Character = game.Players:GetCharacterAppearanceAsync(Player.CharacterAppearanceId)
	Character.Parent = game.ServerStorage
	local Hairs,Accessories = {},{}
	for _,v in ipairs(Character:GetChildren())do
		if v:IsA("Accessory")then
			local Attachment = v:FindFirstChildWhichIsA("Attachment",true)
			if v:FindFirstChild("ParticleEmitter") then
				v:Destroy()
			end

			if v.Name:find("Snorkel") then
				table.insert(Accessories,v:Clone())
			end

			if v.Name == "EarsAccessory" then
				table.insert(Hairs,v:Clone())
			end

			if Attachment then
				if Attachment.Name == "HairAttachment" then
					table.insert(Hairs,v:Clone())
				elseif Attachment.Name == "FaceFrontAttachment"then
					table.insert(Accessories,v:Clone())
				elseif Attachment.Name == "FaceCenterAttachment"then
					table.insert(Accessories,v:Clone())
				end
			end
		end
	end
	game.Debris:AddItem(Character,1)
	return Hairs,Accessories
end
local cd = false

script.Parent.Activated:Connect(function(Player, Character, Data)
	if cd then return end

	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Data = game.ServerStorage.PlayerData[Player.Name]
	local u4 = _G.MouseData(Player)
	if not u4.Target then
		return
	end
	if not u4.Target:IsDescendantOf(workspace.Live) then
		return
	end
	if u4.Target:IsDescendantOf(Character) then
		return
	end
	local u4 = u4.Target.Parent:FindFirstChild("HumanoidRootPart") and u4.Target.Parent or u4.Target.Parent.Parent:FindFirstChild("HumanoidRootPart") and u4.Target.Parent.Parent
	if not u4 then
		return
	end
	if not game.ServerStorage.PlayerData:FindFirstChild(u4.Name) then
		return
	end
	cd = true
	task.delay(2, function()
		cd = false
	end)
	-- numb is how many steps of parents it takes to reach workspace.Live
	-- numb - 1 because just below the workspace.Live step lies the target character
	coroutine.wrap(function()
		local sphere = Instance.new("Part")
		sphere.Anchored = true
		sphere.CanCollide = false
		sphere.Color = Color3.fromRGB(220, 220, 220)
		sphere.Transparency = 0.5
		sphere.Material = Enum.Material.Neon
		sphere.Size = Vector3.new(0.05,0.05,0.05)
		local specialmesh = Instance.new("SpecialMesh")
		specialmesh.Parent = sphere
		specialmesh.MeshType = Enum.MeshType.Sphere
		sphere.Parent = workspace
		sphere.CFrame = Character.HumanoidRootPart.CFrame
		game:GetService("TweenService"):Create(sphere,TweenInfo.new(0.4),{Size = Vector3.new(6,6,6)}):Play()
		game.Debris:AddItem(sphere,1.5)
		wait(0.6)
		game:GetService("TweenService"):Create(sphere,TweenInfo.new(0.4),{Size = Vector3.new(0.05,0.05,0.05)}):Play()
	end)()
	for _,v in pairs(Character:GetChildren())do
		if v:IsA("Shirt")or v:IsA("Pants")then
			v:Destroy()
		end
	end
	for _,v in pairs(u4:GetChildren())do
		if v:IsA("Shirt")or v:IsA("Pants")then
			v:Clone().Parent = Character
		end
	end

	local data2 = game.ServerStorage.PlayerData[u4.Name]
	Character.Humanoid.DisplayName = tostring(data2.HouseRank.Value == "Owner" and "Lord "..data2.FirstName.Value.." "..data2.LastName.Value or data2.FirstName.Value.." "..data2.LastName.Value)
	local Race = data2.Race.Value
	
	Data.PrimaryWeapon.Value = data2.PrimaryWeapon.Value
	Data.Weapon.Value = data2.Weapon.Value
	Data.Enchant.Value = data2.Enchant.Value
	Data.Armor.Value = data2.Armor.Value


	if data2.Skills.Value:find("PrinceBlessing") then
		local v3 = Instance.new("Accessory")
		v3.Name = "Bald"
		v3.Parent = Character
		local model = game.ServerStorage.Assets.FusedHelm2:Clone()
		model.Parent = Character
	end
	for i,v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") and v:FindFirstChild("Handle") then
			v:Destroy()
		end
	end
	for i,v in pairs(u4:GetChildren()) do
		if v:IsA("Accessory") and v:FindFirstChild("Handle") then
			v:Clone().Parent = Character
		end
	end
	local Race = data2.Race.Value
	if Race == "Kasparan"then
		for _,v in pairs(game.ServerStorage.Assets.KasparanHorns:GetChildren())do
			local c = v:Clone()
			c.Parent = Character:WaitForChild("Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	elseif Race == "Azael"then
		for _,v in pairs(game.ServerStorage.Assets.AzaelHorns:GetChildren())do
			local c = v:Clone()
			c.Parent = Character:WaitForChild("Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	end
	if Race == "Lich" or Race == "Scroom" or Race == "Metascroom" or Race == "Dullahan" then
		if Race == "Scroom" then
			local Head = nil
			local Variant = data2.RaceVariant.Value
			if game.ServerStorage.Assets.ScroomHeads:FindFirstChild(Variant) then
				Head = game.ServerStorage.Assets.ScroomHeads:FindFirstChild(Variant).ScroomHead:Clone()
			else
				local numb: number = math.random(1, 5)
				if numb == 1 then
					Data.RaceVariant.Value = "Blue"
				elseif numb == 2 then
					Data.RaceVariant.Value = "Brown"
				elseif numb == 3 then
					Data.RaceVariant.Value = "Green"
				elseif numb == 4 then
					Data.RaceVariant.Value = "Shine"
				elseif numb == 5 then
					Data.RaceVariant.Value = "Default"
				end
				Variant = Data.RaceVariant.Value
				Head = game.ServerStorage.Assets.ScroomHeads:FindFirstChild(Variant).ScroomHead:Clone()
			end
			Head.Weld.Part0 = Head
			Head.Weld.Part1 = Character.Head
			Head.Parent = Character
			Character.Head.Transparency = 0.99
		end
		if Race == "Metascroom" then
			local Head = nil
			local Variant = data2.RaceVariant.Value
			if game.ServerStorage.Assets.ScroomHeads:FindFirstChild("Metascroom") then
				Head = game.ServerStorage.Assets.ScroomHeads:FindFirstChild("Metascroom").ScroomHead:Clone()
			end
			Head.Weld.Part0 = Head
			Head.Weld.Part1 = Character.Head
			Head.Parent = Character
			Character.Head.Transparency = 0.99
		end
		if Race == "Lich" then
			local lichhead = game.ServerStorage.Assets.LichHead:Clone()
			lichhead.Weld.Part0 = Character.Head
			lichhead.Weld.Part1 = lichhead
			lichhead.Weld.C1 = CFrame.new(0,0,0.2)*CFrame.Angles(math.rad(630),math.rad(90),0)
			for _,v in pairs(lichhead:GetChildren())do
				if v.Name =="EyeAttach"then
					v.EyeP.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0,Player.Backpack.ManaColor.Value),
						ColorSequenceKeypoint.new(1,Player.Backpack.ManaColor.Value),
					})
					v.EyeP.Enabled = true
				end
			end
			lichhead.Parent = Character
			Character.Head.Transparency = 0.99
		end
		if Race == "Dullahan" then
			local Head = game.ServerStorage.Assets.DullahanHead:Clone()
			Head.Parent = Character
			Head.Weld.Part0 = Head
			Head.Weld.Part1 = Character.Head
			if Data.DaysSurvived.Value >= 5 then
				local Light = game.ServerStorage.Assets.DullahanLight:Clone()
				Light.Color = u4.DullahanLight.Color

				Light.Weld.Part0 = WaitForChild(Character,"Head")
				Light.Parent = Character
			end
			Character.Head.Transparency = 0.99
		end
	end
	for i,v in pairs(Character:GetChildren()) do
		if v.Name == "ScroomHead" or v.Name == "DullahanHead" or v.Name == "LichHead" then
			v:Destroy()
		end
	end
	for i,v in pairs(game.ReplicatedStorage.Assets.Faces:GetChildren()) do
		if Character.Head:FindFirstChild(v.Name) then
			Character.Head[v.Name]:Destroy()
		end
		if FindFirstChild(u4.Head, v.Name) then
			u4.Head[v.Name]:Clone().Parent = Character.Head
		end
	end
	for _,v in pairs(Character:GetChildren())do
		if v.Name == "Head"or v.Name == "Torso"or v.Name == "Left Arm"or v.Name == "Right Arm"or v.Name == "Left Leg"or v.Name == "Right Leg"then
			v.Color = u4.Head.Color
		end
	end
end)