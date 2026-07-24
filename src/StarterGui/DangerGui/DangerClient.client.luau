game.Players.LocalPlayer.ChildRemoved:Connect(function(ch)
	if ch.Name == "Ingame" then
		script.Parent:Destroy()
	end
end)
local l__LocalPlayer__1 = game.Players.LocalPlayer
local v2 = l__LocalPlayer__1.Character
while not v2 do
	wait()
	v2 = l__LocalPlayer__1.Character
end
local u1 = "safe"
local l__TextLabel__2 = script.Parent:WaitForChild("TextLabel")
local function u3()
	if l__LocalPlayer__1:FindFirstChild("MortalDanger")then
		u1 = "mortaldanger"
	elseif l__LocalPlayer__1:FindFirstChild("Danger")then
		u1 = "danger"
	else
		u1 = "safe"
	end
	l__TextLabel__2.Visible = u1 ~= "safe"
	if u1 == "mortaldanger" then
		l__TextLabel__2.Text = "MORTAL DANGER\nDeath is at your heels!"
		return
	end
	if u1 == "danger" then
		l__TextLabel__2.Text = "IN DANGER\nYour life is at risk!"
		return
	end
	l__TextLabel__2.Text = "Safe"
end
l__LocalPlayer__1.ChildAdded:connect(function()
	wait()
	u3()
end)
l__LocalPlayer__1.ChildRemoved:connect(function()
	wait()
	u3()
end)