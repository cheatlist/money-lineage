return function(Character, Player, PlayerData, Race, ServerStorage)
	if (Race.Value == "Seraph" or Race.Value == "Phoenix") and PlayerData.Lives.Value > 0 and PlayerData.Area.Value ~= "The Hall of Shattered Wills" and PlayerData.Area.Value ~= "norpa" then
		Player.Character:WaitForChild("HumanoidRootPart")
		task.spawn(function()
			for num = 1,10 do
				local Descendants = Player.Character:GetDescendants()
				for i = 1,#Descendants do
					local v = Descendants[i]
					if (v:IsA("BasePart") or v:IsA("Decal"))and v.Name ~= "LeftHilt" and v.Name~="Hilt" and v.Parent.Name ~= "RuneArmLeft" and v.Parent.Name ~= "RuneArmRight" and v.Name ~= "Back" and v.Name ~= "HumanoidRootPart" and v.Name ~= "AngelForm" then
						v.Transparency = 1
					end
				end
				task.wait(.1)
			end
		end)
		local SeraphimFlight = game.ServerStorage.Assets.Seraphim.Flight.SeraphFly:Clone()
		SeraphimFlight.Parent = Character
		SeraphimFlight.Disabled = false
		--
		local Orb
		if Race.Value == "Seraph" then
			Orb = game.ServerStorage.Assets.Seraphim.AngelForm:Clone()
			Orb.Parent = Character
		else
			Orb = game.ServerStorage.Assets.Seraphim.PhoenixForm:Clone()
			Orb.Name = "AngelForm"
			Orb.Parent = Character
		end

		local Transparency = Instance.new('NumberValue')
		Transparency.Name = 'Transparency'
		Transparency.Parent = Character.Boosts
		Transparency.Value = 1

		local Weld = Instance.new("Weld")
		Weld.Part0 = Orb
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = Orb

		local Action = Instance.new("Folder")
		Action.Name = "Stun"
		Action.Parent = Character

		local LightFall = Instance.new("Folder")
		LightFall.Name = 'NoFall'
		LightFall.Parent = Character

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
			local fall = ServerStorage.RacialAbilities["Angel Fall"]:Clone()
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
						if v:IsA("BasePart") and v.Name~="Hilt" and v.Name ~= "LeftHilt" and v.Parent.Name ~= "RuneArmLeft" and v.Parent.Name ~= "RuneArmRight" and v.Name ~= "Back" and v.Name ~= "HumanoidRootPart" and v.Name ~= "AngelForm" then
							v.Transparency = 1
						end
					end
					task.wait(.05)
				end
			end)
		end
	else
		if Player.Backpack:FindFirstChild("Angel Fall") then
			Player.Backpack:FindFirstChild("Angel Fall"):Destroy()
		end
		if Player.Backpack:FindFirstChild("Phoenix Descent") then
			Player.Backpack:FindFirstChild("Phoenix Descent"):Destroy()
		end
	end
end
