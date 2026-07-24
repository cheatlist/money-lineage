function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","NoDam","ReturnStun","Action","Blocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
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
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not p1:FindFirstChild("MoneyGuard")then
		local v1 = Instance.new("Accessory")
		v1.Name = "MoneyGuard"
		v1.Parent = p1
		p1.HumanoidRootPart.MoneyCharge:Play()
		p1.HumanoidRootPart.MoneyEmit:Emit(50)
	else
		p1.MoneyGuard:Destroy()
		p1.HumanoidRootPart.MoneyEmit:Emit(5)
		p1.HumanoidRootPart.MoneyDischarge:Play()
	end
	wait(1)
	canuse = true
end)