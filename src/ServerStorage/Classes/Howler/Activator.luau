local spell = {}
-- Disarm Spell
function sub(...)
    coroutine.wrap(...)()
end

local TweenService = game:GetService("TweenService")
local tagHumanoid = game.ServerStorage.Requests.TagHumanoid

spell.upperbound = 80
spell.lowerbound = 60
spell.signs = 10
spell.cost = 50

local spelleffect = game.ServerStorage.SpellEffects.Killing
en = true
function spell:Activate(char,castSuccess,currentprop)
	if game.CollectionService:HasTag(char,"Casting") then return end
	if en == false then return end

	local mana = char.Mana
	local play = game.Players:GetPlayerFromCharacter(char)
	local manacolor = game.ServerStorage.PlayerData[play.Name].ManaColor.Value
	
	local mouse
	pcall(function()
		mouse = require(game.ServerStorage.Modules.RemoteLib).getMouse(play)
	end)
	
	if not mouse then return end
	en = true
	if castSuccess == 0 or castSuccess == 1 then
		mana.Value = math.max(mana.Value-spell.cost,0)
	
		char.HumanoidRootPart.PerfectCast:Play()
		
		local master = nil
		if castSuccess == 0 then
			master = char
		else
			en = false
		end
		for i,v in pairs(game.Workspace.Live:GetChildren()) do
			if v:FindFirstChild("MonsterInfo") then
				local masterVal = v.MonsterInfo.Master.Value
				if masterVal and masterVal.Name == char.Name then
					en = false return 
				end
			end
		end
		for i = 1,1 do
			local monster = game.ServerStorage.Requests.SpawnMonster:Invoke("Howler",char.Torso.Position + Vector3.new(math.random(-15,15),0,math.random(-15,15)),master)
			
			local f = game.ServerStorage.Assets.Dark:Clone()
			f.CFrame = monster.Torso.CFrame
			f.Parent = workspace.Thrown
			game.ServerStorage.Debris:Fire(f,2)
			f.Sound:Play()
			f.Attachment.OrbParticle:Emit(100)
			local tweenInfo02 = TweenInfo.new(.75,	Enum.EasingStyle.Sine, Enum.EasingDirection.Out,0,false)
			local tween02 = TweenService:Create(f,tweenInfo02,{Size=Vector3.new(10.05, 10.05, 10.05)})
			tween02:Play()
			
			Instance.new("Accessory",monster).Name = "Summoned"
		end
	else
		char.HumanoidRootPart.Diffusion:Play()
		if currentprop and currentprop:FindFirstChild("Backfire") then
			currentprop.Backfire.Color = ColorSequence.new(Color3.new(manacolor.r,manacolor.g,manacolor.b))
			currentprop.Backfire:Emit(15)
		end
	end

	wait(600)
	en = true
end

return spell