local l__LocalPlayer__1 = game.Players.LocalPlayer
local l__next__3 = next
local v4, v5 = l__LocalPlayer__1:WaitForChild("PlayerGui"):children()
local l__Parent__8 = script.Parent
local l__CurrentCamera__9 = workspace.CurrentCamera
local l__Finish__10 = l__Parent__8:WaitForChild("Finish")
local l__MenuPans__11 = game.ReplicatedStorage:WaitForChild("MenuPans")
local l__Overlay__12 = l__Parent__8:WaitForChild("Overlay")
local l__Controls__13 = l__Parent__8:WaitForChild("Controls")
local l__Choices__15 = l__Parent__8:WaitForChild("Choices")
local l__CopyrightBar__16 = l__Parent__8:WaitForChild("CopyrightBar")
local l__Cursor__17 = l__Choices__15:WaitForChild("Cursor")
local l__Offset__18 = l__Choices__15.Position.Y.Offset
local v19 = {}
local l__next__20 = next
local v21, v22 = l__Choices__15:children()
while true do
	local v23, v24 = l__next__20(v21, v22)
	if not v23 then
		break
	end
	v22 = v23
	if v24:IsA("TextButton") then
		if v24.Name == "Play" then
			v24.TextColor3 = Color3.fromRGB(249, 237, 224)
		else
			v24.TextColor3 = Color3.fromRGB(191, 182, 172)
		end
		table.insert(v19, v24)
	end
end
game.Lighting.Ambient = Color3.fromRGB(20,20,20)
for v25, v26 in next, v19 do
	v26.MouseEnter:connect(function()
		for v27, v28 in next, v19 do
			if v28 ~= v26 then
				game.TweenService:Create(v28, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					TextColor3 = Color3.fromRGB(191, 182, 172)
				}):Play()
			end
		end
		game.TweenService:Create(v26, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			TextColor3 = Color3.fromRGB(249, 237, 224)
		}):Play()
		game.TweenService:Create(l__Cursor__17, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
			Position = UDim2.new(0, 0, 0, v26.Position.Y.Offset + 11)
		}):Play()
	end)
	local u1 = false
	v26.MouseButton1Click:connect(function()
		local ui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ServerBrowse")
		if v26.Name ~= "Play" then
			if v26.Name == "Controls" then
				ui.Enabled = false
				l__Controls__13.Visible = not l__Controls__13.Visible
				return
			end
			if v26.Name == "Servers" then
				if ui then
					l__Controls__13.Visible = false
					ui.Enabled = not ui.Enabled
				end
				return
			end
		end
		u1 = true
		l__Finish__10:FireServer()
		game.TweenService:Create(l__Choices__15, TweenInfo.new(0.5), {
			Position = UDim2.new(0, -150, 0.95, l__Choices__15.Position.Y.Offset)
		}):Play()
		game.TweenService:Create(l__CopyrightBar__16, TweenInfo.new(0.5), {
			Position = UDim2.new(1, 200, 0, 10)
		}):Play()
	end)
end
local l__MarketplaceService__2 = game:GetService("MarketplaceService")

l__Choices__15.Conquest.MouseButton1Click:Connect(function()
	script.Conquest:FireServer()
end)

l__CurrentCamera__9.CameraType = Enum.CameraType.Scriptable
local v30 = l__MenuPans__11:children()
local v31 = nil
while true do
	local v32 = nil
	while true do
		v32 = v30[math.random(1, #v30)]
		if v32 ~= v31 then
			break
		end	
	end
	if false then
		break
	end
	if l__CurrentCamera__9.CameraSubject and l__CurrentCamera__9.CameraSubject:IsDescendantOf(workspace) then
		l__Overlay__12.Visible = false
		wait(0.1)
		if l__LocalPlayer__1.Character and l__CurrentCamera__9.CameraSubject:IsDescendantOf(l__LocalPlayer__1.Character)then
			break
		end
	else
		v31 = v32
		l__CurrentCamera__9.CameraType = Enum.CameraType.Scriptable
		l__CurrentCamera__9.CFrame = v32["1"].CFrame
		game.TweenService:Create(l__Overlay__12, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()
		wait(0.5)
		l__Overlay__12.Visible = false
		if l__CurrentCamera__9.CameraSubject and l__CurrentCamera__9.CameraSubject:IsDescendantOf(workspace) then
			l__Overlay__12.Visible = false
			wait(0.1)
		else
			for v33 = 2, #v32:children() do
				wait(0.5)
				local v34 = v32[tostring(v33)]
				local v35 = (l__CurrentCamera__9.CFrame.p - v34.Position).magnitude / 20
				if false then
					break
				end
				if l__CurrentCamera__9.CameraSubject and l__CurrentCamera__9.CameraSubject:IsDescendantOf(workspace) then
					if l__LocalPlayer__1.Character and l__CurrentCamera__9.CameraSubject:IsDescendantOf(l__LocalPlayer__1.Character)then
						break
					end
				end
				local v36 = game.TweenService:Create(l__CurrentCamera__9, TweenInfo.new(v35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					CFrame = v34.CFrame
				})
				v36:Play()
				local v37 = 0
				while true do
					v37 = v37 + wait()
					if v35 <= v37 then
						break
					end
					if false then
						break
					end
					if l__CurrentCamera__9.CameraSubject and l__CurrentCamera__9.CameraSubject:IsDescendantOf(workspace) then
						if l__LocalPlayer__1.Character and l__CurrentCamera__9.CameraSubject:IsDescendantOf(l__LocalPlayer__1.Character)then
							break
						end
					end				
				end
				v36:Cancel()
				if false then
					break
				end
				if l__CurrentCamera__9.CameraSubject and l__CurrentCamera__9.CameraSubject:IsDescendantOf(workspace) then
					if l__LocalPlayer__1.Character and l__CurrentCamera__9.CameraSubject:IsDescendantOf(l__LocalPlayer__1.Character)then
						break
					end
				end
				l__CurrentCamera__9.CFrame = v34.CFrame
			end
			l__Overlay__12.BackgroundTransparency = 1
			l__Overlay__12.Visible = true
			game.TweenService:Create(l__Overlay__12, TweenInfo.new(0.5), {
				BackgroundTransparency = 0
			}):Play()
			wait(0.5)
		end
	end
	if false then
		break
	end
end
l__CurrentCamera__9.CameraType = Enum.CameraType.Custom
game.TweenService:Create(l__Overlay__12, TweenInfo.new(0.5), {
	BackgroundTransparency = 1
}):Play()
wait(0.5)
if not l__CurrentCamera__9.CameraSubject or not l__CurrentCamera__9.CameraSubject:IsDescendantOf(workspace) then
	local l__Character__38 = l__LocalPlayer__1.Character
	if l__Character__38 then
		local l__Humanoid__39 = l__Character__38:FindFirstChild("Humanoid")
		if l__Humanoid__39 then
			l__CurrentCamera__9.CameraSubject = l__Humanoid__39
			l__CurrentCamera__9.CameraType = Enum.CameraType.Fixed
		end
	end
end
l__Parent__8:Destroy()