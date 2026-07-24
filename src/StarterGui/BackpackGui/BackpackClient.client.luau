wait(1.5)
game.Players.LocalPlayer.ChildRemoved:Connect(function(ch)
	if ch.Name == "Ingame" then
		script.Parent:Destroy()
	end
end)
local l__LocalPlayer__1 = game.Players.LocalPlayer
local l__Backpack__2 = l__LocalPlayer__1:WaitForChild("Backpack")
local l__UserInputService__3 = game:GetService("UserInputService")
local l__RunService__4 = game:GetService("RunService")
local v5 = l__LocalPlayer__1.Character
while not v5 do
	wait()
	v5 = l__LocalPlayer__1.Character
end
while not v5.Parent == workspace.Live do
	wait()
end
local l__Humanoid__6 = v5:WaitForChild("Humanoid")
local v7 = require(game.ReplicatedStorage.Modules.ToolHandler)
local l__ToolFrame__8 = script:WaitForChild("ToolFrame")
local l__Parent__9 = script.Parent
local l__MainFrame__10 = l__Parent__9:WaitForChild("MainFrame")
local l__BackpackFrame__11 = l__Parent__9:WaitForChild("BackpackFrame")
local l__ScrollingFrame__12 = l__BackpackFrame__11:WaitForChild("ScrollingFrame")
local l__Container__13 = l__Parent__9.Parent:WaitForChild("StatGui"):WaitForChild("Container")
local l__UIGridLayout__1 = l__ScrollingFrame__12:WaitForChild("UIGridLayout")
local function u2()
	l__ScrollingFrame__12.CanvasSize = UDim2.new(0, 0, 0, l__UIGridLayout__1.AbsoluteContentSize.Y + 16)
end
l__UIGridLayout__1.Changed:connect(function()
	u2()
end)
u2()
local l__GetChildren__3 = game.GetChildren
local l__IsA__4 = game.IsA
local u5 = {}
local function u6(p1, p2)
	local v14 = l__GetChildren__3(p1)
	for v15 = 1, #v14 do
		local v16 = v14[v15]
		if v16.Name == p2 and l__IsA__4(v16, "Tool") then
			return v16
		end
	end
end
local u7 = nil
local u8 = game.ReplicatedStorage.Requests.Get:InvokeServer({"SlotData"})
pcall(function()
	u7 = game.HttpService:JSONDecode(u8.SlotData)
end)
if not u7 then
	u7 = {}
end
local v17 = {}
for v18 = 1, 12 do
	local v19 = script.SlotMarker:clone()
	v19.Visible = false
	v19.Position = UDim2.new((v18 - 1) / 11, 0, 0, 0)
	v19.Parent = l__MainFrame__10
	v17[v18] = v19
end
local u9 = {}
local u10 = {}
local u11 = nil
local u12 = false
local u13 = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=" }
local function u14()

	game.ReplicatedStorage.Requests.UpdateSlotData:FireServer(u7)

end

local ToolFrameColor = Color3.fromRGB(215,203,191)
local MoneyToolFrameColor = Color3.fromRGB(206,213,216)

local ToolFrameColorSel = Color3.fromRGB(255,248,238)
local MoneyToolFrameColorSel = Color3.fromRGB(238,248,255)

local TextLabelColor = Color3.fromRGB(255,221,162)
local MoneyTextLabelColor = Color3.fromRGB(199,243,255)

local function u15(p3)
	local v20 = 0
	for v21 = 1, 12 do
		if u9[v21] then
			v20 = v20 + 1
		end
	end
	local v22 = l__Backpack__2:GetChildren()
	local v23 = v5:FindFirstChildOfClass("Tool")
	if v23 then
		table.insert(v22, v23)
	end
	local v24 = {}
	local l__next__25 = next
	local v26 = nil
	for i,v in pairs(v22)do
		local l__Name__29 = v.Name
		local l__Quantity__30 = v:FindFirstChild("Quantity")
		local v31 = l__Quantity__30 and l__Quantity__30.Value or 1
		local v32 = v24[l__Name__29]
		v24[l__Name__29] = v32 and v32 + v31 or v31	
	end
	local v33 = 0
	for v34 = 1, 12 do
		local v35 = u9[v34]
		local v36 = v35 and u10[v35]
		if v36 then
			v33 = v33 + 1
			local l__frame__37 = v36.frame
			if l__frame__37 and u11 ~= v35 then
				local v38 = v20 > 1 and (v33 - 1) / (v20 - 1) or 0
				if u12 then
					v38 = (v34 - 1) / 11
				end
				l__frame__37.Slot.Text = u13[v34]
				if string.find(l__frame__37.Slot.Text, "Poisonous") or string.find(l__frame__37.Slot.Text, "Demisesous") then
					l__frame__37.Slot.Text = "Meat"
				end
				l__frame__37.Position = UDim2.new(v38, 0, 0, 0)
				l__frame__37.Slot.Visible = true
				l__frame__37.Parent = l__MainFrame__10
				local v39 = v17[v34]
				if v39 then
					v39.Visible = false
				end
			end
		else
			local v40 = v17[v34]
			if v40 then
				v40.Visible = u12
			end
		end
	end
	for v41, v42 in next, u10 do
		local l__frame__43 = v42.frame
		if l__frame__43 then
			local v44 = v24[v41]
			if v44 then
				l__frame__43.Quantity.Text = string.format("x%i", v44)
				l__frame__43.Quantity.Visible = v44 > 1

				if string.find(tostring(l__frame__43),"Vocare") then
					l__frame__43.Quantity.Visible = true
				end
			end
			if u11 ~= v41 then
				local v45 = nil
				v45 = game.CollectionService:HasTag(l__frame__43, "BPSelected")
				if v5:FindFirstChild(v41) then
					if not v45 then
						local c = nil
						if not l__LocalPlayer__1:FindFirstChild("MoneyUI")then
							c = ToolFrameColorSel
						else
							c = MoneyToolFrameColorSel
						end
						game.TweenService:Create(l__frame__43, TweenInfo.new(0.1), {
							BackgroundColor3 = c,
							TextTransparency = 0,
						}):Play()
						game.TweenService:Create(l__frame__43.Overlay, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
							Size = UDim2.new(1, 10, 1, 10),
						}):Play()
						game.CollectionService:AddTag(l__frame__43, "BPSelected")
					end
				elseif v45 then
					local c = nil
					if not l__LocalPlayer__1:FindFirstChild("MoneyUI")then
						c = ToolFrameColor
					else
						c = MoneyToolFrameColor
					end
					game.TweenService:Create(l__frame__43, TweenInfo.new(0.1), {
						BackgroundColor3 = c,
						TextTransparency = 0.2
					}):Play()
					game.TweenService:Create(l__frame__43.Overlay, TweenInfo.new(0.1), {
						Size = UDim2.new(1, 6, 1, 6)
					}):Play()
					game.CollectionService:RemoveTag(l__frame__43, "BPSelected")
				else
					if not l__LocalPlayer__1:FindFirstChild("MoneyUI")then
						l__frame__43.BackgroundColor3 = Color3.fromRGB(215, 203, 191)
					else
						l__frame__43.BackgroundColor3 = MoneyToolFrameColor
					end
					l__frame__43.TextTransparency = 0.2
					l__frame__43.Overlay.Size = UDim2.new(1, 6, 1, 6)
				end
				if not v42.slot then
					l__frame__43.Slot.Visible = false
					l__frame__43.Parent = l__ScrollingFrame__12
				end
			end
		end
	end
	local v46 = v20 > 1 and 72 * (v20 - 1) or 0
	if u12 then
		v46 = 792
	end
	l__MainFrame__10.Size = UDim2.new(0, v46, 0, 60)
	l__BackpackFrame__11.Visible = u12
end
local function u16(p4)
	local v47 = 6
	if p4:FindFirstChild("PrimaryWeapon") then
		return 0
	end
	if p4:FindFirstChild("Skill") then
		return 1
	end
	if p4:FindFirstChild("Spell") then
		return 2
	end
	if p4:FindFirstChild("Item") then
		return 3
	end
	if p4:FindFirstChild("Trinket") then
		return 4
	end
	if p4:FindFirstChild("isIngredient") then
		v47 = 5
	end
	return v47
end
local function u17(p5)
	local v48 = tick()
	local v49 = u5[p5]
	if v49 and v48 < v49 then
		return
	end
	local v50 = v5:FindFirstChild(p5)
	if v50 then
		if v50:FindFirstChild("Handle") then
			u5[p5] = v48 + 0.2
		end
		l__Humanoid__6:UnequipTools()
		return
	end
	local v51 = u6(l__Backpack__2, p5)
	if v51 then
		if v51:FindFirstChild("Handle") then
			u5[p5] = v48 + 0.2
		end
		l__Humanoid__6:EquipTool(v51)
	end
end
local l__CurrentCamera__18 = workspace.CurrentCamera
local function u19(p6, p7, p8)
	local v52 = u10[p7]
	if not v52 then
		return
	end
	local l__slot__53 = v52.slot
	if l__slot__53 then
		u9[l__slot__53] = nil
		u7[tostring(l__slot__53)] = nil
	end
	if p6 then
		local v54 = u9[p6]
		if v54 then
			local v55 = u10[v54]
			if v55 then
				if l__slot__53 then
					u9[l__slot__53] = v54
					u7[tostring(l__slot__53)] = v54
				end
				v55.slot = l__slot__53
			end
		end
		u9[p6] = p7
		u7[tostring(p6)] = p7
	end
	v52.slot = p6
	if not p8 then
		u14()
	end
end
local u20 = {
	[Enum.KeyCode.One] = 1, 
	[Enum.KeyCode.Two] = 2, 
	[Enum.KeyCode.Three] = 3, 
	[Enum.KeyCode.Four] = 4, 
	[Enum.KeyCode.Five] = 5, 
	[Enum.KeyCode.Six] = 6, 
	[Enum.KeyCode.Seven] = 7, 
	[Enum.KeyCode.Eight] = 8, 
	[Enum.KeyCode.Nine] = 9, 
	[Enum.KeyCode.Zero] = 10, 
	[Enum.KeyCode.Minus] = 11, 
	[Enum.KeyCode.Equals] = 12
}
game.ReplicatedStorage.Requests.OpenBackpack.OnClientEvent:Connect(function()
	u12 = not u12
	l__Container__13.Visible = not u12
	u15()
end)
l__UserInputService__3.InputBegan:connect(function(p9, p10)
	if p10 then
		return
	end
	local v56 = u20[p9.KeyCode]
	local v57 = v56 and u9[v56]
	if v57 then
		u17(v57)
		u15()
		return
	end
	if p9.KeyCode.Value == Enum.KeyCode.Backquote.Value or p9.KeyCode.Value == Enum.KeyCode.M.Value then
		u12 = not u12
		l__Container__13.Visible = not u12
		u15()
	end
end)
l__UserInputService__3.InputEnded:connect(function(p11)
	if p11.UserInputType == Enum.UserInputType.MouseButton1 then
		u11 = nil
	end
end)
local function u21(p12, p13)
	if not p12.Parent then
		return
	end
	local l__Name__58 = p12.Name
	local v59 = u10[l__Name__58]
	if v59 then
		return
	end
	local v60 = l__ToolFrame__8:clone()
	v60.Text = l__Name__58
	if string.find(v60.Text, "Poisonous") or string.find(v60.Text, "Demisesous") then
		v60.Text = "Meat"
	end
	local v61 = u16(p12)
	v60.Name = v61 .. l__Name__58
	local u22 = v59
	v60.MouseButton1Down:connect(function()
		if u11 then
			return
		end
		if not u12 then
			u17(l__Name__58)
			u15()
			return
		end
		local l__slot__62 = u22.slot
		u11 = l__Name__58
		if not l__LocalPlayer__1:FindFirstChild("MoneyUI")then
			v60.BackgroundColor3 = Color3.fromRGB(255, 248, 238)
		else
			v60.BackgroundColor3 = MoneyToolFrameColorSel
		end
		v60.Parent = l__Parent__9
		for v64 = 1, 12 do
			local v65 = u9[v64]
			local v66 = v65 and u10[v65]
			local v67 = v17[v64]
			if v67 then
				v67.Visible = not v66 or not v66.frame or v64 == l__slot__62
			end
		end
		while true do
			local v68 = l__UserInputService__3:GetMouseLocation()
			local v69 = Vector2.new(v68.X, v68.Y)
			v60.Position = UDim2.new(0, v69.X, 0, v69.Y)
			local l__ViewportSize__70 = l__CurrentCamera__18.ViewportSize
			local v71 = l__ViewportSize__70.Y - 70
			local v72 = false
			if v71 - 5 < v68.Y then
				v72 = v68.Y < v71 + 65
			end
			local v73 = (v69.X - ((l__ViewportSize__70 / 2).X - 396)) / 792 * 11 + 1
			local v74 = v73 - math.floor(v73) > 0.5 and math.ceil(v73) or math.floor(v73)
			v75 = nil
			if v74 >= 1 and v74 <= 12 and v72 then
				v75 = v74
			end
			l__RunService__4.RenderStepped:wait()
			if not u11 then
				break
			end		
		end
		if v75 == l__slot__62 then
			u17(l__Name__58)
		else
			u19(v75, l__Name__58)
		end
		u15()
	end)
	u22 = {
		frame = v60, 
		tooltype = v61
	}
	u10[l__Name__58] = u22
	local l__Quantity__76 = p12:FindFirstChild("Quantity")
	if l__Quantity__76 then
		u22.quantityCon = l__Quantity__76.Changed:connect(function()
			u15()
		end)
	end
	local v77 = false
	for i,v in pairs(u7)do
		local v82 = type(i) == "number" and i or tonumber(i)
		if v82 and v == l__Name__58 then
			u19(v82, l__Name__58, true)
			v77 = true
			break
		end	
	end
	if not v77 and p13 then
		for v83 = 1, 12 do
			if not u9[v83] then
				u19(v83, l__Name__58, true)
				break
			end
		end
	end
	u15()
	return v59
end
l__Backpack__2.ChildAdded:connect(function(p14)
	if not p14:IsA("Tool") then
		return
	end
	if u10[p14.Name] then
		u15()
		return
	end
	wait()
	u21(p14, true)
	u14()
end)
local function u23(p15, onlyclear)
	local v84 = u10[p15]
	if not v84 then
		return
	end
	if v5:FindFirstChild(p15) or u6(l__Backpack__2, p15) then
		return
	end
	if onlyclear then
		local v85 = v84.tooltype and 6
		v84.frame:Destroy()
		local l__quantityCon__87 = v84.quantityCon
		if l__quantityCon__87 then
			l__quantityCon__87:disconnect()
		end
		u10[p15] = nil
		return
	end
	local v85 = v84.tooltype and 6
	u10[p15] = nil
	v84.frame:Destroy()
	local l__slot__86 = v84.slot
	if l__slot__86 and u9[l__slot__86] == p15 and v85 ~= 1 and v85 ~= 2 and v85 ~= 0 then
		u9[l__slot__86] = nil
		u7[tostring(l__slot__86)] = nil
	end
	local l__quantityCon__87 = v84.quantityCon
	if l__quantityCon__87 then
		l__quantityCon__87:disconnect()
	end

	u15()
	u14()

	return true
end
l__Backpack__2.ChildRemoved:connect(function(p16)
	if not p16:IsA("Tool") then
		return
	end
	if l__LocalPlayer__1:FindFirstChild("UsedVerto") then 
		local l__Name__88 = p16.Name
		u23(l__Name__88, true)
		return
	end
	local l__Name__88 = p16.Name
	if not u10[l__Name__88] then
		u15()
		return
	end
	u23(l__Name__88)
end)
v5.ChildAdded:connect(function(p17)
	if not p17:IsA("Tool") then
		return
	end
	if u10[p17.Name] then
		u15()
		return
	end
	wait()
	u21(p17, true)
	u14()
end)
v5.ChildRemoved:connect(function(p18)
	if not p18:IsA("Tool") then
		return
	end
	local l__Name__89 = p18.Name
	if not u10[l__Name__89] then
		u15()
		return
	end
	u23(l__Name__89)
end)
local v90 = not (not next(u7))
local v91 = l__Backpack__2:GetChildren()
for v92 = 1, #v91 do
	local v93 = v91[v92]
	if v93 and v93:IsA("Tool") and not u21(v93, not v90) then
		u15(true)
	end
end
if not v90 then
	u14()
end