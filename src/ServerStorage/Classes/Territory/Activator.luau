local v1 = {};
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(l__Parent__1)
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Stun", "ReturnStun", "Action", "Blocking", "SpellBlocking", "Climbing", "ActiveCast", "Immortal"},
		healthAtOrBelow = 0,
		presentTagBlocks = {"Unconscious", "Knocked"},
	})
end

local v3 = tick();
local l__TweenService__4 = game:GetService("TweenService");
local u2 = { game.Workspace.Live };
function ray(p1, p2, p3, p4)
	local v5, v6, v7 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).lookVector * p3), u2);
	return v5, v6, v7;
end;
local u3 = true;
local u5 = require(game.ServerScriptService.Modules.HitDetection);
local tool = script.Parent
local debounce = false
local radius = 40 --radius of the domain
local duration = 2 --how long it takes for the part to tween, +3 seconds or so for the particles to fade in.
local velocityVal = 3.7 --dont change this
function v1.Active(p5, p6, p7, p8)
	if u3 == false then
		return;
	end;
	if ActionCheck(p5) then
		return;
	end;
	if debounce then return end

	script.Parent.Sound:Play()

	debounce = true
	spawn(function()
		task.wait(5)
		debounce = false
	end)

	local part = Instance.new("Part")
	part.CanCollide = false
	part.Anchored = true
	part.Parent = workspace 
	part.Transparency = 1

	local pe = Instance.new("ParticleEmitter")
	pe.Parent = part 
	pe.SpreadAngle = Vector2.new(0,180)
	pe.Texture = "rbxassetid://9953839287"
	pe.Rate = 500
	pe.Color = ColorSequence.new(Color3.new(0,0,0))
	pe.Drag = 3
	pe.Rotation = NumberRange.new(0,180)
	pe.Lifetime = NumberRange.new(10)
	pe.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0,0),
		NumberSequenceKeypoint.new(0.3,0),
		NumberSequenceKeypoint.new(0.3001,7),
		NumberSequenceKeypoint.new(1,7),
	})
	pe.Squash = NumberSequence.new(1.05)

	local pe2 = Instance.new("ParticleEmitter")
	pe2.Parent = part 
	pe2.SpreadAngle = Vector2.new(0,180)
	pe2.Texture = "rbxassetid://9953839287"
	pe2.Rate = 2000
	pe2.Color = ColorSequence.new(Color3.new(0,0,0))
	pe2.Drag = 3
	pe2.Rotation = NumberRange.new(0,180)
	pe2.Lifetime = NumberRange.new(20)
	pe2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0,0),
		NumberSequenceKeypoint.new(0.18,0),
		NumberSequenceKeypoint.new(0.1801,11),
		NumberSequenceKeypoint.new(1,11),
	})
	pe2.Squash = NumberSequence.new(1.05)

	local char = tool.Parent
	local hrp = char.HumanoidRootPart

	local cfBegin = CFrame.new(hrp.Position - hrp.CFrame.LookVector * radius, hrp.Position)
	local posEnd = hrp.Position + hrp.CFrame.LookVector * radius

	part.CFrame = cfBegin

	task.wait(1/30)
	task.wait(1/30)

	local lerp = 0

	local t = tick()
	local tLast = tick()
	while (lerp < 1) do 
		t = tick()
		local dt = t - tLast

		lerp += dt/duration
		local rt = 1/2 * radius * math.sqrt(1 - (2 * lerp - 1)^2)
		part.Position = cfBegin.Position * (1 - lerp) + posEnd * lerp
		pe.Speed = NumberRange.new(rt * velocityVal)
		pe2.Speed = NumberRange.new(rt * velocityVal)
		tLast = t
		task.wait(1/30)
	end
	--[[u3 = false;
	local v8 = Instance.new("Accessory");
	v8.Name = "Action";
	v8.Parent = p5;
	local v9 = Instance.new("Folder");
	v9.Name = "NoDelete";
	v9.Parent = v8;
	game.Debris:AddItem(v8, 1);
	local v10 = p5.Humanoid:LoadAnimation(script.Parent.Anim);
	v10:Play();
	local l__HumanoidRootPart__6 = p5.HumanoidRootPart;
	local l__Value__7 = p8.Stats.Damage.Value;
	local l__Value__8 = p8.Stats.Length.Value;
	v10:GetMarkerReachedSignal("stab"):Connect(function()
		local v11 = Instance.new("BodyVelocity");
		game.CollectionService:AddTag(v11, "AllowedBM");
		v11.maxForce = Vector3.new(math.huge, math.huge, math.huge);
		v11.Velocity = l__HumanoidRootPart__6.CFrame.LookVector * 15;
		v11.Parent = l__HumanoidRootPart__6;
		game.Debris:AddItem(v11, 0.2);
		u5.magnitudeCheck(p5, l__HumanoidRootPart__6.Position, l__Value__8, {
			physical = true, 
			spear = true, 
			slash = true, 
			damage = l__Value__7
		}, true);
	end);
	v10:GetMarkerReachedSignal("pull"):Connect(function()
		local v12
		if p5:FindFirstChild("Focus") then
			v12 = 5;
		else
			v12 = 3;
		end;
		u5.magnitudeCheck(p5, l__HumanoidRootPart__6.Position, l__Value__8, {
			physical = true, 
			spear = true, 
			slash = true, 
			damage = l__Value__7, 
			waterspikes = v12, 
			delay = 0.2
		}, true);
	end);
	task.wait(12);
	u3 = true;]]
end;
return v1;