local shake = {}
shake.new = function (y1, x1, z1, time1)
	local Humanoid = game.Players.LocalPlayer.Character.Humanoid
	for i = 1, time1 do
		local x = math.random(-100,x1)/x1
		local y = math.random(-100,y1)/y1
		local z = math.random(-100,z1)/z1
		Humanoid.CameraOffset = Vector3.new(x,y,z)
		print(i,x,y,z)
		game:GetService("RunService").RenderStepped:Wait()
	end
	Humanoid.CameraOffset = Vector3.new(0,0,0)
end
return shake