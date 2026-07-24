function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"WraithHelm","FusedHelm1","FusedHelm2","Baima","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local model = game.ReplicatedStorage.Assets.Outfits.Bucket:Clone()
local canuse = true
local equipped = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	for i,v in pairs(p1.Boosts:GetChildren()) do
		if v.Name == "HealthBoost" then
			if v:FindFirstChild("Type") then
				if v:FindFirstChild("Type").Value ~= "Helmet" then return end 
			end
		end
	end
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local animation
	if not equipped then
		animation = p1.Humanoid:LoadAnimation(script.Parent.Anim1)
		equipped = true
	else
		animation = p1.Humanoid:LoadAnimation(script.Parent.Anim2)
		equipped = false
	end
	animation:Play()
	
	wait(0.25)
	wait(0.75)
	canuse = true
end)