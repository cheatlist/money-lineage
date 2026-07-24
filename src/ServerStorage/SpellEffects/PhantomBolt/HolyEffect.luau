local module = {}
function module.hitEffect(character,hit,info,stun,checkvamp)

	game.ServerStorage.Requests.TagHumanoid:Fire(character,hit,info)
	local v1 = game.ServerStorage.Assets.PhantomImpact:Clone()
	v1.Parent = character.HumanoidRootPart
	v1:Play()
	game.Debris:AddItem(v1,2)
	if hit and hit:FindFirstChild("HumanoidRootPart") then
		local v2 = script.Parent.ParticleEmitter:Clone()
		v2.Parent = hit.HumanoidRootPart
		v2.Enabled = true
		v2:Emit(1)
		game.Debris:AddItem(v2,2)
	end
end
return module