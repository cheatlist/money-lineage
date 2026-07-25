local module = {}

function module.spindulys(Character,p4,color)
	local plr = game.Players:GetPlayerFromCharacter(Character)
	color = plr.Backpack.ManaColor.Value
	local effects = script.Parent
	local crystalclone = effects.Crystal:Clone()
	crystalclone.Color = color
	local chargeball = effects.ChargeBall:Clone()
	chargeball.Color = color 
	chargeball.Parent = workspace.Thrown
	chargeball.CFrame = Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
	chargeball.Size = Vector3.new(0.1,0.1,0.1)
	chargeball.Arrow:Play()
	game:GetService("TweenService"):Create(chargeball,TweenInfo.new(1.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Size = Vector3.new(2,2,2)}):Play()
	wait(1.5)
	game:GetService("TweenService"):Create(chargeball,TweenInfo.new(1,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Size = Vector3.new(0.01,0.01,0.01)}):Play()
	local beam = effects.Beam:Clone()
	beam.Parent = workspace.Thrown
	beam.Color = color 
	beam.CFrame = chargeball.CFrame
	beam.Size = Vector3.new(1,1,1)
	local u9 = _G.MouseData(plr)
	if not u9 then
		chargeball:Destroy()
		beam:Destroy()
		return
	end
	beam.Valuee.Value = 1
	game:GetService("TweenService"):Create(beam.Valuee,TweenInfo.new(5,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Value = 0.001}):Play()
	beam.CFrame = CFrame.new(beam.Position,u9.Hit.p)
	beam.CFrame = beam.CFrame + beam.CFrame.LookVector *0.5
	local startpos = beam.Position
	local bl = {Character}
	beam.Touched:Connect(function() end)
	while true do task.wait(1/30)
		beam.Size = beam.Size + Vector3.new(0,0,8)
		beam.Size = Vector3.new(beam.Valuee.Value,beam.Valuee.Value,beam.Size.Z)
		beam.CFrame = beam.CFrame + beam.CFrame.LookVector * 4
		local ray = Ray.new(beam.Position,beam.CFrame.LookVector * ((beam.Size.Z/2)+2))
		local part,pos,norm = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Thrown,workspace.Live,workspace.AreaMarkers},false,true)
		local people = beam:GetTouchingParts()
		for i,v in pairs(people) do 
			if v:IsDescendantOf(workspace.Live) then 
				if not table.find(bl,v.Parent) and v.Parent:FindFirstChild("Humanoid") then
					table.insert(bl,v.Parent)
					game.ServerStorage.Requests.TagHumanoid:Fire(Character, v.Parent, {
						mana = true, 
						damage = 25, 
						manaknockup = 60, 
					})
				end
			end
		end
		if beam.Size.X <= 0.01 or beam.Size.Z >= (startpos-u9.Hit.p).magnitude or part then
			coroutine.wrap(function()
				while true do task.wait(1/30)
					beam.Size = Vector3.new(beam.Valuee.Value,beam.Valuee.Value,beam.Size.Z)
					if beam.Size.X <= 0.01 then 
						beam:Destroy()
						chargeball:Destroy()

						break
					end
				end
			end)()
			if part then 
				for i = 1,Random.new(math.random(1,1000000)):NextInteger(8,12) do
					local random = math.random
					local crystal = effects.Crystal:Clone()
					crystal.Color = color
					crystal.Parent = workspace.Thrown
					crystal.CFrame = CFrame.new(pos,pos+norm) * CFrame.Angles(math.rad(-90),0,0) * CFrame.Angles(math.rad(Random.new(random(1,10000)):NextInteger(-45,45)),0,math.rad(Random.new(random(1,10000)):NextInteger(-45,45)))
					local yes = crystal.CFrame
					local random1  = Random.new(math.random(1,1000000)):NextNumber(10,25)
					game:GetService("TweenService"):Create(crystal,TweenInfo.new(0.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Size = Vector3.new(random1,random1,random1),CFrame = yes + yes.UpVector*(random1/2)}):Play()
				end	
				for i,v in pairs(workspace.Live:GetChildren()) do 
					if v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position-pos).magnitude <= 25 then 
						game.ServerStorage.Requests.TagHumanoid:Fire(Character, v, {
							mana = true, 
							damage = 25, 
							manaknockup = 60, 
							manaknockupself = true, 
						})
					end
				end
				break
			end
			break
		end
	end
end

function module.mirgeti(Character,p4,color)
	local plr = game.Players:GetPlayerFromCharacter(Character)
	color = plr.Backpack.ManaColor.Value
	local u9 = _G.MouseData(plr)
	if not u9 then
		return
	end
end

return module
