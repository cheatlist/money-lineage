local module = {}

local wait = task.wait
local cool = false
local l__TweenService__3 = game:GetService("TweenService")

function LIGHTNING(p1, p2, p3, p5, p6)
	local v6 = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local l__lookVector__7 = CFrame.new(p1, p2).LookVector
	local v8 = (p1 - p2).Magnitude / p3
	local v9 = p1
	local v10 = 1 - 1
	while true do
		local v11 = game.ServerStorage.Assets.LightningPart2:Clone()
		v11.FormFactor = "Symmetric"
		v11.Size = Vector3.new(1, 1, 1)
		v11.CanCollide = false
		v11.Transparency = 0.2
		v11.Anchored = true
		v11.Material = Enum.Material.Neon
		v11.Color = p6

		local v12 = CFrame.new(p1 + l__lookVector__7 * (v10 * v8), p2 + l__lookVector__7) * CFrame.new(math.random(-100, 100) / 100 * v8 / 2, math.random(-100, 100) / 100 * v8 / 2, 0)
		local l__magnitude__13 = (v12.p - v9).Magnitude
		local v14 = Instance.new("BlockMesh", v11)
		v14.Scale = Vector3.new(p5, p5, l__magnitude__13 + p5 / 4)
		v11.CFrame = CFrame.new((v12.p + v9) / 2, v12.p)
		v9 = v12.p
		v11.Parent = game.Workspace
		wait()
		l__TweenService__3:Create(v14, v6, {
			Scale = Vector3.new(p5 * 2, p5 * 2, l__magnitude__13 + p5 / 4)
		}):Play()
		l__TweenService__3:Create(v11, v6, {
			Transparency = 1
		}):Play()
		game.Debris:AddItem(v11, 0.8)
		if 0 <= 1 then
			if v10 < p3 then

			else
				break
			end
		elseif p3 < v10 then

		else
			break
		end
		v10 = v10 + 1	
	end
end

function module.Active(Player)
	if cool == false then
		cool = true
		coroutine.wrap(function()
			wait(15)
			cool = false
		end)()
		local white = Color3.new(1, 1, 1)
		local lightBlue = Color3.new(0, 2/3, 1)
		local yellow = Color3.new(1, 1, 0)
		local action = Instance.new("Accessory");
		action.Name = "Action";
		action.Parent = Player;
		local Sound = script.Parent.LightningHit:Clone()
		Sound.Parent = Player.HumanoidRootPart
		Sound:Play()
		game.Debris:AddItem(Sound, 5)
		local anim = Player.Humanoid:LoadAnimation(script.Parent.Leap)
		anim:Play()
		for i, track in pairs (Player.Humanoid:GetPlayingAnimationTracks()) do
			if track.Name == "GrabLand" then
				anim:Stop()
			end
		end
		local OldPos = Player.HumanoidRootPart.Position
		local lightningParticle = game.ReplicatedStorage.Assets.Lightning:clone()
		lightningParticle.Parent = Player.HumanoidRootPart
		lightningParticle.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, white),
			ColorSequenceKeypoint.new(0.25, lightBlue),
			ColorSequenceKeypoint.new(0.5, white),
			ColorSequenceKeypoint.new(0.75, yellow),
			ColorSequenceKeypoint.new(1, white)
		}
		game.Debris:AddItem(lightningParticle,1)
		for _,part in pairs(Player:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				local pticle = game.ReplicatedStorage.Assets:WaitForChild("Electric"):clone()
				pticle.Enabled = true
				pticle.Parent = part
				pticle.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, white),
					ColorSequenceKeypoint.new(0.25, lightBlue),
					ColorSequenceKeypoint.new(0.5, white),
					ColorSequenceKeypoint.new(0.75, yellow),
					ColorSequenceKeypoint.new(1, white)
				}
				delay(0.5,function()
					pticle.Enabled = false
				end)
				game.Debris:AddItem(pticle,1)
			end
		end
		wait(.5)
		local Sound = script.Parent.ThunderingLeap:Clone()
		Sound.Parent = Player.HumanoidRootPart
		Sound:Play()
		game.Debris:AddItem(Sound, 5)
		Player.HumanoidRootPart.CFrame = Player.HumanoidRootPart.CFrame * CFrame.new(0,100,-100)
		local NewPos = Player.HumanoidRootPart.Position
		spawn(function()
			LIGHTNING(OldPos, NewPos, 2.85, 3.55, game.ServerStorage.PlayerData[Player.Name].ManaColor.Value);
		end)
		action:Destroy()
	end
end

return module;