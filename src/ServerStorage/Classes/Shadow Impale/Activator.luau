local module = {};
module.upperbound = 100;
module.lowerbound = 70;
module.signs = 0;
module.cost = 0;
module.solanedict = true;

function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")

local canuse = true
local spelleffect = game.ServerStorage.SpellEffects.ShadowyBlade

local tool = script.Parent
local HitDetection = require(game.ServerScriptService.Modules.HitDetection)
function module.Activate(player, char)
	if game.CollectionService:HasTag(char,"Casting") then return end
	if char.Cooldowns:FindFirstChild("Shadow Impale") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Shadow Impale"
	CD.Value = 15
	CD.Parent = char.Cooldowns
	game.Debris:AddItem(CD, 15)


	local play = game.Players:GetPlayerFromCharacter(char)

	local NOMOVE = Instance.new("Accessory")
	NOMOVE.Name = "Action"
	NOMOVE.Parent = char
	--char.Humanoid.AutoRotate = false

	canuse = false


	local summon = char.Humanoid:LoadAnimation(tool.Windup)
	summon:Play()

	task.wait(0.025)

	local noise = spelleffect.summon:Clone()
	game.ServerStorage.Debris:Fire(noise,3)
	noise.Parent = char.Torso
	noise:Play()


	task.wait(0.025)

	local Temporary = game.ServerStorage.verto:FindFirstChild("Shadowy Blade"):Clone()
	Temporary.Parent = char.Hilt
	local HiltWeldClone = char.Hilt.HiltWeld:Clone()
	HiltWeldClone.Parent = char.Hilt
	HiltWeldClone.Part0 = char.Hilt
	HiltWeldClone.Part1 = Temporary
	HiltWeldClone.C1 = CFrame.new(-1, -2, 0, -4.37113883e-08, 1, -4.37113883e-08, 0, -4.37113883e-08, -1, -1, -4.37113883e-08, 1.91068547e-15)

	local mdl = game.ServerStorage.verto:FindFirstChild("Shadowy Blade")
	local longestAxis = mdl.Size.X
	if mdl.Size.Y > longestAxis then
		longestAxis = mdl.Size.Y
	end
	if mdl.Size.Z > longestAxis then
		longestAxis = mdl.Size.Z
	end

	local theCubes = {}
	local cubeSize = 0.4
	local cubesRequired = math.floor(math.floor(longestAxis)/cubeSize)
	local startpos = char["Right Arm"].CFrame * CFrame.new(0,-1.2,0)
	for i = 1,cubesRequired do
		local lightCube = spelleffect.LightCube:Clone()
		game.ServerStorage.Debris:Fire(lightCube,2.5)
		table.insert(theCubes,lightCube)
		lightCube.Transparency = 1
		local heyy = CFrame.new(char["Right Arm"].CFrame.X, char["Right Arm"].CFrame.Y, char["Right Arm"].CFrame.Z)
		lightCube.CFrame = heyy * CFrame.new(math.random(-4,4),math.random(7,10),math.random(-4,4))*CFrame.Angles(math.random(-20,20),math.random(-20,20),math.random(-20,20))
		lightCube.Parent = game.Workspace
		local fTweenInfo = TweenInfo.new(.3,Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local destination = startpos*CFrame.new(math.random(-14,14)/100,(-cubeSize*i)+cubeSize,math.random(-2,2)/100)
		local fadeTween = TweenService:Create(lightCube,fTweenInfo,{CFrame = destination,Transparency = 0.6}):Play()
		--lightCube.CFrame = startpos*CFrame.new(math.random(-14,14)/100,(-cubeSize*i)+cubeSize,math.random(-2,2)/100)
		if (i < cubesRequired/3) or ((math.random(1,2) == 1) and (i < cubesRequired/1.2)) then
			local pairCube = spelleffect.LightCube:Clone()
			game.ServerStorage.Debris:Fire(pairCube,2.5)
			table.insert(theCubes,pairCube)
			pairCube.Parent = game.Workspace
			pairCube.CFrame = heyy * CFrame.new(math.random(-4,4),math.random(7,10),math.random(-4,4))*CFrame.Angles(math.random(-20,20),math.random(-20,20),math.random(-20,20))
			local fadeTween = TweenService:Create(pairCube,fTweenInfo,{CFrame = destination * CFrame.new(-(cubeSize-.1),0,math.random(-2,2)/100),Transparency = 0.6}):Play()
		end
		task.wait(.00025)
	end

	task.wait(.00025)

	for i = 1,#theCubes do
		local fTweenInfo = TweenInfo.new(.1,Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local fadeTween = TweenService:Create(theCubes[i],fTweenInfo,{Transparency = 0}):Play()
	end

	task.wait(.00025)

	local oldpcolor
	local THEPROP
	for i,v in next, char.Hilt:GetChildren() do
		if v:FindFirstChild("Prop") and not game.CollectionService:HasTag(v,"SideProp") then
			v.Transparency = .4
			oldpcolor = v.Color

			v.BrickColor = BrickColor.new("Light purple")
			v.Color = Color3.fromRGB(85, 85, 255)
			THEPROP = v
		end
	end

	for i = 1,#theCubes do
		local fTweenInfo = TweenInfo.new(.1,Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local fadeTween = TweenService:Create(theCubes[i],fTweenInfo,{Transparency = 1}):Play()
		task.wait(.005)
	end

	if THEPROP ~= nil then
		local fTweenInfo = TweenInfo.new(.15,Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local fadeTween = TweenService:Create(THEPROP,fTweenInfo,{Color = oldpcolor,Transparency = 0}):Play()
	end---23523vgfgs
	task.wait(.05)
	--char.Humanoid.AutoRotate = true
	summon:Stop()
	NOMOVE:Destroy()


	local Strike = char.Humanoid:LoadAnimation(tool.Strike)
	Strike:Play()

	char.HumanoidRootPart.ShadowImpaling:Play()
	char.HumanoidRootPart.BaneEmit:Emit(30)

	task.wait(0.55) -- dont change this it feels fucking terrible
	
	for i = 1,2 do
		HitDetection.magnitudeCheck(char,char.HumanoidRootPart.Position,13,{
			damage = 15,
			physical = true,
			knockback = true,
			slash = true,
			noparry = true,
			spear = true,
			cursestack = true,
			blockbreak = true,
			noenchant = true,
			move = "Shadow Impale"
		})
		task.wait(0.1)
	end
	Temporary:Destroy()
	HiltWeldClone:Destroy()

	task.wait(15)
	canuse = true

end

local canuse2 = true
function module.Active2(char)
	if game.CollectionService:HasTag(char,"Casting") then return end
	if char.Cooldowns:FindFirstChild("Demise Cut") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Demise Cut"
	CD.Value = 15
	CD.Parent = char.Cooldowns
	game.Debris:AddItem(CD, 15)


	local play = game.Players:GetPlayerFromCharacter(char)

	local NOMOVE = Instance.new("Accessory")
	NOMOVE.Name = "Action"
	NOMOVE.Parent = char
	char.Humanoid.AutoRotate = false

	canuse2 = false


	local summon = char.Humanoid:LoadAnimation(tool.Windup)
	summon:Play()

	task.wait(0.025)

	local noise = spelleffect.summon:Clone()
	game.ServerStorage.Debris:Fire(noise,3)
	noise.Parent = char.Torso
	noise:Play()

	task.wait(0.025)

	local Temporary = game.ServerStorage.verto:FindFirstChild("Shadowy Blade"):Clone()
	Temporary.Parent = char.Hilt
	local HiltWeldClone = char.Hilt.HiltWeld:Clone()
	HiltWeldClone.Parent = char.Hilt
	HiltWeldClone.Part0 = char.Hilt
	HiltWeldClone.Part1 = Temporary
	HiltWeldClone.C1 = CFrame.new(-1, -2, 0, -4.37113883e-08, 1, -4.37113883e-08, 0, -4.37113883e-08, -1, -1, -4.37113883e-08, 1.91068547e-15)

	local mdl = game.ServerStorage.verto:FindFirstChild("Shadowy Blade")
	local longestAxis = mdl.Size.X
	if mdl.Size.Y > longestAxis then
		longestAxis = mdl.Size.Y
	end
	if mdl.Size.Z > longestAxis then
		longestAxis = mdl.Size.Z
	end

	local theCubes = {}
	local cubeSize = 0.4
	local cubesRequired = math.floor(math.floor(longestAxis)/cubeSize)
	local startpos = char["Right Arm"].CFrame * CFrame.new(0,-1.2,0)
	for i = 1,cubesRequired do
		local lightCube = spelleffect.LightCube:Clone()
		game.ServerStorage.Debris:Fire(lightCube,2.5)
		table.insert(theCubes,lightCube)
		lightCube.Transparency = 1
		local heyy = CFrame.new(char["Right Arm"].CFrame.X, char["Right Arm"].CFrame.Y, char["Right Arm"].CFrame.Z)
		lightCube.CFrame = heyy * CFrame.new(math.random(-4,4),math.random(7,10),math.random(-4,4))*CFrame.Angles(math.random(-20,20),math.random(-20,20),math.random(-20,20))
		lightCube.Parent = game.Workspace
		local fTweenInfo = TweenInfo.new(.3,Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local destination = startpos*CFrame.new(math.random(-14,14)/100,(-cubeSize*i)+cubeSize,math.random(-2,2)/100)
		local fadeTween = TweenService:Create(lightCube,fTweenInfo,{CFrame = destination,Transparency = 0.6}):Play()
		--lightCube.CFrame = startpos*CFrame.new(math.random(-14,14)/100,(-cubeSize*i)+cubeSize,math.random(-2,2)/100)
		if (i < cubesRequired/3) or ((math.random(1,2) == 1) and (i < cubesRequired/1.2)) then
			local pairCube = spelleffect.LightCube:Clone()
			game.ServerStorage.Debris:Fire(pairCube,2.5)
			table.insert(theCubes,pairCube)
			pairCube.Parent = game.Workspace
			pairCube.CFrame = heyy * CFrame.new(math.random(-4,4),math.random(7,10),math.random(-4,4))*CFrame.Angles(math.random(-20,20),math.random(-20,20),math.random(-20,20))
			local fadeTween = TweenService:Create(pairCube,fTweenInfo,{CFrame = destination * CFrame.new(-(cubeSize-.1),0,math.random(-2,2)/100),Transparency = 0.6}):Play()
		end
		task.wait(.00025)
	end

	task.wait(.00025)

	for i = 1,#theCubes do
		local fTweenInfo = TweenInfo.new(.1,Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local fadeTween = TweenService:Create(theCubes[i],fTweenInfo,{Transparency = 0}):Play()
	end

	task.wait(.00025)

	local oldpcolor
	local THEPROP
	for i,v in next, char.Hilt:GetChildren() do
		if v:FindFirstChild("Prop") and not game.CollectionService:HasTag(v,"SideProp") then
			v.Transparency = .4
			oldpcolor = v.Color

			v.BrickColor = BrickColor.new("Light purple")
			v.Color = Color3.fromRGB(85, 85, 255)
			THEPROP = v
		end
	end

	for i = 1,#theCubes do
		local fTweenInfo = TweenInfo.new(.1,Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local fadeTween = TweenService:Create(theCubes[i],fTweenInfo,{Transparency = 1}):Play()
		task.wait(.005)
	end

	if THEPROP ~= nil then
		local fTweenInfo = TweenInfo.new(.15,Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local fadeTween = TweenService:Create(THEPROP,fTweenInfo,{Color = oldpcolor,Transparency = 0}):Play()
	end---23523vgfgs
	task.wait(.05)
	char.Humanoid.AutoRotate = true
	summon:Stop()

	NOMOVE:Destroy()

	local Strike = char.Humanoid:LoadAnimation(tool.Strike2)
	Strike:Play()

	char.HumanoidRootPart.ShadowImpaling:Play()
	char.HumanoidRootPart.BaneEmit:Emit(30)

	task.wait(0.09)

	HitDetection.magnitudeCheck(char,char.HumanoidRootPart.Position,13,{
		damage = 25,
		physical = true,			
		knockback = true,
		slash = true,
		noparry = true,
		spear = true,
		cursestack = true,
		blockbreak = true,
		noenchant = true,
		demisecut = true,
		move = "Shadow Impale"
	})
	task.wait(0.1)
	Temporary:Destroy()
	HiltWeldClone:Destroy()

	task.wait(15)
	canuse2 = true
end

return module