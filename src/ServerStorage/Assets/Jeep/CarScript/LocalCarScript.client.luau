local userInputService = game:GetService("UserInputService")
local camera = game.Workspace.CurrentCamera
local player = game.Players.LocalPlayer
local character = player.Character
local humanoidRootPart = character.HumanoidRootPart
local car = script:WaitForChild("Car").Value
local stats = car:WaitForChild("Configurations")
local Raycast = require(car.CarScript.RaycastModule)

if car:WaitForChild('Owner').Value ~= player.Name then
	return script:Destroy()
end

local cameraType = Enum.CameraType.Follow

local movement = Vector2.new()

local seat = car:WaitForChild("DriveSeat")

seat.Changed:Connect(function(property)
	if property == "Throttle" then
		movement = Vector2.new(movement.X, seat.Throttle)
	end
	if property == "Steer" then
		movement = Vector2.new(seat.Steer, movement.Y)
	end
end)

local force = 0
local damping = 0

local mass = 0

for i, v in pairs(car:GetChildren()) do
	if v:IsA("BasePart") then
		mass = mass + (v:GetMass() * 196.2)
	end
end

force = mass * stats.Suspension.Value
damping = force / stats.Bounce.Value

local bodyVelocity = Instance.new("BodyVelocity", car.Chassis)
bodyVelocity.velocity = Vector3.new(0, 0, 0)
bodyVelocity.maxForce = Vector3.new(0, 0, 0)

local bodyAngularVelocity = Instance.new("BodyAngularVelocity", car.Chassis)
bodyAngularVelocity.angularvelocity = Vector3.new(0, 0, 0)
bodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)

local rotation = 0

local function UpdateThruster(thruster)
	--Make sure we have a bodythrust to move the wheel
	local bodyThrust = thruster:FindFirstChild("BodyThrust")
	if not bodyThrust then
		bodyThrust = Instance.new("BodyThrust", thruster)
	end
	--Do some raycasting to get the height of the wheel
	local hit, position = Raycast.new(thruster.Position, thruster.CFrame:vectorToWorldSpace(Vector3.new(0, -1, 0)) * stats.Height.Value)
	local thrusterHeight = (position - thruster.Position).magnitude
	if hit and hit.CanCollide then
		--If we're on the ground, apply some forces to push the wheel up
		bodyThrust.force = Vector3.new(0, ((stats.Height.Value - thrusterHeight)^2) * (force / stats.Height.Value^2), 0)
		local thrusterDamping = thruster.CFrame:toObjectSpace(CFrame.new(thruster.Velocity + thruster.Position)).p * damping
		bodyThrust.force = bodyThrust.force - Vector3.new(0, thrusterDamping.Y, 0)
	else
		bodyThrust.force = Vector3.new(0, 0, 0)
	end
	
	--Wheels
	local wheelWeld = thruster:FindFirstChild("WheelWeld")
	if wheelWeld then
		wheelWeld.C0 = CFrame.new(0, -math.min(thrusterHeight, stats.Height.Value * 0.8) + (wheelWeld.Part1.Size.Y / 2), 0)
		-- Wheel turning
		local offset = car.Chassis.CFrame:inverse() * thruster.CFrame
		local speed = car.Chassis.CFrame:vectorToObjectSpace(car.Chassis.Velocity)
		if offset.Z < 0 then
			local direction = 1
			if speed.Z > 0 then
				direction = -1
			end
			wheelWeld.C0 = wheelWeld.C0 * CFrame.Angles(0, (car.Chassis.RotVelocity.Y / 2) * direction, 0)
		end
		wheelWeld.C0 = wheelWeld.C0 * CFrame.Angles(rotation, 0, 0)
	end
end

--A simple function to check if the car is grounded
local function IsGrounded()
	local hit, position = Raycast.new((car.Chassis.CFrame * CFrame.new(0, 0, (car.Chassis.Size.Z / 2) - 1)).p, car.Chassis.CFrame:vectorToWorldSpace(Vector3.new(0, -1, 0)) * (stats.Height.Value + 0.2))
	if hit and hit.CanCollide then
		return(true)
	end
	return(false)
end

local oldCameraType = camera.CameraType
camera.CameraType = cameraType

spawn(function()
	while character.Humanoid.SeatPart == car.DriveSeat do
		game:GetService("RunService").RenderStepped:wait()
		
		if userInputService:IsKeyDown(Enum.KeyCode.F) then
			car:SetPrimaryPartCFrame(car.PrimaryPart.CFrame * CFrame.new(0,2,0))
		end
		
		--Broken gyro input
		--[[if userInputService.GyroscopeEnabled then
			local inputObject, cframe = userInputService:GetDeviceRotation()
			local up = cframe:vectorToWorldSpace(Vector3.new(0, 1, 0))
			local angle = (1 - up.Y) * (math.abs(up.X) / up.X)
			movement = Vector2.new(angle, movement.Y)
		end]]
		
		if IsGrounded() then
			if movement.Y ~= 0 then
				local velocity = car.Chassis.CFrame.lookVector * movement.Y * stats.Speed.Value
				car.Chassis.Velocity = car.Chassis.Velocity:Lerp(velocity, 0.1)
				bodyVelocity.maxForce = Vector3.new(0, 0, 0)
			else
				bodyVelocity.maxForce = Vector3.new(mass / 2, mass / 4, mass / 2)
			end
			local rotVelocity = car.Chassis.CFrame:vectorToWorldSpace(Vector3.new(movement.Y * stats.Speed.Value / 50, 0, -car.Chassis.RotVelocity.Y * 5 * movement.Y))
			local speed = -car.Chassis.CFrame:vectorToObjectSpace(car.Chassis.Velocity).unit.Z
			rotation = rotation + math.rad((-stats.Speed.Value / 5) * movement.Y)
			if math.abs(speed) > 0.1 then
				rotVelocity = rotVelocity + car.Chassis.CFrame:vectorToWorldSpace((Vector3.new(0, -movement.X * speed * stats.TurnSpeed.Value, 0)))
				bodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)
			else
				bodyAngularVelocity.maxTorque = Vector3.new(mass / 4, mass / 2, mass / 4)
			end
			car.Chassis.RotVelocity = car.Chassis.RotVelocity:Lerp(rotVelocity, 0.1)
			
			--bodyVelocity.maxForce = Vector3.new(mass / 3, mass / 6, mass / 3)
			--bodyAngularVelocity.maxTorque = Vector3.new(mass / 6, mass / 3, mass / 6)
		else
			bodyVelocity.maxForce = Vector3.new(0, 0, 0)
			bodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)
		end
		
		for i, part in pairs(car:GetChildren()) do
			if part.Name == "Thruster" then
				UpdateThruster(part)
			end
		end
	end
	for i, v in pairs(car:GetChildren()) do
		if v:FindFirstChild("BodyThrust") then
			v.BodyThrust:Destroy()
		end
	end
	bodyVelocity:Destroy()
	bodyAngularVelocity:Destroy()
	camera.CameraType = oldCameraType
	userInputService.ModalEnabled = false
	script:Destroy()
end)