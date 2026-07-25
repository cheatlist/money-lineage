return function(Player, Humanoid, HumanoidRootPart, PlayerData, RunService, getCharacter, setCharacter)
	local CFramesSaved = {}

	local Bypasses = {"FlightOk", "TPSafe", "ManaFlying"}

	local lastCF = nil

	local function CheckForTags()
		local TargetTag, isTag = Player.Character, false
		for _, BypassTag in pairs(Bypasses) do
			if (TargetTag:FindFirstChild(BypassTag)) then

				for i = 1,#CFramesSaved do
					table.remove(CFramesSaved, math.abs(1-#CFramesSaved) + 1);
				end
				lastCF = getCharacter().HumanoidRootPart.CFrame;
				isTag = true
				break
			end
		end
		return isTag
	end

	local function TriggerAA()
		coroutine.wrap(function()
			local Alarm = Instance.new("Sound")
			Alarm.Name = "Alarm"
			Alarm.SoundId = "rbxassetid://8268306342"
			Alarm.Looped = true
			Alarm.Volume = 0.05
			Alarm.Parent = HumanoidRootPart
			Alarm:Play()

			local Gun = Instance.new('Sound')
			Gun.SoundId = "rbxassetid://2452480039"
			Gun.Volume = 4
			Gun.Parent = HumanoidRootPart

			pcall(function()
				task.wait(3.34299)

				Alarm:Destroy()
				Gun:Play()

				if Player and Player.Character then
					--Player.Character:BreakJoints();
					warn("AA Activated.")
				end
			end)

		end)()
	end

	local AAVariables = {
		TimeToShoot = 60,
		Timer = 0,
		Shot = false
	}

	local s = RunService.Heartbeat:Connect(function()
		local Character = getCharacter()
		if not Character or not Character.PrimaryPart or not Humanoid then
			if Character then
				Character:BreakJoints()
			end
			return
		end
		if not Character:FindFirstChild("AngelForm") then
			local Part, endPoint = workspace:FindPartOnRayWithIgnoreList(Ray.new(HumanoidRootPart.Position, Vector3.new(0, -15, 0)), {Player.Character, workspace.Thrown, workspace.AreaMarkers}, false, false)
			if not Part and not CheckForTags() and Humanoid:GetState() ~= Enum.HumanoidStateType.Swimming and Player.Character.IsClimbing.Value == false then
				AAVariables.Timer = math.min(AAVariables.TimeToShoot, AAVariables.Timer+0.025)
			else
				AAVariables.Timer = math.max(0, AAVariables.Timer-0.025)
			end
			if AAVariables.Timer >= AAVariables.TimeToShoot and not AAVariables.Shot then
				AAVariables.Shot = true
				TriggerAA()
			end
		end
		if (Character.HumanoidRootPart.Position - Vector3.new(0,100,0)).magnitude < 50 then
			if PlayerData.Lives.Value > 0 then
				local spawns = game.ServerStorage.SpawnPoints[PlayerData.SpawnPoint.Value]:GetChildren()
				local tpcf = spawns[math.random(1,#spawns)].CFrame
				Character:PivotTo(tpcf * CFrame.new(0,2,0))
			else
				Character:PivotTo(workspace.SolanSpawn.CFrame)
			end
		end
		task.wait()
	end)

	local lastCFrame = HumanoidRootPart.CFrame

	task.spawn(function()
		while task.wait(0.5) do
			local Character = Player.Character
			setCharacter(Character)
			if not Character or not HumanoidRootPart then
				return
			end
			if not Character.PrimaryPart then
				Character:BreakJoints()
				return
			end
			if (lastCF == nil) then
				lastCF = HumanoidRootPart.CFrame
			end
			if not CheckForTags() then
				if math.floor((Vector3.new(lastCF.p.X, 0, lastCF.p.Z) - Vector3.new(HumanoidRootPart.Position.X, 0, HumanoidRootPart.Position.Z)).Magnitude) >= 150 then
					if #CFramesSaved <= 0 then
						return
					end
					Character:PivotTo(CFramesSaved[1])
				end
			end
			if #CFramesSaved >= 6 then
				table.remove(CFramesSaved, 1)
			end
			table.insert(CFramesSaved, HumanoidRootPart.CFrame)
			lastCF = HumanoidRootPart.CFrame
		end
	end)
end
