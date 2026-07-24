local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");
local Player = script:WaitForChild("Player");
local Parent = script.Parent;
local ScrollingFrame = Parent:WaitForChild("PlayerFrame"):WaitForChild("ScrollingFrame");
local UIListLayout = ScrollingFrame:WaitForChild("UIListLayout");
local Ban = Parent:WaitForChild("Ban");
local infoFrame = Parent:WaitForChild("InfoFrame")
local lastGrips = Parent:WaitForChild("LastGrips")
local CommandBar = Parent:WaitForChild("CommandBar");
local Bar = CommandBar:WaitForChild("Bar");
local Indicator0 = Parent:WaitForChild("Indicator");
Indicator0.Visible = false;
Ban.Visible = false;
local Output = CommandBar:WaitForChild("Output");
local plr = game.Players.LocalPlayer
local player = plr
repeat wait() until plr.Character
local character = plr.Character
repeat wait() until character:FindFirstChild("HumanoidRootPart")
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) 

Parent.Enabled = false

Bar.FocusLost:connect(function(p1)
	if p1 then
		--print(Bar.Text)
		local Text = Bar.Text
		local v11, v12 = game.ReplicatedStorage.Requests.Command:InvokeServer(Text)
		Bar.Text = "";
		if v11 or v12 then
			if v11 and not v12 then
				v12 = "Command Successful";
			end;
			Output.Text = v12;
			spawn(function()
				wait(5);
				if Output.Text == v12 then
					Output.Text = "";
				end;
			end);
		end;
	end;
end);
local Enum_Material_Air = Enum.Material.Air;
local u3 = Enum.HumanoidStateType.None;
local u4 = Enum.HumanoidStateType.StrafingNoPhysics;
local function v13(p2, p3)
	local Position4 = p2.Position;
	local v15, v16 = workspace:FindPartOnRay(Ray.new(Position4, Vector3.new(0, -15, 0)), p2.Parent);
	local v17 = p3:GetState();
	if v15 then
		if (not v15 or not v16 or not ((Position4 - v16).Magnitude > 10) or p3.FloorMaterial ~= Enum_Material_Air) and v17 ~= u3 and v17 ~= u4 then
			return;
		end;
	elseif p3.FloorMaterial ~= Enum_Material_Air and v17 ~= u3 and v17 ~= u4 then
		return;
	end;
	return true;
end;
UIListLayout.Changed:connect(function()
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y);
end);
local Spectating = nil;
local LocalPlayer = Players.LocalPlayer;
local CurrentCamera = workspace.CurrentCamera;
Ban.MouseButton1Click:connect(function()
	if Spectating then
		game.ReplicatedStorage.Requests.Command:InvokeServer('ban ' .. Spectating.Name)
	end;
end);

function getTimeStamp(t)
	local osDate = os.date("!*t",t or nil)
	local year = osDate["year"]
	local month = string.format("%0" .. 2 .. "i", osDate["month"])
	local day = string.format("%0" .. 2 .. "i", osDate["day"])

	return year .. "/" .. month .. "/" .. day
end

infoFrame.ShowLastGrips.Title.MouseButton1Click:Connect(function()
	lastGrips.Visible = not lastGrips.Visible
end)

local u8 = {};
local function swapSpectate(toSpectate)
	if not toSpectate then
		return;
	end;
	if Spectating and Spectating.Name == toSpectate.Name then
		Spectating = nil
		local Character = LocalPlayer.Character
		local Hum = Character and Character:FindFirstChild("Humanoid")
		if Hum then
			CurrentCamera.CameraSubject = Hum
		end
		Indicator0.Visible = false
		Ban.Visible = false
		infoFrame.Visible = false
		lastGrips.Visible = false
		return
	end
	Spectating = toSpectate
	local Character = toSpectate.Character
	local Hum = Character and Character:FindFirstChild("Humanoid")
	if Hum then
		CurrentCamera.CameraSubject = Hum
	end;
	Indicator0.Text = "Currently Spectating: " .. toSpectate.Name
	Indicator0.Visible = true
	Ban.Visible = true
	task.spawn(function()
		while Spectating == toSpectate do
			local pData = game.ReplicatedStorage.Requests.GetMMInfo:InvokeServer(toSpectate)
			if Spectating ~= toSpectate then break end
			if pData then
				infoFrame.Class.Val.Text = pData.Class
				infoFrame.CharacterName.Val.Text = pData.CharacterName
				infoFrame.Race.Val.Text = pData.Race
				infoFrame.Edict.Val.Text = pData.Edict
				infoFrame.FirstJoin.Val.Text = getTimeStamp(pData.FirstJoin)
				infoFrame.Days.Val.Text = pData.Days
				if pData.Shifted == false then
					infoFrame.Shifted.Val.Text = "false"
					infoFrame.Shifted.Val.TextColor3 = Color3.fromRGB(255, 0, 0)
				else
					infoFrame.Shifted.Val.Text = pData.Shifted
					infoFrame.Shifted.Val.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
				infoFrame.TotalGrips.Val.Text = pData.TotalGrips
				if pData.SpecWhitelist == false then
					infoFrame.SpecWhitelist.Val.Text = "false"
					infoFrame.SpecWhitelist.Val.TextColor3 = Color3.fromRGB(255, 0, 0)
				else
					infoFrame.SpecWhitelist.Val.Text = "true"
					infoFrame.SpecWhitelist.Val.TextColor3 = Color3.fromRGB(0, 255, 0)
				end
				infoFrame.AdminLevel.Val.Text = pData.AdminLevel

				for _,v in lastGrips:GetChildren() do
					if v:IsA("Frame") then v:Destroy() end
				end

				for _,v in game.HttpService:JSONDecode(pData.LastGrips) do
					local z = script.Grip:Clone()
					z.user.Text = v.killer
					z.date.Text = getTimeStamp(v.tim)
					z.Name = v.tim
					z.Parent = lastGrips
				end
				infoFrame.Visible = true
			end
			task.wait(5)
		end
	end)
end;
Players.PlayerRemoving:connect(function(p5)
	local v22 = u8[p5];
	if v22 then
		u8[p5] = nil;
		local fm3 = v22.fm;
		if fm3 then
			fm3:Destroy();
		end;
	end;
end);
local function u10(p6)
	if p6 == LocalPlayer then
		return;
	end;
	local v24 = Player:clone();
	v24.Text = p6.Name .. ": ?/s ?mp";
	v24.Name = p6.Name;
	v24.Parent = ScrollingFrame;
	v24.MouseButton1Click:connect(function()
		swapSpectate(p6);
	end);
	u8[p6] = {
		fm = v24, 
		lps = Vector3.new()
	};
end;
Players.PlayerAdded:connect(function(p7)
	u10(p7)
end)
for i, v in next, Players:GetPlayers() do
	u10(v)
end
for i, v in next, Players:GetPlayers() do
	if not ScrollingFrame:FindFirstChild(v.Name) then
		coroutine.wrap(function()
			repeat wait() until v.Character
			--	repeat wait() until v.PlayerName.Value ~= ""
			u10(v);
		end)()
	end
end;
local on = false
UserInputService.InputBegan:connect(function(p8, p9)
	if p9 then
		return;
	end;
	if p8.KeyCode == Enum.KeyCode.Tab then
		Parent.Enabled = not Parent.Enabled;
		on = Parent.Enabled
		local Character0 = LocalPlayer.Character;
		local v31 = Character0 and Character0:FindFirstChild("Humanoid");
		if v31 then
			CurrentCamera.CameraSubject = v31;
		end;
	end;
end);
while wait(0.5) do
	for v34, v35 in next, u8 do
		local v36 = v35 and v35.fm;
		local v37 = v35 and v35.lps;
		local Character8 = v34.Character;
		if v36 and v36.Parent and v37 and Character8 then
			local Head9 = Character8:FindFirstChild("Head");
			local v40 = Head9 and Character8:FindFirstChild("Humanoid");
			if v40 then
				local Position1 = Head9.Position;
				local v42 = math.ceil((v37 - Position1).magnitude * 2);
				local Mana3 = Character8:WaitForChild("Mana")
				local v44 = Mana3 and math.floor(Mana3.Value * 10) / 10 or "???";
				v36.TextColor3 = (v13(Head9, v40) or v42 > 100) and Color3.new(1, 0, 0) or Color3.new(1, 1, 1);
				v36.Text = v34.Name .. ": " .. v42 .. "/s " .. v44 .. "mp";
				pcall(function()
					if type(v44) ~= "number" then
						v36.ManaBar.Visible = false;
						return;
					end;
					v36.ManaBar.Visible = true;
					game.TweenService:Create(v36.ManaBar.Scaler, TweenInfo.new(0.3), {
						Size = UDim2.new(math.clamp(v44 / 100, 0, 1), 0, 1, 0)
					}):Play();
				end);
				v35.lps = Position1;
			end;
		end;
	end

	if Spectating and Spectating.Parent then
		local Character5 = Spectating.Character;
		local v46 = Character5 and Character5:FindFirstChild("Humanoid");
		if v46 and script.Parent.Enabled == true then
			CurrentCamera.CameraSubject = v46;
		end;
	end;
end;