local l__LocalPlayer__1 = game.Players.LocalPlayer
local l__Parent__2 = script.Parent
local v3 = 1
local v4 = 0
while true do
	v4 = v4 + v3
	if v4 >= 3 or v4 <= 0 then
		v3 = -v3
	end
	l__Parent__2.ImageRectOffset = Vector2.new(v4 * 13, 0)
	if v4 == 0 then
		wait(0.18)
	else
		wait(0.04)
	end
	if not l__Parent__2 then
		break
	end
	if not l__Parent__2.Parent then
		break
	end
	if not l__Parent__2:IsDescendantOf(l__LocalPlayer__1) then
		break
	end
end
