local module = {}

local Damage = require(game.ServerScriptService.Modules.HitDetection)
local TagHumanoid = game.ServerStorage.Requests.TagHumanoid
local wait = task.wait
local cool = false

local function lookAt(eye,target)
	local forwardVector = (target - eye).unit
	local upVector = Vector3.new(0,5,0)
	local rightVector = forwardVector:Cross(upVector)
	local upVector2 = rightVector:Cross(forwardVector)
	return CFrame.fromMatrix(eye,rightVector,upVector2)
end

local function NearestPerson(Character)
	local Closest,Target = 14,nil
	Character = script.Parent.Parent
	for _,v in ipairs(game.Workspace.Live:GetChildren()) do
		if v.Name ~= Character.Name and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <Closest then
			Closest = (v.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
			Target = v
		end
	end
	return Target
end

module.Active = function(Player,Character)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	local Target = NearestPerson(Character)
	if Character.Cooldowns:FindFirstChild("Electric Smite") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Electric Smite"
	CD.Value = 25
	CD.Parent = Character.Cooldowns
	game.Debris:AddItem(CD, 25)
	if cool == false then
		local data = game.ServerStorage.PlayerData:FindFirstChild(Character.Name)
		
		local waiting = 0.5
		local waiting2 = 0.25
		local waiting3 = 0.35
		local waiting4 = 0.2
		local waiting5 = 0.15
		if data.Skills.Value:find("TheLightning") then
			waiting = 0.35
			waiting2 = 0.175
			waiting3 = 0.225
			waiting4 = 0.15
			waiting5 = 0.1
		end
		
		
		local action = Instance.new("Folder");
		action.Name = "Action";
		action.Parent = Character;
		local anim = Character.Humanoid:LoadAnimation(script.Parent.ElectricSmite)
		anim:Play()
		local Sound = script.Parent.LightningHit:Clone()
		Sound.Parent = Character.HumanoidRootPart
		Sound:Play()
		game.Debris:AddItem(Sound, 5)
		for _,part in pairs(Character:children()) do
			if part.Name == "Left Leg" then
				local pticle = game.ReplicatedStorage.Assets.Electric:clone()
				if data.Skills.Value:find("TheThunderstorm") then
					pticle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
				elseif data.Skills.Value:find("TheCalmbeforethestorm") then
					pticle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
				elseif data.Skills.Value:find("TheLightning") then
					pticle.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
				end
				pticle.Enabled = true
				pticle.Parent = part
				
				delay(waiting,function()
					pticle.Enabled = false
				end)
				game.Debris:AddItem(pticle,1)
			end
		end
		wait(waiting2)
		local oldpos = Character.HumanoidRootPart.Position
		if Target then
			Character:SetPrimaryPartCFrame(CFrame.new(Target.HumanoidRootPart.CFrame.p,Character.HumanoidRootPart.CFrame.p) * CFrame.new(2,5,-4) * (Character.HumanoidRootPart.CFrame - Character.HumanoidRootPart.CFrame.p))
		else
			Character:SetPrimaryPartCFrame(CFrame.new(Character.HumanoidRootPart.CFrame.p) * CFrame.new(2,5,-4) * (Character.HumanoidRootPart.CFrame - Character.HumanoidRootPart.CFrame.p))
		end
	
		local newpos = Character.HumanoidRootPart.Position
		local burst = game.ReplicatedStorage.Assets.FlashLine:Clone()
		if data.Skills.Value:find("TheThunderstorm") then
			burst.Color = Color3.fromRGB(255, 255, 0)
			burst.Electric.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
		elseif data.Skills.Value:find("TheCalmbeforethestorm") then
			burst.Color = Color3.fromRGB(255, 255, 255)
			burst.Electric.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		elseif data.Skills.Value:find("TheLightning") then
			burst.Color = Color3.fromRGB(85, 0, 255)
			burst.Electric.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
		end
		burst.Parent = workspace.Thrown
		burst.CFrame = Character.HumanoidRootPart.CFrame - Character.Humanoid.MoveDirection*13
		game.Debris:AddItem(burst,waiting3)
		game.TweenService:Create(burst,TweenInfo.new(waiting4),{Size=Vector3.new(4.5,4.5,4.5)}):Play()
		delay(waiting4,function()
			game.TweenService:Create(burst,TweenInfo.new(waiting5),{Size=Vector3.new(0,0,0),Transparency=1}):Play()
		end)

		local burst2 = game.ReplicatedStorage.Assets.flash:Clone()
		if data.Skills.Value:find("TheThunderstorm") then
			burst2.Color = Color3.fromRGB(255, 255, 0)
			burst2.Electric.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
			burst2.PointLight.Color = Color3.fromRGB(255, 255, 0)
		elseif data.Skills.Value:find("TheCalmbeforethestorm") then
			burst2.Color = Color3.fromRGB(255, 255, 255)
			burst2.Electric.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			burst2.PointLight.Color = Color3.fromRGB(255, 255, 255)
		elseif data.Skills.Value:find("TheLightning") then
			burst2.Color = Color3.fromRGB(85, 0, 255)
			burst2.Electric.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
			burst2.PointLight.Color = Color3.fromRGB(85, 0, 255)
		end
		burst2.Parent = workspace.Thrown
		burst2.CFrame = lookAt(oldpos+Character.Humanoid.MoveDirection*7,newpos)
		game.Debris:AddItem(burst2,waiting3)
		delay(waiting4,function()
			game.TweenService:Create(burst2,TweenInfo.new(waiting5),{Transparency=1}):Play()
		end)

		local lightningParticle = game.ReplicatedStorage.Assets.Lightning:clone()
		if data.Skills.Value:find("TheThunderstorm") then
			lightningParticle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
		elseif data.Skills.Value:find("TheCalmbeforethestorm") then
			lightningParticle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		elseif data.Skills.Value:find("TheLightning") then
			lightningParticle.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
		end
		lightningParticle.Parent = Character.HumanoidRootPart
		lightningParticle:Emit(10)
		game.Debris:AddItem(lightningParticle,0.1)
		wait(waiting2)
		local Table = {
			physical = true, 
			damage = 15,
			ManaCancel = true,
			smitestun = true,
			fist = true,
			Banem1 = true,
			sparks = true,
			bypassfischdodge = true,
			manastop = true,
			blockallsides = true,
		}
		if data.Skills.Value:find("TheThunderstorm") then
			Table.LightningStunSuper = true
		end
		TagHumanoid:Fire(Character, Target, Table)
		action:Destroy()
		Character.Humanoid:UnequipTools()
	end
end

return module;