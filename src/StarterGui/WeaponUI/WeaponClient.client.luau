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
local SelectedWeapon = nil

game.Players.LocalPlayer:WaitForChild("GetWeaponSelection", 9999).OnClientInvoke = function()
	return SelectedWeapon
end

local MainFrame = script.Parent:WaitForChild("MainFrame")
local WeaponFrame = script:WaitForChild("Weapon")

local Weapons = game.HttpService:JSONDecode(game.ReplicatedStorage.Requests.Get:InvokeServer({"SpecMeta"}).SpecMeta)

function Refresh(reload)
	local list = {}
	
	for i, v in pairs(Weapons) do
		table.insert(list, i)
	end
	table.sort(list)

	if SelectedWeapon then
		if not Weapons[SelectedWeapon] then
			SelectedWeapon = list[1]
		end
	else
		SelectedWeapon = list[1]
	end

	for i, v in pairs(MainFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for i, v in pairs(list) do
		local Frame = WeaponFrame:Clone()
		Frame.Parent = MainFrame
		Frame.Text = v
		
		Frame.TextLabel.Text = Weapons[v]

		if v == SelectedWeapon then
			Frame.TextTransparency = 0
		else
			Frame.TextTransparency = 0.5
		end
		Frame.MouseButton1Click:Connect(function()
			SelectedWeapon = v
			Refresh()
		end)
	end
end

game.ReplicatedStorage.Requests.SpecMetaChanged.OnClientEvent:Connect(function(Table)
	local Info = game.HttpService:JSONDecode(Table)
	if Info then
		Weapons = Info
	end
	Refresh()
end)
Refresh()

