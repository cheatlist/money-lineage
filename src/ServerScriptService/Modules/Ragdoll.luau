--// extreme#3007

local module = {}

local Ragdoll_Constraints = script:WaitForChild("Ragdoll_Constraints")

local Socket_Neck = Instance.new("BallSocketConstraint")
Socket_Neck.Name = "SocketNeck"
Socket_Neck.LimitsEnabled = true
Socket_Neck.Restitution = 0
Socket_Neck.TwistLimitsEnabled = true
Socket_Neck.UpperAngle = 60
Socket_Neck.TwistLowerAngle = -40
Socket_Neck.TwistUpperAngle = 40
Socket_Neck.Parent = Ragdoll_Constraints

local Socket_LeftHip = Instance.new("BallSocketConstraint")
Socket_LeftHip.Name = "SocketLeft Hip"
Socket_LeftHip.LimitsEnabled = true
Socket_LeftHip.Restitution = 0
Socket_LeftHip.TwistLimitsEnabled = true
Socket_LeftHip.UpperAngle = 70
Socket_LeftHip.TwistLowerAngle = -5
Socket_LeftHip.TwistUpperAngle = 80
Socket_LeftHip.Parent = Ragdoll_Constraints

local Socket_LeftShoulder = Instance.new("BallSocketConstraint")
Socket_LeftShoulder.Name = "SocketLeft Shoulder"
Socket_LeftShoulder.LimitsEnabled = true
Socket_LeftShoulder.Restitution = 0
Socket_LeftShoulder.TwistLimitsEnabled = true
Socket_LeftShoulder.UpperAngle = 140
Socket_LeftShoulder.TwistLowerAngle = -85
Socket_LeftShoulder.TwistUpperAngle = 80
Socket_LeftShoulder.Parent = Ragdoll_Constraints

local Socket_RightHip = Instance.new("BallSocketConstraint")
Socket_RightHip.Name = "SocketRight Hip"
Socket_RightHip.LimitsEnabled = true
Socket_RightHip.Restitution = 0
Socket_RightHip.TwistLimitsEnabled = true
Socket_RightHip.UpperAngle = 70
Socket_RightHip.TwistLowerAngle = -5
Socket_RightHip.TwistUpperAngle = 80
Socket_RightHip.Parent = Ragdoll_Constraints

local Socket_RightShoulder = Instance.new("BallSocketConstraint")
Socket_RightShoulder.Name = "SocketRight Shoulder"
Socket_RightShoulder.LimitsEnabled = true
Socket_RightShoulder.Restitution = 0
Socket_RightShoulder.TwistLimitsEnabled = true
Socket_RightShoulder.UpperAngle = 140
Socket_RightShoulder.TwistLowerAngle = -85
Socket_RightShoulder.TwistUpperAngle = 80
Socket_RightShoulder.Parent = Ragdoll_Constraints

local Create = {
	Neck = function(Character)
		if not Character:FindFirstChild("Torso") then return end
		if not Character.Torso:FindFirstChild("Neck") then return end
		if not Character:FindFirstChild("Head") then return end

		Character.Torso.Neck.Part0 = nil
		local TorsoAttach = Instance.new("Attachment")
		TorsoAttach.Name = "RagdollAttach"
		TorsoAttach.Position = Vector3.new(0, 1, 0)
		TorsoAttach.Orientation = Vector3.new(-90, -180, 0)
		TorsoAttach.Parent = Character.Torso
		local RagdollAttach = Instance.new("Attachment")
		RagdollAttach.Name = "RagdollAttach"
		RagdollAttach.Position = Vector3.new(0, -0.5, 0)
		RagdollAttach.Orientation = Vector3.new(-90, -180, 0)
		RagdollAttach.Parent = Character.Head
		local Constraint = Socket_Neck:Clone()
		Constraint.Attachment0 = TorsoAttach
		Constraint.Attachment1 = RagdollAttach
		Constraint.Parent = Character.Torso
	end;
	["Left Hip"] = function(Character)
		if not Character:FindFirstChild("Torso") then return end
		if not Character.Torso:FindFirstChild("Left Hip") then return end
		if not Character:FindFirstChild("Left Leg") then return end

		Character.Torso["Left Hip"].Part0 = nil
		local TorsoAttach = Instance.new("Attachment")
		TorsoAttach.Name = "RagdollAttach"
		TorsoAttach.Position = Vector3.new(-1, -1, 0)
		TorsoAttach.Orientation = Vector3.new(0, -90, 0)
		TorsoAttach.Parent = Character.Torso
		local RagdollAttach = Instance.new("Attachment")
		RagdollAttach.Name = "RagdollAttach"
		RagdollAttach.Position = Vector3.new(-0.5, 1, 0)
		RagdollAttach.Orientation = Vector3.new(0, -90, 0)
		RagdollAttach.Parent = Character["Left Leg"]
		local Constraint = Socket_LeftHip:Clone()
		Constraint.Attachment0 = TorsoAttach
		Constraint.Attachment1 = RagdollAttach
		Constraint.Parent = Character.Torso
	end;
	["Left Shoulder"] = function(Character)
		if not Character:FindFirstChild("Torso") then return end
		if not Character.Torso:FindFirstChild("Left Shoulder") then return end
		if not Character:FindFirstChild("Left Arm") then return end

		Character.Torso["Left Shoulder"].Part0 = nil
		local TorsoAttach = Instance.new("Attachment")
		TorsoAttach.Name = "RagdollAttach"
		TorsoAttach.Position = Vector3.new(-1, 0.5, 0)
		TorsoAttach.Orientation = Vector3.new(0, -90, 0)
		TorsoAttach.Parent = Character.Torso
		local RagdollAttach = Instance.new("Attachment")
		RagdollAttach.Name = "RagdollAttach"
		RagdollAttach.Position = Vector3.new(0.5, 0.5, 0)
		RagdollAttach.Orientation = Vector3.new(0, -90, 0)
		RagdollAttach.Parent = Character["Left Arm"]
		local Constraint = Socket_LeftShoulder:Clone()
		Constraint.Attachment0 = TorsoAttach
		Constraint.Attachment1 = RagdollAttach
		Constraint.Parent = Character.Torso
	end;
	["Right Hip"] = function(Character)
		if not Character:FindFirstChild("Torso") then return end
		if not Character.Torso:FindFirstChild("Right Hip") then return end
		if not Character:FindFirstChild("Right Leg") then return end

		Character.Torso["Right Hip"].Part0 = nil
		local TorsoAttach = Instance.new("Attachment")
		TorsoAttach.Name = "RagdollAttach"
		TorsoAttach.Position = Vector3.new(1, -1, 0)
		TorsoAttach.Orientation = Vector3.new(0, 90, 0)
		TorsoAttach.Parent = Character.Torso
		local RagdollAttach = Instance.new("Attachment")
		RagdollAttach.Name = "RagdollAttach"
		RagdollAttach.Position = Vector3.new(0.5, 1, 0)
		RagdollAttach.Orientation = Vector3.new(0, 90, 0)
		RagdollAttach.Parent = Character["Right Leg"]
		local Constraint = Socket_RightHip:Clone()
		Constraint.Attachment0 = TorsoAttach
		Constraint.Attachment1 = RagdollAttach
		Constraint.Parent = Character.Torso
	end;
	["Right Shoulder"] = function(Character)
		if not Character:FindFirstChild("Torso") then return end
		if not Character.Torso:FindFirstChild("Right Shoulder") then return end
		if not Character:FindFirstChild("Right Arm") then return end

		Character.Torso["Right Shoulder"].Part0 = nil
		local TorsoAttach = Instance.new("Attachment")
		TorsoAttach.Name = "RagdollAttach"
		TorsoAttach.Position = Vector3.new(1, 0.5, 0)
		TorsoAttach.Orientation = Vector3.new(0, 90, 0)
		TorsoAttach.Parent = Character.Torso
		local RagdollAttach = Instance.new("Attachment")
		RagdollAttach.Name = "RagdollAttach"
		RagdollAttach.Position = Vector3.new(-0.5, 0.5, 0)
		RagdollAttach.Orientation = Vector3.new(0, 90, 0)
		RagdollAttach.Parent = Character["Right Arm"]
		local Constraint = Socket_RightShoulder:Clone()
		Constraint.Attachment0 = TorsoAttach
		Constraint.Attachment1 = RagdollAttach
		Constraint.Parent = Character.Torso
	end;
}

local Players = game:GetService("Players")

local SetNetwork = function(Character, Parts, Option)
	if not Character then
		return
	end
	if not Parts then
		for _, Child in pairs(Character:GetChildren()) do
			if not Child:IsA("BasePart") or Child :IsA("BasePart") and not Child:CanSetNetworkOwnership() then
				continue
			end
			Child:SetNetworkOwner(nil)
		end
	end
	if typeof(Parts) == "string" then
		for _, Child in pairs(Character:GetChildren()) do
			if not Child:IsA("BasePart") or Child :IsA("BasePart") and not Child:CanSetNetworkOwnership() then
				continue
			end
			Child:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
		end
	elseif typeof(Parts) == "table" then
		for _, Child in pairs(Parts) do
			if not Child:IsA("BasePart") or Child :IsA("BasePart") and not Child:CanSetNetworkOwnership() then
				continue
			end
			if Option == "Player" then
				Option = Players:GetPlayerFromCharacter(Character)
			end
			Child:SetNetworkOwner(Option)
		end
	end
end

local function weldTogether(Clone, Part)
	local Weld = Instance.new("Weld")
	Weld.Part0 = Clone
	Weld.Part1 = Part
	local CloneCFrame = CFrame.new(Clone.Position)
	Weld.C0 = Clone.CFrame:Inverse() * CloneCFrame
	Weld.C1 = Part.CFrame:Inverse() * CloneCFrame
	Weld.Parent = Clone
end

local Sockets = {
	Neck = {
		UpperAngle = 60,
		TwistLowerAngle = -40,
		TwistUpperAngle = 40,
	},
	Shoulder = {
		UpperAngle = 140,
		TwistLowerAngle = -85,
		TwistUpperAngle = 85,
	},
	Hip = {
		UpperAngle = 70,
		TwistLowerAngle = -5,
		TwistUpperAngle = 80,
	},
}

local Bones = {}
local Parts = {}

function module.Ragdoll(Character,Set, carry)
	local Torso = Character:FindFirstChild("Torso")
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	local Player = game:GetService("Players"):GetPlayerFromCharacter(Character)
	if not Torso then return warn(tostring(Character),"did not have an existing torso when attempting to ragdoll them") end
	if not Humanoid then return warn(tostring(Character),"did not have an existing humanoid when attempting to ragdoll them") end
	if not HumanoidRootPart then return warn(tostring(Character),"did not have an existing humanoidrootpart when attempting to ragdoll them") end
	if Set then
		if game.CollectionService:HasTag(Character, "IsRagdolled") or game.CollectionService:HasTag(Character, "Unragdolling") then
			return
		end
		if game.CollectionService:HasTag(Character, "GettingUp") then
			for i,v in pairs(Character:GetChildren()) do
				if v.Name == "Knocked" or v.Name == "Unconscious" then
					v:Destroy()
				end
			end
			return
		end
		game.CollectionService:AddTag(Character, "IsRagdolled")
		if Character:FindFirstChild("Boosts") and not Character.Boosts:FindFirstChild("TightHood") and Character:FindFirstChild("Hood") then
			local Character_Children = Character:GetChildren()
			for Index = 1,#Character_Children do
				local Object = Character_Children[Index]
				if string.find(tostring(Object.Name),"Hood") then
					Object.Parent = nil
				end
			end
		end
		Humanoid.PlatformStand = true
		Humanoid.RequiresNeck = false
		Humanoid.AutoRotate = false
		
		Parts = {}
		
		for _, instance in pairs(Character:GetChildren()) do
			if not instance:IsA("BasePart") then
				continue
			end
			local networkOwner = instance:CanSetNetworkOwnership() and instance:GetNetworkOwner()
			if not networkOwner then
				networkOwner = nil
			end

			local Clone = instance:Clone()
			Clone:ClearAllChildren()
			Clone.Transparency = 1
			Clone.Name = "Bone"
			Clone.Size = Clone.Size * 0.5
			Clone.CanCollide = true
			weldTogether(Clone, instance)
			Clone.Parent = instance

			if Clone:CanSetNetworkOwnership() then
				pcall(function()
					Clone:SetNetworkOwner(nil)
				end)
			end
			if instance:CanSetNetworkOwnership() then
				pcall(function()
					instance:SetNetworkOwner(nil)
				end)
			end
			table.insert(Parts, instance)
		end

		Bones = {}

		if Character:FindFirstChild("Torso") then
			for _, instance in pairs(Character.Torso:GetChildren()) do
				if not instance:IsA("Motor6D") then
					continue
				end
				local Part0 = instance.Part0
				local Part1 = instance.Part1

				local RagdollAttach0 = Instance.new("Attachment")
				RagdollAttach0.Name = "RagdollAttach"
				RagdollAttach0.Parent = Part0
				RagdollAttach0.CFrame = instance.C0
				game:GetService("CollectionService"):AddTag(RagdollAttach0, "RagdollAttach")

				local RagdollAttach1 = Instance.new("Attachment")
				RagdollAttach1.Name = "RagdollAttach"
				RagdollAttach1.Parent = Part1
				RagdollAttach1.CFrame = instance.C1
				game:GetService("CollectionService"):AddTag(RagdollAttach1, "RagdollAttach")

				local BallSocketConstraint = Instance.new("BallSocketConstraint")
				BallSocketConstraint.Attachment0 = RagdollAttach0
				BallSocketConstraint.Attachment1 = RagdollAttach1

				Bones[RagdollAttach1] = true
				Bones[RagdollAttach0] = true
				Bones[BallSocketConstraint] = true

				local socketLimit
				if instance.Name:match("Neck") then
					socketLimit = Sockets.Neck
				elseif instance.Name:match("Shoulder") then
					socketLimit = Sockets.Shoulder
				elseif instance.Name:match("Hip") then
					socketLimit = Sockets.Hip
				end

				if socketLimit then
					BallSocketConstraint.LimitsEnabled = true
					BallSocketConstraint.TwistLimitsEnabled = true
					BallSocketConstraint.UpperAngle = socketLimit.UpperAngle
					BallSocketConstraint.TwistUpperAngle = socketLimit.TwistUpperAngle
					BallSocketConstraint.TwistLowerAngle = socketLimit.TwistLowerAngle
				end

				BallSocketConstraint.Name = "Socket" .. instance.Name
				BallSocketConstraint.Parent = instance.Parent
				instance.Part0 = nil
			end
		end
	else
		game.CollectionService:AddTag(Character, "GettingUp")
		game.CollectionService:RemoveTag(Character, "IsRagdolled")
		Humanoid.PlatformStand = false
		Humanoid.RequiresNeck = false
		Humanoid.AutoRotate = true
		local Character_Descendants = Character:GetDescendants()
		local noBone = false
		
		for _, Child in Character:GetDescendants() do
			if Child:IsA("BasePart") then
				for _, Value in Child:GetDescendants() do
					if Value.Name == "Bone" or Value.Name == "RagdollAttach" then
						Value:Destroy()
					end
				end
			end
		end

		for _, Child in Torso:GetChildren() do
			if Child:IsA("BallSocketConstraint") or Child.Name == "RagdollAttach" then
				Child:Destroy()
			elseif Child:IsA("Motor6D") then
				Child.Part0 = Torso
				Child.Enabled = true
			end
		end

		SetNetwork(Character, "Player")
		
		local BodyGyro = script.BodyGyro:Clone()
		BodyGyro.Parent = Character.HumanoidRootPart
		game.Debris:AddItem(BodyGyro, 0.4)
		
		wait(0.1)
		game.CollectionService:RemoveTag(Character, "GettingUp")
		if BodyGyro then
			BodyGyro:Destroy()
		end
	end
end

return module