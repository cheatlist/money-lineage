local Holder = script.Parent.MainFrame
local Close = script.Parent.Frame.Close
local tpgui = script.tp
local Sort = script.Parent.Frame.Sort

local function process(inst)
	inst:WaitForChild("Players")
	inst:WaitForChild("Ranks")
	inst:WaitForChild("ServerName")
	inst:WaitForChild("Age")
	inst:WaitForChild("HouseMajority")
	local b
	local paren = true
	if inst.ServerName.Value == game.ReplicatedStorage.ServerName.Value then  
		b = script.Parent.Frame.CurrServer
		paren = false
	elseif Holder:FindFirstChild(inst.Name) then
		b = Holder:FindFirstChild(inst.Name)
		paren = false
	else
		b = script.Template:Clone()
		b.Name = inst.Name
	end
	local plrs
	if inst.Players.Value >= game.Players.MaxPlayers then
		plrs = "MAX"
	else
		plrs = inst.Players.Value.. " Players"
	end
	b.Frame.Players.Text = plrs
	b.Frame.HouseMajority.Text = "House Majority: ".. inst.HouseMajority.Value
	b.Frame.plr.Value = inst.Players.Value
	b.Frame.Ranked.Text = inst.Ranks.Value.. " Ranked"
	b.ServerName.Text = "<i>".. inst.ServerName.Value .."</i>"
	b.Age.Text = "Approx Age: "..inst.Age.Value
	if inst.ServerName.Value ~= game.ReplicatedStorage.ServerName.Value then
		b.MouseButton1Click:Connect(function()
			if not game.Players.LocalPlayer:FindFirstChild("recenttp") then
				game.ReplicatedStorage.toServer:FireServer(b.Name)
				tpgui.Parent = game.Players.LocalPlayer.PlayerGui
				tpgui.Enabled = true
				tpgui.LoadingGui.Disabled = false
			end
		end)
	end
	b.MouseEnter:Connect(function()
		game.TweenService:Create(b.ImageLabel,TweenInfo.new(.6),{ImageTransparency = 0.95}):Play()
	end)
	b.MouseLeave:Connect(function()
		game.TweenService:Create(b.ImageLabel,TweenInfo.new(.6),{ImageTransparency = 0.8}):Play()
	end)
	if paren then
		b.Parent = Holder
	end
	sorter()
end

if  game.ReplicatedStorage.ServerName.Value == "Private Server" then
	script.Parent.Frame.CurrServer.Visible = false
end

script.Parent.Frame.CurrentServer.Text = game.ReplicatedStorage.ServerName.Value
game.ReplicatedStorage.ServerName.Changed:Connect(function()
	if game.ReplicatedStorage.ServerName.Value == "Private Server" then
		script.Parent.Frame.CurrServer.Visible = false
	else
		script.Parent.Frame.CurrServer.Visible = true
	end
	script.Parent.Frame.CurrentServer.Text = game.ReplicatedStorage.ServerName.Value
end)
Close.MouseButton1Click:Connect(function()
	script.Parent.Enabled = false
end)
--<i></i>
game.ReplicatedStorage.toServer.OnClientEvent:Connect(function(errmsg)
	tpgui.LoadingGui.Disabled = true
	tpgui.Enabled = false
	tpgui.Parent = script
	task.spawn(function()
		local f = Instance.new("Accessory")
		f.Name = "tpfail"
		f.Parent = game.Players.LocalPlayer
		task.wait(1)
		local ete = script.Parent.Frame.Error:clone()
		ete.Text = errmsg
		ete.Visible = true
		local tw = game.TweenService:Create(ete, TweenInfo.new(2.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextStrokeTransparency = 1, TextTransparency = 0, Position = UDim2.new(0.493, 0, 1.023, 34)}):Play()
		game.Debris:AddItem(ete, 3)
	end)
end)

local sort = "Name"
Sort.MouseButton1Click:Connect(function()
	for _,v in pairs(game.ReplicatedStorage.Servers:GetChildren()) do
		process(v)
	end
	if sort == "Name" then
		sort = "Players"
		Sort.Text = "Sort by: Players"
	elseif sort == "Players" then
		sort = "Rank"
		Sort.Text = "Sort by: Ranked"
	elseif sort == "Rank" then
		sort = "Name"
		Sort.Text = "Sort by: Name"
	end
	sorter()
end)

function sorter()
	local srs = {}
	for _,v in pairs(Holder:GetChildren()) do
		if v:IsA("TextButton") then
			table.insert(srs, {instance = v, Name = string.gsub(v.ServerName.Text,"<i>",""), Players = v.Frame.plr.Value, Rank = string.gsub(v.Frame.Ranked.Text," Ranked","")})
		end
	end
	table.sort(srs, function(a,b)
		if sort == "Name" then
			return a[sort] < b[sort]
		else
			return a[sort] > b[sort]
		end
	end)
	for i,v in pairs(srs) do
		v.instance.LayoutOrder = i
	end
end
for _,v in pairs(game.ReplicatedStorage.Servers:GetChildren()) do
	process(v)
	for _,z in v:GetChildren() do
		z.Changed:Connect(function()
			process(v)
		end)
	end
end
game.ReplicatedStorage.Servers.ChildAdded:Connect(function(inst)
	process(inst)
	for _,z in inst:GetChildren() do
		z.Changed:Connect(function()
			process(inst)
		end)
	end
end)
game.ReplicatedStorage.Servers.ChildRemoved:Connect(function(inst)
	local z = Holder:FindFirstChild(inst.Name)
	if z then z:Destroy() end
end)
