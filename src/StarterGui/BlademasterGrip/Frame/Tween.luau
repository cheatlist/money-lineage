local module = {}

module.Tween = function(data)
	script.Parent.TextLabel.Text = data
	script.Parent.TextLabel.Shadow.Text = data
	game:GetService("TweenService"):Create(script.Parent.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
	game:GetService("TweenService"):Create(script.Parent.TextLabel, TweenInfo.new(1, Enum.EasingStyle.Linear), {TextTransparency = 0}):Play()
	game:GetService("TweenService"):Create(script.Parent.TextLabel.Shadow, TweenInfo.new(1, Enum.EasingStyle.Linear), {TextTransparency = 0.6}):Play()
	wait(3)
	game:GetService("TweenService"):Create(script.Parent.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
	game:GetService("TweenService"):Create(script.Parent.TextLabel, TweenInfo.new(1, Enum.EasingStyle.Linear), {TextTransparency = 1}):Play()
	game:GetService("TweenService"):Create(script.Parent.TextLabel.Shadow, TweenInfo.new(1, Enum.EasingStyle.Linear), {TextTransparency = 1}):Play()
end
return module
