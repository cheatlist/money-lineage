local race = script.Parent.Script.RemoteFunction:InvokeServer("Race")
local temp = script.Parent.Script.RemoteFunction:InvokeServer("UnlockedRaces")
local UnlockedEdicts = script.Parent.Script.RemoteFunction:InvokeServer("UnlockedEdicts")
local wipe = script.Parent.Script.Wipe
local marketplaceservice = game:GetService("MarketplaceService")
local iknowright = string.split(temp,",")
local unlockedraces = {}
local character = nil
local racevariant = "Default"
local face = ""
local mana = Color3.new(0,0,0)
local gender = "Male"
local FirstName = ""
local edict = "None"
local boldened = nil
local bolding = nil
local boldenedname = nil
local boldenedrace = nil
local boldenededict = script.Parent["Edict  Selection"].NameFrame.EdictFrame.Example
local boldenededict2 = "None"
local UIS = game:GetService("UserInputService")
local nameselect = script.Parent["Name  Selection"]
local raceselect = script.Parent["Race Selection"]
local vanityselect = script.Parent["Vanity Selection"]
local edictselect = script.Parent["Edict  Selection"]
local scroomhead = nil
local faceframe = vanityselect.FaceFrame
local manaframe = vanityselect.ManaFrame
local variantframe = vanityselect.VariantFrame
local holdingm1 = false
local RS = game:GetService("ReplicatedStorage")
raceselect.RaceName.Shadow.RACENAME.Text = "<b>"..race.."</b>"

script.Parent.AREAMUSIC:Play()
local cooldown = false
for i,v in pairs(iknowright) do
	if v ~= "" then
		table.insert(unlockedraces, v)
	end
end
local allraces = {
	"Haseldan",
	"Rigan",
	"Ashiin",
	"Castellan",
	"Kasparan",
	"Gaian",
	"Scroom",
	"LesserNavaran",
	"Madrasian",
	"Dinakeri",
	"Morvid",
	"Fischeran",
	"Vind",
	"Dzin",
	"Azael",
	"Cameo",
}

local BlacklistedObjects = {
	"ParticleEmitter",
	"Fire",
	"WrapLayer",
	"SurfaceAppearance"
}

local function checkforraces()
	local howmany = 0
	for i,v in pairs(allraces) do
		for j,k in pairs(unlockedraces) do
			local string1 = string.lower(v)
			local string2 = string.lower(k)
			if string1:find(string2) then
				howmany += 1
			end
		end
	end
	if howmany >= 16 then
		raceselect.RaceName.Races.Shadow.MainFrame.MainFrame.Visible = false
	end
end

local function DoAccessories()
	cooldown = true
	local zzzz = game.Players:GetCharacterAppearanceAsync(game.Players.LocalPlayer.CharacterAppearanceId)
	zzzz.Parent = game:GetService("ServerStorage")
	local Hairs,Accessories = {},{}
	for _,v in ipairs(zzzz:GetChildren())do
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
	game.Debris:AddItem(zzzz,1)
	return Hairs,Accessories
end

local function UpdateAppearance(checkforface,checkforvariant)
	cooldown = true
	local Character = character
	local ReplicatedAssets = game.ReplicatedStorage.Assets
	local RaceInfo = game.ReplicatedStorage.Info.Races:FindFirstChild(race)
	if RaceInfo:FindFirstChild(racevariant) then
		RaceInfo = RaceInfo[racevariant]
	end
	if Character.Head:FindFirstChild("faceee") and not checkforvariant then
		Character.Head:FindFirstChild("faceee"):Destroy()
	end
	if checkforface and checkforface == true then
		local b
		if face == "" then
			local faces = {
				Normal = {
					"Angry",
					"Friendly",
					"Disgruntled",
					"Hollow",
					"Sad",
					"Serious",
					"Tired",
					"Determined",
				},
				LesserNavaran = {
					"Blank",
				},
				Navaran = {
					"Blank",
				},
				Fischeran  = {
					"Variant Angry",
					"Variant Determined",
					"Variant Disgruntled",
					"Variant Friendly",
					"Variant Hollow",
					"Variant Sad",
					"Variant Serious",
					"Variant Tired",
				},
				Rigan  = {
					"Variant Angry",
					"Variant Determined",
					"Variant Disgruntled",
					"Variant Friendly",
					"Variant Hollow",
					"Variant Sad",
					"Variant Serious",
					"Variant Tired",
				},
				Gaian = {"Gaian"},
				Morvid = {"MorvidSupreme"},
				Phoenix = {"MorvidSupreme"},
				Wretch = {"Fused"},
				Kasparan = {
					"DragonAnxious",
					"DragonFrustrated",
					"DragonSigil",
					"DragonSmug",
					"DragonUnimpressed",
				},
				Azael = {
					"AzaelConcerned",
					"AzaelFired",
					"AzaelStern",
				},

				Dinakeri = {
					"Dinakeri Confident",
					"Dinakeri Indifferent",
				},
				Howler = {
					"Howler Smug",
					"Howler Determined",
					"Howler Indifferent"
				},
			}
			if not faces[race] then
				local random = math.random(1,#faces["Normal"])
				b = ReplicatedAssets.Faces[faces["Normal"][random]]
				face = faces["Normal"][random]
			else
				local random = math.random(1,#faces[race])
				b = ReplicatedAssets.Faces[faces[race][random]]
				face = faces[race][random]
			end
		else
			b = ReplicatedAssets.Faces:WaitForChild(face)
		end
		local c = b:Clone()
		c.Color3 = RaceInfo.EyeColor.Value
		c.Parent = Character.Head
		c.Name = "faceee"
		return
	end
	if checkforvariant and checkforvariant == true then
		local RaceVariant = racevariant
		if RaceInfo:FindFirstChild(RaceVariant) then
			RaceInfo = RaceInfo[RaceVariant]
		end
		local HairColor = RaceInfo.HairColor
		if race ~= "Scroom" and race ~= "Dullahan" and race ~= "Metascroom" then
			Character.Head.faceee.Color3 = RaceInfo.EyeColor.Value
		end
		task.spawn(function()

			local Hairs,Accessories = DoAccessories()
			for _,v in pairs(Accessories)do
				v.Parent = Character
			end
			for _,v in pairs(Hairs)do
				if not Character:FindFirstChild("Bald") and not RaceInfo:FindFirstChild("Bald") and not RaceInfo.Parent:FindFirstChild("Bald") then
					v.Parent = Character
					if v:FindFirstChild("Handle")then
						local SM = v.Handle:FindFirstChildWhichIsA("SpecialMesh")
						if SM then
							SM.TextureId = "rbxassetid://2599831937"
							SM.VertexColor = Vector3.new(HairColor.Value.r,HairColor.Value.g,HairColor.Value.b)
						end
						v.Handle.Color = HairColor.Value
					end
				else
					v:Destroy()
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
				Description.HeadColor = RaceInfo.SkinColor.Value
				Description.LeftArmColor = RaceInfo.SkinColor.Value
				Description.LeftLegColor = RaceInfo.SkinColor.Value
				Description.RightArmColor = RaceInfo.SkinColor.Value
				Description.RightLegColor = RaceInfo.SkinColor.Value
				Description.TorsoColor = RaceInfo.SkinColor.Value
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
		if race == "Scroom" then
			local Head
			if ReplicatedAssets.ScroomHeads:FindFirstChild(racevariant) then
				Character:FindFirstChild("ScroomHead"):Destroy()
				Head = ReplicatedAssets.ScroomHeads:FindFirstChild(racevariant).ScroomHead:Clone()
				Head.Weld.Part0 = Head
				Head.Weld.Part1 = Character.Head
				Head.Parent = Character
				Character.Head.Transparency = 0.99
			end
		end
		if race == "Howler" then
			if ReplicatedAssets.HowlerManes:FindFirstChild(racevariant) then
				local Mane
				Character:FindFirstChild("HowlerMane"):Destroy()
				Mane = ReplicatedAssets.HowlerManes:FindFirstChild(racevariant).HowlerMane:Clone()
				Mane.Parent = Character
			end
		end
		return
	end
	local GetChildren,GetDescendants = game.GetChildren,game.GetDescendants
	local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild

	if Character:FindFirstChild("Bald") then
		Character:FindFirstChild("Bald"):Destroy()
	end

	for i,v in pairs(character:GetDescendants()) do
		if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Decal") or v.Name == "DragonHorn" or v.Name == "AzaelHorn" or v.Name == "Bald" or v.Name == "ScroomHead" or v.Name == "DullahanHead" or v.Name == "LichHead" or v.Name == "DullahanLight" then
			v:Destroy()
		end
	end

	for _,v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") and v:FindFirstChild("Handle") then
			v:Destroy()
		end
	end

	local NoHead = {"Dullahan", "Lich", "Scroom", "Metascroom", "Metascroom"}

	if NoHead[race] then
		for _,v in pairs(Character.Head:GetChildren()) do
			if v:IsA("Decal") then
				v:Destroy()
			end
		end
	end

	if Character:FindFirstChild("Head") then
		Character.Head.Transparency = 0
	end

	local RaceVariant = racevariant
	if RaceInfo:FindFirstChild(RaceVariant) then
		RaceInfo = RaceInfo[RaceVariant]
	end
	local HairColor = RaceInfo.HairColor

	local b
	local faces = {
		Normal = {
			"Angry",
			"Friendly",
			"Disgruntled",
			"Hollow",
			"Sad",
			"Serious",
			"Tired",
			"Determined",
		},
		LesserNavaran = {
			"Blank",
		},
		Navaran = {
			"Blank",
		},
		Fischeran  = {
			"Variant Angry",
			"Variant Determined",
			"Variant Disgruntled",
			"Variant Friendly",
			"Variant Hollow",
			"Variant Sad",
			"Variant Serious",
			"Variant Tired",
		},
		Rigan  = {
			"Variant Angry",
			"Variant Determined",
			"Variant Disgruntled",
			"Variant Friendly",
			"Variant Hollow",
			"Variant Sad",
			"Variant Serious",
			"Variant Tired",
		},
		Gaian = {"Gaian"},
		Wretch = {"Fused"},
		Morvid = {"MorvidSupreme"},
		Phoenix = {"MorvidSupreme"},
		Kasparan = {
			"DragonAnxious",
			"DragonFrustrated",
			"DragonSigil",
			"DragonSmug",
			"DragonUnimpressed",
		},
		Azael = {
			"AzaelConcerned",
			"AzaelFired",
			"AzaelStern",
		},

		Dinakeri = {
			"Dinakeri Confident",
			"Dinakeri Indifferent",
		},
		Howler = {
			"Howler Smug",
			"Howler Determined",
			"Howler Indifferent"
		},
	}
	local c
	if not faces[race] and face == "" then
		local random = math.random(1,#faces["Normal"])
		b = ReplicatedAssets.Faces[faces["Normal"][random]]
		face = faces["Normal"][random]
		c = b:Clone()
		c.Color3 = RaceInfo.EyeColor.Value
		c.Parent = Character.Head
		c.Name = "faceee"
	elseif face == "" and faces[race] then
		local random = math.random(1,#faces[race])
		b = ReplicatedAssets.Faces[faces[race][random]]
		face = faces[race][random]
		c = b:Clone()
		c.Color3 = RaceInfo.EyeColor.Value
		c.Parent = Character.Head
		c.Name = "faceee"
	end

	task.spawn(function()

		local Hairs,Accessories = DoAccessories()
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
				v:Destroy()
			end
		end
		WaitForChild(Character,"Head")
		if FindFirstChild(Character.Head,"face")then
			Character.Head.face:Destroy()
		end


		local function doa()
			local Description = Character.Humanoid:GetAppliedDescription()
			Description.Head = 0
			Description.Torso = 0
			Description.LeftArm = 0
			Description.RightArm = 0
			Description.LeftLeg = 0
			Description.RightLeg = 0
			Description.HeadColor = RaceInfo.SkinColor.Value
			Description.LeftArmColor = RaceInfo.SkinColor.Value
			Description.LeftLegColor = RaceInfo.SkinColor.Value
			Description.RightArmColor = RaceInfo.SkinColor.Value
			Description.RightLegColor = RaceInfo.SkinColor.Value
			Description.TorsoColor = RaceInfo.SkinColor.Value
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

	if (race ~= "Scroom" and race ~= "Metascroom" and race ~= "Gaian" and race ~= "Morvid" and race ~= "Cameo") then
		local randomshirt = math.random(1,3)
		if randomshirt == 1 then
			ReplicatedAssets.Outfits.BlueAdventurer[gender].Pants:Clone().Parent = character
			ReplicatedAssets.Outfits.BlueAdventurer[gender].Shirt:Clone().Parent = character
		elseif randomshirt == 2 then
			ReplicatedAssets.Outfits.GreenAdventurer[gender].Pants:Clone().Parent = character
			ReplicatedAssets.Outfits.GreenAdventurer[gender].Shirt:Clone().Parent = character
		elseif randomshirt == 3 then
			ReplicatedAssets.Outfits.RedAdventurer[gender].Pants:Clone().Parent = character
			ReplicatedAssets.Outfits.RedAdventurer[gender].Shirt:Clone().Parent = character
		end
	end
	if race == "Gaian" then
		ReplicatedAssets.Outfits.GaianDefault["Male"].Pants:Clone().Parent = character
		ReplicatedAssets.Outfits.GaianDefault["Male"].Shirt:Clone().Parent = character
	end
	if race == "Morvid" or race == "Cameo" then
		ReplicatedAssets.Outfits.Rags["Male"].Pants:Clone().Parent = character
		ReplicatedAssets.Outfits.Rags["Male"].Shirt:Clone().Parent = character
	end

	if race == "Kasparan"then
		for _,v in pairs(GetChildren(ReplicatedAssets.KasparanHorns))do
			local c = v:Clone()
			c.Parent = WaitForChild(Character,"Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	elseif race == "Azael"then
		for _,v in pairs(GetChildren(ReplicatedAssets.AzaelHorns))do
			local c = v:Clone()
			c.Parent = WaitForChild(Character,"Head")
			c.Weld.Part0 = Character.Head
			c.Weld.Part1 = c
		end
	end

	if race == "Dullahan" then
		local Head = ReplicatedAssets.DullahanHead:Clone()
		Head.Parent = Character
		Head.Weld.Part0 = Head
		Head.Weld.Part1 = Character.Head
		Character.Head.Transparency = 0.99
		if c then
			c:Destroy()
		end
	elseif race == "Lich"then
		local lichhead = ReplicatedAssets.LichHead:Clone()
		lichhead.Weld.Part0 = Character.Head
		lichhead.Weld.Part1 = lichhead
		lichhead.Weld.C0 = CFrame.new(2.1855695e-09, 0.170000002, -0.0499999933, 0, -1, 0, 0, 0, -1, 1, 0, 0)
		lichhead.Weld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		for _,v in pairs(GetChildren(lichhead))do
			if v.Name =="EyeAttach"then
				v.EyeP.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,mana),
					ColorSequenceKeypoint.new(1,mana),
				})
				v.EyeP.Enabled = true
			end
		end
		lichhead.Parent = Character
		Character.Head.Transparency = 0.99
		if c then
			c:Destroy()
		end
	elseif race == "Scroom"then
		local Head
		local Variant = racevariant
		if ReplicatedAssets.ScroomHeads:FindFirstChild(Variant) then
			Head = ReplicatedAssets.ScroomHeads:FindFirstChild(Variant).ScroomHead:Clone()
		else
			local numb: number = math.random(1, 5)
			if numb == 1 then
				racevariant = "Blue"
			elseif numb == 2 then
				racevariant = "Brown"
			elseif numb == 3 then
				racevariant = "Green"
			elseif numb == 4 then
				racevariant = "Shine"
			elseif numb == 5 then
				racevariant = "Default"
			end
			Variant = racevariant
			Head = ReplicatedAssets.ScroomHeads:FindFirstChild(Variant).ScroomHead:Clone()
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
	elseif race == "Metascroom" then
		local Variant = "Metascroom"
		local Head = ReplicatedAssets.ScroomHeads:FindFirstChild("Metascroom").ScroomHead:Clone()
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
	elseif race == "Howler" then
		local Mane
		local Variant = racevariant
		Mane = ReplicatedAssets.HowlerManes:FindFirstChild(Variant).HowlerMane:Clone()
		Mane.Parent = Character
	end
end

local function CreateCharacter()
	character = game.ReplicatedStorage.Rig:Clone()
	character.Parent = workspace
	character.HumanoidRootPart.CFrame = workspace["the bawa parts"].player_spot.CFrame
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = workspace["the bawa parts"].camera_part_zoom.CFrame
	workspace.CurrentCamera.CameraSubject = workspace["the bawa parts"].camera_part_zoom
	UpdateAppearance()
end

local function getfaces()
	cooldown = true
	for i,v in pairs(faceframe.ScrollingFrame:GetChildren()) do
		if v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end
	faceframe.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
	local ReplicatedAssets = game.ReplicatedStorage.Assets
	local b
	local faces = {
		Normal = {
			"Angry",
			"Friendly",
			"Disgruntled",
			"Hollow",
			"Sad",
			"Serious",
			"Tired",
			"Determined",
		},
		LesserNavaran = {
			"Blank",
		},
		Navaran = {
			"Blank",
		},
		Fischeran  = {
			"Variant Angry",
			"Variant Determined",
			"Variant Disgruntled",
			"Variant Friendly",
			"Variant Hollow",
			"Variant Sad",
			"Variant Serious",
			"Variant Tired",
		},
		Rigan  = {
			"Variant Angry",
			"Variant Determined",
			"Variant Disgruntled",
			"Variant Friendly",
			"Variant Hollow",
			"Variant Sad",
			"Variant Serious",
			"Variant Tired",
		},
		Gaian = {"Gaian"},
		Wretch = {"Fused"},
		Morvid = {"MorvidSupreme"},
		Phoenix = {"MorvidSupreme"},
		Kasparan = {
			"DragonAnxious",
			"DragonFrustrated",
			"DragonSigil",
			"DragonSmug",
			"DragonUnimpressed",
		},
		Azael = {
			"AzaelConcerned",
			"AzaelFired",
			"AzaelStern",
		},

		Dinakeri = {
			"Dinakeri Confident",
			"Dinakeri Indifferent",
		},
		Howler = {
			"Howler Smug",
			"Howler Determined",
			"Howler Indifferent"
		},
	}
	if not faces[race] then
		if race == "Scroom" or race == "Metascroom" or race == "Dullahan" then return end
		for i,v in pairs(faces["Normal"]) do
			local string1 = string.lower(v)
			local string2 = string.lower(face)
			local name = script.Parent.Example:Clone()
			name.Parent = faceframe.ScrollingFrame
			name.Text = v
			name.Name = v
			if string1 == string2 then
				name.Text = "<b>"..v.."</b>"
			end
			name.Visible = true
			faceframe.ScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
			name.MouseEnter:connect(function()
				game.TweenService:Create(name, TweenInfo.new(0.1), {
					TextColor3 = Color3.new(1, 1, 1)
				}):Play()
				game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
			end)
			name.MouseLeave:connect(function()
				game.TweenService:Create(name, TweenInfo.new(0.3), {
					TextColor3 = Color3.new(0.8, 0.8, 0.8)
				}):Play()
				game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
			end)
			name.MouseButton1Click:connect(function()
				if face == name.Name then
					return
				end
				if face ~= "" then
					faceframe.ScrollingFrame:FindFirstChild(face).Text = face
				end
				face = name.Name
				name.Text = "<b>"..v.."</b>"
				UpdateAppearance(true)
			end)
		end
	else
		for i,v in pairs(faces[race]) do
			local string1 = string.lower(v)
			local string2 = string.lower(face)
			local name = script.Parent.Example:Clone()
			name.Parent = faceframe.ScrollingFrame
			name.Text = v
			name.Name = v
			if string1 == string2 then
				name.Text = "<b>"..v.."</b>"
			end
			name.Visible = true
			faceframe.ScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
			name.MouseEnter:connect(function()
				game.TweenService:Create(name, TweenInfo.new(0.1), {
					TextColor3 = Color3.new(1, 1, 1)
				}):Play()
				game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
			end)
			name.MouseLeave:connect(function()
				game.TweenService:Create(name, TweenInfo.new(0.3), {
					TextColor3 = Color3.new(0.8, 0.8, 0.8)
				}):Play()
				game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
			end)
			name.MouseButton1Click:connect(function()
				if face == name.Name then
					return
				end
				if face ~= "" then
					faceframe.ScrollingFrame:FindFirstChild(face).Text = face
				end
				face = name.Name
				name.Text = "<b>"..v.."</b>"
				UpdateAppearance(true)
			end)
		end
	end
end

local function getnames(text)
	cooldown = true
	for i,v in pairs(nameselect.NameFrame.NameScrollingFrame:GetChildren()) do
		if v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end
	local enteredname = string.lower(text)
	nameselect.NameFrame.NameScrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
	if RS.Names:FindFirstChild(race) then
		local names = require(RS.Names[race])
		for i,v in pairs(names) do
			local namecomparable = string.lower(v)
			if text ~= "" then
				if namecomparable:find(enteredname) then
					local name = script.Parent.Example:Clone()
					name.Parent = nameselect.NameFrame.NameScrollingFrame
					name.Text = v
					if FirstName == v then
						name.Text = "<b>"..v.."</b>"
					end
					if boldenedname ~= nil and boldenedname == v then
						boldened = name
					end
					name.Visible = true
					nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
					name.MouseEnter:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.1), {
							TextColor3 = Color3.new(1, 1, 1)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
					end)
					name.MouseLeave:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.3), {
							TextColor3 = Color3.new(0.8, 0.8, 0.8)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
					end)
					name.MouseButton1Click:connect(function()
						if boldened ~= nil then
							boldened.Text = FirstName
						end
						boldened = name
						boldenedname = boldened.Text
						FirstName = name.Text
						name.Text = "<b>"..v.."</b>"
						script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
					end)
				end
			else
				local name = script.Parent.Example:Clone()
				name.Parent = nameselect.NameFrame.NameScrollingFrame
				name.Text = v
				if FirstName == v then
					name.Text = "<b>"..v.."</b>"
				end
				if boldenedname ~= nil and boldenedname == v then
					boldened = name
				end
				name.Visible = true
				nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
				name.MouseEnter:connect(function()
					game.TweenService:Create(name, TweenInfo.new(0.1), {
						TextColor3 = Color3.new(1, 1, 1)
					}):Play()
					game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
				end)
				name.MouseLeave:connect(function()
					game.TweenService:Create(name, TweenInfo.new(0.3), {
						TextColor3 = Color3.new(0.8, 0.8, 0.8)
					}):Play()
					game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
				end)
				name.MouseButton1Click:connect(function()
					if boldened ~= nil then
						boldened.Text = FirstName
					end
					boldened = name	
					boldenedname = boldened.Text
					FirstName = name.Text
					name.Text = "<b>"..v.."</b>"
					script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
				end)
			end
		end
	elseif race == "Dinakeri" then
		local names = require(RS.Names["Azael"])
		for i,v in pairs(names) do
			local namecomparable = string.lower(v)
			if text ~= "" then
				if namecomparable:find(enteredname) then
					local name = script.Parent.Example:Clone()
					name.Parent = nameselect.NameFrame.NameScrollingFrame
					name.Text = v
					if FirstName == v then
						name.Text = "<b>"..v.."</b>"
					end
					if boldenedname ~= nil and boldenedname == v then
						boldened = name
					end
					name.Visible = true
					nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
					name.MouseEnter:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.1), {
							TextColor3 = Color3.new(1, 1, 1)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
					end)
					name.MouseLeave:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.3), {
							TextColor3 = Color3.new(0.8, 0.8, 0.8)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
					end)
					name.MouseButton1Click:connect(function()
						if boldened ~= nil then
							boldened.Text = FirstName
						end
						boldened = name
						boldenedname = boldened.Text
						FirstName = name.Text
						name.Text = "<b>"..v.."</b>"
						script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
					end)
				end
			else
				local name = script.Parent.Example:Clone()
				name.Parent = nameselect.NameFrame.NameScrollingFrame
				name.Text = v
				if FirstName == v then
					name.Text = "<b>"..v.."</b>"
				end
				if boldenedname ~= nil and boldenedname == v then
					boldened = name
				end
				name.Visible = true
				nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
				name.MouseEnter:connect(function()
					game.TweenService:Create(name, TweenInfo.new(0.1), {
						TextColor3 = Color3.new(1, 1, 1)
					}):Play()
					game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
				end)
				name.MouseLeave:connect(function()
					game.TweenService:Create(name, TweenInfo.new(0.3), {
						TextColor3 = Color3.new(0.8, 0.8, 0.8)
					}):Play()
					game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
				end)
				name.MouseButton1Click:connect(function()
					if boldened ~= nil then
						boldened.Text = FirstName
					end
					boldened = name	
					boldenedname = boldened.Text
					FirstName = name.Text
					name.Text = "<b>"..v.."</b>"
					script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
				end)
			end
		end
	elseif race == "Metascroom" then
		local names = require(RS.Names["Scroom"])
		for i,v in pairs(names) do
			local namecomparable = string.lower(v)
			if text ~= "" then
				if namecomparable:find(enteredname) then
					local name = script.Parent.Example:Clone()
					name.Parent = nameselect.NameFrame.NameScrollingFrame
					name.Text = v
					if FirstName == v then
						name.Text = "<b>"..v.."</b>"
					end
					if boldenedname ~= nil and boldenedname == v then
						boldened = name
					end
					name.Visible = true
					nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
					name.MouseEnter:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.1), {
							TextColor3 = Color3.new(1, 1, 1)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
					end)
					name.MouseLeave:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.3), {
							TextColor3 = Color3.new(0.8, 0.8, 0.8)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
					end)
					name.MouseButton1Click:connect(function()
						if boldened ~= nil then
							boldened.Text = FirstName
						end
						boldened = name
						boldenedname = boldened.Text
						FirstName = name.Text
						name.Text = "<b>"..v.."</b>"
						script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
					end)
				end
			else
				local name = script.Parent.Example:Clone()
				name.Parent = nameselect.NameFrame.NameScrollingFrame
				name.Text = v
				if FirstName == v then
					name.Text = "<b>"..v.."</b>"
				end
				if boldenedname ~= nil and boldenedname == v then
					boldened = name
				end
				name.Visible = true
				nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
				name.MouseEnter:connect(function()
					game.TweenService:Create(name, TweenInfo.new(0.1), {
						TextColor3 = Color3.new(1, 1, 1)
					}):Play()
					game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
				end)
				name.MouseLeave:connect(function()
					game.TweenService:Create(name, TweenInfo.new(0.3), {
						TextColor3 = Color3.new(0.8, 0.8, 0.8)
					}):Play()
					game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
				end)
				name.MouseButton1Click:connect(function()
					if boldened ~= nil then
						boldened.Text = FirstName
					end
					boldened = name	
					boldenedname = boldened.Text
					FirstName = name.Text
					name.Text = "<b>"..v.."</b>"
					script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
				end)
			end
		end
	elseif race == "Fischeran" then
		local names = require(RS.Names["Vind"])
		for i,v in pairs(names) do
			local namecomparable = string.lower(v)
			if text ~= "" then
				if namecomparable:find(enteredname) then
					local name = script.Parent.Example:Clone()
					name.Parent = nameselect.NameFrame.NameScrollingFrame
					name.Text = v
					if FirstName == v then
						name.Text = "<b>"..v.."</b>"
					end
					if boldenedname ~= nil and boldenedname == v then
						boldened = name
					end
					name.Visible = true
					nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
					name.MouseEnter:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.1), {
							TextColor3 = Color3.new(1, 1, 1)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
					end)
					name.MouseLeave:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.3), {
							TextColor3 = Color3.new(0.8, 0.8, 0.8)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
					end)
					name.MouseButton1Click:connect(function()
						if boldened ~= nil then
							boldened.Text = FirstName
						end
						boldened = name
						boldenedname = boldened.Text
						FirstName = name.Text
						name.Text = "<b>"..v.."</b>"
						script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
					end)
				end
			else
				local name = script.Parent.Example:Clone()
				name.Parent = nameselect.NameFrame.NameScrollingFrame
				name.Text = v
				if FirstName == v then
					name.Text = "<b>"..v.."</b>"
				end
				if boldenedname ~= nil and boldenedname == v then
					boldened = name
				end
				name.Visible = true
				nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
				name.MouseEnter:connect(function()
					game.TweenService:Create(name, TweenInfo.new(0.1), {
						TextColor3 = Color3.new(1, 1, 1)
					}):Play()
					game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
				end)
				name.MouseLeave:connect(function()
					game.TweenService:Create(name, TweenInfo.new(0.3), {
						TextColor3 = Color3.new(0.8, 0.8, 0.8)
					}):Play()
					game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
				end)
				name.MouseButton1Click:connect(function()
					if boldened ~= nil then
						boldened.Text = FirstName
					end
					boldened = name	
					boldenedname = boldened.Text
					FirstName = name.Text
					name.Text = "<b>"..v.."</b>"
					script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
				end)
			end
		end
	else
		if gender == "Male" then
			local names = require(RS.Names["Masculine"])
			for i,v in pairs(names) do
				local namecomparable = string.lower(v)
				if text ~= "" then
					if namecomparable:find(enteredname) then
						local name = script.Parent.Example:Clone()
						name.Parent = nameselect.NameFrame.NameScrollingFrame
						name.Text = v
						if FirstName == v then
							name.Text = "<b>"..v.."</b>"
						end
						if boldenedname ~= nil and boldenedname == v then
							boldened = name
						end
						name.Visible = true
						nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30) 
						name.MouseEnter:connect(function()
							game.TweenService:Create(name, TweenInfo.new(0.1), {
								TextColor3 = Color3.new(1, 1, 1)
							}):Play()
							game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
						end)
						name.MouseLeave:connect(function()
							game.TweenService:Create(name, TweenInfo.new(0.3), {
								TextColor3 = Color3.new(0.8, 0.8, 0.8)
							}):Play()
							game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
						end)
						name.MouseButton1Click:connect(function()
							if boldened ~= nil then
								boldened.Text = FirstName
							end
							boldened = name
							boldenedname = boldened.Text
							FirstName = name.Text
							name.Text = "<b>"..v.."</b>"
							script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
						end)
					end
				else
					local name = script.Parent.Example:Clone()
					name.Parent = nameselect.NameFrame.NameScrollingFrame
					name.Text = v
					if FirstName == v then
						name.Text = "<b>"..v.."</b>"
					end
					if boldenedname ~= nil and boldenedname == v then
						boldened = name
					end
					name.Visible = true
					nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
					name.MouseEnter:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.1), {
							TextColor3 = Color3.new(1, 1, 1)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
					end)
					name.MouseLeave:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.3), {
							TextColor3 = Color3.new(0.8, 0.8, 0.8)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
					end)
					name.MouseButton1Click:connect(function()
						if boldened ~= nil then
							boldened.Text = FirstName
						end
						boldened = name
						boldenedname = boldened.Text
						FirstName = name.Text
						name.Text = "<b>"..v.."</b>"
						script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
					end)
				end
			end
		else 
			local names = require(RS.Names["Feminine"])
			for i,v in pairs(names) do
				local namecomparable = string.lower(v)
				if text ~= "" then
					if namecomparable:find(enteredname) then
						local name = script.Parent.Example:Clone()
						name.Parent = nameselect.NameFrame.NameScrollingFrame
						name.Text = v
						if FirstName == v then
							name.Text = "<b>"..v.."</b>"
						end
						if boldenedname ~= nil and boldenedname == v then
							boldened = name
						end
						name.Visible = true
						nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
						name.MouseEnter:connect(function()
							game.TweenService:Create(name, TweenInfo.new(0.1), {
								TextColor3 = Color3.new(1, 1, 1)
							}):Play()
							game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
						end)
						name.MouseLeave:connect(function()
							game.TweenService:Create(name, TweenInfo.new(0.3), {
								TextColor3 = Color3.new(0.8, 0.8, 0.8)
							}):Play()
							game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
						end)
						name.MouseButton1Click:connect(function()
							if boldened ~= nil then
								boldened.Text = FirstName
							end
							boldened = name
							boldenedname = boldened.Text
							FirstName = name.Text
							name.Text = "<b>"..v.."</b>"
							script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
						end)
					end
				else
					local name = script.Parent.Example:Clone()
					name.Parent = nameselect.NameFrame.NameScrollingFrame
					name.Text = v
					if FirstName == v then
						name.Text = "<b>"..v.."</b>"
					end
					if boldenedname ~= nil and boldenedname == v then
						boldened = name
					end
					name.Visible = true
					nameselect.NameFrame.NameScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
					name.MouseEnter:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.1), {
							TextColor3 = Color3.new(1, 1, 1)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
					end)
					name.MouseLeave:connect(function()
						game.TweenService:Create(name, TweenInfo.new(0.3), {
							TextColor3 = Color3.new(0.8, 0.8, 0.8)
						}):Play()
						game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
					end)
					name.MouseButton1Click:connect(function()
						if boldened ~= nil then
							boldened.Text = FirstName
						end
						boldened = name
						boldenedname = boldened.Text
						FirstName = name.Text
						name.Text = "<b>"..v.."</b>"
						script.Parent.Container["Finish Character"].Variant.Text = "<b>"..string.upper(FirstName).." "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
					end)
				end
			end
		end
	end
end

local function resetvalues()
	racevariant = "Default"
	face = ""
	gender = "Male"
	scroomhead = nil
	raceselect.RaceName.Female.FemaleButton.Text = "Female"
	raceselect.RaceName.Male.MaleButton.Text = "<b>".."Male".."</b>"
	FirstName = ""
	script.Parent.Container["Finish Character"].Variant.Text = "<b>".."??? "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
end

local function getvariants()
	for i,v in pairs(variantframe.ScrollingFrame:GetChildren()) do
		if v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end
	variantframe.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,30)
	racevariant = "Default"
	local lol = script.Parent.Example:Clone()
	lol.Parent = variantframe.ScrollingFrame
	lol.Text = "<b>".."Default".."</b>"
	lol.Visible = true
	lol.Name = "Default"
	lol.MouseEnter:connect(function()
		game.TweenService:Create(lol, TweenInfo.new(0.1), {
			TextColor3 = Color3.new(1, 1, 1)
		}):Play()
		game.TweenService:Create(lol.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
	end)
	lol.MouseLeave:connect(function()
		game.TweenService:Create(lol, TweenInfo.new(0.3), {
			TextColor3 = Color3.new(0.8, 0.8, 0.8)
		}):Play()
		game.TweenService:Create(lol.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
	end)
	lol.MouseButton1Click:connect(function()
		if racevariant == lol.Text then
			return
		end
		variantframe.ScrollingFrame:FindFirstChild(racevariant).Text = racevariant
		racevariant = lol.Text
		lol.Text = "<b>"..lol.Text.."</b>"
		UpdateAppearance(nil, true)
	end)

	for i,v in pairs(game.ReplicatedStorage.Info.Races[race]:GetChildren()) do
		if v.Name == "Bald" then  end
		if v:IsA("Folder") and v.Name ~= "Bald" then 
			local name = script.Parent.Example:Clone()
			name.Parent = variantframe.ScrollingFrame
			name.Text = v.Name
			name.Name = v.Name
			if racevariant == v.Name then
				name.Text = "<b>"..v.Name.."</b>"
			end
			name.Visible = true
			variantframe.ScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
			name.MouseEnter:connect(function()
				game.TweenService:Create(name, TweenInfo.new(0.1), {
					TextColor3 = Color3.new(1, 1, 1)
				}):Play()
				game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
			end)
			name.MouseLeave:connect(function()
				game.TweenService:Create(name, TweenInfo.new(0.3), {
					TextColor3 = Color3.new(0.8, 0.8, 0.8)
				}):Play()
				game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
			end)
			name.MouseButton1Click:connect(function()
				if racevariant == name.Text then
					return
				end
				variantframe.ScrollingFrame:FindFirstChild(racevariant).Text = racevariant
				racevariant = name.Text
				name.Text = "<b>"..name.Text.."</b>"
				UpdateAppearance(nil, true)
			end)
		end
	end
end

local function getraces()
	cooldown = true
	for i,v in pairs(raceselect.RaceName.Races.Shadow.MainFrame.ScrollingFrame:GetChildren()) do
		if v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end
	raceselect.RaceName.Races.Shadow.MainFrame.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
	raceselect.RaceName.Races.Shadow.MainFrame.ScrollingFrame.Size = UDim2.new(1,-30,0,0)
	raceselect.RaceName.Races.Shadow.MainFrame.MainFrame.Position = UDim2.new(1,0,0,20)
	raceselect.RaceName.Races.Shadow.MainFrame.Size = UDim2.new(1,0,0,30)
	raceselect.RaceName.Races.Shadow.MainFrame.RaceChance.Position = UDim2.new(1,0,0,70)
	for i,v in pairs(unlockedraces) do
		local name = script.Parent.Example:Clone()
		name.Parent = raceselect.RaceName.Races.Shadow.MainFrame.ScrollingFrame
		name.Text = v
		name.Name = v
		if race == v then
			name.Text = "<b>"..v.."</b>"
			boldenedrace = v
			bolding = name
		end
		if boldenedrace ~= nil and boldenedrace == v then
			bolding = name
		end
		name.Visible = true
		raceselect.RaceName.Races.Shadow.MainFrame.ScrollingFrame.CanvasSize += UDim2.new(0,0,0,30)
		raceselect.RaceName.Races.Shadow.MainFrame.ScrollingFrame.Size = UDim2.new(1,-30,0,math.min(raceselect.RaceName.Races.Shadow.MainFrame.ScrollingFrame.Size.Y.Offset + 30, 210))
		raceselect.RaceName.Races.Shadow.MainFrame.Size = UDim2.new(1,0,0,math.min(raceselect.RaceName.Races.Shadow.MainFrame.Size.Y.Offset + 30, 230))
		raceselect.RaceName.Races.Shadow.MainFrame.MainFrame.Position = UDim2.new(1,0,0,math.min(raceselect.RaceName.Races.Shadow.MainFrame.MainFrame.Position.Y.Offset + 30, 220))
		raceselect.RaceName.Races.Shadow.MainFrame.RaceChance.Position = UDim2.new(1,0,0,math.min(raceselect.RaceName.Races.Shadow.MainFrame.RaceChance.Position.Y.Offset + 30, 250))
		name.MouseEnter:connect(function()
			game.TweenService:Create(name, TweenInfo.new(0.1), {
				TextColor3 = Color3.new(1, 1, 1)
			}):Play()
			game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
		end)
		name.MouseLeave:connect(function()
			game.TweenService:Create(name, TweenInfo.new(0.3), {
				TextColor3 = Color3.new(0.8, 0.8, 0.8)
			}):Play()
			game.TweenService:Create(name.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
		end)
		name.MouseButton1Click:connect(function()
			if race == name.Name then return end
			resetvalues()
			if bolding ~= nil then
				bolding.Text = race
			end
			bolding = name
			boldenedrace = bolding.Text
			race = name.Text
			name.Text = "<b>"..v.."</b>"
			raceselect.RaceName.Shadow.RACENAME.Text = "<b>"..name.Text.."</b>"
			UpdateAppearance()
			getnames("")
			getfaces()
			getvariants()
		end)
	end
end

local function getedicts()
	local NoneButton = script.Parent["Edict  Selection"].NameFrame.EdictFrame.Example
	NoneButton.Text = "<b>".."None".."</b>"
	NoneButton.MouseButton1Click:Connect(function()
		boldenededict.Text = boldenededict2
		boldenededict = NoneButton
		boldenededict2 = boldenededict.Text
		boldenededict.Text = "<b>".."None".."</b>"
		edict = "None"
	end)
	NoneButton.MouseEnter:connect(function()
		game.TweenService:Create(NoneButton, TweenInfo.new(0.1), {
			TextColor3 = Color3.new(1, 1, 1)
		}):Play()
		game.TweenService:Create(NoneButton.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
	end)
	NoneButton.MouseLeave:connect(function()
		game.TweenService:Create(NoneButton, TweenInfo.new(0.3), {
			TextColor3 = Color3.new(0.8, 0.8, 0.8)
		}):Play()
		game.TweenService:Create(NoneButton.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
	end)
	for i,v in pairs(UnlockedEdicts) do
		local Example = script.Parent.Example:Clone()
		Example.Parent = script.Parent["Edict  Selection"].NameFrame.EdictFrame
		Example.Visible = true
		Example.Text = i.." - Tier "..v
		Example.ExampleShadow.Text = i.." - Tier "..v
		Example.MouseButton1Click:Connect(function()
			boldenededict.Text = boldenededict2
			boldenededict = Example
			boldenededict2 = boldenededict.Text
			boldenededict.Text = "<b>"..i.." - Tier "..v.."</b>"
			edict = i
		end)
		Example.MouseEnter:connect(function()
			game.TweenService:Create(Example, TweenInfo.new(0.1), {
				TextColor3 = Color3.new(1, 1, 1)
			}):Play()
			game.TweenService:Create(Example.ExampleShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
		end)
		Example.MouseLeave:connect(function()
			game.TweenService:Create(Example, TweenInfo.new(0.3), {
				TextColor3 = Color3.new(0.8, 0.8, 0.8)
			}):Play()
			game.TweenService:Create(Example.ExampleShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
		end)
	end
end

for i,v in pairs(script.Parent:GetDescendants()) do
	if v:IsA("TextButton") and v.Name ~= "choiceShadow" and v.Parent ~= script.Parent["Edict  Selection"].NameFrame.EdictFrame and v.Name ~= "ExampleShadow" then
		v.MouseButton1Click:connect(function()
			if v.Name == "NameChoice" then
				raceselect.Visible = false
				vanityselect.Visible = false
				nameselect.Visible = true
				edictselect.Visible = false
			elseif v.Name == "RaceChoice" then
				raceselect.Visible = true
				vanityselect.Visible = false
				nameselect.Visible = false
				edictselect.Visible = false
			elseif v.Name == "VanityChoice" then
				raceselect.Visible = false
				vanityselect.Visible = true
				nameselect.Visible = false
				edictselect.Visible = false
			elseif v.Name == "EdictChoice" then
				raceselect.Visible = false
				vanityselect.Visible = false
				nameselect.Visible = false
				edictselect.Visible = true
			elseif v.Name == "FemaleButton" then
				gender = "Female"
				raceselect.RaceName.Male.MaleButton.Text = "Male"
				raceselect.RaceName.Female.FemaleButton.Text = "<b>".."Female".."</b>"
				FirstName = ""
				script.Parent.Container["Finish Character"].Variant.Text = "<b>".."??? "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
				getnames("")
			elseif v.Name == "MaleButton" then
				gender = "Male"
				raceselect.RaceName.Female.FemaleButton.Text = "Female"
				raceselect.RaceName.Male.MaleButton.Text = "<b>".."Male".."</b>"
				FirstName = ""
				script.Parent.Container["Finish Character"].Variant.Text = "<b>".."??? "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
				getnames("")
			elseif v.Name == "FaceButton" then
				faceframe.Visible = true
				manaframe.Visible = false
				variantframe.Visible = false
			elseif v.Name == "ManaButton" then
				faceframe.Visible = false
				manaframe.Visible = true
				variantframe.Visible = false
			elseif v.Name == "VariantButton" then
				faceframe.Visible = false
				manaframe.Visible = false
				variantframe.Visible = true
			elseif v.Name == "FinishChar" then
				local Data = {
					Name = FirstName,
					Gender = gender,
					Race = race,
					Variant = racevariant,
					ManaColour = mana,
					Face = face,
					Edict = edict,
				}
				wipe:FireServer(Data)
				if character then
					character:Destroy()
				end
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				repeat wait() until
				game.Players.LocalPlayer.Character
				local l__Character__38 = game.Players.LocalPlayer.Character
				if l__Character__38 then
					local l__Humanoid__39 = l__Character__38:FindFirstChild("Humanoid")
					if l__Humanoid__39 then
						workspace.CurrentCamera.CameraSubject = l__Humanoid__39
						workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
						wait(0.001)
						script.Parent:Destroy()
					end
				end
			end
		end)
		v.MouseEnter:connect(function()
			game.TweenService:Create(v, TweenInfo.new(0.1), {
				TextColor3 = Color3.new(1, 1, 1)
			}):Play()
			game.TweenService:Create(v.choiceShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
		end)
		v.MouseLeave:connect(function()
			game.TweenService:Create(v, TweenInfo.new(0.3), {
				TextColor3 = Color3.new(0.8, 0.8, 0.8)
			}):Play()
			game.TweenService:Create(v.choiceShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
		end)
	end

end

nameselect.SearchBarFrame.NameSearch:GetPropertyChangedSignal("Text"):Connect(function()
	getnames(nameselect.SearchBarFrame.NameSearch.Text)
end)

CreateCharacter()
getfaces()
character.Humanoid:LoadAnimation(character.ANIMATION):Play()
getnames("")
getraces()
checkforraces()
getvariants()
getedicts()
raceselect.RaceName.Male.MaleButton.Text = "<b>".."Male".."</b>"
script.Parent.Container["Finish Character"].Variant.Text = "<b>".."??? "..string.upper(game.Players.LocalPlayer["leaderstats"].LastName.Value).."</b>"
if game.Players.LocalPlayer.PlayerGui:FindFirstChild("StatGui") then
	game.Players.LocalPlayer.PlayerGui.StatGui.Enabled = false
	game.Players.LocalPlayer.PlayerGui.BackpackGui.Enabled = false
	game.Players.LocalPlayer.PlayerGui.CurrencyGui.Enabled = false
	game.Players.LocalPlayer.PlayerGui.DialogueGui.Enabled = false
	game.Players.LocalPlayer.PlayerGui.LeaderboardGui.Enabled = false
end
local clicked = false

raceselect.RaceName.Races.Shadow.MainFrame.MainFrame.BuyReroll.MouseButton1Click:Connect(function()
	if clicked then return end
	raceselect.RaceName.Races.Shadow.MainFrame.RaceChance.Visible = true
	clicked = true
	marketplaceservice:PromptProductPurchase(game.Players.LocalPlayer,1349079279)
	task.spawn(function()
		task.wait(5)
		raceselect.RaceName.Races.Shadow.MainFrame.RaceChance.Visible = false
		task.wait(2)
		clicked = false
	end)
end)

game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child)
	cooldown = true
	if child.Name == "Rerolled" then
		resetvalues()
		if bolding ~= nil then
			bolding.Text = race
		end
		boldened = nil
		bolding = nil
		boldenedname = nil
		boldenedrace = nil -- 😂😂😂
		race = script.Parent.Script.RemoteFunction:InvokeServer("Race")
		temp = script.Parent.Script.RemoteFunction:InvokeServer("UnlockedRaces")
		iknowright = string.split(temp,",")
		unlockedraces = {}
		raceselect.RaceName.Shadow.RACENAME.Text = "<b>"..race.."</b>"
		for i,v in pairs(iknowright) do
			if v ~= "" then
				table.insert(unlockedraces, v)
			end
		end
		getraces()
		getnames("")
		UpdateAppearance()
		checkforraces()
		getfaces()
		nameselect.SearchBarFrame.NameSearch.Text = ""
	end
end)
local notalready = false
while cooldown and not notalready do
	notalready = true
	task.spawn(function()
		wait(1)
		notalready = false
		cooldown = false
	end)
end

local l__Parent__1 = script.Parent["Vanity Selection"].ManaFrame;
local l__Main__2 = l__Parent__1:WaitForChild("Main");
local l__Color__3 = l__Main__2:WaitForChild("Color");
local l__Slider__1 = script:WaitForChild("Slider");
local u2 = false;
local l__mouse__3 = game.Players.LocalPlayer:GetMouse();
local function v5(p1, p2)
	local v6 = l__Slider__1:clone();
	v6.Parent = p1;
	v6.Position = UDim2.new(p2, 0, 0.5, 0);
	local l__X__4 = p1.AbsolutePosition.X;
	local l__X__5 = p1.AbsoluteSize.X;
	v6.MouseButton1Down:connect(function()
		if u2 then
			return;
		end;
		u2 = true;
		while true do
			holdingm1 = false
			v6.Position = UDim2.new(math.clamp((l__mouse__3.X - l__X__4) / l__X__5, 0, 1), 0, 0.5, 0);
			game:GetService("RunService").RenderStepped:wait();
			if not u2 then
				break;
			end;		
		end;
	end);
	return v6;
end;
game:GetService("UserInputService").InputEnded:connect(function(p3)
	if p3.UserInputType == Enum.UserInputType.MouseButton1 then
		holdingm1 = false
		u2 = false;
	end;
end);
local l__BackgroundColor3__7 = l__Color__3.BackgroundColor3;
local v8, v9, v10 = Color3.toHSV(l__BackgroundColor3__7);
local v11 = v5(l__Main__2.Hue, v8);
local v12 = v5(l__Main__2.Saturation, v9 / 0.95);
local v13 = v5(l__Main__2.Value, (v10 - 0.05) / 0.9);
local u6 = l__BackgroundColor3__7;
local u7 = v8;
local u8 = v9;
local u9 = v10;
mana = Color3.new(l__Color__3.BackgroundColor3.R,l__Color__3.BackgroundColor3.G,l__Color__3.BackgroundColor3.B)
v11:GetPropertyChangedSignal("Position"):connect(function()
	u7 = v11.Position.X.Scale;
	u6 = Color3.fromHSV(u7, u8, u9);
	l__Color__3.BackgroundColor3 = u6;
	mana = Color3.new(l__Color__3.BackgroundColor3.R,l__Color__3.BackgroundColor3.G,l__Color__3.BackgroundColor3.B)
end);
v12:GetPropertyChangedSignal("Position"):connect(function()
	u8 = v12.Position.X.Scale;
	u6 = Color3.fromHSV(u7, u8, u9);
	l__Color__3.BackgroundColor3 = u6;
	mana = Color3.new(l__Color__3.BackgroundColor3.R,l__Color__3.BackgroundColor3.G,l__Color__3.BackgroundColor3.B)
end);
v13:GetPropertyChangedSignal("Position"):connect(function()
	u9 = v13.Position.X.Scale * 0.95 + 0.05;
	u6 = Color3.fromHSV(u7, u8, u9);
	l__Color__3.BackgroundColor3 = u6;
	mana = Color3.new(l__Color__3.BackgroundColor3.R,l__Color__3.BackgroundColor3.G,l__Color__3.BackgroundColor3.B)
end);


UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		holdingm1 = true
	end
end)
local oldpos = nil 
UIS.InputChanged:Connect(function(input)
	if holdingm1 and input.UserInputType == Enum.UserInputType.MouseMovement then
		if oldpos == nil then
			oldpos = input.Position.X
		end
		local dif = input.Position.X - oldpos
		character.HumanoidRootPart.CFrame *= CFrame.Angles(0,math.rad(dif),0)
		oldpos = input.Position.X
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		holdingm1 = false
		oldpos = nil
	end
end)
