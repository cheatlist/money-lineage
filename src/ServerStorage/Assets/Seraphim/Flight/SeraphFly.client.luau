
local plr = game.Players.LocalPlayer
local c = plr.Character or plr.CharacterAdded:Wait()
ended = false
local uis = game:GetService("UserInputService")
local hrp = c:WaitForChild("HumanoidRootPart")
local humanoid = c:WaitForChild("Humanoid")
local flying = false
game.ReplicatedStorage.Requests.ConfusedDay.OnClientEvent:Connect(function()
	flying = false
end)
flying = true
for _,v in pairs(plr.Character.HumanoidRootPart:GetChildren()) do
	if v:IsA("BodyMover") then
		v:Destroy()
	end
end
c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame + Vector3.new(0,1000,0)
local bp = Instance.new("BodyPosition", plr.Character.HumanoidRootPart)
game.CollectionService:AddTag(bp,"AllowedBM")
bp.MaxForce=  Vector3.new(80000,80000,80000)
bp.P = 8000
bp.Position = c.HumanoidRootPart.Position+Vector3.new(0,200,0)
coroutine.wrap(function()
	repeat wait()
		local r = Ray.new(c.HumanoidRootPart.Position,Vector3.new(0,-111111,0))
		local ig = {workspace.Live,workspace.AreaMarkers}
		local par,pos,nor = workspace:FindPartOnRayWithIgnoreList(r,ig)
		if par then
			bp.Position = Vector3.new(bp.Position.X, pos.Y+300,bp.Position.Z)
		end
		bp.Position = bp.Position + (humanoid.MoveDirection * 5)
	until not flying
	bp:Destroy()
end)()
--uis.InputBegan:Connect(function(k,g)
--	if g then return end
--	if not flying then return end
--	if k.KeyCode == Enum.KeyCode.W then
--		repeat wait() 
--			bp.Position = bp.Position+c.HumanoidRootPart.CFrame.lookVector*3
--		until not uis:IsKeyDown(Enum.KeyCode.W)
--	end
--	if k.KeyCode == Enum.KeyCode.D then
--		repeat wait() 
--			bp.Position = bp.Position+c.HumanoidRootPart.CFrame.rightVector*3
--		until not uis:IsKeyDown(Enum.KeyCode.D)
--	end
--	if k.KeyCode == Enum.KeyCode.A then
--		repeat wait() 
--			bp.Position = bp.Position+c.HumanoidRootPart.CFrame.rightVector*-3
--		until not uis:IsKeyDown(Enum.KeyCode.A)
--	end
--	if k.KeyCode == Enum.KeyCode.S then
--		repeat wait() 
--			bp.Position = bp.Position+c.HumanoidRootPart.CFrame.lookVector*-3
--		until not uis:IsKeyDown(Enum.KeyCode.A)
--	end
--end)