local TweenService = game:GetService("TweenService")
local hitDetection = require(game.ServerScriptService.Modules.HitDetection)
local wrap = coroutine.wrap
local v1 = {}
local function create(name,deletetime,parent,accessory)
	local i
	if not accessory then
		i = Instance.new("Accessory")
	else
		i = Instance.new("Accessory")
	end
	i.Name = name
	i.Parent = parent
	if deletetime then
		game.Debris:AddItem(i,deletetime)
	end
	return i
end

function v1.Lightning(p1, p2, p5, p3, p4)
	local v6 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local l__lookVector__7 = CFrame.new(p1, p2).LookVector
	local v8 = (p1 - p2).magnitude / p3
	local v9 = p1
	local v10 = 1 - 1
	task.spawn(function()
		while true do
			local v11 = Instance.new("Part")
			v11.BrickColor = BrickColor.new(p4)
			v11.FormFactor = "Symmetric"
			v11.Size = Vector3.new(1, 1, 1)
			v11.CanCollide = false
			v11.Transparency = 0.2
			v11.Anchored = true
			v11.Material = Enum.Material.Neon
			local v12 = CFrame.new(p1 + l__lookVector__7 * (v10 * v8), p2 + l__lookVector__7) * CFrame.new(math.random(-100, 100) / 100 * v8 / 2, math.random(-100, 100) / 100 * v8 / 2, 0)
			local l__magnitude__13 = (v12.p - v9).magnitude
			local v14 = Instance.new("BlockMesh", v11)
			v14.Scale = Vector3.new(p5, p5, l__magnitude__13 + p5 / 4)
			v11.CFrame = CFrame.new((v12.p + v9) / 2, v12.p)
			v9 = v12.p
			v11.Parent = game.Workspace
			wait()
			TweenService:Create(v14, v6, {
				Scale = Vector3.new(p5 * 2, p5 * 2, l__magnitude__13 + p5 / 4)
			}):Play()
			TweenService:Create(v11, v6, {
				Transparency = 1
			}):Play()
			game.Debris:AddItem(v11, 0.5)
			if 0 <= 1 then
				if v10 < p3 then
				else
					break
				end
			elseif p3 < v10 then
			else
				break
			end
			v10 = v10 + 1	
		end
	end)
end
function v1.Wings(HumanoidRootPart, color3)
	local wing1 = game.ServerStorage.Assets.DragonWing:Clone()
	wing1.CFrame = HumanoidRootPart.CFrame+HumanoidRootPart.CFrame.LookVector*1.25+HumanoidRootPart.CFrame.RightVector*5.75+Vector3.new(0,1.25,0)
	wing1.Color = color3
	wing1.Parent = workspace
	TweenService:Create(wing1,TweenInfo.new(0.25),{Transparency = 0.6,Orientation = wing1.Orientation+Vector3.new(0,-65,0),Position = wing1.Position-wing1.CFrame.LookVector*5-wing1.CFrame.RightVector*2.6}):Play()
	game.Debris:AddItem(wing1, 1)
	local wing2 = game.ServerStorage.Assets.DragonWing:Clone()
	wing2.CFrame = HumanoidRootPart.CFrame+HumanoidRootPart.CFrame.LookVector*1.25+HumanoidRootPart.CFrame.RightVector*-5.75+Vector3.new(0,1.25,0)
	wing2.Orientation = wing2.Orientation+Vector3.new(0,180,0)
	wing2.Color = color3
	wing2.Parent = workspace
	local tw1 = TweenService:Create(wing2,TweenInfo.new(0.25),{Transparency = 0.6,Orientation = wing2.Orientation+Vector3.new(0,65,0),Position = wing2.Position-wing2.CFrame.LookVector*-5-wing2.CFrame.RightVector*2.6})
	tw1:Play()
	game.Debris:AddItem(wing2, 1)
	wrap(function()
		tw1.Completed:Wait()
		TweenService:Create(wing1,TweenInfo.new(0.4),{Transparency = 1}):Play()
		TweenService:Create(wing2,TweenInfo.new(0.4),{Transparency = 1}):Play()
	end)()
end

function v1.HeraldWings(HumanoidRootPart)

	local player = game.Players:GetPlayerFromCharacter(HumanoidRootPart.Parent)

	local wing1 = game.ServerStorage.Assets.HeraldWing:Clone()
	wing1.Parent = HumanoidRootPart
	wing1.Anchored = false
	wing1.CanCollide = false
	wing1:SetNetworkOwner(player)
	local weld1 = Instance.new("Weld", wing1)
	weld1.Part0 = wing1
	weld1.Part1 = HumanoidRootPart.Parent.Torso
	weld1.C1 = CFrame.new(3.75,2,4)*CFrame.Angles(0,math.rad(-45),0)
	local wing2 = game.ServerStorage.Assets.HeraldWing:Clone()
	wing2.Parent = HumanoidRootPart
	wing2.Anchored = false
	wing2.CanCollide = false
	wing2:SetNetworkOwner(player)
	local weld2 = Instance.new("Weld", wing2)
	weld2.Part0 = wing2
	weld2.Part1 = HumanoidRootPart.Parent.Torso
	weld2.C1 = CFrame.new(-3.75,2,4)*CFrame.Angles(0,math.rad(225),0)
	coroutine.wrap(function()
		for i = 1, 10 do
			game:GetService("TweenService"):Create(weld2,TweenInfo.new(1.5),{C1 = CFrame.new(-3.25,2,4.5)*CFrame.Angles(0,math.rad(240),0)}):Play()
			game:GetService("TweenService"):Create(weld1,TweenInfo.new(1.5),{C1 = CFrame.new(3.25,2,4.5)*CFrame.Angles(0,math.rad(-60),0)}):Play()
			wait(1.5)
			game:GetService("TweenService"):Create(weld2,TweenInfo.new(1.25),{C1 = CFrame.new(-3.75,2,4)*CFrame.Angles(0,math.rad(225),0)}):Play()
			game:GetService("TweenService"):Create(weld1,TweenInfo.new(1.25),{C1 = CFrame.new(3.75,2,4)*CFrame.Angles(0,math.rad(-45),0)}):Play()
			wait(1.5)
		end
		game:GetService("TweenService"):Create(wing1,TweenInfo.new(0.2),{Transparency=1}):Play()
		game:GetService("TweenService"):Create(wing2,TweenInfo.new(0.2),{Transparency = 1}):Play()
		game.Debris:AddItem(wing1, 0.3)
		game.Debris:AddItem(wing2,0.3)
	end)()
end

function v1.Wings2(HumanoidRootPart)

	local player = game.Players:GetPlayerFromCharacter(HumanoidRootPart.Parent)

	local wing1 = game.ServerStorage.Assets.DragonWing2:Clone()
	wing1.Parent = HumanoidRootPart
	wing1.Anchored = false
	wing1.CanCollide = false
	wing1:SetNetworkOwner(player)
	local weld1 = Instance.new("Weld", wing1)
	weld1.Part0 = wing1
	weld1.Part1 = HumanoidRootPart.Parent.Torso
	weld1.C1 = CFrame.new(3.75,2,4)*CFrame.Angles(0,math.rad(-45),0)
	local wing2 = game.ServerStorage.Assets.DragonWing2:Clone()
	wing2.Parent = HumanoidRootPart
	wing2.Anchored = false
	wing2.CanCollide = false
	wing2:SetNetworkOwner(player)
	local weld2 = Instance.new("Weld", wing2)
	weld2.Part0 = wing2
	weld2.Part1 = HumanoidRootPart.Parent.Torso
	weld2.C1 = CFrame.new(-3.75,2,4)*CFrame.Angles(0,math.rad(225),0)
	coroutine.wrap(function()
		for i = 1, 10 do
			game:GetService("TweenService"):Create(weld2,TweenInfo.new(1.5),{C1 = CFrame.new(-3.25,2,4.5)*CFrame.Angles(0,math.rad(240),0)}):Play()
			game:GetService("TweenService"):Create(weld1,TweenInfo.new(1.5),{C1 = CFrame.new(3.25,2,4.5)*CFrame.Angles(0,math.rad(-60),0)}):Play()
			wait(1.5)
			game:GetService("TweenService"):Create(weld2,TweenInfo.new(1.25),{C1 = CFrame.new(-3.75,2,4)*CFrame.Angles(0,math.rad(225),0)}):Play()
			game:GetService("TweenService"):Create(weld1,TweenInfo.new(1.25),{C1 = CFrame.new(3.75,2,4)*CFrame.Angles(0,math.rad(-45),0)}):Play()
			wait(1.5)
		end
		game:GetService("TweenService"):Create(wing1,TweenInfo.new(0.2),{Transparency=1}):Play()
		game:GetService("TweenService"):Create(wing2,TweenInfo.new(0.2),{Transparency = 1}):Play()
		game.Debris:AddItem(wing1, 0.3)
		game.Debris:AddItem(wing2,0.3)
	end)()
end

function v1.ColdStrike(p1)
	local s1 = game.ServerStorage.Assets.FairfrozenParticle:Clone()
	s1.Parent = game.Workspace.Thrown
	s1.ColdWind:Play()
	s1.Position = p1.HumanoidRootPart.Position + Vector3.new(0,-5,0)
	game:GetService("Debris"):AddItem(s1,2)
	task.delay(1,function()
		s1.a1.coldpart.Enabled = false
		s1.a2.coldpart.Enabled = false
	end)
end

local function lanniseffect(v)
	local c = v:Clone()
	c:ClearAllChildren()
	c.Anchored = true
	c.CanCollide = false
	c.Transparency = 1
	c.Color = Color3.fromRGB(27,42,53)
	c.Parent = workspace.Thrown
	wrap(function()
		TweenService:Create(c,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency = 0.258,CFrame = c.CFrame * CFrame.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))*CFrame.Angles(math.random(-360,360),math.random(-360,360),math.random(-360,360))}):Play()
		wait(2)
		TweenService:Create(c,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{CFrame = v.CFrame}):Play()
		wait(1)
		TweenService:Create(c,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency = 1}):Play()
		game.Debris:AddItem(c,1.5)
	end)()
end

function v1.sakuraeffect(v,time)
	spawn(function()
		local part = Instance.new("Part")
		part.Parent = workspace
		local oldpartcframe = v.CFrame
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 0.3
		part.Color = Color3.fromRGB(249, 155, 255)
		part.CFrame = v.CFrame
		part.Size = v.Size
		part.Material = Enum.Material.Neon
		game.Debris:AddItem(part, time*2)
		local fakepart = Instance.new("Part")
		fakepart.Parent = workspace
		fakepart.Anchored = true
		fakepart.CanCollide = false
		fakepart.Transparency = 1 
		fakepart.CFrame = v.CFrame + Vector3.new(math.random(-15, 15),math.random(-3, 15),math.random(-15, 15))
		fakepart.Orientation = Vector3.new(math.random(-160, 160),math.random(-160, 160),math.random(-160, 160))
		game.Debris:AddItem(fakepart, 3)
		local goal = {}
		goal.CFrame = fakepart.CFrame
		goal.Transparency = 1
		local tween = game:GetService("TweenService"):Create(part, TweenInfo.new(time/2), goal)
		tween:Play()
		for _,v in pairs(v:GetChildren()) do
			if v:IsA('SpecialMesh') then
				local mesh = v:Clone()
				mesh.Parent = part
				mesh.TextureId = "rbxassetid://0"
				mesh.VertexColor = Vector3.new(part.Color.R,part.Color.G,part.Color.B)
			end
		end
	end)
end

function v1.Lanniseffect3(Character)
	local Root = Character.HumanoidRootPart
	local Parts = {}
	local Descendants = Character:GetChildren()
	local DarkMatter = game.ServerStorage.Assets.DarkMatter:Clone()
	DarkMatter.Parent = Root
	Root.Reverse:Play()
	local Transparency = Instance.new("NumberValue")
	Transparency.Name = "Transparency"
	Transparency.Value = 1
	Transparency.Parent = Character.Boosts
	game.Debris:AddItem(Transparency,3)
	for _,v in pairs(Descendants) do
		if v:IsA("BasePart") and v.Name~="Hilt" and v.Parent.Name ~= "RuneArmLeft" and v.Parent.Name ~= "RuneArmRight" and v.Name ~= "Back" then
			lanniseffect(v)
		end
	end
	task.spawn(function()
		wait(3)
		DarkMatter.Enabled = false
		wait(0.5)
		local Rebirth = game.ServerStorage.Assets.Rebirth:Clone()
		Rebirth.Parent = Root
		Rebirth:Play()
		game.Debris:AddItem(Rebirth,2)
		game.Debris:AddItem(DarkMatter,2)
	end)
end
function v1.Lannis(Character)
	local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Character.Name) 
	if PlayerData and PlayerData.Artifact.Value == "Lannis" and PlayerData.Race.Value == "Howler" then 
		create("Immortal",3.5,Character)
		create("LannisCD",30,Character,true)
		create("canmanashield", 3.5, Character)
	elseif PlayerData and PlayerData.Artifact.Value == "Lannis" and PlayerData.Race.Value ~= "Howler" then
		create("Immortal",3.5,Character)
		create("LannisCD",40,Character,true)
		create("canmanashield", 3.5, Character)
	end
	
	local Root = Character.HumanoidRootPart
	local Parts = {}
	local Descendants = Character:GetDescendants()
	local DarkMatter = game.ServerStorage.Assets.DarkMatter:Clone()
	DarkMatter.Parent = Root
	Root.Reverse:Play()
	local Transparency = Instance.new("NumberValue")
	Transparency.Name = "Transparency"
	Transparency.Value = 1
	Transparency.Parent = Character.Boosts
	game.Debris:AddItem(Transparency,3)
	--[[for i = 1,#Descendants do
		local v = Descendants[i]
		if v:IsA("BasePart") and not (v.Parent.ClassName == "Accessory" or v.Parent.Parent.ClassName == "Accessory") and v.Name~="Hilt" and v.Parent.Name ~= "RuneArmLeft" and v.Parent.Name ~= "RuneArmRight" and v.Name ~= "Back" or v.Parent.Name == "Sigil Helmet" or v.Name == 'ScroomHead' then
			if v.Name == 'Head' and v.Transparency == 1 then continue end
			lanniseffect(v)
		end
	end]]
	for i = 1, #Descendants do
		local v = Descendants[i]
		if v:IsA('BasePart') and v.Transparency ~= 1 and not (v.Parent.ClassName == 'Accessory' or v.Parent.Parent.ClassName == 'Accessory') and v.Name~="Hilt" and v.Parent.Name ~= "RuneArmLeft" and v.Parent.Name ~= "RuneArmRight" and v.Name ~= "Back" or v.Parent.Name == "Sigil Helmet" then
			lanniseffect(v)
		end
	end
	wait(3)
	DarkMatter.Enabled = false
	wait(0.5)
	local Rebirth = game.ServerStorage.Assets.Rebirth:Clone()
	Rebirth.Parent = Root
	Rebirth:Play()
	game.Debris:AddItem(Rebirth,2)
	game.Debris:AddItem(DarkMatter,2)
end

function v1.HowlerLannis(Character)
	if Character:FindFirstChild("Immortal") then return end
	create("Immortal",3.5,Character)
	local DarkMatter = game.ServerStorage.Assets.DarkMatter:Clone()
	DarkMatter.Parent = Character.HumanoidRootPart
	game.Debris:AddItem(DarkMatter,5)
	Character.HumanoidRootPart.Reverse:Play()
	local Descendants = Character:GetDescendants()
	for i = 1,#Descendants do
		local v = Descendants[i]
		if v:IsA("BasePart") or v:IsA("WedgePart") then
			if v.Transparency ~= 1 then
				v.Transparency = 1
				local c = v:Clone()
				c:ClearAllChildren()
				c.Anchored = true
				c.CanCollide = false
				c.Transparency = 1
				c.Color = Color3.fromRGB(27,42,53)
				c.Parent = workspace.Thrown
				wrap(function()
					TweenService:Create(c,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency = 0.258,CFrame = c.CFrame * CFrame.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))*CFrame.Angles(math.random(-360,360),math.random(-360,360),math.random(-360,360))}):Play()
					wait(2)
					TweenService:Create(c,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{CFrame = v.CFrame}):Play()
					wait(1)
					TweenService:Create(c,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency = 1}):Play()
					game.Debris:AddItem(c,1.5)
					v.Transparency = 0
				end)()
			end
		end
	end
	wait(3)
	DarkMatter.Enabled = false
	wait(0.5)
	local Rebirth = game.ServerStorage.Assets.Rebirth:Clone()
	Rebirth.Parent = Character.HumanoidRootPart
	Rebirth:Play()
	game.Debris:AddItem(Rebirth,2)
end

--[[function v1.Explosion(CFrame, Size, TagInfo, Bool, Color)
	local explosion = script.Explosion:Clone()
	explosion:SetPrimaryPartCFrame(CFrame)
	for _,obj in next,explosion:GetChildren() do
		if obj:IsA("BasePart") then
			obj.Color = Color
		end
		if obj:IsA("ParticleEmitter") then
			obj.Color = ColorSequence.new(Color)
		end
		if obj.Name == "Ball" then
			obj.Size = Vector3.new(Size,Size,Size)
		end
	end
	explosion.Parent = workspace.Thrown
	explosion.Ball.Sound:Play()
	explosion.SmokeParticle.ParticleEmitter:Emit(20)
	game:GetService("Debris"):AddItem(explosion,2)
	TweenService:Create(explosion.Ball.Mesh,TweenInfo.new(0.25),{Scale = Vector3.new(1,1,1)}):Play()
	TweenService:Create(explosion.Ball,TweenInfo.new(0.25),{Transparency = 1}):Play()
	TweenService:Create(explosion.Ring.Mesh,TweenInfo.new(0.5),{Scale = Vector3.new(1,1,1)}):Play()
	TweenService:Create(explosion.Ring,TweenInfo.new(0.5),{Transparency = 1}):Play()
	if TagInfo then
		hitDetection.magnitudeCheck(nil,explosion.Ball.Position,Size,TagInfo,nil,false)
	end
end]]
local l__TweenService__1 = game:GetService("TweenService")
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
function v1.Explosion(p11, p12, p13, p14, p15, p16)
	spawn(function()
		for v21, v22 in pairs(game.Workspace.Live:GetChildren()) do
			if v22:FindFirstChild("HumanoidRootPart") and ((not p16 or v22 ~= p16) and (p11.p - v22.HumanoidRootPart.Position).magnitude <= p12) then
				l__TagHumanoid__2:Fire(p16 or v22, v22, p13);
			end;
		end;
		local v23 = game.ServerStorage.SmokeParticle:Clone();
		v23.CFrame = p11;
		v23.Parent = game.Workspace;
		game.Debris:AddItem(v23, 3);
		spawn(function()
			wait(1);
			v23.ParticleEmitter.Enabled = false;
		end);
		local v24 = game.ServerStorage.ExplosionBall:Clone();
		game.Debris:AddItem(v24, 0.75);
		if p15 ~= nil then
			v24.Color = p15;
		end;
		v24.Mesh.Scale = Vector3.new(0, 0, 0);
		v24.Size = Vector3.new(p12 * 2, p12 * 2, p12 * 2);
		v24.CFrame = p11;
		v24.Parent = game.Workspace;
		local v25 = game.ServerStorage.ExplosionRing:Clone();
		game.Debris:AddItem(v25, 0.75);
		if p15 ~= nil then
			v25.Color = p15;
		end;
		v25.Mesh.Scale = Vector3.new(0, 0, 0);
		v25.Size = Vector3.new(p12 * 2.5, p12 * 2.5, p12 * 0.5);
		v25.CFrame = p11 * CFrame.Angles(1.5707963267948966, 0, 0);
		v25.Parent = game.Workspace;
		local v26 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
		local v27 = l__TweenService__1:Create(v25.Mesh, v26, {
			Scale = Vector3.new(v25.Size.X, v25.Size.X, v25.Size.X / 2)
		});
		local v28 = l__TweenService__1:Create(v24, v26, {
			Transparency = 0.5
		});
		local v29 = l__TweenService__1:Create(v25, v26, {
			Transparency = 0.6
		});
		l__TweenService__1:Create(v24.Mesh, v26, {
			Scale = Vector3.new(1, 1, 1)
		}):Play();
		v27:Play();
		v28:Play();
		v29:Play();
		v24.Sound:Play();
		wait(0.3);
		local v30 = TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
		local v31 = l__TweenService__1:Create(v25, v30, {
			Transparency = 1
		});
		l__TweenService__1:Create(v24, v30, {
			Transparency = 1
		}):Play();
		v31:Play();
	end);
end;

function v1.QuickLightning(p6, p7, p8, p9, p10)
	local v11 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
	local l__lookVector__12 = CFrame.new(p6, p7).lookVector;
	local v13 = (p6 - p7).magnitude / p9;
	local v14 = p6;
	for v15 = 1, p9 do
		local v16 = Instance.new("Part");
		v16.FormFactor = "Symmetric";
		v16.Size = Vector3.new(1, 1, 1);
		v16.CanCollide = false;
		v16.Transparency = 0.2;
		v16.Anchored = true;
		v16.BrickColor = BrickColor.new(p10);
		v16.Material = Enum.Material.Neon;
		local v17 = CFrame.new(p6 + l__lookVector__12 * (v15 * v13), p7 + l__lookVector__12) * CFrame.new(math.random(-100, 100) / 100 * v13 / 2, math.random(-100, 100) / 100 * v13 / 2, 0);
		local l__magnitude__18 = (v17.p - v14).magnitude;
		local v19 = Instance.new("BlockMesh", v16);
		v19.Scale = Vector3.new(p8, p8, l__magnitude__18 + p8 / 4);
		v16.CFrame = CFrame.new((v17.p + v14) / 2, v17.p);
		v14 = v17.p;
		local v20 = Instance.new("PointLight");
		v20.Color = BrickColor.new(p10).Color;
		v20.Shadows = false;
		v20.Brightness = 0.1;
		v20.Range = 10;
		v20.Parent = v16;
		v16.Parent = game.Workspace;
		l__TweenService__1:Create(v20, v11, {
			Range = 0
		}):Play();
		l__TweenService__1:Create(v19, v11, {
			Scale = Vector3.new(p8 * 2, p8 * 2, l__magnitude__18 + p8 / 4)
		}):Play();
		l__TweenService__1:Create(v16, v11, {
			Transparency = 1
		}):Play();
		game.Debris:AddItem(v16, 0.3);
	end;
end;

return v1