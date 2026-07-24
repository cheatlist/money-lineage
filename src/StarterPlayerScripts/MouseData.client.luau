local Plrs: Players = game:GetService'Players'
local LP: Player = Plrs.LocalPlayer or Plrs.PlayerAdded:Wait()
local Mouse: Mouse = LP:GetMouse()
local Rem = game:GetService'ReplicatedStorage':WaitForChild'MouseData'
Rem.Name = '\0'
Rem.OnClientInvoke = function(): {[string]: any}
	return {
		Hit = Mouse.Hit, 
		Target = Mouse.Target, 
		UnitRay = Mouse.UnitRay, 
		X = Mouse.X, 
		Y = Mouse.Y
	}
end