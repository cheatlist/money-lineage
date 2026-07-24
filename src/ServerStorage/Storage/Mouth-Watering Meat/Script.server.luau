function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.Commands)
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
	if HasTag(CollectionService,p1,"Vampirism") or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Scroom" or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Dullahan" or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Gaian" or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Metascroom" then
		local r = math.random(1, 4)
		if r == 4 then
			script.Parent.Handle.Cough:Play()
		else
			script.Parent.Handle.Cough:Play()
		end
		return
	end
	canuse = false
	u3.RemoveFromInventory(game.Players:GetPlayerFromCharacter(p1),script.Parent.Name)
	p1.Humanoid:LoadAnimation(script.Parent.Animation):Play()
	wait(0.6)
	script.Parent.Handle.Sound:Play()
	game.Debris:AddItem(script.Parent,0.65)
	
	--//local stomach = math.clamp(p1.Stomach.Value+50,0,p1.Humanoid.MaxHealth)
	if p1.Stomach.Value + 80 > p1.Humanoid.MaxHealth or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Cameo"  then
		local diff = p1.Humanoid.MaxHealth - p1.Stomach.Value
		local tofill = 80 - diff
		p1.Stomach.Value = p1.Humanoid.MaxHealth --//= stomach
		if p1.ExtraStomach.Value + tofill/2.2 <= p1.Humanoid.MaxHealth then
			p1.ExtraStomach.Value += tofill/2.2
		else
			p1.ExtraStomach.Value = p1.Humanoid.MaxHealth
		end
	else
		p1.Stomach.Value += 80
	end
end)