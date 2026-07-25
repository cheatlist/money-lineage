local module = {}

Bezier = function(Start, Mid, End, Index)
	local A = Start:Lerp(Mid, Index)
	local B = Start:Lerp(End, Index)

	return A:Lerp(B, Index)
end

local function Curve(Part, Start, Mid, End)
	coroutine.wrap(function()
		for i = 0, 1, 0.1 do
			local Next = Bezier(Start, Mid, End, i)

			game.TweenService:Create(Part, TweenInfo.new(0.1), {CFrame = Next}):Play()

			task.wait(1/30)
		end

		Part.Attachment.TestTrail1.Enabled = false
	end)()
end

module.DeathPlague = function(Properties)
	local Character = Properties.Character
	local Root = Character.PrimaryPart
	local Target = Properties.Target
	local TargetRoot = Target.PrimaryPart
	
	local End = TargetRoot.CFrame
	
	local Effect = script.Shockwave:Clone()
	Effect.Parent = workspace.Effects
	Effect.CFrame = CFrame.new(Root.Position, End.Position) * CFrame.Angles(0, math.rad(90), math.rad(90))

	game.TweenService:Create(Effect, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Vector3.new(12.76, 1, 12.829)}):Play()
	game.TweenService:Create(Effect, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 1}):Play()

	game.Debris:AddItem(Effect, 0.6)

	coroutine.wrap(function()
		while Effect do
			game.TweenService:Create(Effect, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {CFrame = Effect.CFrame * CFrame.Angles(0, math.rad(90), 0)}):Play()

			task.wait(0.6)
		end
	end)()

	local Start = Root.CFrame
	local Magnitude = (Start.Position - End.Position).Magnitude

	for i = 1, 6 do
		local Mid = Start * CFrame.new(i % 2 == 0 and Magnitude*2 or -Magnitude*2, -8 + (6 * i), -Magnitude/2)

		local Trail = script.Trail:Clone()
		Trail.CFrame = Start
		Trail.Parent = workspace.Effects
		game.Debris:AddItem(Trail, 3)

		Curve(Trail, Start, Mid, End)
	end
end

return module
