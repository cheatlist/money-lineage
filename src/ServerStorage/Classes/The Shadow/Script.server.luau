local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent): boolean
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","NoDam","ReturnStun","Action","Blocking","ActiveCast","Unconscious","Knocked"},
	})
end
local canuse: boolean = true
local effectcd: boolean = false
local function invis(Target, Transparency, State)
	if not effectcd then
		Target.HumanoidRootPart.ShadowEmitter:Emit(20)
		effectcd = true
		task.delay(1, function()
			effectcd = false
		end)
	end
	if not State then
		for i,v in pairs(Target.Boosts:GetChildren()) do
			if v.Name == "Transparency" then
				task.wait(1/30)
				v:Destroy()
			end
		end
	else
		local Invis = Instance.new("NumberValue")
		Invis.Value = Transparency
		Invis.Name = "Transparency"
		Invis.Parent = Target.Boosts
	end
end
local detect
script.Parent.Equipped:Connect(function(Player, Character)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	if Character.Humanoid.MoveDirection.Magnitude>0 then
		return
	end
	if not canuse then
		return
	end
	canuse = false
	task.delay(0.5, function()
		canuse = true
	end)
	invis(Character, 1, true)
	task.spawn(function()
		while true do
			if Character.Humanoid.MoveDirection.Magnitude > 0.1 then
				break
			end
			task.wait(1/30)
		end
		Character.Humanoid:UnequipTools()
	end)
	if detect then
		detect:Disconnect()
		detect = nil
	end
	detect = Character.ChildAdded:Connect(function(child)
		if child.Name == "NoDam" then
			Character.Humanoid:UnequipTools()
		end
	end)
end)
script.Parent.Unequipped:Connect(function(Player, Character)
	Player = script.Parent.Parent.Parent
	if detect then
		detect:Disconnect()
		detect = nil
	end
	if Player.Character then
		Character = Player.Character
		invis(Character, 1, false)
	end
end)