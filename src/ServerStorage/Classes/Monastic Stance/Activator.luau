local module = {}
local used

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(aisar)
	return ActionCheckModule(aisar, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end

function Anchor(Target, Statement)
	if Statement then
		game.CollectionService:AddTag(Target, "FreezeRoot")
	else
		game.CollectionService:RemoveTag(Target, "FreezeRoot")
	end
end

function module.Active(character)

	if ActionCheck(character) then
		return
	end

	if character.Cooldowns:FindFirstChild("Monastic Stance") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Monastic Stance"
	CD.Value = 35
	CD.Parent = character.Cooldowns
	game.Debris:AddItem(CD, 35)

	task.spawn(function()
		task.wait(35)

		used = false
	end)

	local Stomp = character.Humanoid.Animator:LoadAnimation(script.Parent.Stomp)
	Stomp:Play()
	Anchor(character, true)
	task.wait(0.5)
	if workspace.Destructibles:FindFirstChild("MonkBreak") then
		if (character.HumanoidRootPart.Position - workspace.Destructibles.MonkBreak.Position).Magnitude <= 25 then
			for i = 1,3 do
				local par = workspace.Destructibles.MonkBreak:Clone()
				par.Parent = workspace
				par.CFrame = workspace.Destructibles.MonkBreak.CFrame * CFrame.new(i, 0, 0)
				par.Size = Vector3.new(5,5,5)
				par.Anchored = false
				game.Debris:AddItem(par, 5)
			end
			workspace.Destructibles.MonkBreak:Destroy()
		end
	end
	
	local IdleMonk = character.Humanoid.Animator:LoadAnimation(script.Parent.IdleMonk)
	IdleMonk:Play()

	IdleMonk:AdjustSpeed(0.4)

	local MonasticStance = Instance.new("Folder", character)
	MonasticStance.Name = "MonasticStance"

	character.HumanoidRootPart["SLAMJAM"]:Play()
	Anchor(character)
	local Particle = game.ReplicatedStorage.Assets.MonkParticle:Clone()
	Particle.Parent = character.HumanoidRootPart

	game.Debris:AddItem(Particle, 28)

	task.wait(25)

	IdleMonk:Stop()

	MonasticStance:Destroy()

	Particle.Enabled = false


end
return module