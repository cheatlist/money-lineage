local PlayerDatas = game.ServerStorage.PlayerData
local temphandler = require(game.ServerScriptService.Modules.TemperatureHandler)
local create = function(name,deletetime,parent)
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	if deletetime then
		game.Debris:AddItem(i,deletetime)
	end
	return i
end
local commands = {}

--[[

commands["ShakeAround"] = function(properties, visualproperties)
	for _,v in pairs(workspace.Live:GetChildren()) do
		if not v:FindFirstChild("HumanoidRootPart") then continue end
		if (v.HumanoidRootPart.Position - properties.Position).Magnitude <= properties.Radius then
			local vplayer = game.Players:GetPlayerFromCharacter(v)
			if vplayer then
				game.ReplicatedStorage.Requests.CameraShake:FireClient(vplayer, visualproperties)
			end
			
		end
	end
end

]]

local BlacklistedObjects = {
	"ParticleEmitter",
	"Fire",
	"WrapLayer",
	"SurfaceAppearance"
}

local function DoAccessories(Player)
	local Character = game.Players:GetCharacterAppearanceAsync(Player.CharacterAppearanceId)
	Character.Parent = game.ServerStorage
	local Hairs,Accessories = {},{}
	for _,v in ipairs(Character:GetChildren())do
		if v:IsA("Accessory")then
			local Attachment = v:FindFirstChildWhichIsA("Attachment",true)
			if table.find(BlacklistedObjects,v.ClassName) then
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

commands["Learn"] = function(p)
	local c
	if p:IsA("Model") then 
		c = p
		p = game.Players:GetPlayerFromCharacter(c)
	else	
		c = p.Character or p.CharacterAdded:Wait()
	end
	c.HumanoidRootPart:WaitForChild("Learn"):Play()
	local l1 = game.ServerStorage.Assets.Learn.Attachment:Clone()
	l1.ParticleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,p.Backpack:WaitForChild("ManaColor").Value),
		ColorSequenceKeypoint.new(1,p.Backpack:WaitForChild("ManaColor").Value),
	})
	l1.Parent = c:WaitForChild("Head")
	l1.ParticleEmitter:Emit(15)
	game.Debris:AddItem(l1,1.5)
end

commands["UpdateAppearance"] = function(Player, playlearnsound)
	local Character = Player.Character
	local Data = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
	local GetChildren,GetDescendants = game.GetChildren,game.GetDescendants
	local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
	local Assets = game.ServerStorage.Assets
	local ReplicatedAssets = game.ReplicatedStorage.Assets

	if not Data then return end

	local Race = Data.Race.Value
	local RaceInfo = game.ReplicatedStorage.Info.Races:FindFirstChild(Data.Race.Value)
	if Data.Ascended.Value == true then
		RaceInfo = game.ReplicatedStorage.Info.Races:FindFirstChild("Ascended"..Data.Race.Value)
	end
	local RaceVariant = Data.RaceVariant.Value
	if RaceInfo:FindFirstChild(RaceVariant) then
		RaceInfo = RaceInfo[RaceVariant]
	end
	local HairColor = RaceInfo.HairColor
	if playlearnsound then
		commands["Learn"](Player)
	end

	if Character:FindFirstChild("Bald") then
		Character:FindFirstChild("Bald"):Destroy()
	end

	local b = ReplicatedAssets.Faces:WaitForChild(Data:WaitForChild("Face").Value)
	if Race.Value == "Rigan"or Race.Value == "Fischeran" then
		b = FindFirstChild(ReplicatedAssets.Faces.Rigan,Data.Face.Value)or FindFirstChild(ReplicatedAssets.Faces,Data.Face.Value)
	end
	if Data.Ascended.Value == true then
		if Data.Race.Value == "Castellan" then
			local d = ReplicatedAssets.Faces:FindFirstChild("AscendedCastellan"):Clone()
			d.Parent = Character.Head
			d.Color3 = RaceInfo.EyeColor.Value
		elseif Data.Race.Value == "Ashiin" then
			local d = ReplicatedAssets.Faces:FindFirstChild("AscendedAshiin"):Clone()
			d.Parent = Character.Head
		elseif Data.Race.Value == "Metascroom" then
			b = ReplicatedAssets.Faces:FindFirstChild("AscendedMetascroom2")
			local d = ReplicatedAssets.Faces:FindFirstChild("AscendedMetascroom1"):Clone()
			d.Parent = Character.Head
		else 
			b = ReplicatedAssets.Faces:FindFirstChild("Ascended"..Data.Race.Value)
		end
	end
	local c = b:Clone()
	c.Color3 = RaceInfo.EyeColor.Value
	c.Parent = Character.Head

	for _,v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") and v:FindFirstChild("Handle") then
			v:Destroy()
		end
	end

	task.spawn(function()

		local Hairs,Accessories = DoAccessories(Player)
		for _,v in pairs(Accessories)do
			v.Parent = Character
		end
		for _,v in pairs(Hairs)do
			if not Character:FindFirstChild("Bald") and not RaceInfo:FindFirstChild("Bald") and not FindFirstChild(RaceInfo.Parent,"Bald") and not FindFirstChild(Character,"Bald") then
				v.Parent = Character
				if FindFirstChild(v,"Handle")then
					local SM = v.Handle:FindFirstChildWhichIsA("SpecialMesh")
					if SM then
						SM.TextureId = "rbxassetid://2599831937"
						SM.VertexColor = Vector3.new(HairColor.Value.r,HairColor.Value.g,HairColor.Value.b)
					end
					v.Handle.Color = HairColor.Value
				end
			else
				if v.Name ~= "HowlerMane" then
					v:Destroy()
				end
			end
		end
		WaitForChild(Character,"Head")
		if FindFirstChild(Character.Head,"face")then
			Character.Head.face:Destroy()
		end
		
		local SkinColor = game.Players:GetCharacterAppearanceInfoAsync(Player.UserId).bodyColor3s.torsoColor3
		
		local FaceData = Data.Face.Value
		local RaceData = Data:WaitForChild("Race")
		if Data.Vampire.Value == true then
			local B1,B2,B3 = SkinColor:ToHSV()
			SkinColor = Color3.fromHSV(B1,B2/2,B3)			
			for _,v in pairs(Character:GetDescendants()) do
				if v:IsA("Decal") and v.Name == FaceData then
					v.Color3 = Color3.fromRGB(255,0,0)
				end
			end		
		end
		local function doa()
			local Description = Character.Humanoid:GetAppliedDescription()
			Description.Head = 0
			Description.Torso = 0
			Description.LeftArm = 0
			Description.RightArm = 0
			Description.LeftLeg = 0
			Description.RightLeg = 0
			Description.HeadColor = SkinColor
			Description.LeftArmColor = SkinColor
			Description.LeftLegColor = SkinColor
			Description.RightArmColor = SkinColor
			Description.RightLegColor = SkinColor
			Description.TorsoColor = SkinColor
			Description.Shirt = 0
			Description.Pants = 0
			Character.Humanoid:ApplyDescription(Description)
		end
		local count = 2
		for i = 1,12 do
			local succ, err = pcall(function()
				return doa()
			end)
			if succ then
				break
			end
			wait(1)
		end
	end)

	local Parts = {"DragonHorn","AzaelHorn","Bald","ScroomHead","DullahanHead","LichHead","DullahanLight","AscendedKasparanHorns"}

	for _,v in pairs(Character:GetDescendants()) do
		if Parts[v.Name] then
			v:Destroy()
		end
	end

	if Character:FindFirstChild("Head") then
		Character.Head.Transparency = 0
	end

	if Data.Skills.Value:find("PrinceBlessing") then
		local v3 = Instance.new("Accessory")
		v3.Name = "Bald"
		v3.Parent = Character
	end

	if Race == "Kasparan"then
		if Data.Ascended.Value == true then
			local c = Assets.AscendedKasparanHorns:Clone()
			c.Parent = WaitForChild(Character,"Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		else
			for _,v in pairs(GetChildren(Assets.KasparanHorns))do
				local c = v:Clone()
				c.Parent = WaitForChild(Character,"Head")
				c.Weld.Part0 = Character.Head
				c.Weld.Part1 = c
			end
		end
	elseif Race == "Azael"then
		for _,v in pairs(GetChildren(Assets.AzaelHorns))do
			local c = v:Clone()
			c.Parent = WaitForChild(Character,"Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
			if Data.Ascended.Value == true then
				c.Color = Color3.new(0.403922, 0, 0.00784314)
			end
		end
	elseif Race == "Zelda"then
		for _,v in pairs(GetChildren(Assets.ZeldaHorns))do
			local c = v:Clone()
			c.Parent = WaitForChild(Character,"Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	end


	local NoHead = {"Dullahan", "Lich", "Scroom", "Metascroom"}
	local AscensionHead = {"Scroom", "Metascroom"}

	if NoHead[Race] then 
		if not (Data.Ascension.Value == true and AscensionHead[Race]) then
			for _,v in pairs(Character.Head:GetChildren()) do
				if v:IsA("Decal") then
					v:Destroy()
				end
			end
		end
	end

	if Race == "Dullahan" then
		local Head = Assets.DullahanHead:Clone()
		Head.Parent = Character
		Head.Weld.Part0 = Head
		Head.Weld.Part1 = Character.Head
		if Data.DaysSurvived.Value >= 5 then
			local Light = Assets.DullahanLight:Clone()
			if not RaceInfo then
				Light.Color = Color3.new(255, 176, 0)
			else
				Light.Color = RaceInfo.EyeColor.Value
			end
			Light.Weld.Part0 = WaitForChild(Character,"Head")
			Light.Parent = Character
		end
		Character.Head.Transparency = 0.99
		if c then
			c:Destroy()
		end
	elseif Race == "Lich"then
		local lichhead = game.ServerStorage.Assets.LichHead:Clone()
		lichhead.Weld.Part0 = Character.Head
		lichhead.Weld.Part1 = lichhead
		lichhead.Weld.C0 = CFrame.new(2.1855695e-09, 0.170000002, -0.0499999933, 0, -1, 0, 0, 0, -1, 1, 0, 0)
		lichhead.Weld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		for _,v in pairs(GetChildren(lichhead))do
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
		if c then
			c:Destroy()
		end
	elseif Race == "Scroom" and not Data.Ascended.Value == true then
		local Head
		local Variant = Data.RaceVariant.Value
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
		if c then
			c:Destroy()
		end
		for _,v in pairs(GetChildren(Character))do
			if v:IsA("Accessory")then
				v:Destroy()
			end
		end
	elseif Race == "Metascroom" and not Data.Ascended.Value == true then
		local Variant = "Metascroom"
		local Head = game.ServerStorage.Assets.ScroomHeads:FindFirstChild("Metascroom").ScroomHead:Clone()
		Head.Parent = Character
		Head.Weld.Part0 = Head
		Head.Weld.Part1 = Character.Head
		Character.Head.Transparency = 0.99
		if c then
			c:Destroy()
		end
		for _,v in pairs(GetChildren(Character))do
			if v:IsA("Accessory") and v.Name ~= "FusedHelm2" then
				v:Destroy()
			end
		end
	elseif Race == "Howler" then
		local Mane
		local Variant = Data.RaceVariant.Value
		Mane = ReplicatedAssets.HowlerManes:FindFirstChild(Variant).HowlerMane:Clone()
		Mane.Parent = Character
	end

	if Race == "Gaian"or Race == "Seraph"or Race == "Dullahan"or Race == "Cameo"or Race=="Lich" or Race=="DullahanBawa" or Character:FindFirstChild("LichSummon") or Race == "Wretch" or Race == "Phoenix" then
		local v = Instance.new("BoolValue")
		v.Name = "NoHunger"
		v.Value = true
		v.Parent = Character
	elseif Race == "Navaran" or Race == "Seraph" or Race == "DullahanBawa" then 
		Player.leaderstats:WaitForChild("Hidden").Value = true
	end
end

commands["SendDiscord"] = function(properties)
	pcall(function()
		local webhookURL = "https://discord.com/api/webhooks/962145589729050725/BVzUuMRPdcZIM6CugixNR1Ds4WMbc4S7fvLTpa27U_1sqqMOksfQ_aLGdLVDuAgbsQZ4"

		local Data = {
			["type"] = "rich",
			["content"] = properties.Content or "";
			["embed"] = {
				["title"] = properties.Title or "";
				["description"] = properties.Description or "";
				["type"] = "rich",
				["color"] = properties.Color or tonumber(0xffffff),
				["fields"] = properties.Fields or {}
			}
		}

		game:GetService("HttpService"):PostAsync(webhookURL, game:GetService("HttpService"):JSONEncode(Data))

	end)

end
commands["SendDiscord2"] = function(properties)
	pcall(function()
		local webhookURL = "https://discord.com/api/webhooks/835134100959658024/JEqvfzIoRRa6snLpulXfGG1A9WbnyJWq8yT7ArWcg7jcioTvkfi8tfm8RvsnIP0QvLuv"

		local Data = {
			["type"] = "rich",
			["content"] = properties.Content or "";
			["embed"] = {
				["title"] = properties.Title or "";
				["description"] = properties.Description or "";
				["type"] = "rich",
				["color"] = properties.Color or tonumber(0xffffff),
				["fields"] = properties.Fields or {}
			}
		}

		game:GetService("HttpService"):PostAsync(webhookURL, game:GetService("HttpService"):JSONEncode(Data))

	end)

end
commands["ChangeMoney"] = function(player,path,amount,check)
	if not player.Character then
		return nil
	end
	if path.Money.Value+amount<0 then
		return false
	end
	if check then
		return true
	end
	local add = math.round(tonumber(amount))
	path.Money.Value = math.clamp(path.Money.Value+add,0,2147483647)
	game.ReplicatedStorage.Requests.MoneyChanged:FireClient(player,path.Money.Value)
	return true
end
commands["ChangeInsight"] = function(player,path,amount,check)
	if not player.Character then
		return nil
	end
	if path.Insight.Value+amount<0 then
		return false
	end
	if check then
		return true
	end
	local add = math.round(tonumber(amount))
	if path.Race.Value == "Ashiin" and path.Ascended.Value == true then
		add += math.round(add/2)
	end
	path.Insight.Value = math.round(math.clamp(path.Insight.Value+add,0,10000000000000000000000000000000000000))
	game.ReplicatedStorage.Requests.InsightChanged:FireClient(player,path.Insight.Value)
	return true
end
commands["Metal Arm"] = function(player)
	if not player.Character then
		return
	end
	if player.Character:FindFirstChild("Arm")then
		return
	end
	if game.ServerStorage.PlayerData[player.Name].Race.Value == "Metascroom" then
		if game.ServerStorage.PlayerData[player.Name].MetalArm.Value == true then
			game.ServerStorage.PlayerData[player.Name].MetalArm.Value = false
		end
		return
	end
	local data = PlayerDatas:WaitForChild(player.Name)
	data.MetalArm.Value = true
	local metalarmassets = game.ServerStorage.Assets["Metal Arm"]
	local arm = metalarmassets.Arm:Clone()
	arm.Weld.Part0 = player.Character["Left Arm"]
	arm.Weld.Part1 = arm
	arm.Parent = player.Character
	local plate = metalarmassets.ArmPlate:Clone()
	plate.Weld.Part0 = player.Character["Torso"]
	plate.Weld.Part1 = plate
	plate.Parent = player.Character
	player.Character["Left Arm"].Transparency = 1
	local ironbody = Instance.new("ObjectValue")
	ironbody.Value = arm
	ironbody.Name = "IronBody"
	ironbody.Parent = player.Character
end
local WhiteListedMudock: {number} = {
	--userid
}
commands["ChangeArmor"] = function(player,bruharmor,outfit)
	local character = player.Character
	if not player or not character then
		return
	end
	local data = PlayerDatas:WaitForChild(player.Name, 3)
	if not data then
		return warn("no data for a character")
	end
	local armor
	for _,v in pairs(game.ReplicatedStorage.Assets.Outfits:GetChildren())do
		if string.lower(v.Name)==string.lower(bruharmor)then
			armor = v
			break
		end
	end
	if armor then
		if data.Armor.Value == "Spider Cloak" and armor.Name ~= "Spider Cloak" then
			data.Artifact.Value = "None"
		end
		if armor.Name == "Goku"and data.Race.Value ~= " "then
			if not outfit then
				data.Armor.Value = 'Rags'
			end
			return
		end
		if armor.Name == "Florian"and data.Race.Value ~= "Florian"then
			return
		end
		if not outfit then
			for _,v in pairs(character.Boosts:GetChildren())do
				if v:FindFirstChild("Armor")then
					v:Destroy()
				end
			end
		end
		for _,v in pairs(player.Character:GetChildren())do
			if v:IsA("Shirt")or v:IsA("Pants")then
				v:Destroy()
			end
		end
		if armor.Name == 'Mudock'and not table.find(WhiteListedMudock, player.UserId)then
			if not outfit then
				data.Armor.Value = 'Rags'
			end
			return
		end
		if not outfit then
			for _: number, v in ipairs(armor.Stats:GetChildren())do
				local c1 = v:Clone()
				local v1 = Instance.new("Accessory")
				v1.Name = "Armor"
				v1.Parent = c1
				if v.Name == 'NoHunger'then
					c1.Parent = character
				else
					c1.Parent = character:WaitForChild("Boosts")
				end
			end
			data.Armor.Value = armor.Name
		end
		local gender = "Male"
		if armor:FindFirstChild("Female")and data.Gender.Value == "Female"then
			gender = "Female"
		end
		armor[gender].Shirt:Clone().Parent = character
		armor[gender].Pants:Clone().Parent = character

		local color = string.split(data.DyeColor.Value,",")
		if #color == 3 then
			for _,v in pairs(character:GetChildren())do
				if v:IsA("Shirt")or v:IsA("Pants")then
					v.Color3 = Color3.fromRGB(color[1],color[2],color[3])
				end
			end
		else
			data.DyeColor.Value = ""
		end
	end
end
commands["ChangeWeapon"] = function(player,weapon,dont, dont2)
	if not player.Character then
		return
	end
	local data = PlayerDatas:WaitForChild(player.Name)
	if not data then
		return
	end
	if weapon ~= "Fairfrozen" then
		if data.Artifact.Value == "Fairfrozen" then
			data.Artifact.Value = "None"
		end
	end
	local character = player.Character
	if not dont2 then
		if dont then
			if weapon == "Bronze Dagger" or weapon == "Steel Dagger" or weapon == "Mythril Dagger" then
				data.Weapon.Value = "Dagger"
				data.PrimaryWeapon.Value = weapon
			elseif weapon == "Tanto"then
				data.Weapon.Value = "Dagger"
				data.PrimaryWeapon.Value = "Tanto"
			elseif weapon == "Spirit Dagger" then
				data.Weapon.Value = "Dagger"
				data.PrimaryWeapon.Value = "Spirit Dagger"
			elseif weapon == "Bronze Sword" or weapon == "Steel Sword" or weapon == "Mythril Sword" or weapon == "Illusory Sword" then
				data.Weapon.Value = "Sword"
				data.PrimaryWeapon.Value = weapon
			elseif weapon == "Spirit Sword"then
				data.Weapon.Value = "Sword"
				data.PrimaryWeapon.Value = "Spirit Sword"
			elseif weapon == "Bronze Spear" or weapon == "Steel Spear" or weapon == "Mythril Spear" then
				data.Weapon.Value = "Spear"
				data.PrimaryWeapon.Value = weapon
			elseif weapon == "Katana"then
				data.Weapon.Value = "Katana"
				data.PrimaryWeapon.Value = "Katana"
			elseif weapon == "Mythril Church Spear"then
				data.Weapon.Value = "Spear"
				data.PrimaryWeapon.Value = "Mythril Church Spear"
			elseif weapon == "Thorn Spear"then
				data.Weapon.Value = "Spear"
				data.PrimaryWeapon.Value = "Thorn Spear"
			elseif weapon == "Broom Sword" then
				data.Weapon.Value = "Sword"
				data.PrimaryWeapon.Value = "Broom Sword"
			elseif weapon == "SealedSword"then
				data.Weapon.Value = "Sword"
				data.PrimaryWeapon.Value = "SealedSword"
				if not string.find(data.Skills.Value, "White Fire Charge")then
					data.Skills.Value ..= ",White Fire Charge"
				end
			elseif weapon == "Hammer" or weapon == "Mythril Hammer"then
				data.Weapon.Value = "Hammer"
				data.PrimaryWeapon.Value = "Hammer"
			elseif weapon == "Wraith Sword" then
				data.Weapon.Value = "Sword"
				data.PrimaryWeapon.Value = "WraithSword"
			elseif weapon == 'DeathSword'then
				data.Weapon.Value = 'Sword'
				data.PrimaryWeapon.Value = "DeathSword"
			elseif weapon == "Fairfrozen"then
				data.Weapon.Value = "Spear"
				data.PrimaryWeapon.Value = "Fairfrozen"
			elseif weapon == "Cursedfrozen"then
				data.Weapon.Value = "Spear"
				data.PrimaryWeapon.Value = "Cursedfrozen"		
			elseif weapon == "Bisento"then
				data.Weapon.Value = "Spear"
				data.PrimaryWeapon.Value = "Bisento"
			elseif weapon == "Iron Greatsword" then
				data.Weapon.Value = "Greatsword"
				data.PrimaryWeapon.Value = "Iron Greatsword"
			elseif weapon == "Templar Greatsword" then
				data.Weapon.Value = "Greatsword"
				data.PrimaryWeapon.Value = "Templar Greatsword"
			elseif weapon == "Abyss Greatsword" then
				data.Weapon.Value = "Greatsword"
				data.PrimaryWeapon.Value = "Abyss Greatsword"
			elseif weapon == "Lunar Greatsword" then
				data.Weapon.Value = "Greatsword"
				data.PrimaryWeapon.Value = "Lunar Greatsword"
			elseif weapon == "norpGS"then
				data.Weapon.Value = "Greatsword"
				data.PrimaryWeapon.Value = "norpGS"
			elseif weapon == "EXTREME_GS" then
				data.Weapon.Value = "Greatsword"
				data.PrimaryWeapon.Value = "EXTREME_GS"
			elseif weapon == "Broom Spear"then
				data.Weapon.Value = "Spear"
				data.PrimaryWeapon.Value = "Broom Spear"
			elseif weapon == "Rapier"or weapon == "Mythril Rapier"then
				data.Weapon.Value = "Dagger"
				data.PrimaryWeapon.Value = "Rapier"
			elseif weapon == "Pronged Mythril Spear" then
				data.Weapon.Value = "Spear"
				data.PrimaryWeapon.Value = "Pronged Mythril Spear"
			elseif weapon == "Twinfang"then
				data.Weapon.Value = "Dagger"
				data.PrimaryWeapon.Value = "Twinfang"
			elseif weapon == "Caestus"then
				data.Weapon.Value = "None"
				data.PrimaryWeapon.Value = "Caestus"
			elseif weapon == "Cursed Blade" or weapon == "Dark Sword" then
				data.Weapon.Value = "Sword"
				data.PrimaryWeapon.Value = "Dark Sword"
			else
				data.Weapon.Value = "None"
				data.PrimaryWeapon.Value = "None"
				character.Humanoid:UnequipTools()
				for _,v in pairs(character:GetDescendants())do
					if v:FindFirstChild("PrimaryWeapon")or
						v:FindFirstChild("RequiresWeapon")or
						v:FindFirstChild("PropWeld")or
						v.Name == "HasWeapon"
					then
						v:Destroy()
					end
				end
				for _,v in pairs(player.Backpack:GetDescendants())do
					if v:FindFirstChild("PrimaryWeapon")or
						v:FindFirstChild("RequiresWeapon")or
						v:FindFirstChild("PropWeld")or
						v.Name == "HasWeapon"
					then
						v:Destroy()
					end
				end
				for _,v in pairs(character.Humanoid:GetPlayingAnimationTracks())do
					v:Stop()
				end
			end
			return
		end
		character.Humanoid:UnequipTools()
		for _,v in pairs(character:GetDescendants())do
			if v:FindFirstChild("PrimaryWeapon")or
				v:FindFirstChild("RequiresWeapon")or
				v:FindFirstChild("Prop")or
				v.Name == "HasWeapon"
			then
				v:Destroy()
			end
		end
		for _,v in pairs(player.Backpack:GetDescendants())do
			if v:FindFirstChild("PrimaryWeapon")or
				v:FindFirstChild("RequiresWeapon")or
				v:FindFirstChild("Prop")or
				v.Name == "HasWeapon"
			then
				v:Destroy()
			end
		end
		for _,v in pairs(character.Humanoid:GetPlayingAnimationTracks())do
			v:Stop()
		end
	end
	local clone
	if dont2 then
		clone = script[weapon]:Clone()
		clone.Parent = nil
		return clone
	end
	if weapon == "Bronze Dagger" or weapon == "Steel Dagger" or weapon == "Mythril Dagger" then
		local tool = game.ServerStorage.Weapons.Dagger:Clone()
		data.PrimaryWeapon.Value = weapon
		tool.Parent = player.Backpack
		data.Weapon.Value = "Dagger"
		clone = script[weapon]:Clone()
		clone.Parent = nil
	elseif weapon == "Tanto"then
		local tool = game.ServerStorage.Weapons.Dagger:Clone()
		data.PrimaryWeapon.Value = "Tanto"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Dagger"
		clone = script.Tanto:Clone()
		clone.Parent = nil
	elseif weapon == "Spirit Dagger"then
		local tool = game.ServerStorage.Weapons.Dagger:Clone()
		data.PrimaryWeapon.Value = "Spirit Dagger"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Dagger"
		clone = script["Spirit Dagger"]:Clone()
		clone.Parent = nil
		clone.Color = player.Backpack.ManaColor.Value
	elseif weapon == "Bronze Spear" or weapon == "Steel Spear" or weapon == "Mythril Spear" then
		local tool = game.ServerStorage.Weapons.Spear:Clone()
		data.PrimaryWeapon.Value = weapon
		tool.Parent = player.Backpack
		data.Weapon.Value = "Spear"
		clone = script[weapon]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0,0.25,0.649999976,0.573557019,1.07884407e-05,-0.819165647,-0.819165647,2.07424164e-05,-0.57355696,1.07884407e-05,0.99999994,2.07424164e-05)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Pronged Mythril Spear" then
		local tool = game.ServerStorage.Weapons.Spear:Clone()
		data.PrimaryWeapon.Value = "Pronged Mythril Spear"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Spear"
		clone = script["Pronged Mythril Spear"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(-0.5, 0.75, 0.649999976, -0.819186211, -4.05311584e-06, -0.573527992, -0.573527992, 1.26957893e-05, 0.819186091, 4.05311584e-06, 1.00000012, -1.28746033e-05)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Fairfrozen"then
		local tool = game.ServerStorage.Weapons.Spear:Clone()
		data.PrimaryWeapon.Value = "Fairfrozen"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Spear"
		if not data.Skills.Value:find("Subzero Strike") then
			data.Skills.Value = data.Skills.Value..",Subzero Strike"
		end
		clone = script.Fairfrozen:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0,0.25,0.649999976,0.573557019,1.07884407e-05,-0.819165647,-0.819165647,2.07424164e-05,-0.57355696,1.07884407e-05,0.99999994,2.07424164e-05)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Bisento"then
		local tool = game.ServerStorage.Weapons.Spear:Clone()
		data.PrimaryWeapon.Value = "Bisento"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Spear"
		clone = script.Bisento:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0,0.25,0.649999976,0.573557019,1.07884407e-05,-0.819165647,-0.819165647,2.07424164e-05,-0.57355696,1.07884407e-05,0.99999994,2.07424164e-05)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Staff of Pain"then
		data.PrimaryWeapon.Value = "Staff of Pain"
		data.Weapon.Value = "Sword"
		clone = script["Staff of Pain"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0, 0, 0.5, 0.866007268, -0.500031412, 0, 0.500031412, 0.866007268, 0, 0, 0, 1)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Iron Greatsword" then
		local tool = game.ServerStorage.Weapons.Greatsword:Clone()
		data.PrimaryWeapon.Value = "Iron Greatsword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Greatsword"
		--[[if not data.Skills.Value:find("Oust") then
			data.Skills.Value = data.Skills.Value.."Oust"
		end]]
		clone = script["Iron Greatsword"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0, 0, 0.600000024, -0.5, -4.70876694e-05, 0.866025329, -0.866025388, -4.05311584e-05, -0.5, 5.86211681e-05, -1, -2.05039978e-05)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Cursedfrozen"then
		local tool = game.ServerStorage.Weapons.Spear:Clone()
		data.PrimaryWeapon.Value = "Cursedfrozen"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Spear"
		if not data.Skills.Value:find("Subzero Strike") then
			data.Skills.Value = data.Skills.Value..",Subzero Strike"
		end
		clone = script.Cursedfrozen:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0,0.25,0.649999976,0.573557019,1.07884407e-05,-0.819165647,-0.819165647,2.07424164e-05,-0.57355696,1.07884407e-05,0.99999994,2.07424164e-05)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Templar Greatsword" then
		local tool = game.ServerStorage.Weapons.Greatsword:Clone()
		data.PrimaryWeapon.Value = "Templar Greatsword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Greatsword"
		clone = script["Templar Greatsword"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0, 0, 0.600000024)
		clone.Weld.C1 = CFrame.new(0, -1, 0, -0.707134247, 0.707079291, 0, -0.707079291, -0.707134247, 0, 0, 0, 1)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Abyss Greatsword" then
		local tool = game.ServerStorage.Weapons.Greatsword:Clone()
		data.PrimaryWeapon.Value = "Abyss Greatsword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Greatsword"
		clone = script["Abyss Greatsword"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0, 0, 0.600000024, -0.5, -4.70876694e-05, 0.866025329, -0.866025388, -4.05311584e-05, -0.5, 5.86211681e-05, -1, -2.05039978e-05)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Lunar Greatsword" then
		local tool = game.ServerStorage.Weapons.Greatsword:Clone()
		data.PrimaryWeapon.Value = "Lunar Greatsword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Greatsword"
		clone = script["Lunar Greatsword"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(-0.0520000011, 0.345999986, 0.575999975, -0.766061664, 0.642767608, 0, -0.642767608, -0.766061664, 0, 0, 0, 1)
		clone.Weld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "EXTREME_GS" then
		local tool = game.ServerStorage.Weapons.Greatsword:Clone()
		data.Weapon.Value = "Greatsword"
		data.PrimaryWeapon.Value = "EXTREME_GS"
		tool.Parent = player.Backpack
		clone = script.EXTREME_GS:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.Weld.Part0 = character:WaitForChild("Back")
		clone.Parent = character.Torso
	elseif weapon == "norpGS" then
		local tool = game.ServerStorage.Weapons.norpsword:Clone()
		data.Weapon.Value = "Greatsword"
		data.PrimaryWeapon.Value = "norpGS"
		tool.Parent = player.Backpack
		clone = script.norpGS:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.Weld.Part0 = character:WaitForChild("Back")
		clone.Parent = character.Torso
	elseif weapon == "Broom Spear"then
		local tool = game.ServerStorage.Weapons.Spear:Clone()
		data.PrimaryWeapon.Value = "Broom Spear"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Spear"
		clone = script["Broom Spear"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(-0.5, 1, 0.5, 0.819155693, -0.573571265, 0, 0.573571265, 0.819155693, 0, 0, 0, 1)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Mythril Church Spear"then
		local tool = game.ServerStorage.Weapons.Spear:Clone()
		data.PrimaryWeapon.Value = "Mythril Church Spear"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Spear"
		clone = script["Mythril Church Spear"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
		clone.ChurchBeam.Attachment1 = character["Right Arm"].SpearAttach
	elseif weapon == "Thorn Spear"then
		local tool = game.ServerStorage.Weapons.Spear:Clone()
		data.PrimaryWeapon.Value = "Thorn Spear"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Spear"
		clone = script["Thorn Spear"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0, 0.25, 0.649999976, -1.44230144e-05, -0.707106769, -0.707106769, 6.01238826e-05, 0.707106769, -0.707106769, 1, -5.27126176e-05, 3.23153945e-05)
		clone.Weld.Part1 = clone
		clone.Weld.C1 = CFrame.new(0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		clone.Parent = character.Torso
	elseif weapon == "Broom Sword" then
		local tool = game.ServerStorage.Weapons.Sword:Clone()
		data.PrimaryWeapon.Value = "Broom Sword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Sword"
		clone = script["Broom Sword"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0.25, -0.5, 0.5, -0.866007447, 0.500031412, 0, -0.500031412, -0.866007447, 0, 0, 0, 1)
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Bronze Sword" or weapon == "Steel Sword" or weapon == "Mythril Sword" then
		local tool = game.ServerStorage.Weapons.Sword:Clone()
		data.PrimaryWeapon.Value = weapon
		tool.Parent = player.Backpack
		data.Weapon.Value = "Sword"
		clone = script[weapon]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Illusory Sword" then
		local tool = game.ServerStorage.Weapons.Sword:Clone()
		data.PrimaryWeapon.Value = weapon
		tool.Parent = player.Backpack
		data.Weapon.Value = "Sword"
		clone = script[weapon]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
		for i,v in pairs(clone:GetChildren()) do
			if v:IsA("MeshPart") then
				v.Transparency = 0
			end
		end
	elseif weapon == "Spirit Sword"then
		local tool = game.ServerStorage.Weapons.Sword:Clone()
		data.PrimaryWeapon.Value = "Spirit Sword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Sword"
		clone = script["Spirit Sword"]:Clone()
		clone.Color = player.Backpack.ManaColor.Value
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Dark Sword"then
		local tool = game.ServerStorage.Weapons["Cursed Blade"]:Clone()
		data.PrimaryWeapon.Value = "Dark Sword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Sword"
		clone = script["Dark Sword"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "WraithSword"then
		local tool = game.ServerStorage.Weapons.Sword:Clone()
		data.PrimaryWeapon.Value = "WraithSword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Sword"
		clone = script["WraithSword"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "DeathSword"then
		local tool = game.ServerStorage.Weapons.Sword:Clone()
		data.PrimaryWeapon.Value = "DeathSword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Sword"
		clone = script["DeathSword"]:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "SealedSword"then
		local tool = game.ServerStorage.Weapons.Sword:Clone()
		data.PrimaryWeapon.Value = "SealedSword"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Sword"
		if not string.find(data.Skills.Value, "White Fire Charge")then
			data.Skills.Value ..= ",White Fire Charge"
		end
		clone = script.SealedSword:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Hammer" then
		local tool = game.ServerStorage.Weapons.Hammer:Clone()
		data.PrimaryWeapon.Value = "Hammer"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Hammer"
		clone = script.Hammer:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.C0 = CFrame.new(0, 0.25, 0.600000024, 0.866007268, -0.500031412, 0, 0.500031412, 0.866007268, 0, 0, 0, 1)
		clone.Parent = character.Torso
	elseif weapon == "Katana"then
		local tool = game.ServerStorage.Weapons.Katana:Clone()
		data.PrimaryWeapon.Value = "Katana"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Katana"
		local sheath = script.Sheath:Clone()
		sheath.Weld.Part0 = character.Torso
		sheath.Weld.Part1 = sheath
		sheath.Parent = character.Torso
		clone = script.Katana:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = sheath
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Murasama"then
		local tool = game.ServerStorage.Weapons.Katana:Clone()
		data.PrimaryWeapon.Value = "Murasama"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Katana"
		local sheath = script.Sheath2:Clone()
		sheath.Weld.Part0 = character.Torso
		sheath.Weld.Part1 = sheath
		sheath.Parent = character.Torso
		clone = script.Murasama:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = sheath
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Rapier" or  weapon == "Mythril Rapier"then
		local tool = game.ServerStorage.Weapons.Rapier:Clone()
		data.PrimaryWeapon.Value = "Rapier"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Dagger"
		clone = script.Rapier:Clone()
		clone.Parent = nil
		clone.PropWeld.Part0 = nil
		clone.PropWeld.Part1 = nil
		clone.Weld.Part0 = character.Torso
		clone.Weld.Part1 = clone
		clone.Parent = character.Torso
	elseif weapon == "Twinfang" then
		local tool = game.ServerStorage.Weapons.Twinfang:Clone()
		data.PrimaryWeapon.Value = "Twinfang"
		tool.Parent = player.Backpack
		data.Weapon.Value = "Dagger"
		-- Twinfang has no weapon model of its own - it's just two Mythril Dagger props. Like
		-- every other weapon, the cosmetic is created unparented here - actual PropWeld/Parent
		-- wiring (to Character.Hilt) happens on equip/unequip in WeaponEquip.luau, not here
		-- (see the "Bronze Dagger"/"Steel Dagger"/"Mythril Dagger" branch there for the
		-- pattern this mirrors). The off-hand piece has no slot of its own in the WEAPON/
		-- `clone` single-value pipeline (return clone -> CharacterHandler's WEAPON upvalue ->
		-- 4th arg into every Activator call), so it's linked via an "OffhandPiece" ObjectValue
		-- child that WeaponEquip.luau's "Twinfang" branches follow to weld/unweld it to
		-- Character.LeftHilt in lockstep with the main-hand piece.
		clone = script["Mythril Dagger"]:Clone()
		clone.Name = "Twinfang"
		clone.Parent = nil
		local lc = script["Mythril Dagger"]:Clone()
		lc.Name = "TwinfangOffhand"
		lc.Parent = nil
		local offhandRef = Instance.new("ObjectValue")
		offhandRef.Name = "OffhandPiece"
		offhandRef.Value = lc
		offhandRef.Parent = clone
		if data.Enchant.Value~=""then
			local enchant = string.split(data.Enchant.Value, ",")
			for i,v in pairs(enchant) do
				if v == "" then
					table.remove(enchant, table.find(enchant, v))
				end
			end
			if #enchant > 0 then
				for i = 1,#enchant do
					if script:FindFirstChild(enchant[i]) and script[enchant[i]]:FindFirstChild("EnchantEffect") then
						-- `clone` (the right-hand piece) gets its EnchantEffect from the
						-- shared trailing block below (it runs for any branch that sets
						-- `clone`) - only the off-hand piece needs handling here.
						script[enchant[i]].EnchantEffect:Clone().Parent = lc
					end
				end
			end
		end
	elseif weapon == "Caestus"then
		data.PrimaryWeapon.Value = "Caestus"
		data.Weapon.Value = "None"
		local lc = script.LeftCaestus:Clone()
		lc.Weld.Part0 = character["Left Arm"]
		lc.Weld.Part1 = lc
		lc.Parent = character.Torso
		local rc = script.RightCaestus:Clone()
		rc.Weld.Part0 = character["Right Arm"]
		rc.Weld.Part1 = rc
		rc.Parent = character.Torso
		if data.Enchant.Value~=""then

			local enchant = string.split(data.Enchant.Value, ",")
			for i,v in pairs(enchant) do
				if v == "" then
					table.remove(enchant, table.find(enchant, v))
				end
			end
			if #enchant > 0 then
				for i = 1,#enchant do
					if script:FindFirstChild(enchant[i]) and script[enchant[i]]:FindFirstChild("EnchantEffect") then
						script[enchant[i]].EnchantEffect:Clone().Parent = lc
						script[enchant[i]].EnchantEffect:Clone().Parent = rc
					end
				end
			end
		end

	end
	if clone and data.Enchant.Value~=""then

		local enchant = string.split(data.Enchant.Value, ",")
		for i,v in pairs(enchant) do
			if v == "" then
				table.remove(enchant, table.find(enchant, v))
			end
		end
		if #enchant > 0 then
			for i = 1,#enchant do
				if script:FindFirstChild(enchant[i]) and script[enchant[i]]:FindFirstChild("EnchantEffect") then
					script[enchant[i]].EnchantEffect:Clone().Parent = clone
				end
			end
		end
	end
	commands.UpdateSkills(player)
	commands.UpdateSpells(player)
	commands.UpdateGodSpells(player)

	return clone
end

commands["RacialAbilities"] = function(Player,data)
	local RacialAbilities = game.ServerStorage.RacialAbilities
	local Race = data:WaitForChild("Race")
	local Area = data:WaitForChild("Area")
	if Race.Value == "Madrasian" then
		local has = Player.Backpack:FindFirstChild("Shift") or Player.Character:FindFirstChild("Shift")
		if not has then
			RacialAbilities.Shift:Clone().Parent = Player.Backpack
		end
		local has2 = Player.Backpack:FindFirstChild("Trinket Shift") or Player.Character:FindFirstChild("Trinket Shift")
		if not has2 and (data.IsUltra.Value == true or data.Hybrid.Value ~= "") then
			RacialAbilities["Trinket Shift"]:Clone().Parent = Player.Backpack
		end
		if data.Ascended.Value == true then
			local has3 = Player.Backpack:FindFirstChild("Plasticity") or Player.Character:FindFirstChild("Plasticity")
			if not has3 and (data.IsUltra.Value == true or data.Hybrid.Value ~= "") then
				RacialAbilities["Plasticity"]:Clone().Parent = Player.Backpack
			end
			local has4 = Player.Backpack:FindFirstChild("False Assumptions") or Player.Character:FindFirstChild("False Assumptions")
			if not has4 and (data.IsUltra.Value == true or data.Hybrid.Value ~= "") then
				RacialAbilities["False Assumptions"]:Clone().Parent = Player.Backpack
			end
		end
	end
	if Race.Value == "Ashiin"then
		local has = Player.Backpack:FindFirstChild("TrainedCombat")
		if not has then
			RacialAbilities.TrainedCombat:Clone().Parent = Player.Backpack
		end
		local has2 = Player.Backpack:FindFirstChild("Shoulder Throw")or Player.Character:FindFirstChild("Shoulder Throw")
		if not has2 and data.Skills.Value:find("Shoulder Throw") then
			RacialAbilities["Shoulder Throw"]:Clone().Parent = Player.Backpack
		end
		local has3 = Player.Backpack:FindFirstChild("MercenaryCarry")
		if not has3 then
			RacialAbilities["MercenaryCarry"]:Clone().Parent = Player.Backpack
		end
		local has4 = PlayerDatas[Player.Name].Skills.Value:find("Agility")
		if not has4 then
			data.Skills.Value ..= ",Agility"
		end
	elseif Race.Value == "Dullahan"then
		local has = Player.Backpack:FindFirstChild("Pumpkin Grenade")or Player.Character:FindFirstChild("Pumpkin Grenade")
		if not has then
			RacialAbilities["Pumpkin Grenade"]:Clone().Parent = Player.Backpack
		end
	elseif Race.Value == "DullahanBawa"then
		local has = Player.Backpack:FindFirstChild("Pumpkin Grenade")or Player.Character:FindFirstChild("Pumpkin Grenade")
		if not has then
			RacialAbilities["Pumpkin Grenade"]:Clone().Parent = Player.Backpack
		end
		if not Player.Character:FindFirstChild("WindDodges")then
			local v = Instance.new("NumberValue")
			v.Name = "WindDodges"
			v.Value = 4
			v.Parent = Player.Character
		else
			if Player.Character.WindDodges.Value < 4 then
				Player.Character.WindDodges.Value += 1
			end
		end	
	elseif Race.Value == "Haseldan"then
		local has = Player.Backpack:FindFirstChild("Bloodline")or Player.Character:FindFirstChild("Bloodline")
		if not has and (data.IsUltra.Value == true or data.Hybrid.Value ~= "") then
			RacialAbilities.Bloodline:Clone().Parent = Player.Backpack
		end
		if data.Ascended.Value == true then
			local has2 = Player.Backpack:FindFirstChild("Rage")or Player.Character:FindFirstChild("Rage")
			if not has2 then
				RacialAbilities.Rage:Clone().Parent = Player.Backpack
			end
		end
	elseif Race.Value == "Gaian"then
		local ironbody = Instance.new("ObjectValue")
		ironbody.Value = Player.Character:WaitForChild("Left Arm")
		ironbody.Name = "IronBody"
		ironbody.Parent = Player.Character
		local ironbody2 = Instance.new("ObjectValue")
		ironbody2.Value = Player.Character:WaitForChild("Right Arm")
		ironbody2.Name = "IronBody"
		ironbody2.Parent = Player.Character
		local has = Player.Backpack:FindFirstChild("Repair")or Player.Character:FindFirstChild("Repair")
		if not has then
			RacialAbilities.Repair:Clone().Parent = Player.Backpack
		end	
		local has2 = Player.Backpack:FindFirstChild("SlashResistance")
		if not has2 then
			RacialAbilities.SlashResistance:Clone().Parent = Player.Backpack
		end
		if data.Ascended.Value == true then
			local has3 = Player.Backpack:FindFirstChild("Rocket Launcher") or Player.Character:FindFirstChild("Rocket Launcher")
			if not has3 then
				RacialAbilities["Rocket Launcher"]:Clone().Parent = Player.Backpack
			end
			local has4 = Player.Backpack:FindFirstChild("Overclock") or Player.Character:FindFirstChild("Overclock")
			if not has4 then
				RacialAbilities["Overclock"]:Clone().Parent = Player.Backpack
			end
		end
	elseif Race.Value == "Cameo"then
		if Player.Character.Boosts:FindFirstChild("ColdResist") and Player.Character.Boosts.ColdResist:FindFirstChild("Armor") then
			Player.Character.Boosts.ColdResist.Value = 0.25
		else
			local colderes = Instance.new("IntValue")
			colderes.Value = 0.25
			colderes.Name = "ColdResist"
			colderes.Parent = Player.Character.Boosts
		end
	elseif Race.Value == "Dzin" then
		local has = Player.Backpack:FindFirstChild("Awakened") or Player.Character:FindFirstChild("Awakened")
		if not has and (data.IsUltra.Value == true or data.Hybrid.Value ~= "") then
			RacialAbilities.Awakened:Clone().Parent = Player.Backpack
		end
		local has2 = Player.Backpack:FindFirstChild("World's Pulse")or Player.Character:FindFirstChild("World's Pulse")
		if not has2 then
			RacialAbilities["World's Pulse"]:Clone().Parent = Player.Backpack
		end
	elseif Race.Value == "Rigan"then
		local has = Player.Backpack:FindFirstChild("Flood")or Player.Character:FindFirstChild("Flood")
		if not has and (data.IsUltra.Value == true or data.Hybrid.Value ~= "") then
			RacialAbilities.Flood:Clone().Parent = Player.Backpack
		end
		if data.Ascended.Value == true then
			local has2 = Player.Backpack:FindFirstChild("Ray of Frost")or Player.Character:FindFirstChild("Ray of Frost")
			if not has2 then
				RacialAbilities["Ray of Frost"]:Clone().Parent = Player.Backpack
			end
		end
	elseif Race.Value == "Wretch" then
		local has = Player.Backpack:FindFirstChild("MercenaryCarry")or Player.Character:FindFirstChild("MercenaryCarry")
		if not has then
			RacialAbilities.MercenaryCarry:Clone().Parent = Player.Backpack
		end
	elseif Race.Value == "Lich"then
		local has = Player.Backpack:FindFirstChild("Vagrant Soul")or Player.Character:FindFirstChild("Vagrant Soul")
		if not has then
			RacialAbilities["Vagrant Soul"]:Clone().Parent = Player.Backpack
		end
		local has2 = Player.Backpack:FindFirstChild("SlashResistance")
		if not has2 then
			RacialAbilities["SlashResistance"]:Clone().Parent = Player.Backpack
		end
		local ironbody = Instance.new("ObjectValue")
		ironbody.Value = Player.Character:WaitForChild("Left Arm")
		ironbody.Name = "IronBody"
		ironbody.Parent = Player.Character
		local ironbody2 = Instance.new("ObjectValue")
		ironbody2.Value = Player.Character:WaitForChild("Right Arm")
		ironbody2.Name = "IronBody"
		ironbody2.Parent = Player.Character
		local has = PlayerDatas[Player.Name].Skills.Value:find("Gate")
		if not has then
			PlayerDatas[Player.Name].Skills.Value ..= ",Gate,DeepforestObelisk,DesertObelisk,ForestObelisk,ShoreObelisk,SigilObelisk,SnailObelisk,TundraObelisk"
		end
	--[[
	elseif (Race.Value == "Seraph" or Race.Value == "Phoenix") and Area.Value ~= "The Hall of Shattered Wills" and Area.Value ~= "norpa" and data.Lives.Value > 0 then
		local has = Player.Backpack:FindFirstChild("Angel Fall")or Player.Character:FindFirstChild("Angel Fall")
		if not has then
			local add = {
				"NoFall",
				"Stun",
				"AngelForm",
			}
			for _,v in pairs(add) do
				local z = Instance.new("Accessory")
				z.Name = v
				z.Parent = Player.Character
			end
			local fall = RacialAbilities["Angel Fall"]:Clone()
			fall.Parent = Player.Backpack
			if Race.Value == "Phoenix" then
				fall.Name = "Phoenix Descent"
			end
			Player.Character:WaitForChild("HumanoidRootPart")
			task.spawn(function()
				for num = 1,10 do
					local Descendants = Player.Character:GetDescendants()
					for i = 1,#Descendants do
						local v = Descendants[i]
						if v:IsA("BasePart") and v.Name~="Hilt" and v.Parent.Name ~= "RuneArmLeft" and v.Parent.Name ~= "RuneArmRight" and v.Name ~= "Back" and v.Name ~= "HumanoidRootPart" and v.Name ~= "AngelForm" then
							v.Transparency = 1
						end
					end
					task.wait(.05)
				end
			end)
		end
		local has = PlayerDatas[Player.Name].Skills.Value:find("Gate")
		if not has then
			PlayerDatas[Player.Name].Skills.Value ..= ",Gate,DeepforestObelisk,DesertObelisk,ForestObelisk,ShoreObelisk,SigilObelisk,SnailObelisk,TundraObelisk"
		end]]
	elseif Race.Value == "Scroom"then
		local has = Player.Backpack:FindFirstChild("Decompose")or Player.Character:FindFirstChild("Decompose")
		if not has then
			RacialAbilities.Decompose:Clone().Parent = Player.Backpack
		end
		local has = Player.Backpack:FindFirstChild("Detoxify")or Player.Character:FindFirstChild("Detoxify")
		if not has and data.Class.Value ~= "" then
			RacialAbilities.Detoxify:Clone().Parent = Player.Backpack
		end
	elseif Race.Value == "Metascroom" then
		local has = Player.Backpack:FindFirstChild("Decompose")or Player.Character:FindFirstChild("Decompose")
		if not has then
			RacialAbilities.Decompose:Clone().Parent = Player.Backpack
		end
		local has2 = Player.Backpack:FindFirstChild("Repair")or Player.Character:FindFirstChild("Repair")
		if not has2 then
			RacialAbilities.Repair:Clone().Parent = Player.Backpack
		end
		local has3 = Player.Backpack:FindFirstChild("SlashResistance")
		if not has3 then
			RacialAbilities.SlashResistance:Clone().Parent = Player.Backpack
		end
		local ironbody = Instance.new("ObjectValue")
		ironbody.Value = Player.Character:WaitForChild("Left Arm")
		ironbody.Name = "IronBody"
		ironbody.Parent = Player.Character
		local ironbody2 = Instance.new("ObjectValue")
		ironbody2.Value = Player.Character:WaitForChild("Right Arm")
		ironbody2.Name = "IronBody"
		ironbody2.Parent = Player.Character
		local has = Player.Backpack:FindFirstChild("Exhaust")or Player.Character:FindFirstChild("Exhaust")
		if not has and data.Class.Value ~= "" then
			RacialAbilities.Exhaust:Clone().Parent = Player.Backpack
		end
	elseif Race.Value == "Vind"then
		local has = Player.Backpack:FindFirstChild("Tempest Soul")or Player.Character:FindFirstChild("Tempest Soul")
		if not has then
			RacialAbilities["Tempest Soul"]:Clone().Parent = Player.Backpack
		end

	elseif Race.Value == "Morvid"then
		local FeatherFall = Instance.new("Accessory")
		FeatherFall.Name = "FeatherFall"
		FeatherFall.Parent = Player.Backpack
		local has = Player.Backpack:FindFirstChild("Flock")or Player.Character:FindFirstChild("Flock")
		if not has and data.Class.Value ~= "" then
			RacialAbilities.Flock:Clone().Parent = Player.Backpack
		end
	elseif Race.Value == "Howler"then
		local has = Player.Backpack:FindFirstChild("Herd") or Player.Character:FindFirstChild("Herd")
		if not has and data.Class.Value ~= "" then
			RacialAbilities.Herd:Clone().Parent = Player.Backpack
		end
	elseif Race.Value == "Kasparan"then
		local has = Player.Backpack:FindFirstChild("Respirare") or Player.Character:FindFirstChild("Respirare")
		if not has and data.IsUltra.Value == true or data.Hybrid.Value ~= "" then
			RacialAbilities.Respirare:Clone().Parent = Player.Backpack
		end
		if not data.Skills.Value:find("DragonSpeech") then
			PlayerDatas[Player.Name].Skills.Value ..= ",DragonSpeech"
		end
		local has = Player.Backpack:FindFirstChild("SlashResistance")
		if not has and data.IsUltra.Value == true or data.Hybrid.Value ~= "" then
			RacialAbilities.SlashResistance:Clone().Parent = Player.Backpack
		end
	elseif Race.Value == "Azael"then
		local has = PlayerDatas[Player.Name].Skills.Value:find("Gate")
		if not has then
			PlayerDatas[Player.Name].Skills.Value ..= ",Gate"
		end
	elseif Race.Value == "Seraph"then
		local has = Player.Backpack:FindFirstChild("Gate")or Player.Character:FindFirstChild("Gate")
		if not has then
			game.ServerStorage.Classes.Gate:Clone().Parent = Player.Backpack
		end
		local has2 = Player.Backpack:FindFirstChild("Angel Fall")or Player.Character:FindFirstChild("Angel Fall")
		if not has2 then
			game.ServerStorage.RacialAbilities["Angel Fall"]:Clone().Parent = Player.Backpack
		end
	elseif Race.Value == "Dinakeri"then
		local has = Player.Backpack:FindFirstChild("Soul Rip")or Player.Character:FindFirstChild("Soul Rip")
		if not has then
			game.ServerStorage.Classes["Soul Rip"]:Clone().Parent = Player.Backpack
		end
		game.ServerStorage.Classes.MasteredRune:Clone().Parent = Player.Backpack
	elseif Race.Value == "LesserNavaran" or Race.Value == "Navaran" then
		local has = Player.Backpack:FindFirstChild("Emulate")or Player.Character:FindFirstChild("Emulate")
		if not has then
			game.ServerStorage.RacialAbilities.Emulate:Clone().Parent = Player.Backpack
		end
		if Race.Value == "Navaran" then
			local has = Player.Backpack:FindFirstChild("Jack")or Player.Character:FindFirstChild("Jack")
			if not has then
				game.ServerStorage.RacialAbilities.Jack:Clone().Parent = Player.Backpack
			end
		end
	elseif Race.Value == "Construct"then
		local has = Player.Backpack:FindFirstChild("Galvanize")or Player.Character:FindFirstChild("Galvanize")
		if not has then
			game.ServerStorage.RacialAbilities.Galvanize:Clone().Parent = Player.Backpack
		end
		for i,v in pairs(Player.Character.Boosts:GetChildren()) do
			if v.Name == "ColdResist" then
				v.Value *= 0.25
			else
				local coldres = Instance.new("NumberValue")
				coldres.Value = 0.25
				coldres.Name = "ColdResist"
				coldres.Parent = Player.Character.Boosts
			end
		end
		Player.Character:WaitForChild("Boosts").ChildRemoved:Connect(function(child)
			if child.Name == "ColdResist" then
				task.delay(2, function()
					for i,v in pairs(Player.Character.Boosts:GetChildren()) do
						if v.Name == "ColdResist" then
							v.Value *= 0.25
						else
							local coldres = Instance.new("NumberValue")
							coldres.Value = 0.25
							coldres.Name = "ColdResist"
							coldres.Parent = Player.Character.Boosts
						end
					end
				end)
			end

		end)
	elseif Race.Value == "Fischeran" then
		local has = Player.Backpack:FindFirstChild("Dissolve")or Player.Character:FindFirstChild("Dissolve")
		if not has and data.IsUltra.Value == true or data.Hybrid.Value ~= "" then
			game.ServerStorage.RacialAbilities.Dissolve:Clone().Parent = Player.Backpack
		end
		if not Player.Character:FindFirstChild("WindDodges")then
			local v = Instance.new("NumberValue")
			v.Name = "WindDodges"
			v.Value = 4
			v.Parent = Player.Character
		else
			if Player.Character.WindDodges.Value < 4 then
				Player.Character.WindDodges.Value += 1
			end
		end
	end
end


local allskillsspec = {

}

-- Weapon-compatibility check for a move Tool `sc` against `data` (a PlayerData folder) — extracted
-- from the inline check UpdateSkills used to do below, now also reused by Shift's ability-theft
-- (checked against the shifter's own weapon data, not the theft target's).
commands["CanUseTool"] = function(sc, data)
	if not sc:FindFirstChild("RequiresWeapon") then
		return true
	end
	if allskillsspec[data.Name] then
		return true
	end
	local matches = sc.RequiresWeapon.Value == data.Weapon.Value
		or sc.RequiresWeapon.Value == data.PrimaryWeapon.Value
		or (sc.Name == "Dark Flame Burst" and data.Weapon.Value == "Sword")
		or (sc.Name == "Dark Eruption" and data.Weapon.Value == "Sword")
	if matches then
		return true
	end
	if sc:FindFirstChild("RequiresWeapon2") then
		return sc.RequiresWeapon2.Value == data.Weapon.Value or sc.RequiresWeapon2.Value == data.PrimaryWeapon.Value
	end
	return false
end

commands["UpdateSkills"] = function(player)
	local data = PlayerDatas:WaitForChild(player.Name)
	if data.Race.Value == 'Navaran'or data.Race.Value == "LesserNavaran" then
		local tool = game.ServerStorage.Classes:FindFirstChild(data.Emulated.Value)
		if tool and not tool:FindFirstChild("NoCopy") then
			local found = player.Backpack:FindFirstChild(tool.Name)or player.Character:FindFirstChild(tool.Name)
			if not found then
				for _,v in pairs(player.Backpack:getChildren())do
					if v:FindFirstChild("Emulated")then
						v:Destroy()
					end
				end
				for _,v in pairs(player.Character:getChildren())do
					if v:FindFirstChild("Emulated")then
						v:Destroy()
					end
				end
				local sc = tool:Clone()
				create("Emulated",false,sc)
				task.wait(1/30)
				sc.Parent = player.Backpack
			end
		end
	end

	local skills = string.split(data.Skills.Value,",")
	if table.find(skills, "The Soul") then
		if not game.CollectionService:HasTag(player.Character, "The Soul") then
			game.CollectionService:AddTag(player.Character, "The Soul")
		end
	else
		if  game.CollectionService:HasTag(player.Character, "The Soul") then
			game.CollectionService:RemoveTag(player.Character, "The Soul")
		end
	end
	if #skills > 0 then
		for Indx, Skill in pairs(skills)do
			local sc = game.ServerStorage.Classes:FindFirstChild(Skill) or (data.Race.Value == 'Navaran'and game.ServerStorage.RacialAbilities:FindFirstChild(Skill))
			if sc then
				if not commands.CanUseTool(sc, data) then
					continue
				end
				local found = player.Backpack:FindFirstChild(Skill)or player.Character:FindFirstChild(Skill)
				if not found then
					sc:Clone().Parent = player.Backpack
				end
			end
		end
		for _,v in pairs(player.Backpack:GetChildren())do
			if v:FindFirstChild("RequiresWeapon") and not commands.CanUseTool(v, data) then
				v:Destroy()
			end
			if v:FindFirstChild("DestroySkill")then
				v:Destroy()
			end
		end
	end
end
commands["UpdateSpells"] = function(player)
	local data = PlayerDatas:WaitForChild(player.Name)

	local skills = string.split(data.Spells.Value,",")
	if #skills > 0 then
		for Indx, Skill in pairs(skills)do
			local sc = game.ServerStorage.Classes:FindFirstChild(Skill)
			if sc then
				local found = player.Backpack:FindFirstChild(Skill)or player.Character:FindFirstChild(Skill)
				if not found then
					sc:Clone().Parent = player.Backpack
				end
			end
		end
		for _,v in pairs(player.Backpack:GetChildren())do
			if v:FindFirstChild("DestroySkill")then
				v:Destroy()
			end
		end
	end
end
commands["UpdateGodSpells"] = function(player)
	local data = PlayerDatas:WaitForChild(player.Name)
	local skills = string.split(data.Godspell.Value,",")
	if #skills > 0 then
		if data.Artifact.Value == "Philo" then
			for Indx, Skill in pairs(skills)do
				local sc = game.ServerStorage.Classes:FindFirstChild(Skill)
				if sc then
					local found = player.Backpack:FindFirstChild(Skill)or player.Character:FindFirstChild(Skill)
					if not found then
						sc:Clone().Parent = player.Backpack
					end
				end
			end
			for _,v in pairs(player.Backpack:GetChildren())do
				if v:FindFirstChild("DestroySkill")then
					v:Destroy()
				end
			end
		else
			for _,v in pairs(player.Backpack:GetChildren())do
				if v:FindFirstChild(skills[1])then
					v:Destroy()
				end
			end
		end
	end
end
commands["CarryDrop"] = function(character)
	if character:FindFirstChild("Grabbing") and not character.Grabbing:FindFirstChild("AntiDrop") then
		local carryweld = character.HumanoidRootPart:FindFirstChild("Motor6D")
		local carrying = character:FindFirstChild("Grabbing")
		if carryweld then
			carryweld:Destroy()
		end
		if carrying then
			if carrying.Value and carrying.Value:IsDescendantOf(workspace)then
				local carried = carrying.Value:FindFirstChild("Grabbed")
				if carried then
					carried:Destroy()
				end
				for _,v in pairs(carrying.Value:GetChildren())do
					if v.Name == "Action"then
						v:Destroy()
					end
				end
				for _,v in pairs(carrying.Value.Humanoid:GetPlayingAnimationTracks())do
					v:Stop()
				end
				for _,v in pairs(character.Humanoid:GetPlayingAnimationTracks())do
					v:Stop()
				end
				local bv = Instance.new("BodyVelocity")
				game.CollectionService:AddTag(bv,"AllowedBM")
				bv.MaxForce = Vector3.new(1000000,1600000,1000000)
				bv.Velocity = character.HumanoidRootPart.CFrame.LookVector.unit*20
				bv.Parent = carrying.Value.HumanoidRootPart
				game.Debris:AddItem(bv,0.12)
				if (character.Name == "   " or game.ServerStorage.PlayerData[character.Name].Skills.Value:find("NoKill")) then
					create("NoLifeDanger", 240, carrying.Value)
				end
				create("antinostun", 2, carrying.Value)
				create("Knocked",10,carrying.Value)
				create("Unconscious",10,carrying.Value)
				for _,b in pairs(carrying.Value:GetChildren())do
					if b.Name == "Head"or b.Name == "Torso"or b.Name == "Left Arm"or b.Name == "Right Arm"or b.Name == "Left Leg"or b.Name == "Right Leg"or b.Name == "HumanoidRootPart"then
						b.Massless = false
					end
				end
				for _,b in pairs(carrying.Value:GetChildren())do
					if b.Name == "Head"or b.Name == "Torso"then
						b.CanCollide = true
					end
				end
				local player = game.Players:GetPlayerFromCharacter(carrying.Value)
				if player then
					create("Danger",10,player)
					for _,v in pairs(player:GetChildren())do
						if v.Name == "Danger"and v:FindFirstChild("Carry")then
							v:Destroy()
						end
					end
				end
			end
		end
		character.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims.THROW):Play(0.1,1,2)
		create("CarryCD",0.5,character)
		carrying:Destroy()
		return true
	end
end
commands["AddToInventory"] = function(player,item)
	local data = PlayerDatas:WaitForChild(player.Name)
	if player:IsDescendantOf(workspace.Live) then
		player = game.Players:GetPlayerFromCharacter(player)
	end
	local inventory = string.split(data.Inventory.Value,",")
	local tool = game.ServerStorage.Storage:FindFirstChild(item)and game.ServerStorage.Storage[item]:Clone()or nil
	if tool ~= nil then
		data.Inventory.Value = data.Inventory.Value..","..tool.Name
		tool.Parent = player.Backpack
		return tool
	end
end
commands["RemoveFromInventory"] = function(player,item)
	local data = PlayerDatas:WaitForChild(player.Name)
	local inventory = string.split(data.Inventory.Value,",")
	local toremove = table.find(inventory,item)
	local character = game.Workspace.Live:FindFirstChild(player.Name)
	local player = game.Players:GetPlayerFromCharacter(character)
	if toremove then
		table.remove(inventory,toremove)
		data.Inventory.Value = table.concat(inventory,",")
	end
end
commands["StopBurn"] = function(character)
	if character and character.Parent then
		local wf = character:FindFirstChild("SigilWF")
		if wf then
			wf:Destroy()
		end
		for i,v in pairs(character:GetChildren())do
			if v.Name == "Burning" and not v:FindFirstChild("NoExtinguish") then
				v:Destroy()
				create("BurnCooldown",2,character)
				if character and character:FindFirstChild("HumanoidRootPart")  then
					character.HumanoidRootPart.Extinguish:Play()
					character.HumanoidRootPart.LoopFire:Stop()
				end
			end
		end
		for i,v in pairs(character.HumanoidRootPart:GetChildren())do
			if v.Name == "Burning" or v.Name == "ColoredBurning" and not v:FindFirstChild("NoExtinguish") then
				v.Enabled = false
				game.Debris:AddItem(v,1)
				if character and character:FindFirstChild("HumanoidRootPart") then
					character.HumanoidRootPart.LoopFire:Stop()
				end
			end
		end
	end
end
commands["StartBurn"] = function(enemy,eroot,color,burninfo,firestarter)
	if enemy:FindFirstChild("Burning")then
		return
	end
	if enemy:FindFirstChild("BurnCooldown")then
		return
	end
	if enemy:FindFirstChild("NoBURN")then
		return
	end
	if enemy:FindFirstChild("FireProtection") then
		return
	end
	if not enemy:FindFirstChild("MonsterInfo") and game.ServerStorage.PlayerData[enemy.Name].Race.Value == "Azael" and not (burninfo and burninfo.manastop) then
		if game.ServerStorage.PlayerData[enemy.Name].Race.Value == "Azael" and not game.ServerStorage.PlayerData[enemy.Name].Ascended.Value == true then
			return
		end
	end
	task.spawn(function()
		local burn = create("Burning",false,enemy)
		local executes = true
		if burninfo and burninfo.manastop then
			create("ManaStop",5,enemy)
			local p = color and game.ServerStorage.Assets.ColoredBurning:Clone() or game.ServerStorage.Assets.Burning:Clone()
			if color then
				p.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,color),ColorSequenceKeypoint.new(1,color),})
			end
			p.Parent = eroot
			p.Enabled = true
			Instance.new("Folder", p).Name = "NoExtinguish"
			local v23 = 1.2
			local playerdataenemy = PlayerDatas:FindFirstChild(enemy.Name)
			if playerdataenemy and playerdataenemy.Race.Value == "Kasparan" then
				v23 /= 2
			end
			task.spawn(function()
				for i = 1,10 do
					if enemy and game.ServerStorage.PlayerData:FindFirstChild(enemy.Name) then
						local enemydata = game.ServerStorage.PlayerData:FindFirstChild(enemy.Name)
						if enemydata.Ascended.Value == true and enemydata.Race.Value == "Azael" then
							enemy.Humanoid.Health += 0.5
						else
							game.ServerStorage.Requests.TagHumanoid:Fire(enemy,enemy,{damage = v23,nocombattag = true,downbypass = true,nododge = true})
						end
					else
						game.ServerStorage.Requests.TagHumanoid:Fire(enemy,enemy,{damage = v23,nocombattag = true,downbypass = true,nododge = true})
					end
					if burninfo and burninfo.azurelifesteal then
						firestarter.Humanoid.Health += 1.5
					end
					task.wait(0.5)
				end
				enemy.HumanoidRootPart.Extinguish:Play()
				p:Destroy()
			end)
		end
		if burninfo and burninfo.wraithfire then
			executes = false
			game:GetService("Debris"):AddItem(burn,5)
		end
		eroot.LoopFire:Play()
		local p = color and game.ServerStorage.Assets.ColoredBurning:Clone() or game.ServerStorage.Assets.Burning:Clone()
		if color then
			p.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,color),ColorSequenceKeypoint.new(1,color),})
		end
		p.Parent = eroot
		p.Enabled = true
		if burninfo and burninfo.sulfurfire then
			p.Enabled = false
		end
		if burninfo and burninfo.morifire then
			p.Enabled = false
		end
		task.wait(1)
		while true do
			if not burn or not burn.Parent then
				break
			end
			if enemy.Humanoid.Health <= 0 then
				break
			end
			if enemy.Humanoid:GetState() == Enum.HumanoidStateType.Swimming then
				break
			end
			local dmg = 2
			local timetoburn = 2
			if burninfo and burninfo.ascendedburn then
				dmg = 3
				timetoburn = 2
			end
			if burninfo and burninfo.sulfurfire then
				dmg = 2.75
				timetoburn = 1.5
			end
			if burninfo and burninfo.cursedflame then
				dmg = 3.75	
				timetoburn = 1.5
			end
			if burninfo and burninfo.morifire then
				dmg = 10
				timetoburn = 1.5
			end
			if game.CollectionService:HasTag(enemy,"Vampirism") then
				dmg*=1.75
			end
			temphandler.changeTemperature(enemy,1,0.0125)
			if enemy:FindFirstChild("AntiBurn") then
				task.wait(0.1)
				commands.StopBurn(enemy)
			end
			if color == Color3.fromRGB(255, 255, 255) and enemy:FindFirstChild("SigilWF") and game.ServerStorage.PlayerData:FindFirstChild(enemy.Name) then
				local enemydata = game.ServerStorage.PlayerData:FindFirstChild(enemy.Name)
				if enemydata and enemydata.Ascended.Value == true and enemydata.Race.Value == "Azael" then
					enemy.Humanoid.Health += 1
				else
					game.ServerStorage.Requests.TagHumanoid:Fire(enemy,enemy,{damage = 3.25,nocombattag = true,downbypass = true,nododge = true})
				end
			else
				local enemydata = game.ServerStorage.PlayerData:FindFirstChild(enemy.Name)
				if enemydata and enemydata.Ascended.Value == true and enemydata.Race.Value == "Azael" then
					enemy.Humanoid.Health += 0.75
				else
					game.ServerStorage.Requests.TagHumanoid:Fire(enemy,enemy,{damage = dmg,nocombattag = true,downbypass = true,nododge = true})
				end
			end
			if burninfo and burninfo.azurelifesteal then
				firestarter.Humanoid.Health += 0.78
			end
			task.wait(0.5)
			if executes then
				local Hum = enemy:FindFirstChild'Humanoid'
				if Hum and Hum.Health <= 3 then
					local enemydata = game.ServerStorage.PlayerData:FindFirstChild(enemy.Name)
					if enemydata and enemydata.Ascended.Value == true and enemydata.Race.Value == "Azael" then
						break
					end
					if game.CollectionService:HasTag(enemy,"Vampirism") then
						timetoburn = 0.5
					end
					if not game.CollectionService:HasTag(enemy, "Vampirism") then
						task.wait(timetoburn)
					else
						task.wait(timetoburn/2)
					end
					if not burn or not burn.Parent then
						break
					end
					if not enemy:FindFirstChild("Knocked") then
						break
					end
					if not enemy:FindFirstChild("Unconscious") then
						break
					end
					if enemy.Humanoid:GetState() == Enum.HumanoidStateType.Swimming then
						break
					end
					if enemy.Humanoid.Health <= 0 then
						break
					end
					
					game.ServerStorage.Requests.TagHumanoid:Fire(enemy,enemy,{injury = "heat",downbypass = true,nododge = true})

					task.wait(timetoburn*2)



					if not burn or not burn.Parent then
						break
					end
					if not enemy:FindFirstChild("Knocked") then
						break
					end
					if not enemy:FindFirstChild("Unconscious") then
						break
					end
					if enemy:FindFirstChild("Grabbed") then
						break
					end
					if enemy:FindFirstChild("beinggrabbed") then
						return
					end
					if Hum:GetState() == Enum.HumanoidStateType.Swimming then
						break
					end
					if Hum.Health <= 0 then
						break
					end
					if enemy.Humanoid.Health > 0 then
						_G.Death(enemy,firestarter,true)
						for i,v in pairs(enemy:GetChildren()) do
							if v:IsA("Clothing") then
								v:Destroy()
							end
							if v:IsA("BasePart") then
								v.Material = Enum.Material.Slate
								game:GetService("TweenService"):Create(v,TweenInfo.new(3),{Size = Vector3.new(0,0,0)}):Play()
							end
						end
					end
				end
			end
		end
		commands.StopBurn(enemy)
	end)
end

return commands