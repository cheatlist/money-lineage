local module = {}

function groundDistance(char)
	local ray = Ray.new(char.HumanoidRootPart.Position,Vector3.new(0,-50,0))
	local bHit,bPos,bNor = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Live,workspace.Terrain,workspace.Thrown})
	return (char.HumanoidRootPart.Position.y-bPos.y)
end

local MIN_HEIGHT = 10

module.Change = function(play)
	local char = play.Character
	
	local shadowrush = play.Backpack:FindFirstChild("Shadowrush") or char:FindFirstChild("Shadowrush")
	local cruelwind = play.Backpack:FindFirstChild("Cruel Wind") or char:FindFirstChild("Cruel Wind")
	
	if shadowrush then
		local folder = Instance.new("Folder", play.Backpack)
		folder.Name = "ShadowrushAerialAllow"
		spawn(function()
			wait(1)
			repeat wait() until not folder or groundDistance(char) < MIN_HEIGHT
			game.ServerStorage.Debris:Fire(folder, 0.001)
		end)
	end
	if cruelwind then
		local folder = Instance.new("Folder", play.Backpack)
		folder.Name = "CruelWindAerial"
		spawn(function()
			wait(1)
			repeat wait() until not folder or groundDistance(char) < MIN_HEIGHT
			game.ServerStorage.Debris:Fire(folder, 0.001)
		end)
	end
end

return module
