local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = script:WaitForChild("Player")
local Parent = script.Parent
local ScrollingFrame = Parent:WaitForChild("PlayerFrame"):WaitForChild("ScrollingFrame")
local UIListLayout = ScrollingFrame:WaitForChild("UIListLayout")
local Indicator0 = Parent:WaitForChild("Indicator")
Indicator0.Visible = false

Parent.Enabled = false

local Enum_Material_Air = Enum.Material.Air
local u3 = Enum.HumanoidStateType.None
local u4 = Enum.HumanoidStateType.StrafingNoPhysics
local function v13(p2, p3)
	local Position4 = p2.Position
	local v15, v16 = workspace:FindPartOnRay(Ray.new(Position4, Vector3.new(0, -15, 0)), p2.Parent)
	local v17 = p3:GetState()
	if v15 then
		if (not v15 or not v16 or not ((Position4 - v16).Magnitude > 10) or p3.FloorMaterial ~= Enum_Material_Air) and v17 ~= u3 and v17 ~= u4 then
			return
		end
	elseif p3.FloorMaterial ~= Enum_Material_Air and v17 ~= u3 and v17 ~= u4 then
		return
	end
	return true
end
UIListLayout.Changed:connect(function()
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)
local u5 = nil
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local u8 = {}
local function u9(p4)
	if not p4 then
		return
	end
	if u5 and u5.Name == p4.Name then
		u5 = nil
		local Character8 = LocalPlayer.Character
		local v19 = Character8 and Character8:FindFirstChild("Humanoid")
		if v19 then
			CurrentCamera.CameraSubject = v19
		end
		Indicator0.Visible = false
		return
	end
	u5 = p4
	local Character0 = workspace.Live:FindFirstChild(p4.Name)
	local v21 = Character0 and Character0:FindFirstChild("Humanoid")
	if v21 then
		CurrentCamera.CameraSubject = v21
	end
	Indicator0.Text = "Currently Spectating: " .. p4.Name
	Indicator0.Visible = true
end
Players.PlayerRemoving:connect(function(p5)
	local v22 = u8[p5]
	if v22 then
		u8[p5] = nil
		local fm3 = v22.fm
		if fm3 then
			fm3:Destroy()
		end
	end
end)
local function u10(p6)
	if p6 == LocalPlayer then
		return
	end
	if u8[p6] then
		return
	end
	local v24 = Player:clone()
	v24.Text = p6.Name .. ": ?/s ?mp"
	v24.Name = p6.Name
	v24.Parent = ScrollingFrame
	v24.MouseButton1Click:connect(function()
		u9(p6)
	end)
	u8[p6] = {
		fm = v24, 
		lps = Vector3.new()
	}
end
Players.PlayerAdded:connect(function(p7)
	u10(p7)
end)
for i, v in next, Players:GetPlayers() do
	u10(v)
end
UserInputService.InputBegan:connect(function(p8, p9)
	if p9 then
		return
	end
	if p8.KeyCode == Enum.KeyCode.Tab then
		Parent.Enabled = not Parent.Enabled
		local Character0 = LocalPlayer.Character
		local v31 = Character0 and Character0:FindFirstChild("Humanoid")
		if v31 then
			CurrentCamera.CameraSubject = v31
		end
	end
end)
while wait(0.5)do
	if Parent.Enabled then
		for v34, v35 in next, u8 do
			local v36 = v35 and v35.fm
			local v37 = v35 and v35.lps
			local Character8 = workspace.Live:FindFirstChild(v34.Name)
			if v36 and v36.Parent and v37 and Character8 then
				local Head9 = Character8:FindFirstChild("Head")
				local v40 = Head9 and Character8:FindFirstChild("Humanoid")
				if v40 then
					local Position1 = Head9.Position
					local v42 = math.ceil((v37 - Position1).magnitude * 2)
					local Mana3 = Character8:FindFirstChild("Mana")
					local v44 = Mana3 and math.floor(Mana3.Value * 10) / 10 or "???"
					v36.TextColor3 = (v13(Head9, v40) or v42 > 100) and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
					v36.Text = v34.Name .. ": " .. v42 .. "/s " .. v44 .. "mp"
					pcall(function()
						if type(v44) ~= "number" then
							v36.ManaBar.Visible = false
							return
						end
						v36.ManaBar.Visible = true
						game.TweenService:Create(v36.ManaBar.Scaler, TweenInfo.new(0.3), {
							Size = UDim2.new(math.clamp(v44 / 100, 0, 1), 0, 1, 0)
						}):Play()
					end)
					v35.lps = Position1
				end
			end
		end

		if u5 and u5.Parent then
			local Character5 = workspace.Live:FindFirstChild(u5.Name)
			local v46 = Character5 and Character5:FindFirstChild("Humanoid")
			if v46 then
				CurrentCamera.CameraSubject = v46
			end
		end
	end
end