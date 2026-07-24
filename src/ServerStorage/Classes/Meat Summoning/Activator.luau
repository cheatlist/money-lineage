local commands = require(game.ServerScriptService.Modules.Commands)

local module = {}

local v2 = {
	lowerbound = 0,
	upperbound = 100,
	signs = 0,
	cost = 100
}
local cd = false
function v2.Activate(nothing, Character, againnothing, idontcarelol)
	if cd then
		return
	end
	cd = true
	task.delay(3, function()
		cd = false
	end)
	local Mana = Character.Mana
	local Player = game.Players:GetPlayerFromCharacter(Character)
	local Data = Player and game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
	game.CollectionService:AddTag(Character,"MeatCool")
	spawn(function()
		task.wait(3)
		game.CollectionService:RemoveTag(Character,"MeatCool")
	end)


	if againnothing == 0 then
		Character.HumanoidRootPart.PerfectCast:Play()
		Character.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims:WaitForChild("Snap3")):Play()
		Character.HumanoidRootPart.Snap:Play()
		Mana.Value = math.max(Mana.Value - v2.cost, 0)
		for i=1, 3 do 
			local meat = nil
			if Data.Race ~= "vampire" then --incase u guys yknow go through with the Vampire becoming its own class stuff
				meat = commands.AddToInventory(Player,"Mouth-Watering Meat")
			else
				meat = commands.AddToInventory(Player,"Vint")
			end
			meat.Parent = Player.Backpack
			Character.Humanoid:EquipTool(meat)
			local emit = script.HolyEmit:Clone()
			emit.Parent = meat.Handle
			emit:Emit(15)
			game.Debris:AddItem(emit, 3)
			Character.HumanoidRootPart.Ordersound:Play()
		end	
	else
		Character.HumanoidRootPart.Diffusion:Play();
	end
end
module.alternate = v2


return module
