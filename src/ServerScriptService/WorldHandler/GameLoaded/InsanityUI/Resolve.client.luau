local l__LocalPlayer__1 = game.Players.LocalPlayer;
local v2 = l__LocalPlayer__1.Character or l__LocalPlayer__1.CharacterAdded:Wait()
local l__Resolve__1 = v2:WaitForChild("Insanity",math.huge);
local l__Slider__3 = script.Parent:WaitForChild("Container"):WaitForChild("Resolve"):WaitForChild("Slider");
l__Slider__3.Size = UDim2.new(0, 0, 1, 0);
local function v4()
	local resolveRatio = math.clamp(l__Resolve__1.Value / 100, 0, 1);
	game.TweenService:Create(l__Slider__3, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Size = UDim2.new(resolveRatio, 0, 1, 0)
	}):Play();
end;
l__Resolve__1.Changed:Connect(function()
	v4()
end)
v4();

l__LocalPlayer__1.CharacterRemoving:Connect(function()
	script.Parent:Destroy()
end)