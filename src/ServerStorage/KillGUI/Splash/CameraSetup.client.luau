local FoundTarget = game.Players:GetPlayerFromCharacter(script.Parent.Player.Value)
local LifeSentences = {"Your life has been cruelly taken by ", "Your life has been brutally taken by "}

if FoundTarget then
	local KillerPlayerTxt = script.Parent:WaitForChild("KillerPlayer")
	local KillerCharacter = script.Parent:WaitForChild("KillerCharacter")
	local Prompt = script.Parent:WaitForChild("Prompt")
	local Viewport = script.Parent:WaitForChild("HeadShot")

	Prompt.Text = LifeSentences[math.random(1, #LifeSentences)]

	KillerPlayerTxt.Text = "("..FoundTarget.Character.Name.." | "..FoundTarget.UserId..")"
	KillerCharacter.Text = FoundTarget.Character.Humanoid.DisplayName

	FoundTarget.Character.Archivable = true

	local TargetCharacter = FoundTarget.Character:Clone()

	FoundTarget.Character.Archivable = true

	TargetCharacter.Parent = workspace.Thrown
	TargetCharacter:SetPrimaryPartCFrame(CFrame.new())
	TargetCharacter:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(TargetCharacter.HumanoidRootPart.Position) * CFrame.Angles(0,math.rad(-180),0)

	for _, bodypart in pairs(TargetCharacter:GetChildren()) do
		pcall(function()
			if bodypart:IsA("BasePart") or bodypart:IsA("Accessory") then
				if string.find(bodypart.Name, "Leg") or string.find(bodypart.Name, "Arm") or bodypart.Name == "Torso" then
					bodypart.Transparency = 1
                    --[[bodypart:Destroy()
                    bodypart:ClearAllChildren() ]]
				end
			end
		end)
	end

	local l__HeadShot__1 = script.Parent:WaitForChild("HeadShot");
	TargetCharacter.Parent = l__HeadShot__1
	if l__HeadShot__1 then
		local v2 = Instance.new("Camera");
		v2.FieldOfView = 50;
		v2.CFrame = CFrame.new(Vector3.new(0, 0.25, -3), Vector3.new());
		v2.Parent = l__HeadShot__1;
		l__HeadShot__1.CurrentCamera = v2;
	end;
end