game.Players.LocalPlayer.ChildRemoved:Connect(function(ch)
	if ch.Name == "Ingame" then
		script.Disabled=true
	end
end)
local v1 = nil
local CantCharge = false
local LocalPlayer = game:GetService'Players'.LocalPlayer
local Character = LocalPlayer.Character
local CollectionService = game:GetService("CollectionService")
local HasTag = CollectionService.HasTag
local casting = false
while not Character do
	wait()
	Character = LocalPlayer.Character
end
local Mouse = LocalPlayer:GetMouse()
local Backpack = LocalPlayer.Backpack
local ContextActionService =game:GetService("ContextActionService")
local FowardMovement = Enum.PlayerActions.CharacterForward
local BackwardMovement = Enum.PlayerActions.CharacterBackward
local RightMovement = Enum.PlayerActions.CharacterRight
local LeftMovement = Enum.PlayerActions.CharacterLeft
local function Sink()
	return Enum.ContextActionResult.Sink
end

local function getIngredientsFolder()
	return game.ReplicatedStorage.Requests.CheckClient2:InvokeServer(game.JobId:gsub("%d", ""))
end


local function Pass()
	return Enum.ContextActionResult.Pass
end
local controls = require(game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule):GetControls()
controls:Enable(true)
game.ReplicatedStorage.Requests.Dominused.OnClientEvent:Connect(function(State)
	if State then
		local controls = require(game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule):GetControls()
		controls:Disable()
	else
		local controls = require(game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule):GetControls()
		controls:Enable(true)
	end
end)
task.spawn(function()
	for i = 1,20 do
		local controls = require(game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule):GetControls()
		controls:Enable(true)
		wait(0.1)
	end
end)
game.ReplicatedStorage.Requests.ClearDashVelo.OnClientEvent:Connect(function()
	for i,v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
		if v:IsA("BodyVelocity") then
			task.wait(1/30)
			v:Destroy()
		end
	end
end)
local function hpview()
	for _,v in pairs(workspace.Live:GetChildren()) do
		if v ~= Character then
			local z = v:FindFirstChildWhichIsA("Humanoid")
			if z then
				z.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
				if v:FindFirstChild("MonsterInfo") then
					z.NameDisplayDistance = 0
				end
				z.HealthDisplayDistance = 35
				z.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
			end
		end
	end
	workspace.Live.ChildAdded:Connect(function(ch)
		if ch ~= Character then
			local z = ch:WaitForChild("Humanoid",3)
			if z then
				z.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
				if ch:FindFirstChild("MonsterInfo") then
					z.NameDisplayDistance = 0
				end
				z.HealthDisplayDistance = 35
				z.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
			end
		end
	end)
end
if Backpack:FindFirstChild("HealthView") then
	hpview()
end
Backpack.ChildAdded:Connect(function(deb)
	if deb.Name == "HealthView" then
		hpview()
	end
end)
local UserInputService = game:GetService("UserInputService")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Mana = Character:WaitForChild("Mana")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local OverlayGui = PlayerGui:WaitForChild("OverlayGui")
local WorldPulse = OverlayGui:WaitForChild("WorldPulse")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local GetChildren = game.GetChildren
local Lighting = game:GetService'Lighting'
local GetSunDirection = Lighting.GetSunDirection
local v25 = (function()
	for v26, v27 in pairs(GetChildren(workspace)) do
		if v27.Name == "Folder" and v27.Name ~= "Map" then
			for v28, v29 in pairs(GetChildren(v27)) do
				if v29.Name == "UnionOperation" and v29.Transparency == 1 then
					return v27
				end
			end
		end
	end
end)()
local v30 = v25 and GetChildren(v25)
game:GetService("ContextActionService"):UnbindAction("EmotesMenuToggleAction")
LocalPlayer.CameraMaxZoomDistance = 45
local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA
local GetDescendants = game.GetDescendants
local LoadAnimation = Instance.new("Humanoid").LoadAnimation
local GetState = Instance.new("Humanoid").GetState
local SoundStop = Instance.new("Sound").Stop
local SoundPlay = Instance.new("Sound").Play
local CollectionService = game:GetService("CollectionService")
scr = script
local function sub(...)
	coroutine.wrap(...)()
end
local Requests = ReplicatedStorage:WaitForChild("Requests")

--print("= R.CHECK ================")
--print("NOTE: If you don't see A, B, C, & D below, post a screenshot of this console in bug-reports.")

local Live = workspace:WaitForChild("Live")
local NPCs = workspace:WaitForChild("NPCs")
local Thrown = workspace:WaitForChild("Thrown")
local Terrain = workspace:WaitForChild("Terrain")
local Remotes = script.Parent:WaitForChild("Remotes")
local InvokeServer = Instance.new("RemoteFunction").InvokeServer
local FireServer = Instance.new("RemoteEvent").FireServer
local Humanoid = Character:WaitForChild("Humanoid")
Humanoid:SetStateEnabled("FallingDown",false)
Humanoid:SetStateEnabled("Ragdoll",false)
Humanoid:SetStateEnabled("Flying",false)
local v64 = Instance.new("Animation")
v64.AnimationId = "rbxassetid://11888168221"
local v65 = LoadAnimation(Humanoid,v64)
local Charging = HumanoidRootPart:WaitForChild("Charging")
local FindPartOnRay = workspace.FindPartOnRay
local FindFirstChildOfClass = game.FindFirstChildOfClass
local Stuns = {"Stun", "ReturnStun", "Action", "Blocking"}
local FindFirstChild = game.FindFirstChild
local WaitForChild = game.WaitForChild
local HasTag = CollectionService.HasTag

local LegBroken = CollectionService:HasTag(LocalPlayer.Character ,"BrokenLeg")

	--[[
	local KeyHandler = require(ReplicatedStorage.Assets.Modules.KeyHandler);
	KeyHandler.Init(game.Players.LocalPlayer.Name.."'s","Key")
	local ApplyFallDamage = Remotes.ApplyFallDamage
	local GetData = Remotes.GetData
	local Sprint = Remotes.Sprint
	KeyHandler.createKey(ApplyFallDamage);
	KeyHandler.createKey(GetData)
	KeyHandler.createKey(Sprint)

	local Remote = KeyHandler.getKey("ApplyFallDamage") 
	local Remote2 = KeyHandler.getKey("GetData")
	local Remote4 = KeyHandler.getKey("Sprint")

	sub(function()
		if Remote then
			print("CHECK PASSED: A")
		end
	end)
	sub(function()
		if Remote2 then
			print("CHECK PASSED: B")
		end
	end)
	sub(function()
		if Remote2 then
			print("CHECK PASSED: C")
		end
	end)
	sub(function()
		if Remote4 then
			print("CHECK PASSED: D")
		end
	end)
	--]]
function SpecialActionCheck()
	if not FindFirstChildOfClass(Character,"Humanoid") then
		return true
	end
	for _,v in pairs(Stuns)do
		if v then
		else
			break
		end
		if FindFirstChild(Character,v) then
			return true
		end	
	end
	if Humanoid.Health == 0 then
		return true
	end
	if HasTag(CollectionService,Character,"BeingExecuted")then
	else
		return
	end
	return true
end
local Head = Character:WaitForChild("Head")
local Torso = Character:WaitForChild("Torso")
local Light = Instance.new("PointLight",Head)
Light.Shadows = false
Light.Range = 25
Light.Brightness = 0.1
local v75 = Requests.Get:InvokeServer({"ManaTier"})
local FindPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
Requests.Hallucinate.OnClientEvent:Connect(function(ChosenPlayer)
	for i,v in pairs(workspace.Live:GetChildren()) do
		if LocalPlayer ~= ChosenPlayer and v == ChosenPlayer.Character then
			v:Destroy()
		elseif LocalPlayer == ChosenPlayer and v ~= ChosenPlayer.Character then
			v:Destroy()
		end
	end
	if LocalPlayer == ChosenPlayer and not LocalPlayer:FindFirstChild("Hallucinate55") then
		Instance.new("Folder", LocalPlayer).Name = "Hallucinate55"
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		local dialogues = {"What is there left anymore... Only dust..?", "Where is everyone?", "Did I even exist?", "Am I really alone in this vast world..?"}
		game.Lighting.Blindness.Contrast = 5
		local dialogueorder = 1
		task.spawn(function()
			while wait(20) do
				game.Chat:Chat(LocalPlayer.Character.Head, dialogues[dialogueorder], Enum.ChatColor.White)
				dialogueorder += 1
				if dialogueorder >= 5 then
					dialogueorder = 1
				end
			end
		end)
	end
end)

local gm = game.Workspace.Parent
local del = gm.Destroy
local playsound = Instance.new("Sound").Play;
local seerOverlay = OverlayGui.Seer
local TS = game:GetService("TweenService")
local tweencreate = TS.Create;
local seerBlinded = false
Requests.SeerEye.OnClientEvent:Connect(function(bool)
	if bool and not seerBlinded then
		seerBlinded = true

		seerOverlay.Visible = true
		tweencreate(TS, seerOverlay, TweenInfo.new(0.5), {
			BackgroundTransparency = 0
		}):Play()
		wait(1)

		local eye = seerOverlay.Eye:Clone()
		eye.Parent = seerOverlay

		tweencreate(TS, eye.Sound, TweenInfo.new(1), {
			Volume = 2
		}):Play()
		playsound(eye.Sound)

		eye.Visible = true
		eye:TweenSizeAndPosition(UDim2.new(0, 500, 0, 500), UDim2.new(0.5, -250, 0.5, -175), 
			Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2)
		wait(1)

		tweencreate(TS, eye.Sound, TweenInfo.new(0.5), {
			Volume = 0
		}):Play()
		tweencreate(TS, eye, TweenInfo.new(0.5), {
			ImageTransparency = 1
		}):Play()
		wait(0.4)
		tweencreate(TS, seerOverlay, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()
		wait(0.5)

		seerOverlay.Visible = false
		del(eye)

		wait(2)
		seerBlinded = false
	end
end)
Requests.Dizzy.OnClientEvent:Connect(function(Statement, Size)
	if Statement then

		game.Lighting.Blur.Enabled = true
		if not Size then
			game.Lighting.Blur.Size = 14
		else
			game.Lighting.Blur.Size = Size
		end
	else
		game.Lighting.Blur.Enabled = false
		game.Lighting.Blur.Size = 0
	end
end)
Requests.TPtoNonCliff.OnClientEvent:Connect(function(p2)
	local v76 = CFrame.new(p2, HumanoidRootPart.Position)
	local v77 = HumanoidRootPart.Position - p2
	for v78 = 1, 10 do
		local v79, v80, v81 = FindPartOnRayWithIgnoreList(workspace, Ray.new((v76 * CFrame.new(0, 0, v77.Magnitude / -10)).p, Vector3.new(0, -50, 0)), {Thrown,Live,workspace.AreaMarkers })
		if v79 then
			if v79.CanCollide then
				HumanoidRootPart.CFrame = CFrame.new(v80, v80 + HumanoidRootPart.CFrame.lookVector)
				return
			end
			if v79.Transparency == 0 then
				HumanoidRootPart.CFrame = CFrame.new(v80, v80 + HumanoidRootPart.CFrame.lookVector)
				return
			end
		end
	end
end)
Requests.LetThrough.OnClientEvent:Connect(function(p3, p4, abs)
	if p4 == true then
		p3.CanCollide = false;
		task.delay(0.5, function()
			if not abs then
				p3.CanCollide = true;
			end
		end);
		return;
	end;
	if p4 == false and p3.CanCollide == false then
		p3.CanCollide = true;
	end;
end);
local CombatAnims = ReplicatedStorage:WaitForChild("CombatAnims")
CombatAnims:WaitForChild("Sprint")
sub(function()
	game:GetService("ContentProvider"):PreloadAsync(GetChildren(CombatAnims))
end)
local SprintAnim = LoadAnimation(Humanoid, CombatAnims.Sprint)
local ClimbIdle = LoadAnimation(Humanoid, CombatAnims.ClimbIdle)
local ClimbScramble = LoadAnimation(Humanoid, CombatAnims.ClimbScramble)
local ClimbUp = LoadAnimation(Humanoid, CombatAnims.ClimbUp)
local ClimbLeft = LoadAnimation(Humanoid, CombatAnims.ClimbLeft)
local ClimbRight = LoadAnimation(Humanoid, CombatAnims.ClimbRight)
Requests.GetMouse.OnClientInvoke = function(filter)
	if filter then
		Mouse.TargetFilter = filter
	else
		Mouse.TargetFilter = nil
	end
	return{
		Hit = Mouse.Hit, 
		Target = Mouse.Target, 
		UnitRay = Mouse.UnitRay, 
		X = Mouse.X, 
		Y = Mouse.Y,
		MouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1),
	}
end
local invisparts = {};
for i,v in next, workspace:GetDescendants() do
	if v:IsA("BasePart") and v.Transparency == 1 then
		table.insert(invisparts,v);
	end
end
local rayParams = RaycastParams.new();
local function mouseHit(ignore)
	local ign = {Character}
	for i,v in next,ignore do
		table.insert(ign,v)
	end

	rayParams.FilterDescendantsInstances = ign
	local camray = Mouse.UnitRay
	return workspace:Raycast(camray.Origin,camray.Direction * 1000, rayParams)
end
Requests.GetMouse2.OnClientInvoke = function()
	local rayhit = mouseHit(invisparts)

	local tab = {}
	tab.Hit = rayhit and CFrame.new(rayhit.Position) or Mouse.Hit
	tab.Target = rayhit and rayhit.Instance or Mouse.Target
	tab.UnitRay = Mouse.UnitRay
	tab.X = Mouse.X
	tab.Y = Mouse.Y
	return tab
end
local IsA = game.IsA
local Destroy = game.Destroy
Requests.ClearDodgeVels.OnClientEvent:Connect(function()
	for _,v in pairs(GetChildren(HumanoidRootPart)) do
		if IsA(v, "BodyVelocity") and v.Name == "DodgeVel" then
			Destroy(v)
		end
	end
end)
local CurrentCamera = game.Workspace.CurrentCamera
local u16 = { "SpellBlocking", "ActiveCast", "HeavyAttack", "Blocking", "LightAttack", "NoSprint" }
game.ReplicatedStorage.Observe.OnClientEvent:Connect(function(character, default)
	if default then
		game.Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
		return
	end
	game.Workspace.CurrentCamera.CameraSubject = character.Head
end)
local function u17()
	if not FindFirstChildOfClass(Character, "Humanoid") then
		return true
	end
	if SpecialActionCheck() then
		return true
	end
	if FindFirstChild(Character, "Climbing") then
		return true
	end
	if Humanoid.Health == 0 then
		return true
	end
	if HasTag(CollectionService, Character, "BeingExecuted") then
		return true
	end
	if FindFirstChild(Character, "Knocked") then
		return
	end
end
local CanDash = true
local CanDash2 = true
local Sprinting = false
local function u20()
	for _,v in pairs(u16)do
		if FindFirstChild(Character, v) then
			return
		end
	end
	if FindFirstChild(Character, "Grabbing") and not FindFirstChild(Backpack, "MercenaryCarry") then
		return
	end
	if u17() then
		return
	end
	if CanDash == false then
		return
	end
	if Humanoid.Sit then
		return
	end
	if FindFirstChild(Character, "Knocked") then
		return
	end
	if LegBroken then
		return
	end
	if HasTag(CollectionService, Character, "Casting") then
		return
	end
	if Charging.Playing then
		return
	end
	return true
end

local SpeedBoost = 0
local Play = SprintAnim.Play
local GreatSwordManaSprint = LoadAnimation(Humanoid, CombatAnims.GreatSwordManaSprint)
local HammerManaSprint = LoadAnimation(Humanoid, CombatAnims.HammerManaSprint)
local ManaSprint = LoadAnimation(Humanoid, CombatAnims.ManaSprint)
local KatanaManaSprint = LoadAnimation(Humanoid, CombatAnims.KatanaManaSprint)
local SpearManaSprint = LoadAnimation(Humanoid, CombatAnims.SpearManaSprint)
local Stop = SprintAnim.Stop
local AddItem = game.Debris.AddItem
local u33 = false
local GreatSwordSprint = LoadAnimation(Humanoid, CombatAnims.GreatSwordSprint)
local HammerSprint = LoadAnimation(Humanoid, CombatAnims.HammerSprint)
local KatanaSprint = LoadAnimation(Humanoid, CombatAnims.KatanaSprint)
local SpearSprint = LoadAnimation(Humanoid, CombatAnims.SpearSprint)
local NewClimbScramble = ClimbScramble
local AddTag = CollectionService.AddTag
local Create = TweenService.Create
local hal = workspace.Live:FindFirstChild("Hallucination", true)
if hal then
	hal.Parent:Destroy()
end
local function Sprint(Value)

	if LegBroken then
		return
	end

	if FindFirstChild(Character, "Squeamish") then
		return
	end

	if Value ~= true or not (not Sprinting)then
		if Sprinting then
			Sprinting = false
			SpeedBoost = 0
			u33 = false
			Stop(GreatSwordSprint)
			Stop(HammerSprint)
			Stop(KatanaSprint)
			Stop(SpearSprint)
			Stop(SprintAnim)
			Remotes.Sprint:FireServer(Sprinting)
		end
		return
	end
	if not u20() then
		return
	end
	if FindFirstChild(Character, "Charge")then
		Destroy(Character.Charge)
	end
	if Character.Mana.Value > 0 then
		if HasTag(CollectionService, Character, "Vampirism") and not FindFirstChild(Character, "AntiVampirism")then
			SpeedBoost = 28
		else
			SpeedBoost = 25
		end

		sub(function()
			local ManaColor = Backpack.ManaColor.Value
			local ParticleBack = ReplicatedStorage.Assets.ParticleBack:Clone()
			ParticleBack.TestTrail.Color = ColorSequence.new(Color3.new(ManaColor.r, ManaColor.g, ManaColor.b))
			ParticleBack.CFrame = HumanoidRootPart.CFrame
			ParticleBack.Parent = Thrown
			local Weld = Instance.new("Weld")
			Weld.Parent = ParticleBack
			Weld.Part0 = HumanoidRootPart
			Weld.Part1 = ParticleBack
			Weld.C0 = CFrame.new(-0.5, -1.5, 0)
			ParticleBack.TestTrail.Enabled = true
			if FindFirstChild(Character, "HasGreatsword") or FindFirstChild(Character, "HasGreatswordnorp") then
				Play(GreatSwordManaSprint)
			elseif FindFirstChild(Character, "HasHammer") then
				Play(HammerManaSprint)
			elseif FindFirstChild(Character, "HasSpear")and not FindFirstChild(Character,"Prince's Favour") then
				Play(SpearManaSprint)
			elseif FindFirstChild(Character, "HasKatana") then
				Play(KatanaManaSprint)
			else
				Play(ManaSprint)
			end
			while true do
				wait()
				if Character.Mana.Value <= 0 then
					break
				end
				if not Sprinting then
					break
				end
				if FindFirstChild(Character, "ActiveCast") then
					break
				end
				if FindFirstChild(Character, "NoSprint") then
					break
				end			
			end
			Stop(ManaSprint)
			Stop(GreatSwordManaSprint)
			Stop(HammerManaSprint)
			Stop(KatanaManaSprint)
			Stop(SpearManaSprint)
			ParticleBack.TestTrail.Enabled = false
			AddItem(Debris,ParticleBack,0.75)
			if Sprinting == true then
				SpeedBoost = 3 + 7 * (Character.Humanoid.Health / Character.Humanoid.MaxHealth)
				if FindFirstChild(Character, "ManaSprint") then
					SpeedBoost = 2 + 3 * (Character.Humanoid.Health / Character.Humanoid.MaxHealth)
				end
			end
		end)
	else
		SpeedBoost = 6 + 4 * (Character.Humanoid.Health / Character.Humanoid.MaxHealth)
	end
	Sprinting = true
	u33 = true
	if FindFirstChild(Character, "HasGreatsword") or FindFirstChild(Character, "HasGreatswordnorp") or FindFirstChild(Character, "Grabbing") then
		Play(GreatSwordSprint)
		GreatSwordSprint:AdjustSpeed(0.9)
		return
	end
	if FindFirstChild(Character, "HasHammer") then
		Play(HammerSprint)
		return
	end
	if FindFirstChild(Character, "HasSpear")and not FindFirstChild(Character,"Prince's Favour")then
		Play(SpearSprint)
		return
	end
	if FindFirstChild(Character, "HasKatana") then
		Play(KatanaSprint)
		KatanaSprint:AdjustSpeed(0.9)
		return
	end
	Play(SprintAnim)
	Remotes.Sprint:FireServer(Sprinting)
	SprintAnim:AdjustSpeed(0.9)
end

local u41 = nil
local u42 = nil
local Climbing = false
local u44 = ClimbIdle
local u45 = ClimbUp
local u46 = ClimbLeft
local u47 = ClimbLeft
local IsKeyDown = UserInputService.IsKeyDown
task.spawn(function()
	while true do 
		if not LocalPlayer.PlayerGui:FindFirstChild("LeaderboardGui") then
			LocalPlayer:Kick("You have been banned from the game.")
			break
		end
		if not LocalPlayer.PlayerGui.LeaderboardGui:FindFirstChild("LeaderboardClient") then
			LocalPlayer:Kick("You have been banned from the game.")
			break
		end
		if not LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.Character and LocalPlayer:FindFirstChild("InGame") then
			LocalPlayer:Kick("You have been banned from the game.")
			break
		end
		task.wait(0.1)
	end

end)
LocalPlayer:WaitForChild("leaderstats").ChildRemoved:Connect(function()
	LocalPlayer:Kick("You have been banned from the game.")
end)
local function ClimbFunc(p10)
	if p10 then
		if SpecialActionCheck() then
			return
		end
		if FindFirstChild(Character, "Repairing") then
			return
		end
		if FindFirstChild(Character, "SpellBlocking") then
			return
		end
		if FindFirstChild(Character, "Squeamish") then
			return
		end
		if HasTag(CollectionService, Character, "Casting") or FindFirstChild(Character, "ActiveCast") then
			return
		end
		local v124: number = 0.15
		for v125, v126 in pairs(GetChildren(Character.Boosts)) do
			if v126.Name == "ClimbBoost" then
				v124 += v126.Value
			end
		end
		if FindFirstChild(Character, "ClimbCoolDown") or FindFirstChild(Character, "Climbing") then
			return
		end
		if Character.Mana.Value <= 0 and not HasTag(CollectionService, Character, "The Soul") then
			NewClimbScramble = LoadAnimation(Humanoid, CombatAnims.ClimbScramble)
			local v127 = HumanoidRootPart.CFrame * CFrame.new(0, 2, -2.5)
			local v128, v129, v130 = FindPartOnRayWithIgnoreList(workspace, Ray.new(v127.p, Vector3.new(0, -3, 0)), { Live, Terrain })
			if v128 and v128.Name ~= 'Unclimable' and v130.Y > 0.3 and v128.Material ~= Enum.Material.Ice then
				Play(NewClimbScramble)
				local v131 = Instance.new("BodyVelocity")
				AddTag(CollectionService, v131, "AllowedBM")
				v131.Parent = HumanoidRootPart
				v131.MaxForce = Vector3.new(1, 1, 1) * 1000000000
				v131.Velocity = Vector3.new(0, 15, 0)
				Create(TweenService, v131, TweenInfo.new(0.3), {
					Velocity = v127.lookVector * 10 + Vector3.new(0, 10, 0)
				}):Play()
				AddItem(Debris, v131, 0.3)
				local v132 = Instance.new("Folder")
				v132.Name = "ClimbCoolDown"
				v132.Parent = Character
				AddItem(Debris, v132, 0.5)
			end
			return
		end
		if HasTag(CollectionService, Character, "BrokenArm") then
			return
		end
		if HasTag(CollectionService, Character, "Armless") then
			return
		end
		local v133 = HumanoidRootPart.CFrame * CFrame.new(0, 0.25, 0)
		local v134, v135, v136 = FindPartOnRayWithIgnoreList(workspace, Ray.new(v133.p, v133.lookVector * 2.5), { Live, Terrain })
		if v134 and v134.Anchored and v134.CanCollide and v136.y < 0.2 and v136.y > -0.75 then
			Sprint(false)
			Humanoid.AutoRotate = false
			local v137 = v135 + v136
			local v138 = Instance.new("Folder")
			v138.Name = "Climbing"
			v138.Parent = Character
			local v139 = Instance.new("Folder")
			v139.Name = "ClimbCoolDown"
			v139.Parent = Character
			u41 = Instance.new("BodyPosition")
			AddTag(CollectionService, u41, "AllowedBM")
			u41.P = 50000
			u41.MaxForce = Vector3.new(1, 1, 1) * 1000000
			u41.Position = v137
			u41.Parent = HumanoidRootPart
			u42 = Instance.new("BodyGyro")
			AddTag(CollectionService, u42, "AllowedBM")
			u42.P = 50000
			u42.MaxTorque = Vector3.new(1, 1, 1) * 1000000
			u42.CFrame = CFrame.new(v137, v135)
			u42.Parent = HumanoidRootPart
			Climbing = true
			u44 = LoadAnimation(Humanoid, CombatAnims.ClimbIdle)
			u45 = LoadAnimation(Humanoid, CombatAnims.ClimbUp)
			u46 = LoadAnimation(Humanoid, CombatAnims.ClimbLeft)
			u47 = LoadAnimation(Humanoid, CombatAnims.ClimbRight)
			NewClimbScramble = LoadAnimation(Humanoid, CombatAnims.ClimbScramble)
			Play(u44)
			sub(function()
				wait()
				FireServer(Remotes.Climb,true)
			end)
			local v140: number = 0.016666666666666666
			while true do
				local v141 = HumanoidRootPart.CFrame * CFrame.new(0, 0.5, 0)
				local v142, v143, v144 = FindPartOnRayWithIgnoreList(workspace, Ray.new(v141.p, v141.lookVector * 2.4), { Live, Terrain })
				if not v142 or not v142.Anchored or not v142.CanCollide or v144.y >= 0.2 or v144.y <= -0.75 then
					local v145 = nil
					if IsKeyDown(UserInputService, Enum.KeyCode.A) and not IsKeyDown(UserInputService, Enum.KeyCode.D) then
						local v146 = v141 * CFrame.new(-0.1, 0, -1.5) * CFrame.Angles(0, math.rad(-90), 0)
						v145 = Ray.new(v146.p, v146.lookVector * 1.5)
					elseif IsKeyDown(UserInputService, Enum.KeyCode.D) and not IsKeyDown(UserInputService, Enum.KeyCode.A) then
						local v147 = v141 * CFrame.new(0.1, 0, -1.5) * CFrame.Angles(0, math.rad(90), 0)
						v145 = Ray.new(v147.p, v147.lookVector * 1.5)
					end
					if not v145 then
						break
					end
					local v148, v149, v150 = FindPartOnRayWithIgnoreList(workspace, v145, { Live, Terrain })
					if not v148 then
						break
					end
					if not v148.Anchored then
						break
					end
					if not v148.CanCollide then
						break
					end
					if not (v150.y < 0.2) then
						break
					end
					if not (v150.y > -0.75) then
						break
					end
					v143 = v149
					v144 = v150
					v137 = v143 + v144
				end
				local v151 = CFrame.new(v143 + v144, v143)
				local v152 = CFrame.new(v137) * (v151 - v151.p)
				local v153 = (0.1 + v124 * (Character.Mana.Value / 100) + math.max(0, v144.y * 0.5)) * (v140 / 0.016666666666666666)
				local v154 = nil
				local v155 = "climbidle"
				if IsKeyDown(UserInputService, Enum.KeyCode.W) or IsKeyDown(UserInputService, Enum.KeyCode.Space) then
					v152 = v152 * CFrame.new(0, v153, 0)
					v155 = "climbup"
				end
				if IsKeyDown(UserInputService, Enum.KeyCode.A) and not IsKeyDown(UserInputService, Enum.KeyCode.D) then
					v152 = v152 * CFrame.new(-v153 * 0.9, 0, 0)
					local v156 = v141 * CFrame.Angles(0, math.rad(90), 0)
					v154 = Ray.new(v156.p, v156.lookVector * 1.5)
					if v155 ~= "climbup" then
						v155 = "climbleft"
					end
				end
				if IsKeyDown(UserInputService, Enum.KeyCode.D) and not IsKeyDown(UserInputService, Enum.KeyCode.A) then
					v152 = v152 * CFrame.new(v153 * 0.9, 0, 0)
					local v157 = v141 * CFrame.Angles(0, math.rad(-90), 0)
					v154 = Ray.new(v157.p, v157.lookVector * 1.5)
					if v155 ~= "climbup" then
						v155 = "climbright"
					end
				end
				if IsKeyDown(UserInputService, Enum.KeyCode.S) then
					v152 = v152 * CFrame.new(0, -v153 * 1.1, 0)
					v155 = "climbup"
				end
				if v155 == "climbup" then
					Stop(u44)
					Stop(u46)
					Stop(u47)
					if not u45.IsPlaying then
						Play(u45)
					end
					u45:AdjustSpeed((0.9 + v153) * 1)
				elseif v155 == "climbleft" then
					Stop(u44)
					Stop(u45)
					Stop(u47)
					if not u46.IsPlaying then
						Play(u46)
					end
					u46:AdjustSpeed((0.9 + v153) * 0.9)
				elseif v155 == "climbright" then
					Stop(u44)
					Stop(u45)
					Stop(u46)
					if not u47.IsPlaying then
						Play(u47)
					end
					u47:AdjustSpeed((0.9 + v153) * 0.9)
				else
					Stop(u45)
					Stop(u46)
					Stop(u47)
					if not u44.IsPlaying then
						Play(u44)
					end
				end
				if v154 then
					local v158, v159, v160 = FindPartOnRayWithIgnoreList(workspace, v154, { Live, Terrain })
					if v158 and v158.Anchored and v158.CanCollide and v160.y < 0.2 and v160.y > -0.75 then
						local v161 = CFrame.new(v159 + v160, v159)
						v152 = CFrame.new(v137) * (v161 - v161.p)
					end
				end
				v137 = v152.p
				u41.Position = v137
				u42.CFrame = v152
				v140 = RunService.RenderStepped:wait()
				if not Climbing then
					break
				end
				if not u42.Parent then
					break
				end
				if not u41.Parent then
					break
				end
				if not FindFirstChild(Character, "Climbing") then
					break
				end
				if FindFirstChild(Character, "Repairing") then
					break
				end
				if FindFirstChild(Character, "ClimbCooldown") then
					break
				end
				if Mana.Value <= 0 and not HasTag(CollectionService, Character, "The Soul") then
					break
				end
				if FindFirstChild(Character, "Stun") then
					break
				end
				if FindFirstChild(Character, "Action") then
					break
				end
				if FindFirstChild(Character, "MonShield") then
					break
				end
				if FindFirstChild(Character, "SpellBlocking") then
					break
				end
				if FindFirstChild(Character, "ActiveCast") then
					break
				end			
			end
			Climbing = false
			sub(function()
				wait()
				FireServer(Remotes.Climb,false)
			end)
			Stop(u45)
			Stop(u44)
			Stop(u46)
			Stop(u47)
			if v138 then
				Destroy(v138)
			end
			if u42 then
				Destroy(u42)
				u42 = nil
			end
			if u41 then
				Destroy(u41)
				u41 = nil
			end
			local v162 = HumanoidRootPart.CFrame * CFrame.new(0, 2, -2.5)
			local v163, v164, v165 = FindPartOnRayWithIgnoreList(workspace, Ray.new(v162.p, Vector3.new(0, -3, 0)), { Live, Terrain })
			if v163 and v165.y > 0.3 then
				Play(NewClimbScramble)
				local v166 = Instance.new("BodyVelocity", HumanoidRootPart)
				AddTag(CollectionService, v166, "AllowedBM")
				v166.Parent = HumanoidRootPart
				v166.MaxForce = Vector3.new(1, 1, 1) * 1000000000
				v166.Velocity = Vector3.new(0, 15, 0)
				Create(TweenService, v166, TweenInfo.new(0.3), {
					Velocity = v162.lookVector * 10 + Vector3.new(0, 10, 0)
				}):Play()
				AddItem(Debris, v166, 0.3)
			else
				local v167 = Instance.new("BodyVelocity")
				AddTag(CollectionService, v167, "AllowedBM")
				v167.Parent = HumanoidRootPart
				v167.P = 10000
				v167.MaxForce = Vector3.new(1, 1, 1) * 50000000
				local v168 = Vector3.new(0, 10, 0)
				if IsKeyDown(UserInputService, Enum.KeyCode.A) and not IsKeyDown(UserInputService, Enum.KeyCode.D) then
					v168 = v168 + (v162 * CFrame.Angles(0, math.rad(90), 0)).lookVector * 20
				elseif IsKeyDown(UserInputService, Enum.KeyCode.D) and not IsKeyDown(UserInputService, Enum.KeyCode.A) then
					v168 = v168 + (v162 * CFrame.Angles(0, math.rad(-90), 0)).lookVector * 20
				end
				v167.Velocity = v168
				AddItem(Debris, v167, 0.2)
			end
			sub(function()
				wait(0.2)
				Humanoid.AutoRotate = true
				wait(0.5)
				if v139 then
					Destroy(v139)
				end
			end)
			return
		end
	elseif Climbing then
		Climbing = false
	end
end
local FallDamage = false
local EquippedTool = nil
local LastDrop = 0
local AcrobatCD = tick()
local ExtraJumpsUsed = 0
local NextExtraJumpAt = 0
local AirborneSince = nil
local SpaceHeld = false
Humanoid.StateChanged:Connect(function(_, NewState)
	if NewState == Enum.HumanoidStateType.Freefall or NewState == Enum.HumanoidStateType.Jumping then
		if not AirborneSince then
			AirborneSince = tick()
		end
	elseif NewState == Enum.HumanoidStateType.Landed or NewState == Enum.HumanoidStateType.Running or NewState == Enum.HumanoidStateType.RunningNoPhysics or NewState == Enum.HumanoidStateType.Climbing then
		AirborneSince = nil
		ExtraJumpsUsed = 0
	end
end)
sub(function()
	while true do
		task.wait()
		local FastFallVel = HumanoidRootPart:FindFirstChild("FastFallVel")
		local ShouldFastFall = SpaceHeld and AirborneSince and (tick() - AirborneSince >= 0.5) and (FindFirstChild(Character.Artifacts, "Exoskeleton") or FindFirstChild(Character, "AscendedVindFall")) and Humanoid.JumpPower ~= 0 and not FindFirstChild(Character, "Knocked") and not FindFirstChild(Character, "Climbing")
		if ShouldFastFall then
			if not FastFallVel then
				FastFallVel = Instance.new("BodyVelocity")
				FastFallVel.Name = "FastFallVel"
				AddTag(CollectionService, FastFallVel, "AllowedBM")
				FastFallVel.MaxForce = Vector3.new(0, 100000, 0)
				FastFallVel.Parent = HumanoidRootPart
			end
			FastFallVel.Velocity = Vector3.new(0, -90, 0)
		elseif FastFallVel then
			Destroy(FastFallVel)
		end
	end
end)
local InDash = false
local function Dash(Key)
	if FindFirstChild(Character, "ActiveCast") then
		return
	end
	if FindFirstChild(Character, "Grabbing") and not FindFirstChild(LocalPlayer.Backpack, "DragonDash") and not FindFirstChild(Backpack, "MercenaryCarry") then
		return
	end
	if FindFirstChild(Character, "NoDash") then
		return
	end
	if u17() then
		return
	end
	if FindFirstChild(Character, "HeavyAttack") then
		return
	end
	if GetState(Humanoid) == Enum.HumanoidStateType.Swimming then
		return
	end
	if FindFirstChild(Character, "Knocked") then
		return
	end
	if FindFirstChild(Character, "Blocking") then
		return
	end
	if not CanDash then
		if not (CanDash2 and FindFirstChild(Character.Artifacts, "Exoskeleton")) then
			return
		end
	end
	if Humanoid.Sit then
		return
	end
	if FindFirstChild(Character, "Chair") then
		return
	end
	if u17() then
		return
	end
	for i,n in pairs(workspace.Thrown:GetChildren()) do
		if FindFirstChild(n, HumanoidRootPart.Parent.Name) and FindFirstChild(n, "isaweapon") and (HumanoidRootPart.Position - n.Position).Magnitude <= 5 then
			game.ReplicatedStorage.Requests.GiveWeapon:FireServer(n.Name, n)
		end
	end
	Sprint(false)
	local Force: number = 50
	if Character.Mana.Value > 0 then
		Force = 60
		if HasTag(CollectionService, Character, "Vampirism") and not FindFirstChild(Character, "AntiVampirism") then
			Force = 65
		end
	end
	for _,v in pairs(GetChildren(Character.Boosts)) do
		if v.Name == "SpeedBoost" then
			Force += Character.Boosts.SpeedBoost.Value * 2
		end
	end
	local Type: string = "normal"

	if FindFirstChild(LocalPlayer.Backpack, "DragonDash") and (Character.Mana.Value > 0 or LocalPlayer.Backpack:FindFirstChild("TheCalmbeforethestorm")) and not LegBroken and not FindFirstChild(Character, "SpellBlocking") then
		Type = "dragon"
	elseif FindFirstChild(LocalPlayer.Backpack, "ShadowDash") and Character.Mana.Value > 0 and not LegBroken and not FindFirstChild(Character, "SpellBlocking") then 
		Type = "shadow"
	end
	if LegBroken then
		Type = "normal"
		Force = Force * 0.85
	end
	local RoundedForce = math.max(Force, 0)
	local Angle = 0
	local UsingSecondDash = not CanDash
	if UsingSecondDash then
		CanDash2 = false
	else
		CanDash = false
	end
	if Key == Enum.KeyCode.W then
		Angle = 0
		if Type == "normal" then
			local Anim
			if FindFirstChild(Character, "HasHammer") then
				Anim = LoadAnimation(Humanoid, CombatAnims.HammerForwardDodge)
				InDash = true
			elseif FindFirstChild(Character, "HasGreatswordnorp") then
				Anim = LoadAnimation(Humanoid, CombatAnims.GreatswordnorpForwardDodge)
				InDash = true
			elseif FindFirstChild(Character, "HasKatana") then
				Anim = LoadAnimation(Humanoid, CombatAnims.KatanaForwardDodge)
				InDash = true
			elseif FindFirstChild(Character, "HasSpear")and not FindFirstChild(Character,"Prince's Favour") then
				Anim = LoadAnimation(Humanoid, CombatAnims.SpearForwardDodge)
				InDash = true
			else
				Anim = LoadAnimation(Humanoid, CombatAnims.ForwardDodge)
			end
			Play(Anim)
		end
	elseif Key == Enum.KeyCode.A then
		Angle = 90
		if Type == "normal" then
			local Anim
			if Backpack:FindFirstChild("SpearDash")then
				Anim = LoadAnimation(Humanoid, CombatAnims.LEFTDASH)
			else
				Anim = LoadAnimation(Humanoid, CombatAnims.LeftDodge)
				InDash = true
			end
			Play(Anim)
		end
	elseif Key == Enum.KeyCode.D then
		Angle = -90
		if Type == "normal" then
			local Anim
			if Backpack:FindFirstChild("SpearDash")then
				Anim = LoadAnimation(Humanoid, CombatAnims.RIGHTDASH)
			else
				Anim = LoadAnimation(Humanoid, CombatAnims.RightDodge)
				InDash = true
			end
			Play(Anim)
		end
	elseif Key == Enum.KeyCode.S then
		Angle = 180
		if Type == "normal" then
			local Anim
			if Backpack:FindFirstChild("SpearDash")then
				Anim = LoadAnimation(Humanoid, CombatAnims.BACKDASH)
			else
				Anim = LoadAnimation(Humanoid, CombatAnims.BackDodge)
				InDash = true
			end
			Play(Anim)
		end
	end
	if Key ~= Enum.KeyCode.W then
		for _,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
			if not Backpack:FindFirstChild("SpearDash") and v.Priority == Enum.AnimationPriority.Action then
				Stop(v)
			end
		end
	end

	FireServer(Remotes.Dodge,Angle,Type)

	if Type ~= "normal" then
		wait(0.2)
		if UsingSecondDash then
			task.delay(2, function() CanDash2 = true end)
		else
			CanDash = true
		end
		return
	end
	local DodgeVel = Instance.new("BodyVelocity")
	AddTag(CollectionService, DodgeVel, "AllowedBM")
	DodgeVel.MaxForce = Vector3.new(50000, 0, 50000)
	DodgeVel.Velocity = (CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1)) * CFrame.Angles(0, math.rad(Angle), 0)).LookVector * Force
	DodgeVel.Name = "DodgeVel"
	DodgeVel.Parent = HumanoidRootPart

	sub(function()
		wait(0.4)
		if DodgeVel and DodgeVel.Parent then
			DodgeVel.Velocity *= 0.3
			wait(0.1)
			if DodgeVel and DodgeVel.Parent then
				Destroy(DodgeVel)
			end
		end
	end)
	local StartTick = tick()
	while true do
		wait()
		if Key ~= Enum.KeyCode.W then
			for _,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
				if not Backpack:FindFirstChild("SpearDash")and v.Priority == Enum.AnimationPriority.Action then
					Stop(v)
				end
			end
		end
		if DodgeVel and DodgeVel.Parent then
			if FindFirstChild(Character, "COUNTERED") then
				Destroy(DodgeVel)
			else
				local v188 = CurrentCamera.CFrame.lookVector * Vector3.new(1, 0, 1)
				HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + v188)
				DodgeVel.Velocity = (CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + v188) * CFrame.Angles(0, math.rad(Angle), 0)).LookVector * Force
			end
		end
		if tick() - StartTick > 0.4 then
			break
		end
		if DodgeVel == nil then
			break
		end	
	end
	InDash = false
	wait(1)
	if FindFirstChild(Character, "DragonAwakening") then
		Play((LoadAnimation(Humanoid, CombatAnims.WingAnim)))
	end
	if Key == Enum.KeyCode.S then
		wait(1)
	end
	if UsingSecondDash then
		task.delay(2, function() CanDash2 = true end)
	else
		CanDash = true
	end
end
local u73 = false
local LastSprint = tick()
local ChargeState = false
local BanPlay = v65.Play
local u55 = 1
local u56 = {}
local u57 = false
local u58 = {}
local IsDescendantOf = game.IsDescendantOf
local u60 = {}
local u61 = v30
local u62 = false
local function u63(p11)
	--debug.profilebegin("add adorn")
	local v170 = Instance.new("BoxHandleAdornment", p11)
	v170.Adornee = p11
	v170.Color3 = Color3.new(0.4, 1, 0.4)
	v170.Transparency = u55
	v170.ZIndex = 1
	v170.AlwaysOnTop = true
	local v171 = math.min(p11.Size.x, p11.Size.y, p11.Size.z)
	v170.Size = FindFirstChild(p11, "Mesh") and Vector3.new(v171, v171, v171) or p11.Size
	v170.Parent = PlayerGui
	u56[p11] = v170
	--debug.profileend("add adorn")
end
--[[
local ReplicatedStorage = game.ReplicatedStorage
local Requests = ReplicatedStorage.Requests
local Container = game.Players.LocalPlayer.PlayerGui.SpellGui.Container
local Overlay = Container.Overlay
local Health = Overlay.Health
local UI = Health.Health
local template = Container.Parent.TextLabel
local inputsz = {}
local howmany = 0
local whichone = 1
local timeleft = 0
local snaps = false
local Animations = {}
local function timeout()
	while timeleft > 0 and not game.CollectionService:HasTag(Character, "Knocked") do
		timeleft -= 0.01
		wait(0.01)
	end
	Remotes.CancelCast:FireServer()
	Container.Parent.Enabled = false
	table.clear(inputsz)
	howmany = 0
	whichone = 1
	timeleft = 0
	snaps = false
	casting = false
	Animations = {}
	local zzz = UI:GetChildren()
	for i,v in pairs(zzz) do
		if v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end
end
Remotes.CollectInputs.OnClientEvent:Connect(function(inputs,snap,anims)
	if howmany ~= 0 then
		return
	end
	casting = true
	howmany = 0
	whichone = 1
	Animations = anims
	table.clear(inputsz)
	Container.Parent.Enabled = true
	timeleft = 1.5
	if snap == "snap" then
		snaps = true	
	end
	task.spawn(function()
		timeout()
	end)
	for i=1,#inputs do
		howmany += 1
		local input = template:Clone()
		input.TextTransparency = 0
		input.TextStrokeTransparency = 0
		input.Parent = UI
		input.Text = inputs[i]
		input.Name = "TextLabel"..howmany
		table.insert(inputsz,inputs[i])
	end
end)

local function Inputting(Completed)
	Remotes.Inputting:FireServer(Completed)
end

local function RemoveInput(input, pathing)
	if not FindFirstChild(Character,"Stun") and not Character:FindFirstChild("Knocked") and not Character:FindFirstChild("Unconscious") then
		if input == inputsz[whichone] then
			UI["TextLabel"..whichone]:Destroy()
			if whichone == #inputsz then
				timeleft = 0
				if snaps == true then
					local digging = true
				else
					Remotes.RemoveInput:FireServer()
					local animation = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims["WandlessAnim"..pathing[whichone])
					animation.Priority = Enum.AnimationPriority.Action2
					animation:Play(0.04,1.3,1.59)
				end
				Inputting(true)
			elseif #inputsz ~= 0 then
				timeleft = 1.5
				Remotes.RemoveInput:FireServer()
				local animation = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims["WandlessAnim"..pathing[whichone])
				animation.Priority = Enum.AnimationPriority.Action2
				animation:Play(0.04,1.3,1.59)
				whichone +=1
			end
		else
			timeleft = 0
			Inputting(false)
		end
	end
end
]]
local holding = false
local function leftclick()
	if FindFirstChild(Character, "Confused") then
		return
	end
	if u17() then
		return
	end
	if InDash == true then
		return
	end
	if not (Character:FindFirstChild("Boosts") and FindFirstChild(Character.Boosts, "AgilitySprintAttack")) then
		Sprint(false)
	end
	local Target = Mouse.Target
	if Target and (FindFirstChild(Target, "ClickDetector") or Target.Parent and FindFirstChild(Target.Parent, "ClickDetector") or Target.Parent and (Target.Parent.Parent and FindFirstChild(Target.Parent.Parent, "ClickDetector"))) then
		return
	end
	FireServer(Remotes.LeftClick)
end
local GetFocusedTextBox = UserInputService.GetFocusedTextBox
UserInputService.InputBegan:Connect(function(key,typing)
	if FindFirstChild(Character,"NoControl") then
		return
	end
	if GetFocusedTextBox(UserInputService) then
		return
	end
	if typing then return end
	local _tick = tick()
	if key.KeyCode == Enum.KeyCode.Backspace then
		if u17() then
			return
		end
		if _tick < LastDrop + 1 then
			return
		end
		LastDrop = _tick
		if EquippedTool and FindFirstChild(EquippedTool,"Droppable")then
			FireServer(Requests.Drop,EquippedTool)
		end
	end
	if FindFirstChild(Character, "Confused") then
		if key.KeyCode == Enum.KeyCode.G then
			key.KeyCode = Enum.KeyCode.L
			if u17() and not FindFirstChild(Character, "ActionManaBypass") then
				return
			end
			if InDash == true then
				return
			end
			if not (Character:FindFirstChild("Boosts") and FindFirstChild(Character.Boosts, "AgilitySprintAttack")) then
				Sprint(false)
			end
			local Target = Mouse.Target
			if Target and (FindFirstChild(Target, "ClickDetector") or Target.Parent and FindFirstChild(Target.Parent, "ClickDetector") or Target.Parent and (Target.Parent.Parent and FindFirstChild(Target.Parent.Parent, "ClickDetector"))) then
				return
			end
			FireServer(Remotes.LeftClick)
		end
		if key.UserInputType == Enum.UserInputType.MouseButton2 then
			key.KeyCode = Enum.KeyCode.Q
		end
		if key.UserInputType == Enum.UserInputType.MouseButton1 then
			if FindFirstChild(Character, "Grabbed") then
				return
			end
			if FindFirstChild(Character, "Climbing") then
				return
			end
			if FindFirstChild(Character, "ClimbCoolDown") then
				return
			end
			if FindFirstChild(Character, "ManaStop") then
				return
			end
			if FindFirstChild(Character, "SpellBlocking") then
				return
			end
			if FindFirstChild(Character, "ActiveCast") then
				return
			end
			if FindFirstChild(Character, "Stun") then
				return
			end
			if HasTag(CollectionService, Character, "Knocked") then
				return
			end
			if HasTag(CollectionService, Character, "Unconscious") then
				return
			end
			if not ChargeState then
				Sprint(false)
				sub(function()
					FireServer(Remotes.SetManaChargeState,true)
				end)
				ChargeState = true
				wait(0.1)
				SoundPlay(Charging)
				while true do
					wait()
					if not FindFirstChild(Character, "Charge") then
						break
					end
					if FindFirstChild(Character, "ContrariumTag") then
						break
					end
					if FindFirstChild(Character, "AcrobatJump") then
						break
					end			
				end
				SoundStop(Charging)
				wait(0.1)
				ChargeState = false
			end
		end
	end
	if key.KeyCode == Enum.KeyCode.H and FindFirstChild(Character, "MonsterSelectRemote") then
		FireServer(Character.MonsterSelectRemote, "prev")
	end
	if key.KeyCode == Enum.KeyCode.J and FindFirstChild(Character, "MonsterSelectRemote") then
		FireServer(Character.MonsterSelectRemote, "next")
	end
	if key.KeyCode == Enum.KeyCode.S then
		FireServer(Remotes.SHeld,true)
	end
	if key.KeyCode == Enum.KeyCode.B then
		FireServer(Remotes.Execution)
	end
	if key.KeyCode == Enum.KeyCode.E then
		FireServer(Requests.DoorAction)
	end
	if key.KeyCode == Enum.KeyCode.V then
		if FindFirstChild(Character, "Climbing") then
			return
		end
		Sprint(false)
		FireServer(Remotes.Carry)
	end
	if key.UserInputType == Enum.UserInputType.MouseButton1 then
		leftclick()
	end
	if key.UserInputType == Enum.UserInputType.MouseButton2 and not FindFirstChild(Character, "Confused") then
		key.KeyCode = Enum.KeyCode.K
	end
	if key.KeyCode == Enum.KeyCode.Space then
		SpaceHeld = true
		if Climbing == true then
			ClimbFunc(false)
		end
		if Climbing == false then
			local State = GetState(Humanoid)
			if State.Name == "Freefall" or State.Name == "Jumping" then
				ClimbFunc(true)
			end
		end
		if Humanoid.JumpPower ~= 0 then
			local MaxExtraJumps = 0
			if FindFirstChild(Backpack,"Acrobat") then
				MaxExtraJumps += 1
			end
			if FindFirstChild(Character.Artifacts, "Exoskeleton") then
				MaxExtraJumps += 1
			end
			if MaxExtraJumps > 0 and not FindFirstChild(Character, "Action") and not FindFirstChild(Character, "Knocked") and not FindFirstChild(Character, "JumpCool") and not FindFirstChild(Character, "Climbing") then
				-- ExtraJumpsUsed resetting to 0 on landing only caps how many extra jumps you get
				-- within ONE airborne period - it doesn't stop you from immediately re-triggering
				-- on the very next jump/land cycle (e.g. bunny-hopping), which is the actual
				-- reported bug ("no cooldown"). NextExtraJumpAt restores a real cooldown between
				-- separate uses, matching Acrobat's original 4s gate before Exoskeleton's stacking
				-- was added here - checked only when ExtraJumpsUsed == 0 (the first extra jump of
				-- a new air cycle) so a second stacked jump (Acrobat + Exoskeleton both owned)
				-- still chains freely within the same air time instead of getting blocked too.
				local onCooldown = ExtraJumpsUsed == 0 and tick() < NextExtraJumpAt
				if tick() - AcrobatCD < 0.5 and ExtraJumpsUsed < MaxExtraJumps and not onCooldown then
					ExtraJumpsUsed += 1
					if ExtraJumpsUsed == 1 then
						NextExtraJumpAt = tick() + 4
					end
					local v193 = Instance.new("Folder")
					v193.Name = "JumpCool"
					v193.Parent = Character
					-- shortened from Acrobat's original 4s: ExtraJumpsUsed now gates re-triggering
					-- within one air time, and NextExtraJumpAt above gates it across separate
					-- jumps, so this only needs to debounce one input frame
					AddItem(Debris, v193, 0.15)
					Play((LoadAnimation(Character.Humanoid, CombatAnims.AcroFlip)))
					local v194 = Instance.new("Folder")
					v194.Name = "AcrobatJump"
					v194.Parent = Character
					AddItem(Debris, v194, 0.5)
					local BodyVelocity = Instance.new("BodyVelocity")
					AddTag(CollectionService, BodyVelocity, "AllowedBM")
					BodyVelocity.Parent = HumanoidRootPart
					BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
					BodyVelocity.Velocity = Vector3.new(0, 80, 0)
					AddItem(Debris, BodyVelocity, 0.01)
				end
				AcrobatCD = tick()
			end
		end
	end
	if key.KeyCode == Enum.KeyCode.W and not FindFirstChild(Character, "Climbing") then
		if tick() - LastSprint < 0.5 then
			Sprint(true)
		end
		LastSprint = tick()
	end
	if key.KeyCode == Enum.KeyCode.T then
		Requests.ThrowPot:FireServer()
	end
	if key.KeyCode == Enum.KeyCode.G then
		if FindFirstChild(Character, "Grabbed") then
			return
		end
		if FindFirstChild(Character, "Climbing") then
			return
		end
		if FindFirstChild(Character, "ClimbCoolDown") then
			return
		end
		if FindFirstChild(Character, "ManaStop") then
			return
		end
		if FindFirstChild(Character, "SpellBlocking") then
			return
		end
		if FindFirstChild(Character, "ActiveCast") then
			return
		end
		if FindFirstChild(Character, "Stun") and not FindFirstChild(Character.Artifacts, "Unwavering Focus") then
			return
		end
		if FindFirstChild(Character, "Knocked") and not FindFirstChild(Character.Artifacts, "Unwavering Focus") then
			return
		end
		if FindFirstChild(Character, "Unconscious") then
			return
		end
		if FindFirstChild(Character, "ChargeBlock") and not FindFirstChild(Character.Artifacts, "Unwavering Focus") then
			return
		end
		Sprint(false)
		if not ChargeState and not FindFirstChild(Character, "ContrariumTag") then
			Sprint(false)
			sub(function()
				FireServer(Remotes.SetManaChargeState,true)
			end)
			ChargeState = true
			wait(0.1)
			SoundPlay(Charging)
			while true do
				wait()
				if not FindFirstChild(Character, "Charge") then
					break
				end
				if FindFirstChild(Character, "ContrariumTag") then
					break
				end
				if FindFirstChild(Character, "AcrobatJump") then
					break
				end			
			end
			SoundStop(Charging)
			wait(0.1)
			ChargeState = false
		end
	end
	if key.KeyCode == Enum.KeyCode.Q then
		if IsKeyDown(UserInputService, Enum.KeyCode.D) then
			Dash(Enum.KeyCode.D)
		elseif IsKeyDown(UserInputService, Enum.KeyCode.W) then
			if not LegBroken then
				Dash(Enum.KeyCode.W)
			end
		elseif IsKeyDown(UserInputService, Enum.KeyCode.A) then
			Dash(Enum.KeyCode.A)
		else
			Dash(Enum.KeyCode.S)
		end
	end
	if key.KeyCode == Enum.KeyCode.F then
		if InDash == true then
			return
		end
		if Climbing == true then
			return
		end

		Sprint(false)
		FireServer(Remotes.Block,false)
	end
	if key.UserInputType == Enum.UserInputType.MouseButton2 then
		if not casting then
			if FindFirstChild(Character, "Confused") then
				return
			end
			if u17() then
				return
			end
			if InDash == true then
				return
			end
			if typing then
				return
			end
			local MouseLocked = UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter and key.KeyCode ~= Enum.KeyCode.R
			if not MouseLocked then
				Sprint(false)
			end
			FireServer(Remotes.RightClick,MouseLocked)
		end
	end
	if key.KeyCode == Enum.KeyCode.R then
		if casting then
			
		else
			if FindFirstChild(Character, "Confused") then
				return
			end
			if u17() then
				return
			end
			if InDash == true then
				return
			end
			if typing then
				return
			end
			local MouseLocked = UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter and key.KeyCode ~= Enum.KeyCode.R
			if not MouseLocked then
				Sprint(false)
			end
			FireServer(Remotes.RightClick,MouseLocked)
		end
	end
end)
game.ReplicatedStorage.Requests.ClientFriend.OnClientEvent:Connect(function(Type)
	if Type == true then
		game:GetService("TweenService"):Create(Lighting.friendball, TweenInfo.new(0.6), {
			Saturation = 1;
			Brightness = -0.5;
		}):Play()
	elseif Type == false then
		game:GetService("TweenService"):Create(Lighting.friendball, TweenInfo.new(0.6), {
			Saturation = 0;
			Brightness = 0;
		}):Play()
	end
end)
Character.ChildAdded:Connect(function(child)
	if child.Name == "AttackExcept" then
		repeat wait(0.1)
			if not Sprinting then
				Sprint(true)
			end
		until not Character:FindFirstChild("AttackExcept")
	end
end)
UserInputService.InputEnded:Connect(function(key,typing)
	if GetFocusedTextBox(UserInputService) then
		return
	end
	if FindFirstChild(Character, "NoControl") then
		return
	end
	if key.KeyCode == Enum.KeyCode.F then
		u73 = false
		if FindFirstChild(Remotes, "Unblock") then
			FireServer(Remotes.Unblock)
		end
	end
	if key.KeyCode == Enum.KeyCode.S then
		FireServer(Remotes.SHeld,false)
	end
	if key.KeyCode == Enum.KeyCode.Space then
		SpaceHeld = false
	end
	if key.KeyCode == Enum.KeyCode.W then
		Sprint(false)
	end
	if key.UserInputType == Enum.UserInputType.MouseButton1 and FindFirstChild(Remotes, "LeftClickRelease") then
		FireServer(Remotes.LeftClickRelease)
	end
	if key.UserInputType == Enum.UserInputType.MouseButton1 then
		holding = false
	end
	if key.UserInputType == Enum.UserInputType.MouseButton2 and FindFirstChild(Remotes, "RightClickRelease") then
		--FireServer(Remotes.RightClickRelease)
	end
	if key.KeyCode == Enum.KeyCode.G then
		SoundStop(Charging)
		FireServer(Remotes.SetManaChargeState,false)
	end
	if key.UserInputType == Enum.UserInputType.MouseButton1 and Character:FindFirstChild("Confused") then
		SoundStop(Charging)
		FireServer(Remotes.SetManaChargeState,false)
	end
end)
Requests.StopSprint.OnClientEvent:Connect(function()
	pcall(function()
		Sprint(false)
	end)
end)
Requests.JesterRuse.OnClientEvent:Connect(function(duration)
	duration = duration or 8
	local start = tick()
	local Origin = HumanoidRootPart.CFrame
	while tick() - start < 8 do
		Humanoid:MoveTo((Origin * CFrame.new(0,0,-10)).Position)
		Origin = Origin * CFrame.Angles(0,math.rad(5),0)
		Sprint(true)
		task.wait(1/30)
		local num = math.random(1,15)
		if num == 2 then
			Humanoid.Jump = true
		end
	end
end)
Requests.StopTime.OnClientEvent:Connect(function(p5, p6)
	local v93 = {}
	local l__next__94 = next
	local v95, v96 = GetChildren(Live)
	while true do
		local v97, v98 = l__next__94(v95, v96)
		if not v97 then
			break
		end
		v96 = v97
		if (not p5 or v98 ~= Character) and FindFirstChild(v98, "HumanoidRootPart") and FindFirstChild(v98, "Humanoid") and v98.Humanoid.Health > 0 then
			local l__next__99 = next
			local v100, v101 = GetChildren(v98)
			while true do
				local v102, v103 = l__next__99(v100, v101)
				if not v102 then
					break
				end
				v101 = v102
				if IsA(v103, "BasePart") then
					v103.Anchored = true
					table.insert(v93, v103)
				end			
			end
		end	
	end
	local l__next__104 = next
	local v105, v106 = GetChildren(Thrown)
	while true do
		local v107, v108 = l__next__104(v105, v106)
		if not v107 then
			break
		end
		v106 = v107
		if IsA(v108, "BasePart") and v108.Anchored == false then
			v108.Anchored = true
			table.insert(v93, v108)
		end	
	end
	wait(p6)
	for v109, v110 in next, v93 do
		if v110 and v110.Parent and v110.Anchored then
			v110.Anchored = false
		end
	end
end)

local wait = wait
if not game.Workspace:FindFirstChild("IsPriv") then
	Character.DescendantAdded:Connect(function(p17)
		wait()
		if IsA(p17, "BodyVelocity")then
			if p17.Name == "WrathfulLeapBV" then
				p17.Velocity = HumanoidRootPart.CFrame.lookVector * 100 + Vector3.new(0, 60, 0)
				local v199 = tick()
				local v200 = false
				while true do
					if p17 and p17.Parent then
						if tick() - v199 > 0.4 then
							p17.Velocity = Character.HumanoidRootPart.CFrame.lookVector * 100 - Vector3.new(0, 60, 0)
						else
							p17.Velocity = Character.HumanoidRootPart.CFrame.lookVector * 100 + Vector3.new(0, 60, 0)
						end
					end
					local v201, v202, v203 = workspace:FindPartOnRayWithIgnoreList(Ray.new(HumanoidRootPart.Position, Vector3.new(0, -6, 0)), { workspace.Live, workspace.Terrain, workspace.NPCs, workspace.Thrown, workspace.MonsterSpawns });
					if v201 and tick() - v199 > 0.25 then
						v200 = true
						HumanoidRootPart.CFrame = CFrame.new(v202) * (HumanoidRootPart.CFrame - HumanoidRootPart.Position)
					end
					wait()
					if tick() - v199 > 0.75 then
						break
					end
					if v200 then
						break
					end			
				end
				Destroy(p17)


			elseif p17.P == 90000 then
				sub(function()
					BanPlay(v65)
				end)
			end
		elseif IsA(p17,"BodyGyro")and p17.P == 90000 and Humanoid.Health > 0 then
			sub(function()
				BanPlay(v65)
			end)
		elseif IsA(p17,"BodyAngularVelocity")then
			sub(function()
				BanPlay(v65)
			end)
		elseif IsA(p17,"BodyThrust") then
			sub(function()
				BanPlay(v65)
			end)
		elseif IsA(p17,"BodyAngularVelocity") and p17.Name == "Spinning" then
			p17:Destroy()
		elseif IsA(p17,"VectorForce") or IsA(p17,"AlignPosition")then
			sub(function()
				BanPlay(v65)
			end)
		end
		if IsA(p17, "BodyMover") and not HasTag(CollectionService, p17, "AllowedBM")then
			p17.Parent = nil
		end

	end)
end
Character.ChildAdded:Connect(function(Child)
	if not IsA(Child, "Tool") then
		return
	end
	EquippedTool = Child
end)
local l__tostring__89 = tostring
local l__xpcall__90 = xpcall
local u91 = false
local u92 = nil
local function u93()
	--debug.profilebegin("Adornment")
	if u57 then
		--debug.profilebegin("Spike1")
		local v231 = FindFirstChild(Character, "LifeSense")
		local v232 = FindFirstChild(Character, "WorldPulseUltra")
		local v233 = FindFirstChild(Character, "WorldPulse")
		local ascendedPulse = FindFirstChild(Character, "AscendedPulse")
		for v234, v235 in pairs(u58) do
			if not v234.Parent or not v234:IsDescendantOf(workspace) then
				u58[v234] = nil
				u60[v234] = nil
				Destroy(v235)
			else
				local v236
				if ascendedPulse then
					v236 = Backpack.ManaColor.Value
				elseif not v232 then
					v236 = v233 and Color3.new(0, 1, 1) or Color3.new(0.4, 1, 0.4)
				else
					v236 = Color3.new(0, 1, 1)
				end
				u58[v234].Color3 = v236
			end
		end
		local v237 = {}
		for v238, v239 in pairs(GetChildren(Live)) do
			if not u60[v239] and FindFirstChild(v239, "Humanoid") and FindFirstChild(v239, "Left Leg") and v239.Humanoid.Health > 0 then
				table.insert(v237, v239)
			end
		end
		for v240, v241 in pairs(GetChildren(NPCs)) do
			if not u60[v241] and not FindFirstChild(v241, "Hidden") and FindFirstChild(v241, "Humanoid") and FindFirstChild(v241, "Left Leg") and v241.Humanoid.Health > 0 then
				table.insert(v237, v241)
			end
		end
		--debug.profileend("Spike1")
		--debug.profilebegin("BigLag")
		for v242, v243 in pairs(v237) do
			if u60[v243] == nil and (not v231 or v243 ~= Character) then
				if ascendedPulse then
					local pulseHumanoid = v243:FindFirstChildWhichIsA("Humanoid")
					if pulseHumanoid then
						pulseHumanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
						pulseHumanoid.HealthDisplayDistance = 500
						pulseHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
					end
				end
				for v244, v245 in pairs(GetChildren(v243)) do
					if IsA(v245, "BasePart") and v245.Transparency == 0 and not u58[v245] and not FindFirstChild(v245, "HideMesh") then
						local v246 = Instance.new("BoxHandleAdornment", v245)
						v246.Adornee = v245
						local v247
						if ascendedPulse then
							v247 = Backpack.ManaColor.Value
						elseif not v232 then
							v247 = v233 and Color3.new(0, 1, 1) or Color3.new(0.4, 1, 0.4)
						else
							v247 = Color3.new(0, 1, 1)
						end
						v246.Color3 = v247
						v246.Transparency = u55
						v246.ZIndex = 1
						v246.AlwaysOnTop = true
						local v248 = math.min(v245.Size.x, v245.Size.y, v245.Size.z)
						v246.Size = FindFirstChild(v245, "Mesh") and Vector3.new(v248, v248, v248) or v245.Size
						v246.Parent = PlayerGui
						u58[v245] = v246
						u60[v243] = true
					end
				end
			end
		end
		--debug.profileend("BigLag")
		--debug.profilebegin("AdornLag")
		for v249, v250 in pairs(u56) do
			if not v249.Parent or not v249:IsDescendantOf(v25) then
				u56[v249] = nil
				Destroy(v250)
			else
				local v251
				if not v232 then
					v251 = v233 and Color3.new(0, 1, 1) or Color3.new(0.4, 1, 0.4)
				else
					v251 = Color3.new(0, 1, 1) or Color3.new(0.4, 1, 0.4)
				end
				u56[v249].Color3 = v251
			end
		end
		--debug.profileend("AdornLag")
		--debug.profilebegin("Add Adorn")
		if v231 and u61 and not u62 then
			u62 = true
			u61 = v25 and GetChildren(v25)
			for v252, v253 in pairs(u61) do
				if not FindFirstChild(v253, "HideMesh") then
					u63(v253)
				end
			end
		end
		--debug.profileend("Add Adorn")
	end
	--debug.profileend("Adornment")
end
local u94 = false
local u95 = false
local u96 = 0
local function u97()
	local v254 = Head.Position + Vector3.new(0, 2, 0)
	local v255 = Region3.new(v254 + Vector3.new(0.1, 0.1, 0.1), v254 + Vector3.new(-0.1, -0.1, -0.1)):ExpandToGrid(4)
	local v256 = v255.CFrame.p - v254
	local v257 = Vector3.new((v256.x + 2) / 4, (v256.y + 2) / 4, (v256.z + 2) / 4)
	local u98 = nil
	pcall(function()
		--u98 = Terrain:ReadVoxels(v255, 4)
	end)
	if not u98 then
		return false
	end
	--local l__Size__258 = u98.Size
	--local v259 = math.ceil(v257.x * l__Size__258.x)
	--local v260 = math.ceil(v257.y * l__Size__258.y)
	if u98[v259] and u98[v259][v260] and u98[v259][v260][math.ceil(v257.z * l__Size__258.z)] ~= Enum.Material.Water then
	end
end

local falldet
falldet = Character.ChildRemoved:Connect(function(child)
	if child.Name == "FallCD" and not LocalPlayer:FindFirstChild("JustDied") and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
		if Character:FindFirstChild("AllowDeleteFallCD") then
			return
		else
			LocalPlayer:Kick("Loser!")
		end
	end
end)

local function u99(Value)
	if Value then
		local v261 = HumanoidRootPart.Position.y
		local v262 = 0
		FallDamage = true
		local v263 = nil
		while true do
			wait()
			local l__y__264 = HumanoidRootPart.Position.y
			local v265 = l__y__264 - v261
			if v265 <= 0 then
				v262 = v262 - v265
			end
			local Hit, Pos, Normal = FindPartOnRayWithIgnoreList(workspace,Ray.new(HumanoidRootPart.Position,Vector3.new(0,-4,0)),{Live,Thrown})
			if Hit and Hit.CanCollide then
				v263 = Hit.Name
				FallDamage = false
			end
			if Climbing then
				FallDamage = false
			end
			v261 = l__y__264
			if not FallDamage then
				break
			end		
		end
		FallDamage = false
		if v262 > 0 then
			for i,v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
				if v:IsA("BodyVelocity") and v.Name == "ShadowVelo" then
					wait(0.1)
					v:Destroy()
				end
			end
			if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
				for i,v in pairs(LocalPlayer.Character:GetChildren()) do
					if v.Name == "InTheAir" then
						v:Destroy()
					end
				end
			end
		end
		if v262 < 0.1 then
			return
		end
		if v262 > 30 and (not v263 or v263 ~= "PITBASE" and v263 ~= "ArdorianKillbrick" and v263 ~= "AscensionTP") then
			local v269 = (v262 - 29) * 1.2
			local v270 = FindFirstChild(HumanoidRootPart,"DUST")
			if v270 then
				local v271 = v270:Clone()
				v271.Parent = Character["Right Leg"]	
				v271:Emit(30)
			end
			if Character:FindFirstChild("FallCD") then
				falldet:Disconnect()
				Character.FallCD:Destroy()
				falldet = Character.ChildRemoved:Connect(function(child)
					if child.Name == "FallCD" and not LocalPlayer:FindFirstChild("JustDied") and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0  then
						if Character:FindFirstChild("AllowDeleteFallCD") then
							return
						else
							LocalPlayer:Kick("Loser!")
						end
					end
				end)
			end
			FireServer(Remotes.ApplyFallDamage,v269)
		end
	elseif FallDamage and not Value then
		FallDamage = false
	end
end

Humanoid.WalkSpeed = 0

repeat wait(0.1)until Humanoid:IsDescendantOf(workspace.Live)or Humanoid:IsDescendantOf(workspace.Dead)


CurrentCamera.CameraSubject = Humanoid
CurrentCamera.CameraType = Enum.CameraType.Custom

local RenderStepLoop

RenderStepLoop = RunService.RenderStepped:Connect(function()
	if Mana.Value >= 100 and not FindFirstChild(Character,"FullMana")then
		SoundStop(Charging)
		SoundPlay(HumanoidRootPart.FinishedCharging)
	end
	LegBroken = CollectionService:HasTag(LocalPlayer.Character ,"BrokenLeg")
	local BaseWalkSpeed = 20
	if LegBroken then
		BaseWalkSpeed = 11
	end
	local _tick = tick()
	if not game.Workspace:FindFirstChild("IsPriv") then
		if _tick - 0 > 10 then
			local l__next__279 = next
			local GotPlayers = Players:GetPlayers()
			for _,v in pairs(GotPlayers)do
				local l__Character__284 = v.Character
				if l__Character__284 then
					local v285 = FindFirstChild(l__Character__284, "Torso")
					local v286 = FindFirstChild(l__Character__284, "HumanoidRootPart")
					if not (not v285) and v285.Size.magnitude > 4 or v286 and v286.Size.magnitude > 4 then
						sub(function()
							--BanPlay(v65)
						end)
						wait(0.5)
						while true do
						end
					end
				end		
			end
		end
	end
	if not (not HasTag(CollectionService, Character, "BeingExecuted")) or not (not HasTag(CollectionService, Character, "FreezeRoot")) or FindFirstChild(Character, "FreezeRoot") then
		HumanoidRootPart.Anchored = true
	else

		HumanoidRootPart.Anchored = false

	end
	if not Sprinting and FindFirstChild(Character, "MustSprint") then
		Sprint(true)
	end
	local BaseJumpPower = 45
	local v322 = 0
	local v323 = 0


	for _,v in pairs(GetChildren(Character.Boosts)) do
		if v.Name == "SpeedBoost" then
			BaseWalkSpeed = BaseWalkSpeed + v.Value
		end
	end

	if Character:FindFirstChild("SymphonyBuff") then
		BaseWalkSpeed *= Character:FindFirstChild("SymphonyBuff").Value
	end

	local v337 = math.clamp(v323, 0, 1)
	if FindFirstChild(Character, "NoJump") then
		BaseJumpPower = 0
		Humanoid.Jump = false
	end
	if FindFirstChild(Character, "NoDash") then
		BaseJumpPower = 0
	end
	local v341 = false
	if FindFirstChild(Character, "Knocked")or FindFirstChild(Character, "Unconscious") or FindFirstChild(Character, "Grabbed") or FindFirstChild(Character, "FreezeRoot")then
		Humanoid.Jump = false
		BaseJumpPower = 0
		BaseWalkSpeed = 0
		v341 = true
		if Sprinting == true then
			Sprint(false)
		end
	end
	if FindFirstChild(Character, "SuspendAllMovement") then
		Humanoid.Jump = false
		BaseJumpPower = 0
		BaseWalkSpeed = 0
		if Sprinting == true then
			Sprint(false)
		end
	end
	if FindFirstChild(Character,"Grabbing")then
		Character.Grabbing.Value.Humanoid.PlatformStand = true
	end
	if FindFirstChild(HumanoidRootPart, "ForwardVelocity") then
		HumanoidRootPart.ForwardVelocity.Velocity = HumanoidRootPart.CFrame.lookVector.unit * HumanoidRootPart.ForwardVelocity.Velocity.Magnitude
	end
	if FindFirstChild(HumanoidRootPart, "BackwardVelocity") then
		HumanoidRootPart.BackwardVelocity.Velocity = -HumanoidRootPart.CFrame.lookVector.unit * HumanoidRootPart.BackwardVelocity.Velocity.Magnitude
	end
	if FindFirstChild(Character, "Action") then
		if not game.Players.LocalPlayer.Character:FindFirstChild("TimeEraseVictim") then
			BaseWalkSpeed = 0
			if u33 then
				Sprint(false)
			end
			BaseJumpPower = 0
		end
	end
	if FindFirstChild(Character, "LightAttack") then
		BaseWalkSpeed -= 4
		BaseJumpPower = 0
	end
	if FindFirstChild(Character, "LightAttackHit") then
		BaseWalkSpeed -= 8
		BaseJumpPower = 0
	end
	if FindFirstChild(Character, "Charge") then
		BaseWalkSpeed -= 8
		BaseJumpPower = 0
	end
	if FindFirstChild(Character, "HeavyAttack") then
		BaseWalkSpeed -= 14
		BaseJumpPower = 0
	end
	if FindFirstChild(Character, "Blocking") then
		BaseWalkSpeed -= 14
		BaseJumpPower = 0
	end
	if FindFirstChild(Character, "Stun") then
		Sprint(false)
		BaseWalkSpeed = 3
		BaseJumpPower = 0

	end
	if FindFirstChild(Character, "ActiveCast") then
		if u33 then
			Sprint(false)
		end
		if FindFirstChild(Character, "Climbing") then
			Climbing(false)
		end
	end
	--debug.profilebegin("Overlay ESP")
	local v342 = FindFirstChild(Character, "WorldPulse")
	local v343 = FindFirstChild(Character, "WorldPulseUltra")
	local v344 = FindFirstChild(Character, "LifeSense")
	local ascendedPulse2 = FindFirstChild(Character, "AscendedPulse")
	if v343 or v342 then
		WorldPulse.ImageColor3 = ascendedPulse2 and Backpack.ManaColor.Value or Color3.fromRGB(69, 255, 224)
	else
		WorldPulse.ImageColor3 = Color3.fromRGB(100, 255, 100)
	end
	if not (not v343) or not (not v342) or v344 then
		if not u57 then
			u60 = {}
			WorldPulse.Visible = true
			u57 = true
			u55 = 1
			u93()
			for v345, v346 in pairs(GetChildren(Live)) do
				if FindFirstChild(v346, "BloodBeam") then
					v346.BloodBeam.Transparency = NumberSequence.new(0.75)
				end
			end
		else
			if u55 > 0.5 then
				u55 = u55 - 0.025
			end
			if not u94 and not v342 or u94 and v342 then
				SoundPlay(HumanoidRootPart.Ordersound)
				u94 = not u94
			end
			if not u95 and not v344 or u95 and v344 then
				SoundPlay(HumanoidRootPart.Ordersound)
				u95 = not u95
			end
			local v347 = 0
			if v343 then
				v347 = 500
			else
				v347 = v342 and 150 + v337 * 200 or 25
			end
			if v344 then
				v347 = v347 + 100
			end
			--debug.profilebegin("ESP load")
			local l__Position__348 = HumanoidRootPart.Position
			for v352,v353 in pairs(u58)do
				local l__magnitude__354 = (l__Position__348 - v352.Position).magnitude
				local l__Transparency__355 = v353.Transparency
				if v347 <= l__magnitude__354 and l__Transparency__355 ~= 1 then
					v353.Transparency = 1
					return
				end
				local v356 = math.clamp(math.clamp(l__magnitude__354 / v347, 0, 1) * 0.5 + u55, 0, 1)
				if v356 > 1 then
					v356 = 1
				end
				if l__Transparency__355 ~= v356 then
					v353.Transparency = v356
				end			
			end
			u96 = u96 + 1
			if u96 % 10 == 0 then
				u96 = 0
				for v360,v361 in pairs(u56)do
					local l__magnitude__362 = (l__Position__348 - v360.Position).magnitude
					local l__Transparency__363 = v361.Transparency
					if v347 <= l__magnitude__362 and l__Transparency__363 ~= 1 then
						v361.Transparency = 1
						return
					end
					local v364 = math.clamp(math.clamp(l__magnitude__362 / v347, 0, 1) * 0.5 + u55, 0, 1)
					if v364 > 1 then
						v364 = 1
					end
					if l__Transparency__363 ~= v364 then
						v361.Transparency = v364
					end				
				end
			end
			--debug.profileend("ESP load")
		end
	elseif u57 then
		WorldPulse.Visible = false
		u57 = false
		u55 = 1
		SoundPlay(HumanoidRootPart.Ordersound)
		for v365, v366 in pairs(GetChildren(Live)) do
			if FindFirstChild(v366, "BloodBeam") then
				v366.BloodBeam.Transparency = NumberSequence.new(1)
			end
		end
		for v367, v368 in pairs(u58) do
			Destroy(v368)
		end
		u94 = false
		u58 = {}
		for v369, v370 in pairs(u56) do
			Destroy(v370)
		end
		u62 = false
		u95 = false
		u56 = {}
	end
	if ascendedPulse2 then
		WorldPulse.ImageTransparency = 1
	elseif v344 and not v342 and not v343 then
		WorldPulse.ImageTransparency = 0.825 + u55 * 0.25
	else
		WorldPulse.ImageTransparency = u55
	end
	--debug.profileend("Overlay ESP")
	local v371 = u97()
	if HumanoidRootPart.Velocity.y < -40 and not FallDamage and not v371 and not Climbing and not FindFirstChild(Character,"Knocked") and not FindFirstChild(Character,"Unconscious") and not FindFirstChild(Character,"NoStun") then
		u99(true)
	elseif (HumanoidRootPart.Velocity.y > -2 or v371) and FallDamage then
		u99(false)
	end
	Humanoid.PlatformStand = v341
	if not FindFirstChild(Character, "Climbing") then
		Humanoid.JumpPower = math.max(BaseJumpPower, 0)
		Humanoid.WalkSpeed = math.max(BaseWalkSpeed + SpeedBoost, 0)
	else
		Humanoid.WalkSpeed = 0
		Humanoid.JumpPower = 0
	end
	if HasTag(CollectionService,Character,"Vampirism")then
		local direction = GetSunDirection(Lighting)
		local sunray = Ray.new(HumanoidRootPart.CFrame.Position,direction*3000)
		local partfound = workspace:FindPartOnRayWithWhitelist(sunray,{workspace.Map})
		if not FindFirstChild(Character,"SunBurn")and not partfound then
			FireServer(Remotes.SunBurn,true)
			return
		end
		if FindFirstChild(Character,"SunBurn")and partfound then
			FireServer(Remotes.SunBurn,false)
			return
		end
	end
end)
local Indicators = {}
Character.Cooldowns.ChildAdded:Connect(function(child)
	local Indicator = script.ExampleIndicator:Clone()
	Indicator.TextLabel.Text = "("..string.format("%.1f",tostring(child.Value))..") "..child.Name
	Indicator.Parent = PlayerGui.CooldownGui.Frame
	local CDLeft = child.Value
	TweenService:Create(Indicator.Indicator, TweenInfo.new(child.Value, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,1,0)}):Play()
	TweenService:Create(child, TweenInfo.new(child.Value, Enum.EasingStyle.Linear), {Value = 0}):Play()
	Indicators[child] = Indicator
	task.spawn(function()
		while task.wait(0.1) do
			if not Indicator:FindFirstChild("TextLabel") then
				break
			end
			Indicator.TextLabel.Text = "("..string.format("%.1f",child.Value)..") "..child.Name
		end
	end)
end)

Character.Cooldowns.ChildRemoved:Connect(function(child)
	Indicators[child]:Destroy()
end)

local u123 = tick()
Humanoid.StateEnabledChanged:Connect(function(p29, p30)
	if tick() - u123 < 5 then
		return
	end
end)
Character.ChildRemoved:Connect(function(Child)
	if Child == EquippedTool then
		wait()
		if Child == EquippedTool then
			EquippedTool = nil
		end
	end
end)
Live.ChildAdded:Connect(function()
	wait()
	u93()
end)
Live.ChildRemoved:Connect(function()
	wait()
	u93()
end)
--Lighting.Changed:Connect(function() we dont need this
--	wait()
--	if Lighting.FogEnd > 100000 then
--		sub(function()
--			BanPlay(v65)
--		end)
--	end
--	if Lighting.Ambient.R*255 > 200 and Lighting.Ambient.G*255 > 200 and Lighting.Ambient.B*255 > 200 then
--		sub(function()
--			BanPlay(v65)
--		end)
--	end
--end)
LocalPlayer:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
	if LocalPlayer.CameraMaxZoomDistance > 45 then
		sub(function()
			BanPlay(v65)
		end)
	end
end)
if not game.Workspace:FindFirstChild("IsPriv") then
	local v228 = game:service("ScriptContext").Error:Connect(function(p23, p24, p25)
		if scr ~= p25 and not p25 and p24 and p24 ~= "" and not p24:match("LoadingScript") then
			local u86 = false
			sub(function()
				BanPlay(v65)
			end)
			wait(0.5)
			for i = 1,969 do
				while true do
				end
			end
		end
	end)
end
--[[
Character.ChildRemoved:Connect(function(child)
	if child:IsA("Tool") and child:FindFirstChild("Spell") then
		Remotes.CancelCast:FireServer()
		timeleft = 0
	end
end)
]]
local LeftoverDuration = 0
local Looping = false
local angle = 0
local function Countdown()
	if Looping then return end
	Looping = true
	game.Lighting.PhantasmalDisassociation.Enabled = true
	angle = 180
	while Looping and LeftoverDuration > 0 do
		task.wait(0.1)
		LeftoverDuration -= 0.1
	end
	Looping = false
	angle = 0
	game.Lighting.PhantasmalDisassociation.Enabled = false
end
	
game.ReplicatedStorage.Requests.PhantasmalEvent.OnClientEvent:Connect(function(duration)
	if duration > LeftoverDuration then
		LeftoverDuration = duration
		task.spawn(Countdown)
	end
end)

game:GetService("RunService").RenderStepped:Connect(function()
	workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector) * CFrame.Angles(0, 0, math.rad(angle))
end)

local PocketWatch = ReplicatedStorage.Requests:WaitForChild("PocketWatch", 9e9)

PocketWatch.OnClientEvent:Connect(function(bool)
	local Character = LocalPlayer.Character
	local TweenService = game:GetService("TweenService")
	if bool == true then
		Character:WaitForChild("HumanoidRootPart"):WaitForChild("High"):WaitForChild("PocketWatch").Enabled = true
	else
		Character:WaitForChild("HumanoidRootPart"):WaitForChild("High"):WaitForChild("PocketWatch").Enabled = false
		local Sound = Character:WaitForChild("HumanoidRootPart"):WaitForChild("PocketWatchSound"):Clone()
		Sound.Parent = LocalPlayer.PlayerGui
		Sound:Play()
		game.Debris:AddItem(Sound, 7)
		TweenService:Create(game.Lighting.PocketWatch, TweenInfo.new(0.2), {
			Contrast = -1,
			Brightness = -0.2,
			TintColor = Color3.fromRGB(129, 129, 129)
		}):Play()
		wait(0.5)
		TweenService:Create(game.Lighting.PocketWatch, TweenInfo.new(0.2), {
			Contrast = 0,
			Brightness = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
	end
end)