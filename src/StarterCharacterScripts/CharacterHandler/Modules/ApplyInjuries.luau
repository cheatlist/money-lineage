return function(Character, Player, PlayerData, Race, Torso, create, CollectionService)
	Character:WaitForChild("Head", 5)
	local Injuries2 = string.split(PlayerData.Injuries.Value,",")
	local hasfr = false
	if table.find(Injuries2,"dizzy") and Race.Value ~= "Metascroom" and Race.Value ~= "Gaian" and Race.Value ~= "Lich" then
		game.ReplicatedStorage.Requests.Dizzy:FireClient(Player, true)
	else
		game.ReplicatedStorage.Requests.Dizzy:FireClient(Player, false)
	end
	if table.find(Injuries2,"blind") and Race.Value ~= "Metascroom" and Race.Value ~= "Gaian" and Race.Value ~= "Lich" then
		game.ReplicatedStorage.Requests.Blind:FireClient(Player, true)
	else
		game.ReplicatedStorage.Requests.Blind:FireClient(Player, false)
	end
	if table.find(Injuries2,"chestgash") and Race.Value ~= "Lich" then
		if not Torso:FindFirstChild("Gash") then
			game.ServerStorage.Assets.Gash:Clone().Parent = Torso
		end
	else
		if Torso:FindFirstChild("Gash") then
			Torso.Gash:Destroy()
		end
	end
	if table.find(Injuries2,"heat") and Race.Value ~= "Lich" then
		if not Character.Head:FindFirstChild("BurnMark") then
			game.ServerStorage.Assets.BurnMark:Clone().Parent = Character.Head
		end
	else
		if Character.Head:FindFirstChild("BurnMark") then
			Character.Head.BurnMark:Destroy()
		end
	end
	if table.find(Injuries2,"Frostbite") and Race.Value ~= "Lich" then
		if not Character:FindFirstChild("FBited") then
			create("FBited", false, Character)
			for _,v in pairs(Character:GetChildren())do
				if v.Name == "Head"or v.Name == "Torso"or v.Name == "Left Arm"or v.Name == "Right Arm"or v.Name == "Left Leg"or v.Name == "Right Leg"then
					local H,S,V = v.Color:ToHSV()
					v.Color = Color3.fromHSV(H,S/2,V)
				end
			end
		end
	else
		if Character:FindFirstChild("FBited") then
			Character.FBited:Destroy()
			for _,v in pairs(Character:GetChildren())do
				if v.Name == "Head"or v.Name == "Torso"or v.Name == "Left Arm"or v.Name == "Right Arm"or v.Name == "Left Leg"or v.Name == "Right Leg"then
					local H,S,V = v.Color:ToHSV()
					v.Color = Color3.fromHSV(H,S * 2,V)
				end
			end
		end
	end
	if table.find(Injuries2,"brokenleg") and Race.Value ~= "Lich" then
		CollectionService:AddTag(Character,"BrokenLeg")
		Character.Animate.walk.WalkAnim.AnimationId = "11888151789"
	else
		if CollectionService:HasTag(Character,"BrokenLeg") then
			CollectionService:RemoveTag(Character,"BrokenLeg")
		end
		Player.Character.Animate.walk.WalkAnim.AnimationId = "11888155031"
	end
	if table.find(Injuries2,"brokenarm") and not table.find(Injuries2,"armless") and Race.Value ~= "Lich" then
		CollectionService:AddTag(Character,"BrokenArm")
		Character.Animate.idle.Animation1.AnimationId = "rbxassetid://11888158815"
		Character.Animate.idle.Animation2.AnimationId = "rbxassetid://11888158815"
	else
		if CollectionService:HasTag(Character, "BrokenArm") then
			CollectionService:RemoveTag(Character,"BrokenArm")
		end
		Character.Animate.idle.Animation1.AnimationId = "rbxassetid://11888162284"
		Character.Animate.idle.Animation2.AnimationId = "rbxassetid://11888162284"
	end
	if table.find(Injuries2,"armless") and Race.Value ~= "Metascroom" and Race.Value ~= "Gaian" and Race.Value ~= "Lich" then
		CollectionService:AddTag(Character,"Armless")
		Character:FindFirstChild("Left Arm").Transparency = 1
	else
		if CollectionService:HasTag(Character,"Armless") then
			CollectionService:RemoveTag(Character,"Armless")
		end
		if Character:FindFirstChild("Left Arm") then
			Character:FindFirstChild("Left Arm").Transparency = 0
		end
	end

	-- Mog-related injuries (added 2026-07-29, fixed): Injuries.Value itself already survives
	-- death fine (MoggingModule.grantTimedInjury's task.delay-scheduled removal isn't tied to the
	-- Character), but the Character-parented Accessory marker it ALSO creates - the thing
	-- client-side code (Sprint()/ClimbFunc() in CharacterHandler/Input/init.client.luau) and some
	-- server-side checks (SpellModule's own Squeamish gate) actually read, since they can't see
	-- ServerStorage.PlayerData - was never recreated on a new Character after death. A player who
	-- died while still logically Squeamish/Rage/etc. would silently lose the marker (and thus the
	-- effect) on respawn even though the injury hadn't actually expired. Fixed the same reactive
	-- way every injury above already works: this whole function re-runs on every
	-- PlayerData.Injuries.Changed (see the call site in CharacterHandler/init.server.luau), so this
	-- both restores the marker on a fresh Character (as long as Injuries.Value still lists it) and
	-- removes it automatically once MoggingModule's own scheduled removal fires and updates
	-- Injuries.Value - no separate timer needed here. Uses Instance.new("Accessory") directly
	-- (not the create() helper's Folder) to match grantTimedInjury's own marker type exactly.
	for _, name in ipairs({"Rage", "Squeamish", "VomitForcer", "LackEater", "AnythingEater"}) do
		if table.find(Injuries2, name) then
			if not Character:FindFirstChild(name) then
				local marker = Instance.new("Accessory")
				marker.Name = name
				marker.Parent = Character
			end
		else
			local marker = Character:FindFirstChild(name)
			if marker then
				marker:Destroy()
			end
		end
	end
end
