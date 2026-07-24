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

			task.wait()
		end

		-- Part.Attachment.TestTrail1.Enabled = false
	end)()
end

module.Desert = function(Properties)
	local Character = Properties.Character
	local Root = Character.PrimaryPart
	local Target = Properties.Target
	local TargetRoot = Target.PrimaryPart
	
	local End = TargetRoot.CFrame

	local Start = Root.CFrame
	local Magnitude = (Start.Position - End.Position).Magnitude
	
	for i = 1, 6 do
		local Mid = Start * CFrame.new(i % 2 == 0 and Magnitude*2 or -Magnitude*2, -8 + (6 * i), -Magnitude/2)

		local Trail = script.Trail:Clone()
		Trail.CFrame = Start
		Trail.Parent = workspace.Effects
		game.Debris:AddItem(Trail, 3)

		Curve(Trail, End, Mid, Start)
	end
end

return module
