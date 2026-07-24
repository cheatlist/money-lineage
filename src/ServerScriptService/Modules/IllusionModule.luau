local module = {}

local BlacklistedObjects = {
	"ParticleEmitter",
	"Fire",
	"WrapLayer",
	"SurfaceAppearance"
}

local function DoAccessories(Player, Character)
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

function module.UpdateAppearance(Player, playlearnsound, Character)
	local Character = Character
	local Data = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
	local GetChildren,GetDescendants = game.GetChildren,game.GetDescendants
	local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
	local Assets = game.ServerStorage.Assets
	local ReplicatedAssets = game.ReplicatedStorage.Assets

	if not Data then return end

	local Race = Data.Race.Value
	local RaceInfo = game.ReplicatedStorage.Info.Races:FindFirstChild(Data.Race.Value)
	local RaceVariant = Data.RaceVariant.Value
	if RaceInfo:FindFirstChild(RaceVariant) then
		RaceInfo = RaceInfo[RaceVariant]
	end
	local HairColor = RaceInfo.HairColor

	if Character:FindFirstChild("Bald") then
		Character:FindFirstChild("Bald"):Destroy()
	end

	local b = ReplicatedAssets.Faces:WaitForChild(Data:WaitForChild("Face").Value)
	if Race.Value == "Rigan"or Race.Value == "Fischeran" then
		b = FindFirstChild(ReplicatedAssets.Faces.Rigan,Data.Face.Value)or FindFirstChild(ReplicatedAssets.Faces,Data.Face.Value)
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

		local Hairs,Accessories = DoAccessories(Player, Character)
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


		local SkinColor = RaceInfo.SkinColor.Value
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

	local Parts = {"DragonHorn","AzaelHorn","Bald","ScroomHead","DullahanHead","LichHead","DullahanLight"}

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
		for _,v in pairs(GetChildren(Assets.KasparanHorns))do
			local c = v:Clone()
			c.Parent = WaitForChild(Character,"Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	elseif Race == "Azael"then
		for _,v in pairs(GetChildren(Assets.AzaelHorns))do
			local c = v:Clone()
			c.Parent = WaitForChild(Character,"Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	elseif Race == "Zelda"then
		for _,v in pairs(GetChildren(Assets.ZeldaHorns))do
			local c = v:Clone()
			c.Parent = WaitForChild(Character,"Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	end


	local NoHead = {"Dullahan", "Lich", "Scroom", "Metascroom", "Metascroom"}

	if NoHead[Race] then
		for _,v in pairs(Character.Head:GetChildren()) do
			if v:IsA("Decal") then
				v:Destroy()
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
	elseif Race == "Scroom"then
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
	elseif Race == "Metascroom" then
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

	if Race == "Gaian"or Race == "Seraph"or Race == "Dullahan"or Race == "Cameo"or Race=="Lich" or Race=="DullahanBawa" or Character:FindFirstChild("LichSummon") then
		local v = Instance.new("BoolValue")
		v.Name = "NoHunger"
		v.Value = true
		v.Parent = Character
	elseif Race == "Navaran" or Race == "Seraph" or Race == "DullahanBawa" then 
		Player.leaderstats:WaitForChild("Hidden").Value = true
	end
end

local partblacklist = {Hilt = true,Orb = true,HumanoidRootPart = true,TomeHilt = true,Head = true,--[[LichHead = true,ScroomHead = true,]]RuneHolderL = true,RuneHolderR = true,Back = true,LightBall = true,IsShifted = true,}

local InvisibleHeads = {"Dullahan","Scroom","Metascroom","Lich"}

function module.changetransparency(v,transparency, PlayerData)
	for _,v in pairs(v:GetDescendants())do
		if v:IsA("BasePart")and not partblacklist[v.Name] and v.Parent.Name ~= "RuneArmLeft" and v.Parent.Name ~= "RuneArmRight" then
			v.Transparency = transparency
		end
		if v.Name == "Head" then
			if not table.find(InvisibleHeads,PlayerData.Race.Value) then
				v.Transparency = transparency
			end
		end
		if v.Name == "EnchantEffect" then
			if transparency == 1 then
				v.Enabled = false
			else
				v.Enabled = true
			end
		end
		if v.Name == "Orb" then
			if transparency == 1 then
				v.Transparency = 1
			else
				v.Transparency = 0.75
			end
		end
	end
	if v:FindFirstChild("Head") then
		for _,v in pairs(v.Head:GetChildren())do
			if v:IsA("Decal")then
				v.Transparency = transparency
			end
		end
	end
end

local PlayerDatas = game:GetService("ServerStorage").PlayerData

function module.ChangeArmor(Clone, player,bruharmor,outfit)
	local character = Clone
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
		if not outfit then
			for _: number, v in ipairs(armor.Stats:GetChildren())do
				local c1 = v:Clone()
				local v1 = Instance.new("Accessory")
				v1.Name = "Armor"
				v1.Parent = c1
				if v.Name == 'NoHunger'then
					c1.Parent = character
				else
					c1.Parent = character
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

function module.Escape(p1)
	local Cooldown = Instance.new("NumberValue")
	Cooldown.Parent = p1
	Cooldown.Name = "IllusoryEscape"
	game.Debris:AddItem(Cooldown, 180)
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	HumanoidRootPart.Snap:Play()
	p1.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims.Snap):Play()
	local v18 = game.ReplicatedStorage.Assets.HandHoldIllusion.PointLight:Clone();
	v18.Parent = HumanoidRootPart;
	HumanoidRootPart.PhantasmalEmit:Emit(30)
	local v29 = Instance.new("NumberValue")
	v29.Name = "Transparency"
	v29.Value = 1
	v29.Parent = p1.Boosts
	game.Debris:AddItem(v29, 0.75)
	local v1 = Instance.new("NumberValue")
	v1.Name = "SpeedBoost"
	v1.Value = 30
	v1.Parent = p1.Boosts
	game.Debris:AddItem(v1,0.75)
	local v17 = Instance.new("Accessory")
	v17.Name = "Immortal"
	v17.Parent = p1
	game:GetService("Debris"):AddItem(v17, 0.75)
	local v18 = Instance.new("Accessory")
	v18.Name = "NoAttack"
	v18.Parent = p1
	game:GetService("Debris"):AddItem(v18, 0.75)
	task.wait(0.5)
	v18:Destroy()
	HumanoidRootPart.Illusion.TimePosition = 0.5
	HumanoidRootPart.Illusion:Play()
	local PlayerData = game:GetService("ServerStorage")["PlayerData"]:FindFirstChild(p2.Name)
	for i = 1,math.random(2,3) do
		local Clone = game.ReplicatedStorage.Rig:Clone()
		Clone.Parent = workspace.Illusions
		Clone.HumanoidRootPart.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(math.random(-10,10),0,math.random(-10,10))
		Clone.HumanoidRootPart.Anchored = false
		module.UpdateAppearance(p2, true, Clone)
		module.ChangeArmor(Clone, p2, PlayerData.Armor.Value)
		local CloneHum = Clone.Humanoid
		CloneHum.MaxHealth = 20
		CloneHum.WalkSpeed = 16
		CloneHum.DisplayName = p1.Humanoid.DisplayName
		CloneHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
		CloneHum.HealthDisplayDistance = 0
		CloneHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		CloneHum.NameDisplayDistance = 100
		CloneHum.NameOcclusion = Enum.NameOcclusion.OccludeAll
		CloneHum:LoadAnimation(Clone.WalkAnim):Play()
		task.spawn(function()
			task.wait(0.1)
			CloneHum:MoveTo(HumanoidRootPart.Position + Vector3.new(math.random(-100,100), 0, math.random(-100,100)))
			task.wait(3)
			require(game.ServerScriptService.Modules.Ragdoll).Ragdoll(Clone,true,false)
			require(game.ServerScriptService.WorldHandler.MonsterControl.DecisionModules.Illusions).die(Clone)
		end)
	end
end

return module
