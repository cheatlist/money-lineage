local hs = game.Workspace.Parent:GetService("HttpService")
local ts = game.Workspace.Parent:GetService("TweenService")

local ingredientsFolder = workspace:WaitForChild("Ingredients")
local alchemyFolder = game.ServerStorage:WaitForChild("Alchemy")
local ingredientModels = alchemyFolder:WaitForChild("Models")
local stationFolder = game.Workspace.Parent.Workspace:WaitForChild("Stations")
local toolHandler = require(game:GetService("ServerScriptService").ToolHandler)

game.ReplicatedStorage.Requests.CheckClient2.OnServerInvoke = function(p, arg)
	return ingredientsFolder
end

game.Workspace.Parent.CollectionService:AddTag(ingredientsFolder, "Harmless")

local effmod = require(game.Workspace.Parent.ServerScriptService.Modules.EffectModule)
local list_ingredients = require(script.list_alchemy)

local ingredientProps = list_ingredients.ingredients
local potionRecipes = list_ingredients.recipes

function compareTables(tableCont, tableRec)
	local equal = true
	table.sort(tableCont)
	table.sort(tableRec)
	if #tableCont ~= #tableRec then
		equal = false
	end
	if equal == true then
		for i = 1, #tableCont do
			if tableCont[i] ~= tableRec[i] then
				equal = false
				break
			end
		end
	end
	return equal
end

function checkTableForValue(ctable, cvalue)
	local found = false
	local amount = 0
	for i = 1, #ctable do
		if ctable[i] == cvalue then
			found = true
			amount = amount + 1
		end
	end
	return found, amount
end

function loadAlchemy()
	loadIngredients()
	loadCrucibles()
end

function loadCrucibles()
	for i, v in next, stationFolder:GetChildren() do
		loadCrucible(v)
	end
end

function loadCrucible(v)
	if v.Name == "AlchemyStation" then
		v.User.Changed:connect(function()
			if not v:IsDescendantOf(workspace) then
				return
			end

			if v.User.Value ~= "" then
				local timerGui = script.GUI:clone()
				timerGui.Parent = v.Timer
				timerGui.Enabled = true
				local other = false
				for tm = 60, 1, -1 do
					if not v:FindFirstChild("User") or v.User.Value == "" then
						other = true
						break
					end
					pcall(function()
						timerGui.Countdown.Text = tm
					end)
					wait(1)
				end
				timerGui:Destroy()

				if not v:IsDescendantOf(workspace) then
					return
				end

				if v:FindFirstChild("User") then
					v.User.Value = ""
				end
				if other == false then
					v.Contents.Value = "[]"
					v.Water.Drain:Play()
					v.Water.Boiling:Stop()
					v.Water.Bubbles.Enabled = false
					v.Water.Smoke.Enabled = false
				end
			end
		end)
		v.Contents.Changed:connect(function()
			local cnts = hs:JSONDecode(v.Contents.Value)
			local tweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			local level = (#cnts / 10)
			if level > .7 then
				level = .7
			end
			local coloring
			if #cnts > 0 then
				local totalR, totalG, totalB = 0, 0, 0
				for i = 1, #cnts do
					totalR = totalR + (ingredientProps[cnts[i]].color.r * 255)
					totalG = totalG + (ingredientProps[cnts[i]].color.g * 255)
					totalB = totalB + (ingredientProps[cnts[i]].color.b * 255)
				end
				totalR = totalR / (#cnts)
				totalG = totalG / (#cnts)
				totalB = totalB / (#cnts)

				coloring = Color3.fromRGB(totalR, totalG, totalB)
				if ingredientProps[cnts[#cnts]].hot == true then
					v.Water.Boiling:Play()
					v.Water.Bubbles.Enabled = true
					v.Water.Smoke.Enabled = true
				end
				v.Water.Bubbles.Color = ColorSequence.new(coloring)
			elseif #cnts == 0 then
				coloring = Color3.fromRGB(9, 137, 207)
			end
			local levelTween = ts:Create(v.Water.Level, tweenInfo, {
				Offset = Vector3.new(0, level, 0)
			})
			local colorTween = ts:Create(v.Water, tweenInfo, {
				Color = coloring
			})
			levelTween:Play()
			colorTween:Play()
		end)
		local empEn = true
		local empty = Instance.new("ClickDetector")
		empty.MaxActivationDistance = 8
		empty.Name = "ClickEmpty"
		empty.Parent = v.Bucket
		empty.MouseClick:connect(function(plr)
			if (v.User.Value ~= plr.Name) and (v.User.Value ~= "") then
				return
			end
			if not empEn then
				return
			end
			empEn = false
			v.Contents.Value = "[]"
			v.User.Value = ""
			v.Water.Drain:Play()
			v.Water.Boiling:Stop()
			v.Water.Bubbles.Enabled = false
			v.Water.Smoke.Enabled = false
			wait(.5)
			empEn = true
		end)
		local conEn = true
		local concoct = Instance.new("ClickDetector")
		concoct.MaxActivationDistance = 12
		concoct.Name = "ClickConcoct"
		concoct.Parent = v.Ladle
		concoct.MouseClick:connect(function(plr)
			warn(plr.Name, "clicked it omg")
			if v.User.Value ~= plr.Name then
				warn("nope cuz not same player")
				return
			end
			if not conEn then
				warn("idk what dis is tbh")
				return
			end
			conEn = false
			v.Water.Mix:Play()
			v.Water.Boiling:Stop()
			v.Water.Bubbles.Enabled = false
			v.Water.Smoke.Enabled = false
			local success = false
			local isPotion = false
			local crucContents = hs:JSONDecode(v.Contents.Value)
			local crucColor = v.Water.Color
			v.Contents.Value = "[]"
			for potion, props in next, potionRecipes do
				if compareTables(crucContents, props.recipe) == true then
					if string.match(potion, "Cooked") == nil then
						isPotion = true
					end

					local potionRef = alchemyFolder.Tools:FindFirstChild(potion)

					if potionRef then
						toolHandler.GiveAlchemy(plr, potion)

						if isPotion and game.ServerStorage.PlayerData[plr.Name].Skills.Value:find("Potion Efficiency") then
							toolHandler.GiveAlchemy(plr, potion)
						end
					end
					success = true
					break
				end
			end
		--[[	if isPotion and success == true then
				game.ServerStorage.PlayerData:FindFirstChild(plr.Name).PotionsCrafted.Value = game.ServerStorage.PlayerData:FindFirstChild(plr.Name).PotionsCrafted.Value + 1
			end]]
			if (success == false) and (#crucContents > 0) then
				v.Water.Fail:Emit(20)
				local ext = v.Water.FailSound:clone()
				ext.Parent = v.Water
				game.ServerStorage.Debris:Fire(ext, ext.TimeLength)
				ext:Play()
				if checkTableForValue(crucContents, "Orcher Leaf") == true then
					effmod.Explosion(v.Water.CFrame, 30, {
						mana = true,
						manaknockupself = true,
						manadisarm = true,
						damage = 65
					}, true, crucColor)
				elseif checkTableForValue(crucContents, "Polar Plant") == true then
					effmod.Explosion(v.Water.CFrame, 25, {
						mana = true,
						manaknockupself = true,
						manadisarm = true,
						damage = 50
					}, true, crucColor)
				elseif checkTableForValue(crucContents, "Vile Seed") == true then
					effmod.Explosion(v.Water.CFrame, 13, {
						mana = true,
						manaknockupself = true,
						manadisarm = true,
						damage = 50
					}, true, crucColor)
				elseif checkTableForValue(crucContents, "Lava Flower") == true then
					effmod.Explosion(v.Water.CFrame, 16, {
						mana = true,
						manaknockupself = true,
						manadisarm = true,
						damage = 30
					}, true, crucColor)
				elseif checkTableForValue(crucContents, "Trote") == true then
					effmod.Explosion(v.Water.CFrame, 10, {
						mana = true,
						manaknockupself = true,
						manadisarm = true,
						damage = 20
					}, false, crucColor)
				end
				wait(.4)
			end
			v.User.Value = ""
			wait(.5)
			conEn = true
		end)
	end
end

function loadIngredients()
	for i, v in next, ingredientsFolder:GetChildren() do
		v.Transparency = 1
		v.CanCollide = false
		game.Workspace.Parent.CollectionService:AddTag(v, "Harmless")

		if v:FindFirstChild("ParticleEmitter") then
			v.ParticleEmitter.Enabled = false
		end
		if v:FindFirstChild("PointLight") then
			v.PointLight.Enabled = false
		end

		local en = true

		local pickup = Instance.new("ClickDetector")
		pickup.MaxActivationDistance = 0
		pickup.Parent = v
		pickup.MouseClick:connect(function(plr)
			if not en then
				return
			end
			en = false

			if v.Transparency ~= 0 then
				en = true
				return
			end

			local char = plr.Character
			if not char then
				en = true
				return
			end

			local hum = char:FindFirstChild("Humanoid")
			local hrp = hum and char:FindFirstChild("HumanoidRootPart")
			if not hrp then
				en = true
				return
			end

			if hum.Health <= 0 then
				en = true
				return
			end

			if char:FindFirstChild("TPSafe") then
				en = true
				return
			end

			local mag = (hrp.Position - v.Position).magnitude
			if mag > 20 then
				if mag > 256 then
					local tag = Instance.new("Accessory")
					tag.Name = "NoLocationSave"
					tag.Parent = char

					local playerFolder = game.ServerStorage.PlayerData:FindFirstChild(plr.Name)
					if playerFolder then
						playerFolder.Data.LastLocation.Value = ""
					end

					game.ServerStorage.Requests.DiscordEvent:Fire("exploit", plr.Name .. " tried to pick up a " .. v.Name .. " from " .. mag .. " studs away!", plr.UserId, "Ingredient Exploit")
					hum.Health = 0

					game.ServerStorage.Requests.SuspicionStrike:Invoke(plr.UserId, "ingredient grabbing")
				end
				en = true
				return
			end

			local blFolder = v:FindFirstChild("Blacklist")
			if blFolder and blFolder:FindFirstChild(plr.Name) then
				en = true
				return
			end

			en = false

			if ingredientModels:FindFirstChild(v.Name) then
				v.Transparency = 1
				v.CanCollide = false
				if v:FindFirstChild("ParticleEmitter") then
					v.ParticleEmitter.Enabled = false
				end
				if v:FindFirstChild("PointLight") then
					v.PointLight.Enabled = false
				end

				pickup.MaxActivationDistance = 0

				local hasDuplicateSkill = game.ServerStorage.PlayerData[plr.Name].Skills.Value:find("Green Thumb")

				toolHandler.GiveAlchemy(plr, v.Name, true)
				if hasDuplicateSkill then
					toolHandler.GiveAlchemy(plr, v.Name, true)
				end
				
				local ch = plr.Character
				local playerFolder = ch and game.ServerStorage.PlayerData:FindFirstChild(ch.Name)
				local Race = playerFolder.Race.Value

				if v.Name == "Blood Thorn" and Race ~= "Azael" and Race ~= "Cameo" and Race ~= "Metascroom" and Race ~= "Scroom" and Race ~= "Fischeran" and Race ~= "Gaian" and Race ~= "Howler" and Race ~= "Lich" and Race ~= "Seraph" and Race ~= "Phoenix" then
					if playerFolder then
						if not game.Workspace.Parent.CollectionService:HasTag(ch, "Vampirism") and not ch:FindFirstChild("Phoenix") then
							playerFolder.Vampire.Value = true
							game.ServerStorage.Requests.Injure:Invoke(plr, "vampirism", true)
						end
					end
				end

				if blFolder then
					blFolder:ClearAllChildren()
				end
			else
				warn(plr.Name .. " tried to pick up " .. v.Name .. ", an ingredient that doesn't have a model located in ServerStorage>Alchemy>Models.")
			end

			wait()
			en = true
		end)
	end

	spawn(function()
		while true do
			spawnIngredients()
			wait(300)
		end
	end)
end

stationFolder.ChildAdded:Connect(function(station)
	loadCrucible(station)
end)

local spawnAllIngredients = true
function spawnIngredients()
	local lowplayers = (#game.Workspace.Parent.Players:GetChildren() < 3)
	for i, v in next, ingredientsFolder:GetChildren() do
		if ingredientProps[v.Name] then
			local dice = math.random(1, 100)
			if lowplayers then
				dice = math.random(1, 400)
			end
			--print'OKCHAT'
			if (dice <= ingredientProps[v.Name].rarity) or spawnAllIngredients then
				--print('nyaaahahahaha',v)
				v.Transparency = 0
				v.CanCollide = true
				v.ClickDetector.MaxActivationDistance = 9
				if v:FindFirstChild("ParticleEmitter") then
					v.ParticleEmitter.Enabled = true
				end
				if v:FindFirstChild("PointLight") then
					v.PointLight.Enabled = true
				end
			end
		elseif not ingredientProps[v.Name] then
			--warn("Attempted to spawn ingredient " .. v.Name .. " found in the workspace>Ingredients folder, which is not in the list_alchemy module.")
		end
	end
end

loadAlchemy()