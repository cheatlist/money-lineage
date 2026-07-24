local l__LocalPlayer__1 = game.Players.LocalPlayer
local l__Parent__2 = script.Parent
function sub(...)
	coroutine.wrap(...)()
end
game.Players.LocalPlayer.ChildRemoved:Connect(function(ch)
	if ch.Name == "Ingame" then
		script.Parent:Destroy()
	end
end)
local l__Container__3 = l__Parent__2:WaitForChild("Container")
local l__LeftContainer__4 = l__Parent__2:WaitForChild("LeftContainer")
local rightcontainer = l__Parent__2:WaitForChild("RightContainer")
local l__Health__5 = l__Container__3:WaitForChild("Health")
local l__Slider__6 = l__Health__5:WaitForChild("Slider")
local l__Lives__7 = l__Health__5:WaitForChild("Lives")
local l__Back__8 = l__Health__5:WaitForChild("Constitution"):WaitForChild("Back")
local l__Stomach__9 = l__Back__8:WaitForChild("Stomach")
local l__Stomach__9extra = l__Back__8:WaitForChild("ExtraStomach")
local l__Toxicity__10 = l__Back__8:WaitForChild("Toxicity")
local l__Pointer__11 = l__Health__5:WaitForChild("Temperature"):WaitForChild("Gradient"):WaitForChild("Pointer")
local l__Sanity__12 = game.Lighting:WaitForChild("Sanity")
local l__Slider__13 = l__LeftContainer__4:WaitForChild("Mana"):WaitForChild("Slider")
local slider = rightcontainer:WaitForChild("Mana"):WaitForChild("Slider")
local l__CharacterName__14 = l__Container__3:WaitForChild("CharacterName")
local l__Roller__15 = script:WaitForChild("Roller")
local v16 = {}
local v17 = l__Roller__15:clone()
v17.Parent = l__Lives__7
v17.Position = UDim2.new(0, 10, 0, 0)
v16[v17] = {
	targ = 0, 
	track = 0
}
local any = {
	"";
}
local v18 = {}
for v19 = 1, 3 do
	local v20 = l__Roller__15:clone()
	v20.Parent = l__Lives__7
	v20.Position = UDim2.new(0, 16 + v19 * 13, 0, 0)
	v16[v20] = {
		targ = 0, 
		track = 0
	}
	v18[v19] = v20
end
local v22 = game.ReplicatedStorage.Requests.Get:InvokeServer({"LastName","FirstName","ManaColor","Lives","Deaths","DaysSurvived","Race","HouseRank","Gender","UberTitle"})
local u1 = v22.HouseRank
local u2 = v22.Gender
local u3 = v22.FirstName
local u4 = v22.UberTitle
local u5 = v22.LastName
local function v23()
	if not workspace:FindFirstChild("IsPriv") then
		local v24 = ""
		if u1 == "Owner" then
			local v25
			if u2 == "Female" then
				v25 = "Lady"
			else
				v25 = "Lord"
			end
			v24 = v25
			if u3 == "Ratriel" then
				v24 = "Pontiff"
			end
		end
		local v26 = {}
		if v24 ~= "" then
			table.insert(v26, v24)
		end
		if u3 ~= "" and u3 ~= " " then
			table.insert(v26, u3)
		end
		if u5 ~= "" then
			table.insert(v26, u5)
		end
		if u4 and u4 ~= "" and u4 ~= " " then
			table.insert(v26, ", " .. u4)
		end
		return table.concat(v26, " ")
	else
		if u3 ~= "" and u3 ~= " " then
			return u3
		end
	end
end
local v27 = v23()
local l__DaysSurvived__28 = v22.DaysSurvived
local function u6(p1, p2)
	local v29 = v16[p1]
	if not v29 then
		return
	end
	v29.targ = math.clamp(p2, 0, 9)
	if v29.rolling then
		return
	end
	v29.rolling = true
	sub(function()
		while true do
			local v30
			if v29.track == 9 and v29.targ == 0 then
				v30 = 1
				v29.track = 0
			elseif v29.track == 0 and v29.targ == 9 then
				v30 = -1
				v29.track = 9
			else
				v30 = math.sign(v29.targ - v29.track)
				v29.track = v29.track + v30
			end
			game.TweenService:Create(p1.Char, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Position = UDim2.new(0, 0, 0.5 + v30, 0)
			}):Play()
			wait(0.1)
			p1.Char.Position = UDim2.new(0, 0, 0.5 - v30, 0)
			p1.Char.Text = math.clamp(v29.track, 0, 9)
			game.TweenService:Create(p1.Char, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Position = UDim2.new(0, 0, 0.5, 0)
			}):Play()
			wait(0.1)
			p1.Char.Position = UDim2.new(0, 0, 0.5, 0)
			if v29.track == v29.targ then
				break
			end		
		end
	end)
	v29.rolling = false
end
local function v31(p3, p4)
	local v32 = string.format("%03i", math.clamp(p3, 0, 999))
	for v33 = 1, 3 do
		local v34 = nil
		v34 = tonumber(v32:sub(v33, v33))
		local v35 = v18[v33]
		if p4 then
			v35.Char.Text = v34
			v16[v35].track = v34
		else
			u6(v35, v34)
		end
	end
end
v31(v22.DaysSurvived, true)

if not workspace:FindFirstChild("IsPriv") then
	v17.Char.Text = math.clamp(v22.Lives, 0, 9)
	v16[v17].track = math.clamp(v22.Lives, 0, 9)
else
	v17.Char.Text = 0
	v16[v17].track = 0
end
game.ReplicatedStorage.Requests.LivesChanged.OnClientEvent:connect(function(p5)
	u6(v17, p5)
end)
local l__DaysSurvived__7 = v22.DaysSurvived
game.ReplicatedStorage.Requests.DaysSurvivedChanged.OnClientEvent:connect(function(p7)
	v31(p7)
	if l__DaysSurvived__7 ~= 0 and p7 == 0 and Random.new():NextInteger(1, 100) == 50 then
		local v36 = Instance.new("Sound", script.Parent)
		v36.SoundId = "rbxassetid://2574317817"
		v36:Play()
		game.Debris:AddItem(v36, 3)
	end
end)
local l__ManaColor__37 = v22.ManaColor
local v38, v39, v40 = Color3.toHSV(l__ManaColor__37)
l__Slider__13.BackgroundColor3 = Color3.fromHSV(v38, math.clamp(v39, 0, 0.8), math.clamp(v40, 0.1, 1))
l__Slider__13.Divider.BackgroundColor3 = Color3.fromHSV(v38, v39 * 0.8, v40 * 0.4)
slider.BackgroundColor3 = Color3.fromHSV(v38, math.clamp(v39, 0, 0.8), math.clamp(v40, 0.1, 1))
slider.Divider.BackgroundColor3 = Color3.fromHSV(v38, v39 * 0.8, v40 * 0.4)
local u8 = l__ManaColor__37
local u9 = v38
local u10 = v39
local u11 = v40
game.ReplicatedStorage.Requests.ManaColorChanged.OnClientEvent:connect(function(p9)
	u8 = p9
	local v41, v42, v43 = Color3.toHSV(u8)
	u9 = v41
	u10 = v42
	u11 = v43
	l__Slider__13.BackgroundColor3 = Color3.fromHSV(u9, math.clamp(u10, 0, 0.8), math.clamp(u11, 0.1, 1))
	l__Slider__13.Divider.BackgroundColor3 = Color3.fromHSV(u9, u10 * 0.8, u11 * 0.4)
	slider.BackgroundColor3 = Color3.fromHSV(u9, math.clamp(u10, 0, 0.8), math.clamp(u11, 0.1, 1))
	slider.Divider.BackgroundColor3 = Color3.fromHSV(u9, u10 * 0.8, u11 * 0.4)
end)
l__CharacterName__14.Text = v27:upper()
l__CharacterName__14.Shadow.Text = l__CharacterName__14.Text
local u12 = v27
game.ReplicatedStorage.Requests.NameChanged.OnClientEvent:connect(function(p10, p11, p12, p13, p14)
	u3 = p10
	u4 = p11
	u5 = p12
	u1 = p13
	u2 = p14
	u12 = v23()
	l__CharacterName__14.Text = u12:upper()
	l__CharacterName__14.Shadow.Text = l__CharacterName__14.Text
end)
local char = l__LocalPlayer__1.Character
while not char do
	wait()
	char = l__LocalPlayer__1.Character
end
local l__Humanoid__45 = char:WaitForChild("Humanoid")
local l__Mana__46 = char:WaitForChild("Mana")
local spell = char:WaitForChild("Mana")
local l__Stomach__47 = char:WaitForChild("Stomach")
local l__Stomach__47extra = char:WaitForChild("ExtraStomach")
local l__Toxicity__48 = char:WaitForChild("Toxicity")
local v49 = math.clamp(l__Humanoid__45.Health / l__Humanoid__45.MaxHealth, 0, 1)
if v22.Race == "Seraph" or v22.Race == "Cameo" or v22.Race == "Gaian" or v22.Race == "Dullahan" or v22.Race == "Lich"or char:FindFirstChild'NoHunger'or char:FindFirstChild("LichSummon") or table.find(any,tostring(l__LocalPlayer__1)) then
	l__Stomach__9.BackgroundColor3 = Color3.new(0.9, 0.9, 0.8)
end

char.ChildAdded:Connect(function(Obj)
	if Obj.Name == "NoHunger" then
		if v22.Race == "Seraph" or v22.Race == "Cameo" or v22.Race == "Gaian" or v22.Race == "Dullahan" or v22.Race == "Lich"or char:FindFirstChild'NoHunger'or char:FindFirstChild("LichSummon") or table.find(any,tostring(l__LocalPlayer__1)) then
			l__Stomach__9.BackgroundColor3 = Color3.new(0.9, 0.9, 0.8)
		end
	end
end)
char.ChildRemoved:Connect(function(Obj)
	if Obj.Name == "NoHunger" and v22.Race.Value ~= "Seraph" and v22.Race.Value ~= "Cameo" and v22.Race.Value ~= "Gaian" and v22.Race.Value ~= "Dullahan" and v22.Race.Value ~= "Lich" and not char:FindFirstChild("LichSummon") then
		l__Stomach__9.BackgroundColor3 = Color3.fromRGB(240, 208, 26)
	end
end)
local v50 = math.clamp(l__Mana__46.Value / 100, 0, 1)
local oh = math.clamp(spell.Value / 100, 0, 1)
local v51 = math.clamp(l__Stomach__47.Value / l__Humanoid__45.MaxHealth, 0, 1)
local v51extra = math.clamp(l__Stomach__47extra.Value / l__Humanoid__45.MaxHealth, 0, 1)
local v52 = math.clamp(l__Toxicity__48.Value / l__Toxicity__48.MaxValue, 0, 1)
l__Slider__6.Size = UDim2.new(v49, 0, 1, 0)
l__Slider__13.Size = UDim2.new(1, 0, v50, 0)
slider.Size = UDim2.new(1, 0, v50, 0)
l__Stomach__9.Size = UDim2.new(v51, 0, 0, 6)
l__Stomach__9extra.Size = UDim2.new(v51extra, 0, 0, 6)
l__Toxicity__10.Size = UDim2.new(v52, 0, 0, 6)
local u13 = v49
local function v53()
	u13 = math.clamp(l__Humanoid__45.Health / l__Humanoid__45.MaxHealth, 0, 1)
	game.TweenService:Create(l__Slider__6, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Size = UDim2.new(u13, 0, 1, 0)
	}):Play()
	if l__Humanoid__45.Health <= 0 then
		local v54 = Instance.new("TextLabel")
		v54.Position = UDim2.new(1, -162, 0, -35)
		v54.Size = UDim2.new(0, 200, 0, 20)
		v54.Text = l__LocalPlayer__1.Name:sub(1, 2) .. "\226\128\142" .. l__LocalPlayer__1.Name:sub(3)
		v54.TextColor3 = Color3.new(1, 1, 1)
		v54.Font = "SourceSansSemibold"
		v54.TextSize = 14
		v54.TextXAlignment = "Left"
		v54.BackgroundTransparency = 1
		v54.Parent = l__Parent__2
		v54.Name = "Container"
		game.Debris:AddItem(v54, 10)
	end
end
local u14 = v50
local function v55()
	u14 = math.clamp(l__Mana__46.Value / 100, 0, 1)
	game.TweenService:Create(l__Slider__13, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Size = UDim2.new(1, 0, u14, 0)
	}):Play()
	
end
local zzz14 = oh
local function vv55()
	zzz14 = math.clamp(spell.Value / 100, 0, 1)
	game.TweenService:Create(slider, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Size = UDim2.new(1, 0, zzz14, 0)
	}):Play()

end
local u15 = v51
local function v56()
	u15 = math.clamp(l__Stomach__47.Value / l__Humanoid__45.MaxHealth, 0, 1)
	game.TweenService:Create(l__Stomach__9, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Size = UDim2.new(u15, 0, 0, 6)
	}):Play()
end
local function v56extra()
	u15 = math.clamp(l__Stomach__47extra.Value / l__Humanoid__45.MaxHealth, 0, 1)
	game.TweenService:Create(l__Stomach__9extra, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Size = UDim2.new(u15, 0, 0, 6)
	}):Play()
end
local u16 = v52
local function v57()
	u16 = math.clamp(l__Toxicity__48.Value / l__Toxicity__48.MaxValue, 0, 1)
	game.TweenService:Create(l__Toxicity__10, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Size = UDim2.new(u16, 0, 0, 6)
	}):Play()
end
local l__Temperature__17 = char:WaitForChild("Temperature")
local function v58()
	game.TweenService:Create(l__Pointer__11, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Position = UDim2.new((math.clamp(l__Temperature__17.Value, -1, 1) + 1) / 2, 0, 0, 0)
	}):Play()
end
local l__Sanity__18 = char:WaitForChild("Sanity")
local function v59()
	local v60 = math.clamp(l__Sanity__18.Value, -1, 1)
	if v60 < 0 then
		game.TweenService:Create(l__Sanity__12, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Saturation = v60
		}):Play()
	end
end
spell.Changed:connect(vv55)
vv55()
l__Mana__46.Changed:connect(v55)
v55()
l__Stomach__47.Changed:connect(v56)
v56()
l__Stomach__47extra.Changed:connect(v56extra)
v56extra()
l__Toxicity__48.Changed:connect(v57)
v57()
l__Temperature__17.Changed:connect(v58)
v58()
l__Sanity__18.Changed:connect(v59)
v59()
l__Humanoid__45.HealthChanged:connect(v53)
l__Humanoid__45:GetPropertyChangedSignal("MaxHealth"):connect(v53)
v53()