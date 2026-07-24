
repeat wait()until script.Parent.Parent == workspace.Live
local character = script.Parent
local tweenservice = game.TweenService
local hastag = game.CollectionService.HasTag
local collectionservice = game.CollectionService
local boosts = character:WaitForChild("Boosts")
local stomach = character:WaitForChild("Stomach")
local humanoid = character:WaitForChild("Humanoid")
local toxicity = character:WaitForChild("Toxicity")
local root = character:WaitForChild("HumanoidRootPart")
local player = game.Players:GetPlayerFromCharacter(character)
local GetChildren,GetDescendants = game.GetChildren,game.GetDescendants
local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
local PlayerData = game.ServerStorage.PlayerData:WaitForChild(player.Name)
local commands = require(game.ServerScriptService.Modules.Commands)
local newwait = task.wait
local noregen = false
local oldhealth = humanoid.Health

local whitelistedtovamp_anyrace = {

}

local function applyHealth()
	local helmetBoost

	local hp = 100
	local soulTags = 0
	local soulsnaps = string.split(PlayerData.Snaps.Value,",")
	local hpmod = {}
	for i,v in pairs(soulsnaps) do
		if v ~= "" then
			table.insert(hpmod, v)
		end
	end

	if PlayerData.Race.Value == "Castellan" then
		if #hpmod>2 then
			soulTags = #hpmod - 2
		end
	else
		if #hpmod>1 then
			soulTags = #hpmod - 1
		end
	end

	hp = hp*(0.95^soulTags)
	--hp = hp*(0.95^playerFolder.Data.DevilDeals.Value)

	for i,v in pairs(boosts:children()) do
		if v.Name == "HealthBoost" then
			hp = hp*(1+v.Value)
		end
	end

	local oldRatio = humanoid.Health/humanoid.MaxHealth
	humanoid.MaxHealth = hp
	humanoid.Health = hp*oldRatio

	character.Stomach.MaxValue = hp
	character.ExtraStomach.MaxValue = hp
end
local function haseldanrage()
	if not FindFirstChild(character,"RageCooldown")and not FindFirstChild(character,"SuperStrength")then
		game.ReplicatedStorage.Requests.AngryHaseldan:FireClient(player)
		local v1 = Instance.new("Accessory")
		v1.Name = "HaseldanDamageMultiplier"
		v1.Parent = character
		game.Debris:AddItem(v1,45)
		local v2 = Instance.new("Accessory")
		v2.Name = "SuperStrength"
		v2.Parent = character
		game.Debris:AddItem(v2,50)
		local v3 = Instance.new("Accessory")
		v3.Name = "RageCooldown"
		v3.Parent = character
		game.Debris:AddItem(v3,300)
		if humanoid.Health>3 then
			for _,v in pairs(GetChildren(character))do
				if v.Name == "Knocked"then
					v:Destroy()
				end
			end
		end
	end
end

applyHealth()
PlayerData.Lives.Changed:Connect(function()
	applyHealth()
end)

boosts.ChildAdded:Connect(applyHealth)
boosts.ChildRemoved:Connect(applyHealth)
spawn(function()
	while true do
		PlayerData.MinutesSurvived.Value +=1
		if PlayerData.Vampire.Value == true then
			if character:WaitForChild("Stomach").Value <= 0 then
				PlayerData.VampireStarving.Value += 1
			end
		end
		if character.Meditating.Value == true then
			PlayerData.MinutesMeditated.Value += 1
		end
		if PlayerData.MinutesSurvived.Value >= 15 then
			PlayerData.DaysSurvived.Value += 1
			PlayerData.MinutesSurvived.Value = 0
			PlayerData.CameoCD.Value = false
		end
		toxicity.Value-=1
		wait(60)
	end
end)
local race = WaitForChild(character,"Race").Value
local Whitelist = {Enum.Material.Grass,Enum.Material.Wood,Enum.Material.Sand,Enum.Material.Slate}
while true do
	while humanoid.Health<humanoid.MaxHealth do
		if humanoid.Health <= 0 then
			return
		end
		if FindFirstChild(character,"NoDam")then
			noregen = true
		else
			noregen = false
		end
		if FindFirstChild(character,"NoRegen") or FindFirstChild(character, "Burning") then
			noregen = true
		end
		if FindFirstChild(character, "ForceField") then
			noregen = true
		end
		if race == "Haseldan" and PlayerData.Ascended.Value == false then
			if humanoid.Health>3 and humanoid.Health<humanoid.MaxHealth*0.2 then
				haseldanrage()
			end
		elseif race == "Haseldan" and PlayerData.Ascended.Value == true then
			if humanoid.Health>3 and humanoid.Health<humanoid.MaxHealth*0.4 then
				haseldanrage()
			end
		end
		if FindFirstChild(character,"NoHunger") then
			if PlayerData.Race.Value == "Gaian"then
				if PlayerData.Armor.Value ~= "GaianDefault"then
					stomach.Value = math.huge
				else
					stomach.Value = 0
				end
			else
				stomach.Value = math.huge
			end
		end
		if not noregen or (player.Name == "  " or player.Name == "   ") then
			local baseregen: number = 0.5


			local blacklisted = {"Vind", "Fischeran", "Metascroom", "Scroom", "Gaian", "Seraph", "Lich", "Phoenix"}
			if race == "Vind" or race == "Fischeran" then
				baseregen *= 1.1
			end
			if race == "Dullahan" or race == "Seraph" or race == "Wretch" then
				baseregen *= 1.25
			end
			if character.ExtraStomach.Value > 0 then
				baseregen *= 2.25
			end
			if table.find(blacklisted, race) and not table.find(whitelistedtovamp_anyrace, tostring(player)) and PlayerData.Vampire.Value == true then
				PlayerData.Vampire.Value = false
			end
			local offstomach: number = (baseregen+((100-humanoid.MaxHealth)/1000))*0.25
			if hastag(collectionservice,character,"Vampirism")then
				if stomach.Value>0 then
					baseregen*= 3
				else
					baseregen*= 1.1
				end
				offstomach*= 1.75--//2.25
				if PlayerData.EvampStep.Value > 0 then
					baseregen *= 1.1
					offstomach *= 0.8	
				end
			else
				if stomach.Value>0 then
					baseregen *= 1.5
				end
			end
			local regenboost = FindFirstChild(boosts,"HealthRegen")
			if regenboost then
				local bc = GetChildren(boosts)
				for i,v in ipairs(bc)do
					if v.Name == 'HealthRegen'then
						baseregen += v.Value * .5
					end
				end
			end
			if character:FindFirstChild("ViniferaBuff") then
				baseregen = 4.5/4
			end
			if PlayerData.Skills.Value:find("Regrowth") then
				if table.find(Whitelist, character.Humanoid.FloorMaterial) then
					baseregen *= 1.25
				end
			end
			if not (PlayerData.Race.Value == "Gaian" and PlayerData.Armor.Value == "GaianDefault") and PlayerData.Race.Value ~= "Phoenix" then
				humanoid.Health+=(baseregen*0.4)
			end
			if stomach.Value > 0 and character.ExtraStomach.Value <= 0 and not character:FindFirstChild("NoHunger") then
				stomach.Value-= offstomach
			elseif character.ExtraStomach.Value > 0 then
				character.ExtraStomach.Value -= offstomach * 3.5
			end
		end	
		if root.DragonBloodC.Enabled then
			if humanoid.Health-0.25>5 and not hastag(collectionservice,character,"Vampirism") then
				humanoid.Health-=0.25
			elseif humanoid.Health-0.5>5 and hastag(collectionservice,character,"Vampirism") then
				humanoid.Health-=0.5
			else
				root.DragonBloodC.Enabled = false
			end
		end
		if root.RageParticle.Enabled then
			if humanoid.Health-0.5>5 then
				humanoid.Health-=0.5
			else
				root.RageParticle.Enabled = false
			end
		end
		if PlayerData.Skills.Value:find("IllusionMastery") and not character:FindFirstChild("IllusoryEscape") and humanoid.Health / humanoid.MaxHealth < 0.25 and oldhealth > humanoid.Health and not character:FindFirstChild("ForceField") then
			require(game.ServerScriptService.Modules.IllusionModule).Escape(character)
		end
		oldhealth = humanoid.Health
		newwait(0.25)
	end
	humanoid.HealthChanged:Wait()
end