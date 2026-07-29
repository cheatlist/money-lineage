local v1 = {}
local playerdata = game.ServerStorage.PlayerData
local no = false
function v1.Active(v2)
	_G.Death(script.Parent.Parent);
	for i,v in next, script.Parent.Parent:GetChildren() do
		if v:IsA("Shirt") or v:IsA("Pants") then
			v:Destroy();
		end
		if v:IsA("BasePart") then
			v.Anchored = true
			v.Material = Enum.Material.Neon
			game.TweenService:Create(v, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Transparency = 1,
				Color = Color3.new(0,0,0),
				Position = v.Position+Vector3.new(math.random(-10,10), math.random(-5,10), math.random(-10,10)),
				Orientation = Vector3.new(math.random(-360,360), math.random(-360,360), math.random(-360,360))
			}):Play()
		end
	end
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
end
return v1