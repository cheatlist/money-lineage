return function(Character, Player, PlayerData, CollectionService, HasTag, Boosts, FindFirstChild, TagHumanoid)
	if PlayerData.Vampire.Value == true then
		local FeedTool = game.ServerStorage.Classes.Feed:Clone()
		FeedTool.Parent = Player.Backpack
		CollectionService:AddTag(Character,"Vampirism")
		if PlayerData.EvampStep.Value > 2 then
			local Drain = game.ServerStorage.Classes.Drain:Clone()
			Drain.Parent = Player.Backpack
		end
	end

	local FaceData = PlayerData.Face.Value
	local RaceData = PlayerData:WaitForChild("Race")

	RaceData.Changed:Connect(function()
		if RaceData.Value == "Cameo" or RaceData.Value == "Azael" then
			PlayerData.Vampire.Value = false
		end
	end)

	PlayerData:WaitForChild("Vampire").Changed:Connect(function()
		if PlayerData.Vampire.Value == true then
			if not HasTag(CollectionService,Character,"Vampirism")then
				local FeedTool = game.ServerStorage.Classes.Feed:Clone()
				FeedTool.Parent = Player.Backpack
				CollectionService:AddTag(Character,"Vampirism")
				for _,v in pairs(Character:GetChildren())do
					if v.Name == "Head"or v.Name == "Torso"or v.Name == "Left Arm"or v.Name == "Right Arm"or v.Name == "Left Leg"or v.Name == "Right Leg"then
						local H,S,V = v.Color:ToHSV()
						v.Color = Color3.fromHSV(H,S/2,V)
					end
				end

				for _,v in pairs(Character:GetDescendants()) do
					if v:IsA("Decal") and v.Name == FaceData then
						v.Color3 = Color3.fromRGB(255,0,0)
					end
				end


			end
		elseif PlayerData.Vampire.Value == false then
			if HasTag(CollectionService,Character,"Vampirism")then

				local Race = PlayerData:WaitForChild("Race")
				local Variant = PlayerData:WaitForChild("RaceVariant")
				local RaceInfo = game.ReplicatedStorage.Info.Races:WaitForChild(Race.Value)
				if RaceInfo:FindFirstChild(Variant.Value)then
					RaceInfo = RaceInfo:FindFirstChild(Variant.Value)
				end

				for _,v in pairs(Character:GetDescendants()) do
					if v:IsA("Decal") and v.Name == FaceData then
						v.Color3 = RaceInfo.EyeColor.Value
					end
				end

				CollectionService:RemoveTag(Character,"Vampirism")
				for _,v in pairs(Character:GetChildren())do
					if v.Name == "Head"or v.Name == "Torso"or v.Name == "Left Arm"or v.Name == "Right Arm"or v.Name == "Left Leg"or v.Name == "Right Leg"then
						v.Color = RaceInfo.SkinColor.Value
					end
				end
				local br = FindFirstChild(Boosts,"Vampirism",true)
				if Character:FindFirstChild("Feed") then
					Character:FindFirstChild("Feed"):Destroy()
				else
					Player.Backpack:FindFirstChild("Feed"):Destroy()
				end
				if Character:FindFirstChild("Drain") then
					Character:FindFirstChild("Drain"):Destroy()
				else
					Player.Backpack:FindFirstChild("Drain"):Destroy()
				end
				if br then
					br.Parent:Destroy()
				end
				TagHumanoid:Fire(Character,Character,{nododge = true})
			end
		end
	end)

	PlayerData:WaitForChild("EvampStep").Changed:Connect(function()
		if PlayerData.EvampStep.Value > 2 then
			local Drain = game.ServerStorage.Classes.Drain:Clone()
			Drain.Parent = Player.Backpack
		end
	end)
end
