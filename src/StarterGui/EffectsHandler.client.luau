local l__LocalPlayer__1 = game.Players.LocalPlayer
local v2 = l__LocalPlayer__1.Character or l__LocalPlayer__1.CharacterAdded:wait()
local l__TweenService__3 = game:GetService("TweenService")
local l__CharacterHandler__4 = v2:WaitForChild("CharacterHandler")
local l__Input__5 = l__CharacterHandler__4:WaitForChild("Input")
local l__Requests__6 = game.ReplicatedStorage.Requests
local l__CurrentCamera__10 = workspace.CurrentCamera
local l__Destroy__1 = workspace.Destroy
local l__math_random__3 = math.random
local l__FireServer__4 = Instance.new("RemoteEvent").FireServer
local l__wait__5 = wait
local nsHit = game.Lighting.NsHit
l__Requests__6.NightStoneHit.OnClientEvent:Connect(function()
	game.TweenService:Create(nsHit,TweenInfo.new(.1),{TintColor = Color3.fromRGB(0, 0, 0)}):Play()
	task.wait(.15)
	game.TweenService:Create(nsHit,TweenInfo.new(.1),{TintColor = Color3.fromRGB(255, 255, 255)}):Play()
end)

l__Requests__6.KatanaSkillFX.OnClientEvent:Connect(function(p3, p4, p5, p6, p7)
	if p3:match("TriSlash") then
		spawn(function()
			wait(0.003);
			if p6 then
				local v23 = game.ReplicatedStorage.Assets:FindFirstChild("TriSlash" .. math.random(1, 3)):Clone();
				v23.Size = Vector3.new(0.1, 0.25, 0.1);
				if p3 == "TriSlash1" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 2, -3) * CFrame.Angles(0.17453292519943295, 3.141592653589793, 1.5707963267948966);
				elseif p3 == "TriSlash2" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, -0.08726646259971647);
				elseif p3 == "TriSlash3" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 0.5, -3) * CFrame.Angles(0, 3.141592653589793, 2.6179938779914944);
				end;
				if p4 then
					v23.Color = Color3.fromRGB(82, 174, 255);
				end;
				v23.Parent = game.Workspace.Thrown;
				local v24 = l__TweenService__3:Create(v23, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = Vector3.new(12, 0.5, 7.2)
				}):Play();
				task.delay(0.15,function()
					local v25 = l__TweenService__3:Create(v23, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play();
				end);
			end;
		end);
	elseif p3:match("TriSlash2") then
		spawn(function()
			wait(0.003);
			if p6 then
				local v23 = game.ReplicatedStorage.Assets:FindFirstChild("TriSlash" .. math.random(1, 4)):Clone();
				v23.Size = Vector3.new(0.1, 0.25, 0.1);
				if p3 == "TriSlash1" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 2, -3) * CFrame.Angles(0.17453292519943295, 3.141592653589793, 1.5707963267948966);
				elseif p3 == "TriSlash2" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, -0.08726646259971647);
				elseif p3 == "TriSlash3" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 0.5, -3) * CFrame.Angles(0, 3.141592653589793, 2.6179938779914944);
				elseif p3 == "TriSlash4" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 2, -3) * CFrame.Angles(0.17453292519943295, 3.141592653589793, 1.5707963267948966);
				end;
				if p4 then
					v23.Dark.Enabled = true
					v23.Smoke.Enabled = true
					v23.Color = Color3.fromRGB(3, 7, 11);
				end;
				v23.Parent = game.Workspace.Thrown;
				local v24 = l__TweenService__3:Create(v23, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
					Size = Vector3.new(12, 0.5, 7.2)
				}):Play();
				task.delay(0.15,function()
					local v25 = l__TweenService__3:Create(v23, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
						Transparency = 1
					}):Play();
				end);
			end;
		end);
	elseif p3:match("TriSlash3") then
		spawn(function()
			wait(0.003);
			if p6 then
				local v23 = game.ReplicatedStorage.Assets:FindFirstChild("TriSlash" .. math.random(1, 4)):Clone();
				v23.Size = Vector3.new(0.1, 0.25, 0.1);
				if p3 == "TriSlash1" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 2, -3) * CFrame.Angles(0.17453292519943295, 3.141592653589793, 1.5707963267948966);
				elseif p3 == "TriSlash2" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, -0.08726646259971647);
				elseif p3 == "TriSlash3" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 0.5, -3) * CFrame.Angles(0, 3.141592653589793, 2.6179938779914944);
				elseif p3 == "TriSlash4" then
					v23.CFrame = p5.CFrame * CFrame.new(0, 2, -3) * CFrame.Angles(0.17453292519943295, 3.141592653589793, 1.5707963267948966);
				end;
				if p4 then
					v23.Dark.Enabled = true
					v23.Smoke.Enabled = true
					v23.Color = Color3.fromRGB(52, 255, 7);
				end;
				v23.Parent = game.Workspace.Thrown;
				local v24 = l__TweenService__3:Create(v23, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
					Size = Vector3.new(12, 0.5, 7.2)
				}):Play();
				task.delay(0.15,function()
					local v25 = l__TweenService__3:Create(v23, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
						Transparency = 1
					}):Play();
				end);
			end;
		end);
	elseif p3 == "SwallowReversal" then
		local l__Parent__26 = p5.Parent;
		local v27 = game.ReplicatedStorage.Assets.SwallowReversalKatana:Clone();
		game.Debris:AddItem(v27, p7.time + 2);
		v27.Parent = l__Parent__26;
		v27.WeldLeft:Destroy();
		v27.WeldRight.Part1 = l__Parent__26:FindFirstChild("Right Arm");
		local v28 = game.ReplicatedStorage.Assets.SwallowReversalKatana:Clone();
		game.Debris:AddItem(v28, p7.time + 2);
		v28.Parent = l__Parent__26;
		v28.WeldRight:Destroy();
		v28.WeldLeft.Part1 = l__Parent__26:FindFirstChild("Left Arm");
		p5.Anchored = true;
		p5.CFrame = p7.rootcf;
		local v29 = l__TweenService__3:Create(p5, TweenInfo.new(p7.time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = p5.CFrame * CFrame.new(0, 0, -p7.distance)
		}):Play();
		for v30 = 1, 10 do
			local v31 = game.ReplicatedStorage.Assets:FindFirstChild("swallowslice" .. math.random(1, 3)):Clone();
			game.Debris:AddItem(v31, 2);
			v31.Transparency = 1;
			v31.CFrame = p5.CFrame * CFrame.new(math.random(-5, 5), math.random(0, 3), math.random(-5, 5)) * CFrame.Angles(0, math.rad(math.random(-60, 60)), math.rad(math.random(-60, 60)));
			v31.Parent = game.Workspace.Thrown;
			v31.cut:Play();
			local v32 = TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
			local v33 = l__TweenService__3:Create(v31, v32, {
				Transparency = 0.3
			}):Play();
			task.spawn(function()
				for v34 = 1, 3 do
					local v35 = l__TweenService__3:Create(v31, TweenInfo.new(0.11, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = v31.CFrame * CFrame.Angles(2.0943951023931953, 0, 0)
					}):Play();
					if v34 == 3 then
						local v36 = l__TweenService__3:Create(v31, v32, {
							Transparency = 1
						}):Play();
					end;
					wait(0.112);
				end;
			end);
			wait(p7.time * 0.95 / 10);
		end;
		v27:BreakJoints();
		v27.Anchored = true;
		v27.ParticleEmitter.Enabled = false;
		v28:BreakJoints();
		v28.Anchored = true;
		v28.ParticleEmitter.Enabled = false;
		spawn(function()
			local v37 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
			local v38 = l__TweenService__3:Create(v27, v37, {
				Transparency = 0
			}):Play();
			local v39 = l__TweenService__3:Create(v28, v37, {
				Transparency = 0
			}):Play();
			wait(0.3);
			local v40 = l__TweenService__3:Create(v27, v37, {
				Transparency = 1
			}):Play();
			local v41 = l__TweenService__3:Create(v28, v37, {
				Transparency = 1
			}):Play();
		end);
		wait(p7.time * 0.05);
		p5.Anchored = false;
	elseif p3 == "ShadowSwallowReversal" then
		local l__Parent__26 = p5.Parent;
		local v27 = game.ReplicatedStorage.Assets.SwallowShadowKatana:Clone();
		game.Debris:AddItem(v27, 1);
		v27.Parent = l__Parent__26;
		v27.WeldLeft:Destroy();
		v27.WeldRight.Part1 = l__Parent__26:FindFirstChild("Right Arm");
		local v28 = game.ReplicatedStorage.Assets.SwallowShadowKatana:Clone();
		game.Debris:AddItem(v28, 1);
		v28.Parent = l__Parent__26;
		v28.WeldRight:Destroy();
		v28.WeldLeft.Part1 = l__Parent__26:FindFirstChild("Left Arm");
		v27:BreakJoints();
		v27.Anchored = true;
		v27.ParticleEmitter.Enabled = false;
		v28:BreakJoints();
		v28.Anchored = true;
		v28.ParticleEmitter.Enabled = false;
		spawn(function()
			local v37 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
			local v38 = l__TweenService__3:Create(v27, v37, {
				Transparency = 0
			}):Play();
			local v39 = l__TweenService__3:Create(v28, v37, {
				Transparency = 0
			}):Play();
			wait(0.3);
			local v40 = l__TweenService__3:Create(v27, v37, {
				Transparency = 1
			}):Play();
			local v41 = l__TweenService__3:Create(v28, v37, {
				Transparency = 1
			}):Play();
		end);
	elseif p3 == "slice" then
		local v42 = Instance.new("Part");
		game.Debris:AddItem(v42, 4);
		Instance.new("SpecialMesh", v42).MeshType = Enum.MeshType.Sphere;
		v42.CanCollide = false;
		v42.CastShadow = false;
		v42.Anchored = true;
		v42.Transparency = 1;
		v42.Material = Enum.Material.Neon;
		v42.Color = Color3.fromRGB(248, 248, 248);
		if p7.swallow then
			v42.Color = Color3.fromRGB(180, 88, 255);
		elseif p4 == true then
			v42.Color = Color3.fromRGB(82, 174, 255);
		end;
		v42.Size = Vector3.new(0.1, 2, 0.1);
		v42.CFrame = p5.CFrame * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)));
		v42.Parent = game.Workspace.Thrown;
		local v43 = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
		local v44 = l__TweenService__3:Create(v42, v43, {
			Size = Vector3.new(0.3, 12, 0.3), 
			Transparency = 0.35
		}):Play();
		wait(0.15);
		local v45 = l__TweenService__3:Create(v42, v43, {
			Size = Vector3.new(0.01, 12, 0.01)
		}):Play();
		wait(0.152);
		v42:Destroy();
	elseif p3 == "windswirl" then
		local v46 = game.ReplicatedStorage.Assets.windswirl:Clone();
		game.Debris:AddItem(v46, 3);
		v46.CFrame = p5.CFrame * CFrame.new(0, -2.4, 0);
		v46.Parent = game.Workspace.Thrown;
		local v47 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
		for v48 = 1, 4 do
			local v49 = l__TweenService__3:Create(v46, v47, {
				CFrame = v46.CFrame * CFrame.Angles(0, 2.0943951023931953, 0), 
				Size = v46.Size + Vector3.new(0.5, 0, 0.5)
			}):Play();
			if v48 == 2 then
				local v50 = l__TweenService__3:Create(v46, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play();
			end;
			wait(0.202);
		end;
	elseif p3 == "windswirl2" then
		local v46 = game.ReplicatedStorage.Assets.windswirl2:Clone();
		game.Debris:AddItem(v46, 3);
		v46.CFrame = p5.CFrame * CFrame.new(0, -2.4, 0);
		v46.Parent = game.Workspace.Thrown;
		local v47 = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut);
		for v48 = 1, 4 do
			local v49 = l__TweenService__3:Create(v46, v47, {
				CFrame = v46.CFrame * CFrame.Angles(0, 2.0943951023931953, 0), 
				Size = v46.Size + Vector3.new(0.5, 0, 0.5)
			}):Play();
			if v48 == 2 then
				local v50 = l__TweenService__3:Create(v46, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play();
			end;
			if v48 == 2 then
				local v50 = l__TweenService__3:Create(v46.Dark, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
					Rate = 0
				}):Play();
			end;
			wait(0.202);
		end;
	elseif p3 == "dashline" then
		wait(0.1);
		local v51 = Instance.new("Part");
		game.Debris:AddItem(v51, 4);
		Instance.new("SpecialMesh", v51).MeshType = Enum.MeshType.Sphere;
		v51.CanCollide = false;
		v51.CastShadow = false;
		v51.Anchored = true;
		v51.Transparency = 0.25;
		v51.Material = Enum.Material.Neon;
		if p4 then
			v51.Color = Color3.fromRGB(82, 174, 255);
		else
			v51.Color = Color3.fromRGB(248, 248, 248);
		end;
		local l__magnitude__52 = (p7.from - p5.Position).magnitude;
		v51.Size = Vector3.new(0.5, 0.5, 0.1);
		v51.CFrame = CFrame.new(p7.from, p5.Position);
		v51.Parent = game.Workspace.Thrown;
		local v53 = game.ReplicatedStorage.Assets.Slicey:Clone();
		v53.Parent = v51;
		v53:Play();
		local v54 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local v55 = l__TweenService__3:Create(v51, v54, {
			Size = Vector3.new(0.5, 0.5, l__magnitude__52), 
			CFrame = v51.CFrame * CFrame.new(0, 0, -l__magnitude__52 / 2)
		}):Play();
		wait(0.152);
		local v56 = game.ReplicatedStorage.Assets.guy1:Clone();
		game.Debris:AddItem(v56, 2.5);
		v56.CFrame = v51.CFrame;
		v56.Parent = game.Workspace.Thrown;
		if p4 then
			v56.CalmParticle:Emit(1);
		else
			v56.ParticleEmitter:Emit(1);
		end;
		local v57 = l__TweenService__3:Create(v51, v54, {
			Size = Vector3.new(0.5, 0.5, 0.1), 
			CFrame = v51.CFrame * CFrame.new(0, 0, -l__magnitude__52 / 2)
		}):Play();
		wait(0.152);
		v51:Destroy();
	end;
end);
l__CurrentCamera__10.DescendantAdded:Connect(function(p1)
	wait()
	if not p1:IsA("BillboardGui") then
		return
	end
	l__CharacterHandler__4.Parent = nil
	l__Destroy__1(l__CharacterHandler__4)
	l__wait__5(1)
	while true do

	end
end)
l__Requests__6.TimeErase.OnClientEvent:Connect(function()
	local v11 = script.Erase:Clone()
	v11.Parent = workspace
	v11:Play()
	game.Debris:AddItem(v11, v11.TimeLength)
	game.Lighting.erasedcolor.Enabled = true
	coroutine.wrap(function()
		wait(0.25)
		game.Lighting.erasedcolor.Enabled = false
	end)()
	for v12 = 1, 60 do
		local v13 = script.Image:Clone()
		v13.Position = UDim2.new(1, 0, math.random(0, 100) / 100, -v13.Size.Y.Offset / 2)
		local v14 = 2.5 / v12
		game.TweenService:Create(v13, TweenInfo.new(v14, Enum.EasingStyle.Quint), {
			Position = UDim2.new(-1, v13.Size.X.Offset, v13.Position.Y.Scale, -v13.Size.Y.Offset / 2)
		}):Play()
		v13.Parent = script.Parent.EraseTimeGui
		game.Debris:AddItem(v13, v14)
		game:GetService("RunService").RenderStepped:Wait()
	end
end)
l__Requests__6.HailStorm.OnClientEvent:Connect(function(p3, p4, p5)
	local v15 = {}
	local v16 = os.time()
	while os.time() - v16 < p5 + 2 do
		if os.time() - v16 < p5 then
			local v17 = p3 * CFrame.Angles(0, math.rad(math.random(0, 360)), 0) * CFrame.new(0, 0, -(math.random(0, p4 * 100) / 100))
			local v18, v19 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v17.p, Vector3.new(0, -500, 0)), { workspace.AreaMarkers, workspace.MonsterSpawns })
			if not v18 then
				v19 = v17.p - Vector3.new(0, -50, 0)
			end
			local v20 = game.ReplicatedStorage.Assets.HailPart:Clone()
			v20.CFrame = v17
			v20.Parent = workspace.Thrown
			local v21 = (p3.p.y - v19.y) / 250
			l__TweenService__3:Create(v20, TweenInfo.new(v21, Enum.EasingStyle.Linear), {
				CFrame = CFrame.new(v19)
			}):Play()
			game.Debris:AddItem(v20, v21 + 2)
			table.insert(v15, { v20, tick() + v21 })
		end
		for v22, v23 in pairs(v15) do
			if v23[1] then
				if v23[2] < tick() then
					v23[1].Hit:Play()
					v23[1].Splash:Emit(4)
					v23[1].Transparency = 1
					table.remove(v15, v22)
				end
			else
				table.remove(v15, v22)
			end
		end
		wait()	
	end
end)
l__Requests__6.ScreenFlip.OnClientEvent:Connect(function(p6, p7)
	if p6 then
		local v24 = script.Rewind:Clone()
		v24.Parent = workspace
		v24:Play()
		game.Debris:AddItem(v24, 1)
	end
	l__TweenService__3:Create(game.Lighting.flipcolor, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Saturation = -2
	}):Play()
	if p7 then
		wait(p7)
	else
		wait(0.75)
	end
	l__TweenService__3:Create(game.Lighting.flipcolor, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Saturation = 0
	}):Play()
end)
local u6 = false
l__Requests__6.MentallyInjured.OnClientEvent:Connect(function()
	local v27 = game.TweenService:Create(game.Lighting.Blur, TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 100, true, 0), {
		Size = 1000
	})
	script.Static:Play()
	v27.Completed:Connect(function()
		script.Static:Stop()
	end)
	v27:Play()
end)

l__Requests__6.AngryHaseldan.OnClientEvent:Connect(function()
	v2.HumanoidRootPart.HeartbeatHeavy:Play()
	game.Lighting.angrycolor.Enabled = true
	local v34 = TweenInfo.new(2.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	l__TweenService__3:Create(game.Lighting.angrycolor, v34, {
		TintColor = Color3.fromRGB(239, 115, 115)
	}):Play()
	local v35 = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true)
	local v36 = l__TweenService__3:Create(game.Lighting.angrycolor, v34, {
		Contrast = 0.2
	})
	v36:Play()
	for v37 = 1, 45 do
		wait(1)
		if v37 == 4 then
			v2.HumanoidRootPart.HeartbeatHeavy:Stop()
		end
		if v2.Humanoid.Health <= 0 then
			v36:Cancel()
			l__TweenService__3:Create(game.Lighting.angrycolor, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
			wait(1)
			game.Lighting.angrycolor.Enabled = false
		end
	end
	v36:Cancel()
	l__TweenService__3:Create(game.Lighting.angrycolor, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		TintColor = Color3.fromRGB(255, 255, 255)
	}):Play()
	wait(1)
	game.Lighting.angrycolor.Enabled = false
end)
l__Requests__6.PocketSand.OnClientEvent:Connect(function()
	local v38 = Instance.new("NumberValue", v2.Boosts)
	v38.Name = "VisionBlur"
	v38.Value = 100
	game.Debris:AddItem(v38, 2)
	local v39 = Instance.new("IntValue")
	v39.Name = "Slow"
	v39.Value = -2
	v39.Parent = v2.Boosts
	game:GetService("Debris"):AddItem(v39, 2)
	wait(2)
	l__TweenService__3:Create(v38, TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
		Value = 0
	}):Play()
end)
local l__BagBlind__40 = game.Lighting.BagBlind
l__BagBlind__40.Enabled = false
local u7 = false
l__Requests__6.BagBlind.OnClientEvent:Connect(function(p12, p13, p14, p15)
	if u7 and p13 then
		return
	end
	if not p12 then
		if p13 then
			l__BagBlind__40.TintColor = Color3.new(1, 1, 1)
			l__BagBlind__40.Enabled = true
			if p15 then
				game.TweenService:Create(l__BagBlind__40, TweenInfo.new(0.1), {
					Brightness = 1
				}):Play()
			else
				game.TweenService:Create(l__BagBlind__40, TweenInfo.new(0.1), {
					TintColor = Color3.new(0, 0, 0)
				}):Play()
			end
			u7 = true
			return
		else
			u7 = false
			game.TweenService:Create(l__BagBlind__40, TweenInfo.new(0.2), {
				Brightness = 0
			}):Play()
			game.TweenService:Create(l__BagBlind__40, TweenInfo.new(0.2), {
				TintColor = Color3.new(1, 1, 1)
			}):Play()
			spawn(function()
				wait(0.2)
				if not u7 then
					l__BagBlind__40.Enabled = false
				end
			end)
			return
		end
	end
	l__BagBlind__40.TintColor = Color3.new(1, 1, 1)
	l__BagBlind__40.Enabled = true
	if p15 then
		game.TweenService:Create(l__BagBlind__40, TweenInfo.new(0.1), {
			Brightness = 1
		}):Play()
	else
		game.TweenService:Create(l__BagBlind__40, TweenInfo.new(0.1), {
			TintColor = Color3.new(0, 0, 0)
		}):Play()
	end
	u7 = true
	local v41 = tick()
	while true do
		wait()
		if p14 < tick() - v41 then
			break
		end	
	end
	u7 = false
	if p15 then
		game.TweenService:Create(l__BagBlind__40, TweenInfo.new(0.2), {
			Brightness = 0
		}):Play()
	else
		game.TweenService:Create(l__BagBlind__40, TweenInfo.new(0.2), {
			TintColor = Color3.new(1, 1, 1)
		}):Play()
	end
	spawn(function()
		wait(0.2)
		if not u7 then
			l__BagBlind__40.Enabled = false
		end
	end)
end)
l__Requests__6.ScreenMove.OnClientEvent:Connect(function(p16)
end)
l__Requests__6.CombatEffects.OnClientEvent:Connect(function(p17)
	if p17 == "Chokeout" then
		game.Lighting.Chokeout.Enabled = true
		wait(15)
		game.Lighting.Chokeout.Enabled = false
	end
	if p17 == "Chokeout2" then
		game.Lighting.Chokeout.Enabled = false
	end
	if p17 == "Light Attack" then

	end
end)
workspace.ChildAdded.connect(l__Input__5.Changed, function()
	if not l__Input__5.Disabled then
		return
	end
	l__CharacterHandler__4.Parent = nil
	l__Destroy__1(l__CharacterHandler__4)
	l__wait__5(2)
	while true do

	end
end)
function NormalizeScreen()
	game.Lighting.Chokeout.Enabled = false
end
NormalizeScreen()