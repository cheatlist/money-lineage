return function(Character, Player, PlayerData, Humanoid, HumanoidRootPart, Boosts, create, FindFirstChild, GetChildren, equipped, getWeapon, SigilBuffCheck, VanguardCheck, spearidle, wraithidle, katanaidle, greatswordidle, hammeridle, katanaequip, katanaequipturn)
	local eqstackcheck = 0
	local BardIdle

	local function equipweapon(tool)
		local WEAPON = getWeapon()
		if table.find(equipped, tool) then
			return
		end
		if not Character then
			return
		end
		if Character:FindFirstChild("Hilt"):FindFirstChild("Trumpet") then
			Character:FindFirstChild("Hilt"):FindFirstChild("Trumpet"):Destroy()
		end
		if Character:FindFirstChild("Hilt"):FindFirstChild("Lute") then
			Character:FindFirstChild("Hilt"):FindFirstChild("Lute"):Destroy()
		end

		if Character:FindFirstChild("Hilt"):FindFirstChild("GoldenLute") then
			Character:FindFirstChild("Hilt"):FindFirstChild("GoldenLute"):Destroy()
		end

		if tool:FindFirstChild("Song") then --// bard
			if tool:FindFirstChild("Song"):FindFirstChild("Trumpet") then
				local Trumpet = game.ServerStorage.Assets.Trumpet:Clone()

				if Trumpet then
					Trumpet.Parent = Character["Hilt"]
					Trumpet["PropWeld"].Part0= Character["Hilt"]
					Trumpet["PropWeld"].Part1 = Trumpet
					Trumpet["PropWeld"].C1 = CFrame.new(0.100000001, 0, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0);
					Trumpet["PropWeld"].C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				else
					warn("no trumpet!!")
				end
			else
				local Lute = game.ServerStorage.Assets.Lute:Clone()
				local GoldenLute = game.ServerStorage.Assets.GoldenLute:Clone()
				if Player.Name == "XY_D" then
					if GoldenLute then
						GoldenLute.Parent = Character["Hilt"]
						local PropWeld = Instance.new("Weld")
						PropWeld.Name = "PropWeld"
						PropWeld.Parent = Character["Hilt"]
						PropWeld.Part0 = Character["Hilt"]
						PropWeld.Part1 = GoldenLute
						PropWeld.C1 = CFrame.new(1, 1, 0, 0.499995947, -0.866027713, 2.98917294e-05, 0.66341269, 0.382995188, -0.64280498, 0.556675434, 0.321419746, 0.766029894);
						PropWeld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						GoldenLute.Transparency = 0;
						GoldenLute.Part.Transparency = 0;
						BardIdle = Humanoid:LoadAnimation(GoldenLute.BardIdle)
						BardIdle:Play();
					end
				end
				if Lute and  Player.Name ~= ""  then
					Lute.Parent = Character["Hilt"]
					local PropWeld = Instance.new("Weld")
					PropWeld.Name = "PropWeld"
					PropWeld.Parent = Character["Hilt"]
					PropWeld.Part0 = Character["Hilt"]
					PropWeld.Part1 = Lute
					PropWeld.C1 = CFrame.new(1, 1, 0, 0.499995947, -0.866027713, 2.98917294e-05, 0.66341269, 0.382995188, -0.64280498, 0.556675434, 0.321419746, 0.766029894);
					PropWeld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
					Lute.Transparency = 0;
					Lute.Part.Transparency = 0;
					BardIdle = Humanoid:LoadAnimation(Lute.BardIdle)
					BardIdle:Play();
				end
			end
			return
		end
		local equipcdcheck = false
		eqstackcheck+=1
		if FindFirstChild(Character,"EquipCD")then
			local old = eqstackcheck
			equipcdcheck = true
			while FindFirstChild(Character,"EquipCD")do
				task.wait(0.05)
			end
			if eqstackcheck~=old then
				return
			end
			if tool.Parent~=Character then
				return
			end
		end
		if equipcdcheck and tool.Parent~=Character then
			return
		end
		table.insert(equipped,tool)
		if not Character then
			return
		end
		if Humanoid and HumanoidRootPart then
			local hasweapon = tool:FindFirstChild("RequiresWeapon")
			if hasweapon and hasweapon.Value=="None"then
				hasweapon = nil
			end
			local dim = 0
			local children = Boosts:GetChildren()
			for i = 1,#children do
				local v = children[i]
				if v.Name == "Transparency" then
					dim += v.Value
				end
			end
			table.clear(children)
			if WEAPON then
				if dim >= 1 then
					if WEAPON:IsA("MeshPart") then
						WEAPON.Transparency = 1
					end
					local children = GetChildren(WEAPON)
					for i = 1,#children do
						local v = children[i]
						if v.Name == "EnchantEffect" then
							v.Enabled = false
						end
					end
					table.clear(children)
				else
					if WEAPON:IsA("MeshPart") then
						WEAPON.Transparency = 0
					end
					local children = GetChildren(WEAPON)
					for i = 1,#children do
						local v = children[i]
						if v.Name == "EnchantEffect" then
							v.Enabled = true
						end
					end
					table.clear(children)
				end
			end
			if FindFirstChild(tool,"PrimaryWeapon")or hasweapon then
				if WEAPON and WEAPON:FindFirstChild("PropWeld") then
					--local cl = WEAPON:Clone()
					--cl.Parent = WEAPON.Parent
					task.wait(1/30)
					--WEAPON.Parent = nil
					--WEAPON = cl
					for i,v in pairs(WEAPON:GetChildren()) do
						if v:IsA("Trail") then
							v.Enabled = false
						end
					end
					if WEAPON.Name == "Bronze Dagger" or WEAPON.Name == "Steel Dagger" or WEAPON.Name == "Mythril Dagger" then
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(0.25,0,-0.800000012,0,-1,0,1,0,-0,0,0,1)
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasDagger",false,Character)
						end
					elseif WEAPON.Name == "Twinfang"then
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(0.25,0,-0.800000012,0,-1,0,1,0,-0,0,0,1)
						WEAPON.Parent = Character.Hilt
						local offhandRef = WEAPON:FindFirstChild("OffhandPiece")
						local offhand = offhandRef and offhandRef.Value
						if offhand and Character:FindFirstChild("LeftHilt") then
							offhand.PropWeld.Part0 = Character.LeftHilt
							offhand.PropWeld.Part1 = offhand
							offhand.PropWeld.C1 = CFrame.new(0.25,0,-0.800000012,0,-1,0,1,0,-0,0,0,1)
							offhand.Parent = Character.LeftHilt
						end
						if #equipped <= 1 then
							create("HasDagger",false,Character)
						end
					elseif WEAPON.Name == "Tanto"then
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasDagger",false,Character)
						end
					elseif WEAPON.Name == "Spirit Dagger"then
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Color = Player.Backpack.ManaColor.Value
						WEAPON.PropWeld.C1 = CFrame.new(0.25,0,-0.800000012,0,-1,0,1,0,-0,0,0,1)
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasDagger",false,Character)
						end
					elseif WEAPON.Name == "Bronze Sword" or WEAPON.Name == "Steel Sword" or WEAPON.Name == "Mythril Sword" then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(-1.85000002,0,0,0,0,-1,-1,0,0,0,1,0)
						WEAPON.Parent = Character.Hilt
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Play()
						end

						if #equipped <= 1 then
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Illusory Sword" then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(0, -2, 0, 1, 0, 0, 0, -4.37113883e-08, -1, 0, 1, -4.37113883e-08)
						WEAPON.Parent = Character.Hilt
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Play()
						end

						if #equipped <= 1 then
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Spirit Sword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(-1.85000002,0,0,0,0,-1,-1,0,0,0,1,0)
						WEAPON.Color = Player.Backpack.ManaColor.Value
						WEAPON.Parent = Character.Hilt
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Play()
						end
						if #equipped <= 1 then
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Broom Sword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
						WEAPON.Parent = Character.Hilt
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Play()
						end
						if #equipped <= 1 then
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Dark Sword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Parent = Character.Hilt
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Play()
						end
						if #equipped <= 1 then
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Katana"then
						if WEAPON.Parent == Character:FindFirstChild("Hilt") then
							return
						end
						local EquipCD = Instance.new("Folder")
						EquipCD.Name = "EquipCD"
						EquipCD.Parent = Character
						game.Debris:AddItem(EquipCD,0.5)
						if not PlayerData.Skills.Value:find("Sheathe Mastery") then
							katanaequip:Play()
							task.wait(0.4)
						end
						katanaidle:Play()
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasKatana",false,Character)
						end
						HumanoidRootPart.KatanaUnsheathe:Play()
						local Katana = Character.Hilt:FindFirstChild("Katana")
						if Katana then
							Katana.Attachment1.Sparkle:Emit(3)
						end
					elseif WEAPON.Name == "Murasama"then
						local EquipCD = Instance.new("Folder")
						EquipCD.Name = "EquipCD"
						EquipCD.Parent = Character
						game.Debris:AddItem(EquipCD,0.5)
						katanaequip:Play()
						katanaidle:Play()
						task.wait(0.4)
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasKatana",false,Character)
						end
						HumanoidRootPart.KatanaUnsheathe:Play()
						local Katana = Character.Hilt:FindFirstChild("Murasama")
						if Katana then
							Katana.Attachment1.Sparkle:Emit(3)
						end
					elseif WEAPON.Name == "WraithSword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Parent = Character.Hilt
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Play()
						end
						if #equipped <= 1 then
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "DeathSword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Parent = Character.Hilt
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Play()
						end
						if #equipped <= 1 then
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "SealedSword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Parent = Character.Hilt
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Play()
						end
						if #equipped <= 1 then
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Rapier"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasRapier",false,Character)
						end
					elseif WEAPON.Name == "Bronze Spear" or WEAPON.Name == "Steel Spear" or WEAPON.Name == "Mythril Spear" then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(2,0,0,0,0,1,-1,0,0,0,-1,0)
						WEAPON.Parent = Character.Hilt
						spearidle:Play()
						if #equipped <= 1 then
							create("HasSpear",false,Character)
						end
					elseif WEAPON.Name == "Mythril Church Spear"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasSpear",false,Character)
							create("Prince's Favour",false,Character)
						end
					elseif WEAPON.Name == "Thorn Spear"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(0, 0, 0.100000001, -1, 1.50995803e-07, -6.60023616e-15, 0, -4.37113883e-08, -1, -1.50995803e-07, -1, 4.37113883e-08)
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasSpear",false,Character)
							create("Prince's Favour",false,Character)
						end
					elseif WEAPON.Name == "Broom Spear"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(0, -2, 0, -1, 0, -0, 0, 0, -1, 0, -1, -0)
						WEAPON.Parent = Character.Hilt
						spearidle:Play()
						if #equipped <= 1 then
							create("HasSpear",false,Character)
						end
					elseif WEAPON.Name == "Hammer"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(0, 0.899999976, 0, 0, -1, 0, 0, 0, -1, 1, 0, 0)
						WEAPON.Parent = Character.Hilt
						hammeridle:Play()
						if #equipped <= 1 then
							create("HasHammer",false,Character)
						end
					elseif WEAPON.Name == "Pronged Mythril Spear" then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(0, 0, -2, -1, 0, 0, 0, 1, 0, 0, 0, -1)
						WEAPON.Parent = Character.Hilt
						spearidle:Play()
						if #equipped <= 1 then
							create("HasSpear",false,Character)
						end
					elseif WEAPON.Name == "Fairfrozen"then
						if WEAPON:FindFirstChild'Weld'then
							WEAPON.Weld.Part0 = nil
							WEAPON.Weld.Part1 = nil
						end
						if WEAPON:FindFirstChild'PropWeld'then
							WEAPON.PropWeld.Part0 = Character.Hilt
							WEAPON.PropWeld.Part1 = WEAPON
							WEAPON.PropWeld.C1 = CFrame.new(2,0,0,0,0,1,-1,0,0,0,-1,0)
						end
						WEAPON.Parent = Character.Hilt
						spearidle:Play()
						if #equipped <= 1 then
							create("HasSpear",false,Character)
						end
					elseif WEAPON.Name == "SpearFairfrozen"then
						if WEAPON:FindFirstChild'Weld'then
							WEAPON.Weld.Part0 = nil
							WEAPON.Weld.Part1 = nil
						end
						if WEAPON:FindFirstChild'PropWeld'then
							WEAPON.PropWeld.Part0 = Character.Hilt
							WEAPON.PropWeld.Part1 = WEAPON
							WEAPON.PropWeld.C1 = CFrame.new(2,0,0,0,0,1,-1,0,0,0,-1,0)
						end
						WEAPON.Parent = Character.Hilt
						spearidle:Play()
						if #equipped <= 1 then
							create("HasSpear",false,Character)
						end
					elseif WEAPON.Name == "Iron Greatsword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(-3, 0, -0.200000003, 0, 0, -1, 1, 0, 0, 0, -1, 0)
						WEAPON.Parent = Character.Hilt
						greatswordidle:Play()
						if #equipped <= 1 then
							create("HasGreatsword",false,Character)
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Templar Greatsword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(0, -5, 0, -4.37113883e-08, 1, -4.37113883e-08, -0, -4.37113883e-08, -1, -1, -4.37113883e-08, 1.91068547e-15)
						WEAPON.Parent = Character.Hilt
						greatswordidle:Play()
						if #equipped <= 1 then
							create("HasGreatsword",false,Character)
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Lunar Greatsword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						WEAPON.PropWeld.C1 = CFrame.new(-0.200000003, -2.9000001, 0, 0, -1, 0, 0, 0, -1, 1, 0, 0)
						WEAPON.Parent = Character.Hilt
						greatswordidle:Play()
						if #equipped <= 1 then
							create("HasGreatsword",false,Character)
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Abyss Greatsword"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						--WEAPON.PropWeld.C1 = CFrame.new(-3, 0, -0.200000003, 0, 0, -1, 1, 0, 0, 0, -1, 0)
						WEAPON.PropWeld.C0 = CFrame.new(0.00048828125, -0.399414062, -2.63232422, 0, -1.00000012, 2.98023224e-08, -5.96046448e-08, -2.98023224e-08, 1, -1, 0, 5.96046448e-08)
						WEAPON.PropWeld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						WEAPON.Parent = Character.Hilt
						greatswordidle:Play()
						if #equipped <= 1 then
							create("HasGreatsword",false,Character)
							create("HasSword",false,Character)
						end
					elseif WEAPON.Name == "Bisento"then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(2,0,0,0,0,1,-1,0,0,0,-1,0)
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasSpear",false,Character)
						end
					elseif WEAPON.Name == "EXTREME_GS" then
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.PropWeld.Part0 = Character.Hilt
						WEAPON.PropWeld.Part1 = WEAPON
						WEAPON.PropWeld.C1 = CFrame.new(2,0,0,0,0,1,-1,0,0,0,-1,0)
						WEAPON.Parent = Character.Hilt
						if #equipped <= 1 then
							create("HasGreatsword",false,Character)
							create("HasSword",false,Character)
						end
					end
				end
				if #equipped <= 1 then
					local HasWeapon = Instance.new("ObjectValue")
					HasWeapon.Value = WEAPON
					HasWeapon.Name = "HasWeapon"
					HasWeapon.Parent = Character

				end
			end
		end
	end

	local function unequipweapon(tool)
		local WEAPON = getWeapon()
		if tool:FindFirstChild("Song") then
			if tool:FindFirstChild("Song"):FindFirstChild("Trumpet") then
				if Character.Hilt:FindFirstChild("Trumpet") and not
					(Character:FindFirstChild("Joyous Dance") or
						Character:FindFirstChild("Sweet Soothing") or
						Character:FindFirstChild("Song of Lethargy"))
				then
					Character.Hilt.Trumpet:Destroy()
				end
			else
				if BardIdle and not
					(Character:FindFirstChild("Vinifera's Song") or
						Character:FindFirstChild("Symphony of Horses"))
				then
					BardIdle:Stop()
				end
				if Character.Hilt:FindFirstChild("Lute") and not
					(Character:FindFirstChild("Vinifera's Song") or
						Character:FindFirstChild("Symphony of Horses"))
				then
					Character.Hilt.Lute:Destroy()
				end
				if Character.Hilt:FindFirstChild("GoldenLute") and not
					(Character:FindFirstChild("Vinifera's Song") or
						Character:FindFirstChild("Symphony of Horses"))
				then
					Character.Hilt.GoldenLute:Destroy()
				end
			end
			return
		end
		if #equipped<1 then
			if not Character then
				return
			end
			local equipcdcheck = false
			if FindFirstChild(Character,"EquipCD")then
				local old = eqstackcheck
				equipcdcheck = true
				while FindFirstChild(Character,"EquipCD")do
					task.wait(0.05)
				end
				if eqstackcheck~=old then
					return
				end
			end
			if #equipped>0 then
				return
			end
			local NewTool = Character:FindFirstChildOfClass("Tool")
			if NewTool and (NewTool:FindFirstChild("Weapon") or NewTool:FindFirstChild("PrimaryWeapon") or NewTool:FindFirstChild("RequiresWeapon")) then
				return
			end
			if Humanoid and HumanoidRootPart then
				if WEAPON and WEAPON.Parent and WEAPON:FindFirstChild("PropWeld") then
					if WEAPON.Name == "Bronze Dagger" or WEAPON.Name == "Steel Dagger" or WEAPON.Name == "Mythril Dagger" then
						WEAPON.Parent = nil
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
					elseif WEAPON.Name == "Twinfang"then
						WEAPON.Parent = nil
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local offhandRef = WEAPON:FindFirstChild("OffhandPiece")
						local offhand = offhandRef and offhandRef.Value
						if offhand then
							offhand.Parent = nil
							offhand.PropWeld.Part0 = nil
							offhand.PropWeld.Part1 = nil
						end
					elseif WEAPON.Name == "Tanto"then
						WEAPON.Parent = nil
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
					elseif WEAPON.Name == "Spirit Dagger"then
						WEAPON.Parent = nil
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
					elseif WEAPON.Name == "Bronze Sword" or WEAPON.Name == "Steel Sword" or WEAPON.Name == "Mythril Sword" then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Stop()
						end
						SigilBuffCheck()
					elseif WEAPON.Name == "Illusory Sword" then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.C0 = CFrame.new(0.25, 0, 0.649999976, 3.12722506e-08, 0.707106769, -0.707106829, -1.06770166e-07, -0.707106829, -0.707106769, -1, 9.76107231e-08, 5.3385083e-08)
							Weld.Part0 = Character.Torso
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Stop()
						end
						SigilBuffCheck()
					elseif WEAPON.Name == "Spirit Sword"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Weld.Part0 = Character.Torso
						WEAPON.Weld.Part1 = WEAPON
						WEAPON.Parent = Character.Torso
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Stop()
						end
						SigilBuffCheck()
					elseif WEAPON.Name == "Dark Sword"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Weld.Part0 = nil
						WEAPON.Weld.Part1 = nil
						WEAPON.Parent = Character.Torso
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Stop()
						end
						SigilBuffCheck()
					elseif WEAPON.Name == "Katana"then
						local EquipCD = Instance.new("Folder")
						EquipCD.Name = "EquipCD"
						EquipCD.Parent = Character
						game.Debris:AddItem(EquipCD,0.5)
						katanaidle:Stop()
						if not PlayerData.Skills.Value:find("Sheathe Mastery") then
							katanaequip:Play()
							katanaequipturn:Play()
							spawn(function()
								task.wait(0.4)
								katanaequip:Stop()
							end)
							task.wait(0.3)
						end
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = FindFirstChild(Character.Torso,"Sheath")or Character.Torso
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						HumanoidRootPart.KatanaUnsheathe:Play()
					elseif WEAPON.Name == "Murasama"then
						local EquipCD = Instance.new("Folder")
						EquipCD.Name = "EquipCD"
						EquipCD.Parent = Character
						game.Debris:AddItem(EquipCD,0.5)
						katanaidle:Stop()
						katanaequip:Play()
						katanaequipturn:Play()
						spawn(function()
							task.wait(0.4)
							katanaequip:Stop()
						end)
						task.wait(0.3)
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = FindFirstChild(Character.Torso,"Sheath2")or Character.Torso
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						HumanoidRootPart.KatanaUnsheathe:Play()
					elseif WEAPON.Name == "Rapier"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Weld.Part0 = Character.Torso
						WEAPON.Weld.Part1 = WEAPON
						WEAPON.Parent = Character.Torso
					elseif WEAPON.Name == "SealedSword"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Weld.Part0 = Character.Torso
						WEAPON.Weld.Part1 = WEAPON
						WEAPON.Parent = Character.Torso
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Stop()
						end
						SigilBuffCheck()
					elseif WEAPON.Name == "WraithSword"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Stop()
						end
						SigilBuffCheck()
					elseif WEAPON.Name == "DeathSword"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Weld.Part0 = Character.Torso
						WEAPON.Weld.Part1 = WEAPON
						WEAPON.Parent = Character.Torso
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Stop()
						end
						SigilBuffCheck()
					elseif WEAPON.Name == "Bronze Spear" or WEAPON.Name == "Steel Spear" or WEAPON.Name == "Mythril Spear" then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.C0 = CFrame.new(0,0.25,0.649999976,0.573557019,1.07884407e-05,-0.819165647,-0.819165647,2.07424164e-05,-0.57355696,1.07884407e-05,0.99999994,2.07424164e-05)
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						spearidle:Stop()
					elseif WEAPON.Name == "Mythril Church Spear"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
					elseif WEAPON.Name == "Thorn Spear"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.C0 = CFrame.new(0, 0.25, 0.649999976, -1.44230144e-05, -0.707106769, -0.707106769, 6.01238826e-05, 0.707106769, -0.707106769, 1, -5.27126176e-05, 3.23153945e-05)
							Weld.Part1 = WEAPON
							Weld.C1 = CFrame.new(0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						end
						WEAPON.Parent = Character.Torso
					elseif WEAPON.Name == "Hammer"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Weld.Part0 = Character.Torso
						WEAPON.Weld.C0 = CFrame.new(0, 0.25, 0.600000024, 0.866007268, -0.500031412, 0, 0.500031412, 0.866007268, 0, 0, 0, 1)
						WEAPON.Weld.Part1 = WEAPON
						WEAPON.Parent = Character.Torso
						hammeridle:Stop()
					elseif WEAPON.Name == "Broom Sword"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Weld.Part0 = Character.Torso
						WEAPON.Weld.Part1 = WEAPON
						WEAPON.Parent = Character.Torso
						if PlayerData.Skills.Value:find("WraithTraining") then
							wraithidle:Stop()
						end
						SigilBuffCheck()
					elseif WEAPON.Name == "Broom Spear"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.C0 = CFrame.new(-0.5, 1, 0.5, 0.819155693, -0.573571265, 0, 0.573571265, 0.819155693, 0, 0, 0, 1)
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						spearidle:Stop()
					elseif WEAPON.Name == "Iron Greatsword"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.C0 = CFrame.new(0, 0, 0.600000024, -0.5, -4.70876694e-05, 0.866025329, -0.866025388, -4.05311584e-05, -0.5, 5.86211681e-05, -1, -2.05039978e-05)
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						greatswordidle:Stop()
						SigilBuffCheck()
					elseif WEAPON.Name == "Templar Greatsword"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.C0 = CFrame.new(0, 0, 0.600000024)
							Weld.C1 = CFrame.new(0, -1, 0, -0.707134247, 0.707079291, 0, -0.707079291, -0.707134247, 0, 0, 0, 1)
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						greatswordidle:Stop()
						SigilBuffCheck()
					elseif WEAPON.Name == "Abyss Greatsword"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							--Weld.C0 = CFrame.new(0, 0, 0.600000024, -0.5, -4.70876694e-05, 0.866025329, -0.866025388, -4.05311584e-05, -0.5, 5.86211681e-05, -1, -2.05039978e-05)
							Weld.C0 = CFrame.new(-0.258300781, 0.0600585938, 0.495605469, -0.610812187, 9.20891762e-06, 0.791775465, -0.791775465, -1.87158566e-05, -0.610812306, 9.20891762e-06, -1, 1.86860561e-05)
							Weld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						greatswordidle:Stop()
					elseif WEAPON.Name == "Lunar Greatsword" then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.C0 = CFrame.new(-0.0520000011, 0.345999986, 0.575999975, -0.766061664, 0.642767608, 0, -0.642767608, -0.766061664, 0, 0, 0, 1)
							Weld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						VanguardCheck()
						greatswordidle:Stop()
					elseif WEAPON.Name == "Pronged Mythril Spear" then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.C0 = CFrame.new(-0.5, 0.75, 0.649999976, -0.819186211, -4.05311584e-06, -0.573527992, -0.573527992, 1.26957893e-05, 0.819186091, 4.05311584e-06, 1.00000012, -1.28746033e-05)
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						spearidle:Stop()
					elseif WEAPON.Name == "Fairfrozen"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.C0 = CFrame.new(0,0.25,0.649999976,0.573557019,1.07884407e-05,-0.819165647,-0.819165647,2.07424164e-05,-0.57355696,1.07884407e-05,0.99999994,2.07424164e-05)
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						spearidle:Stop()
					elseif WEAPON.Name == "SpearFairfrozen"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Color = Player.Backpack.ManaColor.Value
						local Weld = WEAPON:FindFirstChild'Weld'
						if Weld then
							Weld.Part0 = Character.Torso
							Weld.C0 = CFrame.new(0,0.25,0.649999976,0.573557019,1.07884407e-05,-0.819165647,-0.819165647,2.07424164e-05,-0.57355696,1.07884407e-05,0.99999994,2.07424164e-05)
							Weld.Part1 = WEAPON
						end
						WEAPON.Parent = Character.Torso
						spearidle:Stop()
					elseif WEAPON.Name == "Bisento"then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Weld.Part0 = Character.Torso
						WEAPON.Weld.C0 = CFrame.new(0,0.25,0.649999976,0.573557019,1.07884407e-05,-0.819165647,-0.819165647,2.07424164e-05,-0.57355696,1.07884407e-05,0.99999994,2.07424164e-05)
						WEAPON.Weld.Part1 = WEAPON
						WEAPON.Parent = Character.Torso
						spearidle:Stop()
					elseif WEAPON.Name == "EXTREME_GS" then
						WEAPON.PropWeld.Part0 = nil
						WEAPON.PropWeld.Part1 = nil
						WEAPON.Weld.Part0 = Character.Back
						WEAPON.Weld.Part1 = WEAPON
						WEAPON.Parent = Character.Torso
						greatswordidle:Stop()
					elseif WEAPON.Name == "norpGS" then
						if Character:FindFirstChild("equippednorpGS") then
							for _,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
								if v.Animation.Name == "GreatswordnorpIdle" then
									v:Stop()
								end
							end
							WEAPON.PropWeld.Part0 = nil
							WEAPON.Weld.Part0 = Character.Back
							WEAPON.Parent = Character.Torso
							Character:FindFirstChild("equippednorpGS"):Destroy()
						end
					end
				end
				for _: number, Obj in ipairs(Character:GetChildren())do
					if Obj.Name == "HasWeapon"or Obj.Name == "HasSword"or Obj.Name == "HasSpear"or Obj.Name == "HasDagger"or Obj.Name == "HasKatana" or Obj.Name == "HasHammer" or Obj.Name == "HasGreatswordnorp" or Obj.Name == "HasGreatsword"  or Obj.Name == "Prince's Favour"then
						Obj:Destroy()
						continue
					end
				end
			end

		end
	end

	return equipweapon, unequipweapon
end
