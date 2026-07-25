local l__TweenService__1 = game:GetService("TweenService")
function erasureEffect()
	local l__TIMEERASEDBY__1 = game.ReplicatedStorage:FindFirstChild("TIMEERASEDBY")
	if not l__TIMEERASEDBY__1 then
		return
	end
	local l__Value__2 = l__TIMEERASEDBY__1.Value
	if l__Value__2 then
		if not l__Value__2.Parent then
			return
		end
	else
		return
	end
	if l__Value__2 ~= game.Players.LocalPlayer.Character then
		l__Value__2.Parent = nil
	end
	local v3 = tick()
	local l__Position__4 = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
	local v5 = {}
	local v6 = Vector3.new(200, 200, 200)
	local v7 = workspace:FindPartsInRegion3WithIgnoreList(Region3.new(l__Position__4 - v6, l__Position__4 + v6), { workspace.Live, workspace.NPCs }, math.huge)
	local v8 = game.ReplicatedStorage.Assets.ErasureStuff.ERASE:Clone();
	v8.Parent = workspace;
	v8:Play();
	local v10 = 1 - 1
	while true do
		local v11 = game.ReplicatedStorage.Assets.ErasureStuff.Image:Clone()
		v11.Position = UDim2.new(1, 0, math.random(0, 100) / 100, -v11.Size.Y.Offset / 2)
		local v12 = 2.5 / v10
		game.TweenService:Create(v11, TweenInfo.new(v12, Enum.EasingStyle.Quint), {
			Position = UDim2.new(-1, v11.Size.X.Offset, v11.Position.Y.Scale, -v11.Size.Y.Offset / 2)
		}):Play()
		v11.Parent = game.Players.LocalPlayer.PlayerGui.EraseTimeGui
		if not _G.Debris then repeat task.wait(1/30) until _G.Debris end
_G.Debris:AddItem(v11, v12)
		game:GetService("RunService").RenderStepped:Wait()
		if 0 <= 1 then
			if v10 < 60 then

			else
				break
			end
		elseif 60 < v10 then

		else
			break
		end
		v10 = v10 + 1	
	end
	game.Lighting.erasedcolor.Enabled = false
	local v13 = {}
	local v14 = 0
	local l__next__15 = next
	local v16 = nil
	while true do
		local v17, v18 = l__next__15(v7, v16)
		if v17 then

		else
			break
		end
		v16 = v17
		if (v18.Position - l__Position__4).Magnitude < 150 then
			if v14 < 900 then
				if not v18:IsA("UnionOperation") then
					local v19 = Instance.new("BlockMesh")
					v19.Scale = Vector3.new(1, 1, 1)
					v19.Name = "HIDEIT"
					v19.Parent = v18
					v14 = v14 + 1
					l__TweenService__1:Create(v19, TweenInfo.new(0.25), {
						Scale = Vector3.new(0, 0, 0), 
						Offset = Vector3.new(math.random(-1, 1) * 5, 10, math.random(-5, 5))
					}):Play()
					if not _G.Debris then repeat task.wait(1/30) until _G.Debris end
_G.Debris:AddItem(v19, 8 - (tick() - v3))
					if v17 % 8 == 0 then
						game:GetService("RunService").RenderStepped:Wait()
					end
				else
					v13[v18] = v18.Transparency
					v18.Transparency = 1
				end
			else
				v13[v18] = v18.Transparency
				v18.Transparency = 1
			end
		else
			v13[v18] = v18.Transparency
			v18.Transparency = 1
		end	
	end
	while true do
		wait()
		if not (8 < tick() - v3) then

		else
			break
		end	
	end
	local l__next__20 = next
	local v21 = nil
	while true do
		local v22, v23 = l__next__20(v13, v21)
		if v22 then

		else
			break
		end
		v21 = v22
		if v22 then
			if v22.Parent then
				v22.Transparency = v23
			end
		end	
	end
	v8:Destroy()
	pcall(function()
		if game.Players:FindFirstChild(l__Value__2.Name) then
			if l__Value__2 ~= game.Players.LocalPlayer.Character then
				l__Value__2.Parent = workspace.Live
			end
		end
	end)
	game.Lighting.erasedcolor.Enabled = true
	local v24 = 1 - 1
	while true do
		local v25 = game.ReplicatedStorage.Assets.ErasureStuff.Image:Clone()
		v25.Position = UDim2.new(1, 0, math.random(0, 100) / 100, -v25.Size.Y.Offset / 2)
		local v26 = 2.5 / v24
		game.TweenService:Create(v25, TweenInfo.new(v26, Enum.EasingStyle.Quint), {
			Position = UDim2.new(-1, v25.Size.X.Offset, v25.Position.Y.Scale, -v25.Size.Y.Offset / 2)
		}):Play()
		v25.Parent = game.Players.LocalPlayer.PlayerGui.EraseTimeGui
		if not _G.Debris then repeat task.wait(1/30) until _G.Debris end
_G.Debris:AddItem(v25, v26)
		game:GetService("RunService").RenderStepped:Wait()
		if 0 <= 1 then
			if v24 < 60 then

			else
				break
			end
		elseif 60 < v24 then

		else
			break
		end
		v24 = v24 + 1	
	end
	game.Lighting.erasedcolor.Enabled = false
	script:Destroy()
end
erasureEffect()