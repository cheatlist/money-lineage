game.Players.LocalPlayer.ChildRemoved:Connect(function(ch)
	if ch.Name == "Ingame" then
		script.Parent:Destroy()
	end
end)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait();
local l__Parent__2 = script.Parent;

local function OffsetToScale(Offset)
	local ViewPortSize = workspace.Camera.ViewportSize
	return ({Offset[1] / ViewPortSize.X, Offset[2] / ViewPortSize.Y})
end

ReplicatedStorage.Requests.CheckClient.OnClientInvoke = function()
	return true;
end;
local l__ErrorFrame__1 = l__Parent__2.ErrorFrame;
local l__TweenService__2 = game:GetService("TweenService");
ReplicatedStorage.Requests.BardBegin.OnClientEvent:Connect(function(p1, p2)
	local v3, count, zindexCount = nil, 0, 1000;
	local v4 = require(ReplicatedStorage.Info.Songs[p1]);
	v3 = 0;
	for v5 = 1, #p1 do
		v3 = v3 + string.byte(p1, v5, v5) * v5;
	end;
	

	
	local l__noteSize__6 = v4.noteSize;
	local newType = v4.newType or false
	local errorRange = v4.errorRange or 0.15
	
	while p2 and p2.Parent and p2.IsPlaying do
		local v7 = Random.new();
		local v9 = 0;
		local u3 = nil;
		local u4 = v7:NextInteger(20, 60) / 100;
		local u5 = v7:NextInteger(25, 60) / 100;
		local u6 = nil;
		local u7 = nil;
		local function v10()
			local v11 = nil;
			u3 = v7:NextInteger(2, 2);
			local v12 = {
				x = u4, 
				y = u5
			};
			u6 = {
				x = v7:NextInteger(50, 100) / 100, 
				y = v7:NextInteger(50, 100) / 100
			};
			if v7:NextInteger(0, 1) == 0 then
				u6.x = u6.x * -1;
			end;
			if v7:NextInteger(0, 1) == 0 then
				u6.x = u6.y * -1;
			end;
			v11 = p2.TimePosition;
			if u3 == 1 then
				u7 = function(p3)
					u4 = v12.x + u6.x * (p3 - v11) * 0.4;
					u5 = v12.y + u6.y * (p3 - v11) * 0.4;
				end;
				return;
			end;
			if u3 == 2 then
				u7 = function(p4)
					u4 = v12.x + u6.x * math.cos(p4 - v11) * 0.4;
					u5 = v12.y + u6.y * math.sin(p4 - v11) * 0.4;
				end;
			end;
		end;
		v10();
		local v13 = {};
		local v14 = 0;
		local u11 = 0;
		local u10 = v14;
		
		l__ErrorFrame__1.Size = UDim2.new(0.45, 0, 0.05, 0);
		for v15, v16 in pairs(v4.data) do
			local v17 = v16[1];
			local v18 = v16[2];
			local v19 = v16[3];
			if (v17 - p2.TimePosition > 0.8 or p2.TimePosition > 1.2) or newType then
				local v20 = nil;
				while true do
					v20 = v17 - p2.TimePosition;
					wait();
					if v20 < (newType and 1 or 1) then
						break;
					end;				
				end
				local v21 = 1;
				if v17 - v9 > 2 then
					v9 = v17;
					v10();
				else
					v21 = 0 + 1;
				end;
				l__ErrorFrame__1.Visible = true;
				u7(v17);
				local v22 = false;
				if u4 < 0.2 or u4 > 0.6 then
					u6.x = u6.x * -1;
					v22 = true;
				end;
				if u5 < 0.2 or u5 > 0.6 then
					u6.y = u6.y * -1;
					v22 = true;
				end;
				if v22 then
					u7(v17);
				end;
				if u4 < 0.2 or u4 > 0.6 or u5 < 0.2 or u5 > 0.6 then
					if u4 < 0.2 then
						u4 = v7:NextInteger(20, 30) / 100;
					elseif u4 > 0.6 then
						u4 = v7:NextInteger(50, 60) / 100;
					else
						u4 = u4;
					end;
					if u5 < 0.2 then
						u5 = v7:NextInteger(25, 35) / 100;
					elseif u5 > 0.6 then
						u5 = v7:NextInteger(50, 60) / 100;
					else
						u5 = u5;
					end;
					v10();
				end;
				local v23 = script.Button:Clone();
				if v4.allowsKeys then
					u4 = u4 * 1.2
					u5 = u5 * 1.2
				end
				if newType then
					local ofs = OffsetToScale({v18,v19})
					v23.Position = UDim2.new(ofs[1],0, ofs[2], 0);
				else
					v23.Position = UDim2.new(u4, 0, u5, 0);
				end
				v23.Size = UDim2.new(0, l__noteSize__6, 0, l__noteSize__6, 0);
				if count >= 6 then count = 0 end;
				count += 1
				zindexCount -= 1
				v23.Label.Text = count;
				v23.Label.ZIndex = zindexCount;
				v23.ZIndex = zindexCount;
				local v24 = l__noteSize__6 + v20 * 100;
				v23.OuterRing.Size = UDim2.new(0, v24, 0, v24);
				Debris:AddItem(v23, 1.5);
				table.insert(v13, v23);
				v23.Parent = l__Parent__2;
				l__TweenService__2:Create(v23.OuterRing, TweenInfo.new(v20, Enum.EasingStyle.Linear), {
					Size = UDim2.new(0, l__noteSize__6 * 1.25, 0, l__noteSize__6 * 1.25)
				}):Play();
				local u8 = 0;
				local u9 = false;
				local click = (function()
					if v23:FindFirstChild("Errored") then
						return;
					end;
					
					if math.abs(u4 - v23.Position.X.Scale) > 0.35 or math.abs(u5 - v23.Position.Y.Scale) > 0.3 then
						return;
					end;
					if v23 == v13[1] and math.abs(v17 - p2.TimePosition) < errorRange then
						v23.Active = false;
						v23.ZIndex = -1000 - u8;
						u9 = true;
						l__Parent__2.Click:Play();
						u10 = u10 + 1;
						if u10 >= 4 then
							u11 = math.max(0, u11 - 1);
							u10 = 0;
							l__TweenService__2:Create(l__ErrorFrame__1, TweenInfo.new(0.1), {
								Size = UDim2.new(math.max(0, 0.45 - 0.45 * u11 / v4.maxErrors), 0, 0.05, 0)
							}):Play();
							ReplicatedStorage.Requests.BardStreak:FireServer(30);
						end;
						v23.OuterRing.Visible = false;
						l__TweenService__2:Create(v23, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
							ImageTransparency = 1, 
							Size = UDim2.new(0, l__noteSize__6 * 1.25, 0, l__noteSize__6 * 1.25)
						}):Play();
						Debris:AddItem(v23, 0.2);
					else
						local v25 = v13[1];
						if v25 then
							v25.Active = false;
							v25.ZIndex = -1000 - u8;
							Instance.new("Folder", v25).Name = "Errored";
							l__TweenService__2:Create(v25, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
								ImageColor3 = Color3.fromRGB(255, 0, 0), 
								ImageTransparency = 1, 
								Size = UDim2.new(0, l__noteSize__6 * 1.25, 0, l__noteSize__6 * 1.25)
							}):Play();
							Debris:AddItem(v25, 0.2);
							if v25:FindFirstChild("OuterRing") then
								v25.OuterRing.Visible = false;
							end;
						end;
						
						
						
						u11 = u11 +1;
						u10 = 0;
						l__TweenService__2:Create(l__ErrorFrame__1, TweenInfo.new(0.1), {
							Size = UDim2.new(math.max(0, 0.45 - 0.45 * u11 / v4.maxErrors), 0, 0.05, 0)
						}):Play();
						if v4.maxErrors < u11 then
							ReplicatedStorage.Requests.BardError:FireServer();
						end;
					end;
					table.remove(v13, 1);
				end);
				v23.MouseButton1Click:Connect(click)
				
				if v4.allowsKeys then
					local plr = game.Players.LocalPlayer
					local mouse = Player:GetMouse()

					mouse.KeyDown:Connect(function(key)
						local x = mouse.X
						local y = mouse.Y
						if (key:lower() == 'z' or key:lower() == 'x') and v23.Parent and x>v23.AbsolutePosition.X and y>v23.AbsolutePosition.Y and x<v23.AbsolutePosition.X+v23.AbsoluteSize.X and y<v23.AbsolutePosition.Y+v23.AbsoluteSize.Y then
							click()
						end
					end)
				end
				
				coroutine.wrap(function()
					while true do
						wait()
						local allowTime = -errorRange
						if v4.allowsKeys then
							allowTime = -0.40
						end
						if v17 - p2.TimePosition <= -errorRange then
							break;
						end;					
					end;
					if v23 and v23.Parent and v23 == v13[1] and not u9 and not v23:FindFirstChild("Errored") then
						v23.Active = false;
						v23.ZIndex = -1000 - u8;
						Instance.new("Folder", v23).Name = "Errored";
						l__TweenService__2:Create(v23, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
							ImageColor3 = Color3.fromRGB(255, 0, 0), 
							ImageTransparency = 1, 
							Size = UDim2.new(0, l__noteSize__6 * 1.25, 0, l__noteSize__6 * 1.25)
						}):Play();
						v23.OuterRing.Visible = false;
						Debris:AddItem(v23, 0.2);
						table.remove(v13, 1);
						
						u11 = u11 +1
						u10 = 0;
						
						l__TweenService__2:Create(l__ErrorFrame__1, TweenInfo.new(0.1), {
							Size = UDim2.new(math.max(0, 0.45 - 0.45 * u11 / v4.maxErrors), 0, 0.05, 0)
						}):Play();
						if v4.maxErrors < u11 then
							ReplicatedStorage.Requests.BardError:FireServer();
						end;
					end;
				end)();
			end;
		end;
		while true do
			wait()
			if p2.TimePosition < 0.2 then
				print(p2.TimePosition,"break?")
				break;
			end;		
		end;
		ReplicatedStorage.Requests.BardFinish:FireServer(0, v4.maxErrors < 0);	
	end;
	l__ErrorFrame__1.Visible = false;
	if p2 and p2.Parent and not p2.IsPlaying then
		wait(0.1)
		if p2 and p2.Parent then
			ReplicatedStorage.Requests.BardError:FireServer();
		end;
	end;
end);