game.Players.LocalPlayer.ChildRemoved:Connect(function(ch)
	if ch.Name == "Ingame" then
		script.Parent.Enabled = false
	end
end)
game.Players.LocalPlayer.ChildAdded:Connect(function(ch)
	if ch.Name == "Ingame" then
		script.Parent.Enabled = true
	end
end)
local l__MainFrame__1 = script.Parent:WaitForChild("MainFrame")
local u1 = false
local u2 = {}
local l__ScrollingFrame__3 = l__MainFrame__1:WaitForChild("ScrollingFrame")
local l__PlayerLabel__4 = script:WaitForChild("PlayerLabel")
local l__LocalPlayer__5 = game.Players.LocalPlayer
local function u6(p1, p2, p3, p4, p5, p6, p7)
	if not workspace:FindFirstChild("IsPriv") then
	local Lordladyv2 = ""
	if p4 == "Owner" then
		local Lordlady
		if p5 == "Female" then
			Lordlady = "Lady"
		else
			Lordlady = "Lord"
		end
		Lordladyv2 = Lordlady
		if p1 == "Ratriel" then
			Lordlady = "Pontiff"
		end
	end
	local v4 = {}
	if Lordladyv2 ~= "" then
		table.insert(v4, Lordladyv2)
	end
	if p1 ~= "" and p1 ~= " " then
		table.insert(v4, p1)
	end
	if p3 ~= "" then
		table.insert(v4, p3)
	end
	local v5 = table.concat(v4, " ")
	local v6 = 0
	local moneyrankseparate = 3 + string.len(tostring(p7)) * 3
	local v7 = v5
	if p6 > 0 and p7 == 0 then
		v6 = 3 + string.len(tostring(p6)) * 3
		v7 = string.rep(" ", v6) .. v5
	elseif p7 > 0 and p6 == 0 then
		v7 = string.rep(" ", moneyrankseparate) .. v5
	elseif p6 > 0 and p7 > 0 then
		v6 = 3 + string.len(tostring(p6)) * 3
		v7 = string.rep(" ", moneyrankseparate) .. string.rep(" ", v6) .. v5	
	end
	if p2 ~= "" then
		v7 = v7 .. ", " .. p2
	end
		return v7
	else
		local v4 = {}
		if p1 ~= "" and p1 ~= " " then
			return " "..p1
		end
	end
end
local function u7()
	if u1 then
		return
	end
	u1 = true
	local v8 = {}
	local v10 = game.Players:GetPlayers()
	for i,v in pairs(v10)do
		local l__leaderstats__14 = v:FindFirstChild("leaderstats")
		local v15 = l__leaderstats__14 and l__leaderstats__14:FindFirstChild("FirstName")
		if l__leaderstats__14 then
			local l__UberTitle__16 = l__leaderstats__14:FindFirstChild("UberTitle")
		end
		local v17 = l__leaderstats__14 and l__leaderstats__14:FindFirstChild("Hidden")
		if u2[v] and v17 and not v17.Value and v15.Value ~= "" then
			table.insert(v8, v)
		elseif u2[v] then
			u2[v].Visible = false
		end	
	end
	table.sort(v8, function(p7, p8)
		if not p7 then
			return true
		end
		if not p8 then
			return false
		end
		local l__leaderstats__18 = p7:FindFirstChild("leaderstats")
		local l__leaderstats__19 = p8:FindFirstChild("leaderstats")
		local l__Value__20 = l__leaderstats__18.LastName.Value
		local l__Value__21 = l__leaderstats__19.LastName.Value
		if l__Value__20 ~= "" and l__Value__21 == "" then
			return true
		end
		if l__Value__20 == "" and l__Value__21 ~= "" then
			return false
		end
		if l__Value__20 < l__Value__21 then
			return true
		end
		if l__Value__21 < l__Value__20 then
			return false
		end
		local l__Value__22 = l__leaderstats__18.FirstName.Value
		local l__Value__23 = l__leaderstats__19.FirstName.Value
		if l__Value__22 < l__Value__23 then
			return true
		end
		if l__Value__23 < l__Value__22 then
			return false
		end
		return p7.Name < p8.Name
	end)
	for v24, v25 in pairs(v8) do
		local v26 = u2[v25]
		v26.Position = UDim2.new(0, 0, 0, (v24 - 1) * 20)
		v26.Visible = true
	end
	for v27, v28 in pairs(l__ScrollingFrame__3:children()) do

	end
	local v29 = #v8 * 20
	l__MainFrame__1.Size = UDim2.new(0.05, 150, 0, math.min(v29 + 20, 340))
	l__ScrollingFrame__3.CanvasSize = UDim2.new(0, 0, 0, v29)
	u1 = false
end
local function u8(p9)
	if u2[p9] then
		return
	end
	u2[p9] = true
	local v30 = l__PlayerLabel__4:clone()
	u2[p9] = v30
	local l__Prestige__31 = v30:WaitForChild("Prestige")
	local moneyprestige = v30:WaitForChild("MoneyPrestige")
	local l__leaderstats__32 = p9:WaitForChild("leaderstats")
	local l__FirstName__33 = l__leaderstats__32:WaitForChild("FirstName")
	local l__UberTitle__34 = l__leaderstats__32:WaitForChild("UberTitle")
	local l__LastName__35 = l__leaderstats__32:WaitForChild("LastName")
	local l__HouseRank__36 = l__leaderstats__32:WaitForChild("HouseRank")
	local l__Gender__37 = l__leaderstats__32:WaitForChild("Gender")
	local l__Hidden__38 = l__leaderstats__32:WaitForChild("Hidden")
	local l__Prestige__39 = l__leaderstats__32:WaitForChild("Prestige")
	local moneyprestigevalue = l__leaderstats__32:WaitForChild("MoneyPrestige")
	local l__MaxEdict__40 = l__leaderstats__32:WaitForChild("MaxEdict")
	local Requests = game.ReplicatedStorage.Requests
	Requests.ShowMaxEdict:InvokeServer()
	local v41 = u6(l__FirstName__33.Value, l__UberTitle__34.Value, l__LastName__35.Value, l__HouseRank__36.Value, l__Gender__37.Value, l__Prestige__39.Value, moneyprestigevalue.Value)
	v30.Text = v41
	if l__Prestige__39.Value > 0 and moneyprestigevalue.Value == 0 then
		l__Prestige__31.Text = "#" .. l__Prestige__39.Value
		l__Prestige__31.Visible = true
		moneyprestige.Position = UDim2.new(0,0,0,1)	
	elseif l__Prestige__39.Value == 0 and moneyprestigevalue.Value > 0 then
		moneyprestige.Text = "#" .. moneyprestigevalue.Value
		moneyprestige.Visible = true
		moneyprestige.Position = UDim2.new(0,0,0,1)	
	elseif l__Prestige__39.Value > 0 and moneyprestigevalue.Value > 0 then
		moneyprestige.Text = "#" .. moneyprestigevalue.Value
		moneyprestige.Visible = true
		l__Prestige__31.Text = "#" .. l__Prestige__39.Value
		l__Prestige__31.Visible = true
		moneyprestige.Position = UDim2.new(0,17,0,1)
	else
		l__Prestige__31.Visible = false 
		moneyprestige.Visible = false
		moneyprestige.Position = UDim2.new(0,0,0,1)	
	end
	if l__MaxEdict__40.Value then
		v30.TextColor3 = Color3.fromRGB(255, 214, 81)
	else
		v30.TextColor3 = Color3.new(1, 1, 1)
	end
	local u9 = v41
	l__UberTitle__34.Changed:Connect(function()
		u9 = u6(l__FirstName__33.Value, l__UberTitle__34.Value, l__LastName__35.Value, l__HouseRank__36.Value, l__Gender__37.Value, l__Prestige__39.Value, moneyprestigevalue.Value)
		v30.Text = u9
		u7()
	end)
	l__FirstName__33.Changed:connect(function()
		u9 = u6(l__FirstName__33.Value, l__UberTitle__34.Value, l__LastName__35.Value, l__HouseRank__36.Value, l__Gender__37.Value, l__Prestige__39.Value, moneyprestigevalue.Value)
		v30.Text = u9
		u7()
	end)
	l__LastName__35.Changed:connect(function()
		u9 = u6(l__FirstName__33.Value, l__UberTitle__34.Value, l__LastName__35.Value, l__HouseRank__36.Value, l__Gender__37.Value, l__Prestige__39.Value, moneyprestigevalue.Value)
		v30.Text = u9
		u7()
	end)
	l__HouseRank__36.Changed:connect(function()
		u9 = u6(l__FirstName__33.Value, l__UberTitle__34.Value, l__LastName__35.Value, l__HouseRank__36.Value, l__Gender__37.Value, l__Prestige__39.Value, moneyprestigevalue.Value)
		v30.Text = u9
		u7()
	end)
	l__Hidden__38.Changed:connect(function()
		u7()
	end)
	l__Gender__37.Changed:connect(function()
		u7()
	end)
	l__Prestige__39.Changed:connect(function()
		u9 = u6(l__FirstName__33.Value, l__UberTitle__34.Value, l__LastName__35.Value, l__HouseRank__36.Value, l__Gender__37.Value, l__Prestige__39.Value, moneyprestigevalue.Value)
		if l__Prestige__39.Value > 0 and moneyprestigevalue.Value == 0 then
			l__Prestige__31.Text = "#" .. l__Prestige__39.Value
			l__Prestige__31.Visible = true
			moneyprestige.Visible = false
			moneyprestige.Position = UDim2.new(0,0,0,1)	
		elseif l__Prestige__39.Value == 0 and moneyprestigevalue.Value > 0 then
			moneyprestige.Text = "#" .. moneyprestigevalue.Value
			moneyprestige.Visible = true
			moneyprestige.Position = UDim2.new(0,0,0,1)
			l__Prestige__31.Visible = false
		elseif l__Prestige__39.Value > 0 and moneyprestigevalue.Value > 0 then
			moneyprestige.Text = "#" .. moneyprestigevalue.Value
			moneyprestige.Visible = true
			l__Prestige__31.Text = "#" .. l__Prestige__39.Value
			l__Prestige__31.Visible = true
			moneyprestige.Position = UDim2.new(0,17,0,1)
		else
			l__Prestige__31.Visible = false 
			moneyprestige.Visible = false
			moneyprestige.Position = UDim2.new(0,0,0,1)
		end
		v30.Text = u9
	end)
	moneyprestigevalue.Changed:Connect(function()
		u9 = u6(l__FirstName__33.Value, l__UberTitle__34.Value, l__LastName__35.Value, l__HouseRank__36.Value, l__Gender__37.Value, l__Prestige__39.Value, moneyprestigevalue.Value)
		if l__Prestige__39.Value > 0 and moneyprestigevalue.Value == 0 then
			l__Prestige__31.Text = "#" .. l__Prestige__39.Value
			l__Prestige__31.Visible = true
			moneyprestige.Position = UDim2.new(0,0,0,1)
			moneyprestige.Visible = false
		elseif l__Prestige__39.Value == 0 and moneyprestigevalue.Value > 0 then
			moneyprestige.Text = "#" .. moneyprestigevalue.Value
			moneyprestige.Visible = true
			moneyprestige.Position = UDim2.new(0,0,0,1)
			l__Prestige__31.Visible = false
		elseif l__Prestige__39.Value > 0 and moneyprestigevalue.Value > 0 then
			moneyprestige.Text = "#" .. moneyprestigevalue.Value
			moneyprestige.Visible = true
			l__Prestige__31.Text = "#" .. l__Prestige__39.Value
			l__Prestige__31.Visible = true
			moneyprestige.Position = UDim2.new(0,17,0,1)
		else
			l__Prestige__31.Visible = false 
			moneyprestige.Visible = false
			moneyprestige.Position = UDim2.new(0,0,0,1)
		end
		v30.Text = u9
	end)
	l__MaxEdict__40.Changed:connect(function()
		if l__MaxEdict__40.Value then
			v30.TextColor3 = Color3.fromRGB(255, 214, 81)
			return
		end
		v30.TextColor3 = Color3.new(1, 1, 1)
	end)
	local u10 = p9.Name:sub(1, 2) .. "\226\128\142" .. p9.Name:sub(3)
	v30.MouseEnter:connect(function()
		local v42 = 0
		v30.Text = u10
		local moneyrankseparate = 3 + string.len(tostring(moneyprestigevalue.Value)) * 3
		if l__Prestige__39.Value > 0 and moneyprestigevalue.Value == 0 then
			v42 = 3 + string.len(tostring(l__Prestige__39.Value)) * 3
			v30.Text = string.rep(" ", v42) .. u10
		elseif moneyprestigevalue.Value > 0 and l__Prestige__39.Value == 0 then
			v30.Text = string.rep(" ", moneyrankseparate) .. u10
		elseif l__Prestige__39.Value > 0 and moneyprestigevalue.Value > 0 then
			v42 = 3 + string.len(tostring(l__Prestige__39.Value)) * 3
			v30.Text = string.rep(" ", moneyrankseparate) .. string.rep(" ", v42) .. u10	
		end
		v30.TextTransparency = 0.3
	end)
	v30.MouseLeave:connect(function()
		v30.Text = u9
		v30.TextTransparency = 0
	end)
	pcall(function()
		v30.Parent = l__ScrollingFrame__3
	end)
	u7()
	return v30
end
game.Players.PlayerAdded:connect(function(p10)
	u8(p10)
end)
local function u11(p11)
	if not u2[p11] then
		return
	end
	local v43 = u2[p11]
	if v43 then
		v43:Destroy()
	end
	u2[p11] = nil
	u7()
end
game.Players.PlayerRemoving:connect(function(p12)
	u11(p12)
end)
for v44, v45 in pairs(game.Players:GetPlayers()) do
	spawn(function()
		u8(v45)
	end)
end

