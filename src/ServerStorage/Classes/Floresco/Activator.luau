local v1 = {}
function sub(...)
	coroutine.wrap(...)()
end
local l__Debris__2 = game:GetService("Debris")
local v3 = require(game.ServerScriptService.Modules.HitDetection)
v1.upperbound = 100
v1.lowerbound = 90
v1.signs = 12
v1.cost = 100
local l__PlantGrowth__4 = game.ServerStorage.SpellEffects.PlantGrowth
local VerdienModules = game.ServerStorage.VerdienModules
local VerdienModule = require(VerdienModules.VerdienModule)
local u1 = {
	upperbound = 95, 
	lowerbound = 80, 
	signs = 0, 
	cost = 100
}
local u2 = 0
local function u3(p1, p2, p3, p4)
	local v5, v6, v7 = workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).LookVector * p3), p4)
	return v5, v6, v7
end
local u4 = require(l__PlantGrowth__4.GrowthEffect)
local l__TweenService__5 = game:GetService("TweenService")
local l__TagHumanoid__6 = game.ServerStorage.Requests.TagHumanoid
function checkNextHeight(p10, p11)
	local v25 = p10 + Vector3.new(0, 6, 0)
	local v26, v27, v28 = u3(v25, v25 - Vector3.new(0, 0.5, 0), 10 + p11, { game.Workspace.Live, workspace.Thrown, workspace.Destructibles })
	return v25.Y - v27.Y
end
local function u10(p12)
	p12:Play()
	task.spawn(function()
		p12.TimePosition = 0
		wait(2)
		if p12 then
			p12:Stop()
		end
	end)
end
local function getchildrenamount(v,name)
	local returntable = {}
	for _,v in pairs(v:GetChildren())do
		if v.Name == name then
			table.insert(returntable,v)
		end
	end
	return #returntable
end
function sinuousMotion(p13, p14, p15, p16, p17, p18)
	task.spawn(function()
		wait(math.random())
		local v29 = -p15 * math.sin(math.rad(p13.Orientation.Y))
		local v30 = -p15 * math.cos(math.rad(p13.Orientation.Y))
		p13.Parent = workspace.Thrown
		p13:SetNetworkOwner(nil)
		local v32 = TweenInfo.new(1 / p16, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local v33 = TweenInfo.new(2 / p16, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local v34 = 0
		while true do
			if v34 < p14 then
			else
				break
			end
			local v35 = p13.Position + Vector3.new(v29, p17, v30)
			local v36 = p17 - checkNextHeight(v35, p17)
			if not (math.abs(math.abs(v36) - 10) < 0.1) then
			else
				p13:Destroy()
				break
			end
			if math.abs(math.abs(p17 - checkNextHeight(p13.Position + Vector3.new(0, v36, 0) + Vector3.new(5 * v29, p17, 5 * v30), p17)) - 10) < 0.1 then
				p13:Destroy()
				break
			end
			l__TweenService__5:Create(p13, v32, {
				Position = v35 + Vector3.new(0, v36, 0)
			}):Play()
			wait(1 / p16)
			local l__Sound__37 = p13:FindFirstChild("Sound")
			if l__Sound__37 then
				if 0.75 < math.random() then
					u10(l__Sound__37)
				end
			end
			for v41,v42 in pairs(workspace.Live:GetChildren())do
				local Torso = v42:FindFirstChild'Torso'
				if Torso and (p13.Position - Torso.Position).Magnitude < 13 then
					if v42 ~= p18.Character then
						--not v42:FindFirstChild("FlorescoHit") and	not v42:FindFirstChild("NoFloresco")
						if not v42:FindFirstChild("NoFloresco") then
							l__TagHumanoid__6:Fire(p18.Character, v42, {
								damage = 4, 
								poison = true,
								noenchant = true,
								bypassblock = true,
								move = "Floresco"
							})
						end

						local v43 = Instance.new("Accessory")
						v43.Name = "FlorescoHit"
						v43.Parent = v42
						game.Debris:AddItem(v43,0.16)
					end
				end			
			end
			l__TweenService__5:Create(p13, v33, {
				Position = p13.Position + 2 * Vector3.new(v29, -p17, v30)
			}):Play()
			wait(2 / p16)
			l__TweenService__5:Create(p13, v32, {
				Position = p13.Position + Vector3.new(v29, p17, v30)
			}):Play()
			wait(1 / p16)
			v34 = v34 + 4 / p16		
		end
		game.Debris:AddItem(p13, 0.1)
	end)
end
local u11 = true
local CollectionService = game:GetService("CollectionService")
local Players = game.Players
local function canRoot(p7): boolean
	if p7:FindFirstChild("Knocked") or p7:FindFirstChild("Blocking") then
		return false;
	end
	return true;
end;
function Anchor(Target, Statement)
	if Statement then
		game.CollectionService:AddTag(Target, "FreezeRoot")
	else
		game.CollectionService:RemoveTag(Target, "FreezeRoot")
	end
end
local l__TweenService__2 = game:GetService("TweenService")
local l__Barrier__1 = game.ServerStorage.SpellEffects.Floresco;
local R3 = require(game.ServerScriptService.RotatedRegion3)
function v1.Activate(p5, p6, p7, p8, p9)
	if game.CollectionService:HasTag(p6, "Casting") then
		return;
	end;
	local p2 = p6
	local l__Mana__2 = p2.Mana;
	local v3 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__4 = v3.Backpack.ManaColor.Value;
	--[[if p3 ~= 0 then
		p2.HumanoidRootPart.Diffusion:Play();
		if p4 and p4:FindFirstChild("Backfire") then
			p4.Backfire.Color = ColorSequence.new(Color3.new(l__Value__4.r, l__Value__4.g, l__Value__4.b));
			p4.Backfire:Emit(15);
		end;
		return;
	end;]]
	if p2:FindFirstChild("EndCast") then
		return;
	end;
	local v5 = Instance.new("Accessory");
	v5.Name = "ActiveCast";
	v5.Parent = p2;
	l__Mana__2.Value = math.max(l__Mana__2.Value - v1.cost, 0);
	p2.HumanoidRootPart.PerfectCast:Play();
	local l__HumanoidRootPart__6 = p2.HumanoidRootPart;
	local v7 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or (game.CollectionService:HasTag(p2, "Knocked") or game.CollectionService:HasTag(p2, "Unconscious")));
	local WindupAnim = p2.Humanoid:LoadAnimation(script.Parent.Windup)
	local Windup = false
	Anchor(p2, true)
	WindupAnim:Play()
	Windup = true
	task.spawn(function()
		while Windup do
			local v17 = v7;
			if not v17 then
				v17 = true;
				v17 = (p2:FindFirstChild("Stun") or p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious"));
			end;
			v7 = v17;
			if v7 then
				Windup:Stop()
				Windup = false
			end;
			task.wait(0.1)
		end
	end)
	
	local v15 = l__PlantGrowth__4.Flower:Clone()
	v15:SetPrimaryPartCFrame(p2.HumanoidRootPart.CFrame * CFrame.new(0, -2.5, 0))
	v15.Parent = workspace.Thrown
	game.Debris:AddItem(v15, 10)
	local v17 = u4.fadeInStart(v15) + u4.fadeInSuccess(v15)
	u4.fadeOut(v15, 5 + v17, 0)

	l__HumanoidRootPart__6.PerfectCast:Play()

	task.wait(0.5)

	if Windup == false then
		return
	end
	Windup = false
	
	local v9 = l__Barrier__1:Clone();
	v9.Parent = workspace.Thrown
	v9.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0,-2.7,0);
	v9.Orientation = Vector3.new(0,90,90)
	l__TweenService__2:Create(v9, TweenInfo.new(1), {
		Transparency = 0
	}):Play();
	l__TweenService__2:Create(v9, TweenInfo.new(1), {
		Size = Vector3.new(0.25, 50, 50)
	}):Play();
	v5:Destroy()
	Anchor(p2, false)
	game.Debris:AddItem(v9, 60);
	task.spawn(function()
		for i = 1,50 do
			local Hitbox = R3.Cylinder(v9.CFrame, v9.Size + Vector3.new(10,0,0))
			Hitbox:GetHumanoids({}, function(humanoid)
				local p5 = humanoid
				local v10 = p5.Parent:FindFirstChild("Humanoid") or p5.Parent.Parent:FindFirstChild("Humanoid");
				if v10 then
					local l__Parent__11 = v10.Parent;
					if l__Parent__11 == p2 or (game.ServerStorage.PlayerData:FindFirstChild(l__Parent__11.Name) and game.ServerStorage.PlayerData:FindFirstChild(l__Parent__11.Name).LastName.Value == game.ServerStorage.PlayerData:FindFirstChild(p2.Name).LastName.Value and game.ServerStorage.PlayerData:FindFirstChild(p2.Name).LastName.Value ~= "") then
						local v12 = l__Parent__11 and game.Players:FindFirstChild(l__Parent__11.Name);
						local v13 = v12 and game.ServerStorage.PlayerData:FindFirstChild(l__Parent__11.Name);
						if v13 then
							if not l__Parent__11:FindFirstChild("Grabbed") then
								l__Parent__11.HumanoidRootPart.Heal:Play()
								l__Parent__11.Humanoid.Health += 0.5
								if game.ServerStorage.PlayerData[p2.Name].Skills.Value:find("Nature's Calling") then
									p2.Humanoid.Health += 0.2
								end 
							end;
						end;
					end
				end
			end)
			task.wait(0.1)
		end
		v9.Parent = workspace.Thrown;
		l__TweenService__2:Create(v9, TweenInfo.new(1), {
			Size = Vector3.new(0, 0, 0)
		}):Play();
		game.Debris:AddItem(v9, 1);
	end)
end;
function u1.Activate(p19, p20, p21, p22)
	if game.CollectionService:HasTag(p20, "Casting") then
		return
	end	
	if not u11 then
		return
	end
	if not game.ServerStorage.PlayerData[game.Players:GetPlayerFromCharacter(p20).Name].Skills.Value:find("Floresco M2") then
		return;
	end
	u11 = false
	local l__Mana__43 = p20.Mana
	local v44 = game.Players:GetPlayerFromCharacter(p20)
	local l__Value__45 = game.ServerStorage.PlayerData[v44.Name].ManaColor.Value

	spawn(function()
		wait(3)
		wait(2)
		u11 = true
	end)
	if p21 == 0 then
		u11 = false
		l__Mana__43.Value = math.max(l__Mana__43.Value - u1.cost, 0)
		u4.snapEffect(p20, p22)
		local v47 = 3
		for v48 = -v47, v47 do
			local v49 = l__PlantGrowth__4.Vine:Clone()
			v49.CFrame = p20.HumanoidRootPart.CFrame * CFrame.new(v48 * 7 * math.random(), -6, v48 * math.random() - 5)
			sinuousMotion(v49, 5, 7, 4 + math.random(), 4.5 + math.random(), v44)
			game.Debris:AddItem(v49, 5)
		end
	else
		l__TagHumanoid__6:Fire(p20, p20, {
			damage = 3.5, 
			poison = true,
			move = "Floresco"
		})
	end
end
v1.alternate = u1
return v1