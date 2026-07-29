function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.Commands)
local FoodModule = require(game.ServerScriptService.Modules.FoodModule)
local CollectionService = game.CollectionService
local HasTag = CollectionService.HasTag
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	do -- return
		return
	end
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	if p1:FindFirstChild("NoHunger") or HasTag(CollectionService,p1,"Vampirism") or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Scroom" or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Metascroom" then
		local r = math.random(1, 4)
		if r == 4 then
			script.Parent.Handle.Cough:Play()
		else
			script.Parent.Handle.Cough:Play()
		end
		return
	end
	if script.Parent.PoisonAmount.Value <= 0 then
		local data = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
		if not FoodModule.eat(p1, data, "Meat", 50) then
			script.Parent.Handle.Cough:Play()
			return
		end
		canuse = false
		u3.RemoveFromInventory(game.Players:GetPlayerFromCharacter(p1),"Meat")
		p1.Humanoid:LoadAnimation(script.Parent.Animation):Play()
		wait(0.175)
		script.Parent.Handle.Sound:Play()
		task.delay(1.218, function()
			script.Parent.Handle.Sound:Stop()
		end)
		canuse = true
	else
		canuse = false
		u3.RemoveFromInventory(game.Players:GetPlayerFromCharacter(p1),"Meat")
		p1.Humanoid:LoadAnimation(script.Parent.Animation):Play()
		wait(0.175)
		script.Parent.Handle.Sound:Play()
		canuse = true

		local poisonseverity = script.Parent.PoisonAmount.Value
		local symptomps = {}
		if poisonseverity >= 25 then
			table.insert(symptomps, "ManaStop")
		end
		if poisonseverity >= 50 then
			table.insert(symptomps, "Slowness")
		end
		if poisonseverity >= 75 then
			table.insert(symptomps, "Weakness")
		end
		if poisonseverity >= 100 then
			table.insert(symptomps, "Demise")
		end
		for i = 1,#symptomps do
			local symp = Instance.new("Folder")
			symp.Name = symptomps[i]
			symp.Parent = p1
			game.Debris:AddItem(symp, 180)
		end
	end
end)