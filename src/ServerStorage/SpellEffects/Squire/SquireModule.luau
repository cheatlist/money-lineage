-- Decompiled with the Synapse X Luau decompiler.

function sub(...)
	coroutine.wrap(...)();
end;
function isEnemy(p1, p2)
	local v1 = game.ServerStorage.PlayerData:FindFirstChild(p2.Name);
	local v2 = v1 and v1.Data.LastName.Value;
	local v3 = game.ServerStorage.PlayerData:FindFirstChild(p1.Name);
	local v4 = v3 and v3.Data.LastName.Value;
	local v5
	if v2 then
		if v4 ~= "" then
			v5 = false;
			if v2 ~= v4 then
				v5 = p2 ~= p1;
			end;
		else
			v5 = p2 ~= p1;
		end;
	else
		v5 = p2 ~= p1;
	end;
	return v5;
end;
function ActionCheck(p3)
	if not p3:FindFirstChild("Humanoid") then
		return true;
	end;
	if p3:FindFirstChild("Stun") then
		return true;
	end;
	if p3:FindFirstChild("ReturnStun") then
		return true;
	end;
	if p3:FindFirstChild("ActiveCast") then
		return true;
	end;
	if p3:FindFirstChild("Action") then
		return true;
	end;
	if p3:FindFirstChild("Blocking") then
		return true;
	end;
	if p3:FindFirstChild("SpellBlocking") then
		return true;
	end;
	if p3:FindFirstChild("IsClimbing") then
		return true;
	end;
	if p3.Humanoid.Health == 0 then
		return true;
	end;
	if p3:FindFirstChild("Climbing") then
		return true;
	end;
	if not game.CollectionService:HasTag(p3, "Unconscious") then
		if game.CollectionService:HasTag(p3, "Knocked") then
			return true;
		end;
	else
		return true;
	end;
	if p3.Humanoid.Sit then

	else
		return;
	end;
	return true;
end;
local l__Parent__1 = script.Parent;
local l__HasSkill__2 = game.ServerStorage.Requests.HasSkill;
local ToolHandler = require(game.ServerScriptService.ToolHandler)
local u3 = Color3.fromRGB(152, 194, 219);
local l__TweenService__4 = game:GetService("TweenService");
local u5 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);
function drop(p4, p5)
	local v6 = Instance.new("StringValue", p4);
	v6.Name = "Summoned";
	v6.Value = p5;
	local v7 = Instance.new("Folder", p4);
	v7.Name = "LightAttack";
	local v8 = nil;
	local v9 = nil;
	local v10 = nil;
	if p5 == "Forge" then
		v8 = l__Parent__1.SmithingStation:Clone();
		v9 = CFrame.new(-3, 6 - 2.1, -5);
		v10 = CFrame.Angles(0 * math.pi / 2, 0 * math.pi / 2, 1 * math.pi / 2);
		if l__HasSkill__2:Invoke(game.Players:GetPlayerFromCharacter(p4), "Gemcutter") then
			v8.Hammer:Destroy();
			v8.Hammer2.Name = "Hammer";
		else
			v8.Gem:Destroy();
			v8.GemPosition:Destroy();
			v8.Hammer2:Destroy();
		end;
		v8.Parent = workspace.Stations;
	elseif p5 == "Furnace" then
		v8 = l__Parent__1.PortableFurnace:Clone();
		v9 = CFrame.new(0, 6 - 0.1, -6);
		v10 = CFrame.Angles(0 * math.pi / 2, 3 * math.pi / 2, 1 * math.pi / 2);
		v8.Parent = workspace;
	elseif p5 == "Grindstone" then
		v8 = l__Parent__1.Grindstone:Clone();
		v9 = CFrame.new(0, 6 - 0.55, -6);
		v10 = CFrame.Angles(3 * math.pi / 2, 2 * math.pi / 2, 3 * math.pi / 2);
		if l__HasSkill__2:Invoke(game.Players:GetPlayerFromCharacter(p4), "Sharpener") then
			for v14, v15 in next, v8:GetChildren() do
				if v15.Name == "Holster" then
					v15.Color = u3;
				end;			
			end;
		end;
		v8.Parent = workspace;
	end;
	local v16 = Instance.new("Folder", v8);
	v16.Name = p4.Name;
	v8:SetPrimaryPartCFrame(p4.HumanoidRootPart.CFrame * v9 * v10);
	local v17 = {};
	local v18 = {};
	local v19 = nil;
	local v20 = nil;
	local v21 = #v8:GetChildren();
	local v22 = 0 - 1;
	while true do
		local v23 = nil;
		local v24 = nil;
		local v25, v26, v27 = pairs(v8:GetChildren());
		while true do
			local v28, v29 = v25(v26, v27);
			if v28 then

			else
				break;
			end;
			v27 = v28;
			if v29:IsA("BasePart") then
				if not v17[v29] then
					if v23 then
						if v29.Position.Y <= v23.Position.Y then
							v23 = v29;
						end;
					else
						v23 = v29;
					end;
				end;
				if not v18[v29] then
					if v24 then
						if v24.Position.Y <= v29.Position.Y then
							v24 = v29;
						end;
					else
						v24 = v29;
					end;
				end;
			end;		
		end;
		if v24 then
			v19 = {
				next = v19, 
				value = v24
			};
			v18[v24] = true;
		end;
		if v23 then
			v20 = {
				next = v20, 
				value = v23
			};
			v17[v23] = true;
		end;
		if 0 <= 1 then
			if v22 < v21 then

			else
				break;
			end;
		elseif v21 < v22 then

		else
			break;
		end;
		v22 = v22 + 1;	
	end;
	local v30 = l__Parent__1.SummonSound:Clone();
	v30.Parent = v8.PrimaryPart;
	v30:Play();
	local v31 = 0;
	local v32 = v19;
	while true do
		if v32 then

		else
			break;
		end;
		local l__value__6
		if v32.value.Name ~= "Material" then
			if v32.value.Name ~= "Timer" then
				if v32.value.Name ~= "Sparks" then
					if v32.value.Name ~= "GemPosition" then
						if v32.value.Name ~= "Furnace" then
							if v32.value.Name == "Smoke" then
								l__value__6 = v32.value;
								spawn(function()
									wait(0.64);
									l__TweenService__4:Create(l__value__6, u5, {
										Transparency = 0
									}):Play();
								end);
							else
								l__TweenService__4:Create(v32.value, u5, {
									Transparency = 0
								}):Play();
							end;
						else
							l__value__6 = v32.value;
							spawn(function()
								wait(0.64);
								l__TweenService__4:Create(l__value__6, u5, {
									Transparency = 0
								}):Play();
							end);
						end;
					end;
				end;
			end;
		end;
		l__TweenService__4:Create(v32.value, u5, {
			Position = v32.value.Position + Vector3.new(0, -6, 0)
		}):Play();
		v31 = v31 + 0.08;
		if p5 == "Grindstone" then
			if not (0.72 < v31) then
				wait(0.08);
			end;
		else
			wait(0.08);
		end;
		v32 = v32.next;	
	end;
	if p5 == "Furnace" then
		local l__Furnace__33 = v8.Furnace;
		l__Furnace__33.Parent = v8;
	elseif p5 == "Grindstone" then
		local l__Wheel__34 = v8.Wheel;
		l__Wheel__34.BodyAngularVelocity.AngularVelocity = Vector3.new(-math.cos(math.rad(l__Wheel__34.Orientation.Y)), 0, math.sin(math.rad(l__Wheel__34.Orientation.Y))) * 20;
		l__Wheel__34.Anchored = false;
	end;
	v7:Destroy();
	game.Debris:AddItem(v6, 1800);
	game.Debris:AddItem(v16, 1800);
	game.Debris:AddItem(v8, 1800);
	local u7 = v32;
	sub(function()
		local l__Position__35 = v8.PrimaryPart.Position;
		local l__HumanoidRootPart__36 = p4.HumanoidRootPart;
		while true do
			wait(1);
			if v8 then
				if p4 then
					if not (25 < (l__HumanoidRootPart__36.Position - l__Position__35).magnitude) then
						if p4.Humanoid.Health == 0 then
							if p5 == "Forge" then

							else
								break;
							end;
							if v8.User.Value ~= "" then

							else
								break;
							end;
						end;
					else
						if p5 == "Forge" then

						else
							break;
						end;
						if v8.User.Value ~= "" then

						else
							break;
						end;
					end;
				else
					if p5 == "Forge" then

					else
						break;
					end;
					if v8.User.Value ~= "" then

					else
						break;
					end;
				end;
			else
				if p5 == "Forge" then

				else
					break;
				end;
				if v8.User.Value ~= "" then

				else
					break;
				end;
			end;		
		end;
		v30:Play();
		v6:Destroy();
		v16:Destroy();
		u7 = v20;
		while true do
			if u7 then

			else
				break;
			end;
			local v37 = u7.value:FindFirstChildOfClass("ParticleEmitter");
			if v37 then
				v37.Enabled = false;
			end;
			l__TweenService__4:Create(u7.value, u5, {
				Transparency = 1
			}):Play();
			l__TweenService__4:Create(u7.value, u5, {
				Position = u7.value.Position + Vector3.new(0, 10, 0)
			}):Play();
			wait(0.04);
			u7 = u7.next;		
		end;
		wait(1);
		game.Debris:AddItem(v8, 0.001);
	end);
end;
local u8 = {};
local u9 = { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns, workspace.AreaMarkers };
function u8.summon(p6, p7)
	local l__Summoned__38 = p6:FindFirstChild("Summoned");
	local v39 = l__Summoned__38 and l__Summoned__38.Value == "Forge";
	if v39 and l__HasSkill__2:Invoke(game.Players:GetPlayerFromCharacter(p6), "Gemcutter") and p7 == "Forge" then
		local v40 = nil;
		for _,Station in next, workspace.Stations:GetChildren() do
			for _,Owner in next, Station:GetChildren() do
				if Owner.Name == p6.Name then
					v40 = Station
					break
				end
			end
		end
		if v40 then
			u8.enchant(v40);
			return;
		end;
	end;
	if l__Summoned__38 then
		return;
	end;
	local u10 = nil;
	local u11 = game.Players:GetPlayerFromCharacter(p6);
	pcall(function()
		u10 = game.ReplicatedStorage.Requests.GetMouse:InvokeClient(u11);
	end);
	if not u10 then
		return;
	end;
	sub(function()
		local v48 = {};
		local v49 = nil;
		for v50 = 1, 4 do
			for v51 = 1, 6 do
				local v52 = l__Parent__1.FlatGround:Clone();
				v52.Parent = workspace;
				local v53 = p6.HumanoidRootPart.CFrame * CFrame.new(-7 + 2 * v51, -4, -13 + 2 * v50);
				v52.CFrame = v53;
				local v54, v55, v56 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v53.p + Vector3.new(0, 4, 0), Vector3.new(0, -25, 0)), u9);
				v52:Destroy();
				if v54.Name == "FlatGround" then
					return;
				end;
				if v49 == nil then
					v49 = v54;
				elseif v54 ~= v49 then
					return;
				end;
			end;
		end;
		for v57 = 1, 4 do
			for v58 = 1, 6 do
				local v59 = l__Parent__1.FlatGround:Clone();
				v59.Parent = workspace;
				local v60 = p6.HumanoidRootPart.CFrame * CFrame.new(-7 + 2 * v58, -3, -13 + 2 * v57);
				v59.CFrame = v60;
				local v61, v62, v63 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v60.p + Vector3.new(0, 4, 0), Vector3.new(0, -25, 0)), u9);
				v59:Destroy();
				if v61.Name ~= "FlatGround" then
					return;
				end;
			end;
		end;
		local v64 = p6.HumanoidRootPart.CFrame * CFrame.new(0, -5, -6);
		local v65, v66, v67 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v64.p + Vector3.new(0, 1, 0), Vector3.new(0, -25, 0)), u9);
		local v68 = v65;
		if not v68 then
			local v69, v70, v71 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v64.p + Vector3.new(0, 5, 0), Vector3.new(0, -25, 0)), u9);
			v68 = v69;
		end;
		if not v68 then
			return;
		end;
		drop(p6, p7);
	end);
end;
function u8.enchant(p8)
	if p8.User.Value ~= "" then
		return;
	end;
	local l__Timer__72 = p8.Timer;
	l__Timer__72.Parent = nil;
	p8.User.Value = "_";
	for v73 = 1, 3 do
		p8.Material.HammerSmash:Play();
		p8.Sparks.ParticleEmitter:Emit(5);
		wait(1);
	end;
	for v74, v75 in pairs(workspace.Live:GetChildren()) do
		local v76 = v75:FindFirstChildOfClass("Tool");
		if v76 then
			local v77 = game.Players:GetPlayerFromCharacter(v75);
			local v78 = game.ServerStorage.PlayerData:FindFirstChild(v77.Name);
			local l__Shard__79 = v76:FindFirstChild("Shard");
			local v80 = v76:FindFirstChild("Gem") and v78.Data.Enchantment or l__Shard__79 and v78.Data.Enchantment2;
			if v80 then
				local v81 = nil;
				if v76.Name:match("Emerald") then
					v81 = "poison";
				elseif v76.Name:match("Diamond") then
					v81 = "lightning";
				elseif v76.Name:match("Opal") then
					v81 = "holy";
				elseif v76.Name:match("Sapphire") then
					v81 = "ice";
				elseif v76.Name:match("Ruby") then
					v81 = "fire";
				elseif not l__Shard__79 and v76.Name:match("Night Stone") then
					v81 = "curse";
				end;
				if l__Shard__79 then
					local l__Enchantment2Expiration__82 = v78.Data.Enchantment2Expiration;
					game.ServerStorage.Requests.SetStoryMarker:Invoke(v77, "Enchant2Updated");
					if v80.Value == v81 and l__Enchantment2Expiration__82.Value > 0 then
						l__Enchantment2Expiration__82.Value = l__Enchantment2Expiration__82.Value + 1800;
					else
						l__Enchantment2Expiration__82.Value = 1800;
					end;
					local v83 = Instance.new("Folder");
					v83.Name = "ShardEnchant";
					v83.Parent = v75;
					for v84, v85 in pairs(v75:GetChildren()) do
						if v85.Name == "ShardEnchant" and v85 ~= v83 then
							v85:Destroy();
						end;
					end;
				end;
				v80.Value = v81;
				local Player = game.Players:GetPlayerFromCharacter(v75)
				if Player then
					ToolHandler.RemoveTool(Player, v76)
				end
				v75.Humanoid:UnequipTools();
			end;
		end;
	end;
	p8.User.Value = "";
	l__Timer__72.Parent = p8;
end;
function grindEffect(p9)
	if p9 then

	else
		return 0;
	end;
	local l__ParticleEmitter__12 = p9.Sparks.ParticleEmitter;
	local l__Sound__13 = p9.Sparks.Sound;
	spawn(function()
		l__ParticleEmitter__12.Enabled = true;
		l__Sound__13:Play();
		wait(l__Sound__13.TimeLength);
		l__ParticleEmitter__12.Enabled = false;
		l__Sound__13:Stop();
	end);
	return l__Sound__13.TimeLength;
end;
function u8.grind(p10)
	local v86 = l__HasSkill__2:Invoke(game.Players:GetPlayerFromCharacter(p10), "Sharpener");
	local v87
	if v86 then
		v87 = 1800;
	else
		v87 = 900;
	end;
	local v88 = nil;
	for v89, v90 in pairs(workspace:GetChildren()) do
		if v90.Name == "Grindstone" then
			for v91, v92 in pairs(v90:GetChildren()) do
				if v92.Name == p10.Name then
					v88 = v90;
				end;
			end;
		end;
	end;
	wait(grindEffect(v88));
	for v93, v94 in pairs(game.Workspace.Live:GetChildren()) do
		if (v94.Torso.Position - v88.PrimaryPart.Position).Magnitude <= 20 and not v94:FindFirstChild("ArmorPolished") then
			local v95 = Instance.new("Folder", v94);
			v95.Name = "ArmorPolished";
			local v96 = Instance.new("NumberValue");
			v96.Name = "DamageDivisor";
			local v97
			if v86 then
				v97 = 1.428;
			else
				v97 = 1.176;
			end;
			v96.Value = v97;
			v96.Parent = v94.Boosts;
			for v98, v99 in pairs(v94:GetChildren()) do
				if v99.Name:match("Arm") or (v99.Name:match("Leg") or v99.Name == "Torso") then
					local v100 = l__Parent__1.Shine:Clone();
					v100.Parent = v99;
					game.Debris:AddItem(v100, v87);
				end;
			end;
			game.Debris:AddItem(v95, v87);
			game.Debris:AddItem(v96, v87);
			local v101 = false;
			local l__next__102 = next;
			local v103, v104 = v94:children();
			while true do
				local v105, v106 = l__next__102(v103, v104);
				if not v105 then
					break;
				end;
				v104 = v105;
				if v106.Name == "DamageMultiplier" and game.CollectionService:HasTag(v106, "SharpenedWeapon") then
					v101 = true;
					break;
				end;			
			end;
			if not v101 then
				local v107 = Instance.new("NumberValue");
				v107.Name = "DamageMultiplier";
				local v108
				if v86 then
					v108 = 1.15;
				else
					v108 = 1.075;
				end;
				v107.Value = v108;
				v107.Parent = v94.Boosts;
				game.CollectionService:AddTag(v107, "SharpenedWeapon");
				local l__Hilt__109 = v94:FindFirstChild("Hilt");
				if l__Hilt__109 then
					local u14 = l__Hilt__109.ChildAdded:Connect(function(p11)
						if not p11:FindFirstChild("Shine") then
							l__Parent__1.Shine:Clone().Parent = p11;
						end;
					end);
					sub(function()
						wait(v87);
						u14:Disconnect();
						local l__Shine__110 = l__Hilt__109:FindFirstChild("Shine", true);
						if l__Shine__110 then
							l__Shine__110:Destroy();
						end;
					end);
				end;
				game.Debris:AddItem(v107, v87);
			end;
		end;
	end;
end;
local v111 = Color3.new(255, 89, 89);
local u15 = CFrame.new(0, 100, 75);
local u16 = Vector3.new(6, 6, 6);
local l__TagHumanoid__17 = game.ServerStorage.Requests.TagHumanoid;
function meteordrop(p12, p13, p14)
	sub(function()
		local v112 = l__Parent__1.Meteor:Clone();
		v112.CFrame = CFrame.new(p13, p13 + p14) * u15;
		v112.Transparency = 1;
		v112.Parent = workspace.Thrown;
		game.Debris:AddItem(v112, 5);
		local v113 = l__Parent__1.NeonMeteor:Clone();
		v113.CFrame = v112.CFrame;
		v113.Transparency = 1;
		v113.Size = u16 + Vector3.new(0.1, 0.1, 0.1);
		v113.Parent = workspace.Thrown;
		game.Debris:AddItem(v113, 5);
		v112.Firesound:Play();
		l__TweenService__4:Create(v112, TweenInfo.new(0.5), {
			Transparency = 0, 
			Size = u16
		}):Play();
		l__TweenService__4:Create(v112, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = p13
		}):Play();
		l__TweenService__4:Create(v113, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = p13
		}):Play();
		sub(function()
			wait(1);
			l__TweenService__4:Create(v112.PointLight, TweenInfo.new(2), {
				Range = 10
			}):Play();
			l__TweenService__4:Create(v113, TweenInfo.new(2), {
				Transparency = 0
			}):Play();
		end);
		wait(2);
		local v114, v115, v116 = pairs(v112:GetChildren());
		while true do
			local v117, v118 = v114(v115, v116);
			if v117 then

			else
				break;
			end;
			v116 = v117;
			v118.Parent = v113;		
		end;
		v112:Destroy();
		v113.Attachment.IllusionArm.Enabled = false;
		v113.Attachment.IllusionArm2.Enabled = false;
		v113.IllusionArm.Enabled = false;
		v113.IllusionArm3.Enabled = false;
		v113.Explosion:Emit(100);
		v113.Firesound2:Play();
		l__TweenService__4:Create(v113, TweenInfo.new(0.25), {
			Size = u16 * 5, 
			Transparency = 1
		}):Play();
		l__TweenService__4:Create(v113.PointLight, TweenInfo.new(0.25), {
			Range = 25
		}):Play();
		local v119, v120, v121 = pairs(workspace.Live:GetChildren());
		while true do
			local v122, v123 = v119(v120, v121);
			if v122 then

			else
				break;
			end;
			v121 = v122;
			if (v123:FindFirstChild("HumanoidRootPart").Position - v113.Position).Magnitude < 20 then
				if isEnemy(p12, v123) then
					local v124 = {
						mana = true, 
						damage = 10, 
						manaknockupself = true, 
						curse = true, 
						burn = true
					};
					if v123:FindFirstChild("Burning") then
						if not v123:FindFirstChild("MonsterInfo") then
							v124.manaknockup = nil;
						end;
					end;
					l__TagHumanoid__17:Fire(p12, v123, v124);
				end;
			end;		
		end;
		wait(0.25);
		l__TweenService__4:Create(v113.PointLight, TweenInfo.new(0.25), {
			Range = 0
		}):Play();
	end);
end;
function positionCalculate(p15, p16)
	local v125 = p15 + p16 * 2;
	local v126 = Instance.new("Part", workspace.Thrown);
	v126.Anchored = true;
	v126.Position = v125;
	local v127 = v126:GetTouchingParts();
	v126:Destroy();
	local v128, v129, v130 = pairs(v127);
	while true do
		local v131, v132 = v128(v129, v130);
		if v131 then

		else
			break;
		end;
		v130 = v131;
		local v133 = false;
		local v134, v135, v136 = pairs(u9);
		while true do
			local v137, v138 = v134(v135, v136);
			if v137 then

			else
				break;
			end;
			v136 = v137;
			if v132:IsDescendantOf(v138) then
				v133 = true;
			end;		
		end;
		if not v133 then
			return false;
		end;	
	end;
	local v139, v140, v141 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(v125, CFrame.new(v125, v125 + Vector3.new(0, -1, 0)).lookVector * 150), u9);
	return v139, v140, v141;
end;
function predict(p17, p18, p19)
	local l__HumanoidRootPart__142 = p17.HumanoidRootPart;
	local v143, v144, v145 = positionCalculate(l__HumanoidRootPart__142.Position + Vector3.new(0, 2, 0), l__HumanoidRootPart__142.Velocity);
	if v143 then
		meteordrop(p17, v144, p19);
	end;
end;
function meteorshower(p20, p21)
	local l__p__146 = p21.p;
	local l__LookVector__147 = CFrame.new(p20.HumanoidRootPart.Position, l__p__146).LookVector;
	local v148 = 0 - 1;
	while true do
		local v149 = {};
		local v150 = 0 - 0.5;
		while true do
			local v151 = 0;
			local v152, v153, v154 = pairs(workspace.Live:GetChildren());
			while true do
				local v155, v156 = v152(v153, v154);
				if v155 then

				else
					break;
				end;
				v154 = v155;
				local l__Magnitude__157 = (v156:FindFirstChild("HumanoidRootPart").Position - l__p__146).Magnitude;
				if v151 < 2 then
					if l__Magnitude__157 < 100 then
						if isEnemy(p20, v156) then
							if not v149[v156] then
								v149[v156] = true;
								v151 = v151 + 1;
								predict(p20, v156, l__LookVector__147);
							end;
						end;
					end;
				end;			
			end;
			if v151 < 2 then
				local v158 = 0;
				local v159 = 2 - v151;
				local v160 = 1 - 1;
				while true do
					local v161 = 100 * math.clamp(math.sqrt(math.random()), 0, 1);
					local v162 = math.rad(math.random(0, 360));
					local v163, v164, v165 = positionCalculate(Vector3.new(l__p__146.X + v161 * math.cos(v162), l__p__146.Y + 2, l__p__146.Z + v161 * math.sin(v162)), Vector3.new(0, 0, 0));
					if v163 then
						meteordrop(p20, v164, l__LookVector__147);
					elseif v158 < 10 then
						v158 = v158 + 1;
					end;
					if 0 <= 1 then
						if v160 < v159 then

						else
							break;
						end;
					elseif v159 < v160 then

					else
						break;
					end;
					v160 = v160 + 1;				
				end;
			end;
			wait(0.5);
			if 0 <= 0.5 then
				if v150 < 2 then

				else
					break;
				end;
			elseif 2 < v150 then

			else
				break;
			end;
			v150 = v150 + 0.5;		
		end;
		if 0 <= 1 then
			if v148 < 1 then

			else
				break;
			end;
		elseif 1 < v148 then

		else
			break;
		end;
		v148 = v148 + 1;	
	end;
end;
function frostnova(p22)
	local l__Position__166 = p22:FindFirstChild("HumanoidRootPart").Position;
	local v167 = l__Parent__1.Snowflake:Clone();
	local oldTransparency = v167.Transparency
	v167.CFrame = p22.HumanoidRootPart.CFrame * CFrame.fromOrientation(0, 0.5235987755982988, 1.5707963267948966);
	v167.Transparency = 1;
	local v168 = v167.Size * 60 / v167.Size.Y;
	v167.Size = v168 * 0.8;
	wait(1);
	v167.Parent = workspace.Thrown;
	v167.Sound:Play();
	game.Debris:AddItem(v167, v167.Sound.TimeLength);
	l__TweenService__4:Create(v167, TweenInfo.new(0.7), {
		Size = v168
	}):Play();
	l__TweenService__4:Create(v167, TweenInfo.new(0.4), {
		Transparency = oldTransparency
	}):Play();
	wait(0.4);
	local v169 = {
		damage = 15, 
		icecase = 7.5, 
		mana = true, 
		manaknockupself = 50
	};
	for v173, v174 in next, workspace.Live:GetChildren() do
		if (v174:FindFirstChild("HumanoidRootPart").Position - l__Position__166).Magnitude < 50 then
			if isEnemy(p22, v174) then
				l__TagHumanoid__17:Fire(p22, v174, v169);
				local v175 = Instance.new("NumberValue");
				v175.Value = -5;
				v175.Name = "SpeedBoost";
				v175.Parent = v174.Boosts;
				game.Debris:AddItem(v175, 10);
			end;
		end;	
	end;
	l__TweenService__4:Create(v167, TweenInfo.new(0.3), {
		Transparency = 1
	}):Play();
end;
function conicHitbox(p23, p24)
	local v176, v177, v178 = pairs(workspace.Live:GetChildren());
	while true do
		local v179, v180 = v176(v177, v178);
		if v179 then

		else
			break;
		end;
		v178 = v179;
		local v181 = v180.HumanoidRootPart.CFrame:inverse() * p24.CFrame;
		local v182 = v181.Y + p24.Size.Y / 2;
		if math.pow(v181.X, 2) / math.pow(p24.Size.X * v182 / p24.Size.Y / 2, 2) + math.pow(v181.Z, 2) / math.pow(p24.Size.Z * v182 / p24.Size.Y / 2, 2) < 1.05 then
			if isEnemy(p23, v180) then
				l__TagHumanoid__17:Fire(p23, v180, {
					damage = 30, 
					sunlight = 50, 
					mana = true, 
					brightblind = 0.5
				});
			end;
		end;	
	end;
end;
function sunstrike(p25, p26)
	local v183 = l__Parent__1.Point:Clone();
	game.Debris:AddItem(v183, 2);
	local l__Origin__184 = v183.Origin;
	local l__Beam__185 = v183.Beam;
	local l__End__186 = v183.End;
	local l__PointLight__187 = v183.PointLight;
	local v188 = l__Parent__1.Shaft:Clone();
	game.Debris:AddItem(v188, 2);
	v183.Parent = workspace.Thrown;
	v183.CFrame = CFrame.new(p26.p);
	v183.Sound:Play();
	local l__Y__189 = l__End__186.Position.Y;
	l__TweenService__4:Create(l__End__186, TweenInfo.new(0.4), {
		Position = Vector3.new(0, 0, 0)
	}):Play();
	wait(0.4);
	v183.Transparency = 0;
	l__TweenService__4:Create(l__Beam__185, TweenInfo.new(1.2), {
		Width1 = 0.1
	}):Play();
	l__TweenService__4:Create(v183, TweenInfo.new(1.2), {
		Size = Vector3.new(2, 2, 2)
	}):Play();
	l__TweenService__4:Create(l__PointLight__187, TweenInfo.new(1.2), {
		Range = 4, 
		Brightness = 1
	}):Play();
	wait(1.2);
	v183.Transparency = 1;
	l__Beam__185.Width1 = 4;
	l__Beam__185.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 0)), ColorSequenceKeypoint.new(0.99, Color3.fromRGB(255, 150, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 50)) });
	v188.Size = Vector3.new(80, 2000, 80);
	v188.CFrame = v183.CFrame;
	v188.Parent = workspace.Thrown;
	conicHitbox(p25, v188);
	l__TweenService__4:Create(l__Beam__185, TweenInfo.new(0.4), {
		Width1 = 0
	}):Play();
	l__TweenService__4:Create(v188, TweenInfo.new(0.4), {
		Transparency = 1
	}):Play();
	l__TweenService__4:Create(l__PointLight__187, TweenInfo.new(0.4), {
		Range = 0
	}):Play();
end;
function consumeShard(p27, p28)
	local v190 = Instance.new("Accessory", p27);
	v190.Name = "Shardcasted";
	game.Debris:AddItem(v190, 15);
	local l__Handle__191 = p28:FindFirstChild("Handle");
	l__Handle__191.Parent = workspace.Thrown;
	l__Handle__191.Material = Enum.Material.Neon;
	local Player = game.Players:GetPlayerFromCharacter(p27)
	if Player then
		ToolHandler.RemoveTool(Player, p28)
	end
	Instance.new("BodyVelocity", l__Handle__191).Velocity = Vector3.new(0, 5, 0);
	local v192 = Instance.new("BodyAngularVelocity", l__Handle__191);
	local v193 = l__Parent__1.ShardSound:Clone();
	v193.Parent = l__Handle__191;
	v193:Play();
	local v194 = l__Parent__1.Shards:Clone();
	v194.Parent = l__Handle__191;
	v194.Color = ColorSequence.new(l__Handle__191.Color);
	v194.Rate = 5;
	l__TweenService__4:Create(l__Handle__191, TweenInfo.new(1.5), {
		Transparency = 1
	}):Play();
	sub(function()
		wait(1.5);
		v194.Rate = 0;
		game.Debris:AddItem(l__Handle__191, 1);
	end);
end;
function u8.shard(p29, p30)
	local v195 = nil;
	if not l__HasSkill__2:Invoke(p29, "Shardcaster") then
		return;
	end;
	local l__Character__196 = p29.Character;
	if l__Character__196:FindFirstChild("Shardcasted") then
		return;
	end;
	if ActionCheck(l__Character__196) then
		return;
	end;
	local u18 = nil;
	pcall(function()
		u18 = game.ReplicatedStorage.Requests.GetMouse:InvokeClient(p29);
	end);
	if not u18 then
		return;
	end;
	v195 = u18.Hit;
	local l__Target__197 = u18.Target;
	if p30.Name == "Opal Shard" then
		if (l__Character__196.HumanoidRootPart.Position - v195.p).Magnitude > 1000 then
			return;
		end;
		consumeShard(l__Character__196, p30);
		sunstrike(l__Character__196, v195);
	elseif p30.Name == "Sapphire Shard" then
		consumeShard(l__Character__196, p30);
		frostnova(l__Character__196);
	elseif p30.Name == "Ruby Shard" then
		if (l__Character__196.HumanoidRootPart.Position - v195.p).Magnitude > 1000 then
			return;
		end;
		consumeShard(l__Character__196, p30);
		meteorshower(l__Character__196, v195);
	end;
end;
function u8.gem(p31, p32)
	if not l__HasSkill__2:Invoke(p31, "Gemcutter") then
		return;
	end;
	local u19 = nil;
	pcall(function()
		u19 = game.ReplicatedStorage.Requests.GetMouse:InvokeClient(p31);
	end);
	if not u19 then
		return;
	end;
	local l__Target__198 = u19.Target;
	if (p31.Character.HumanoidRootPart.Position - u19.Hit.p).magnitude > 10 then
		return;
	end;
	if (l__Target__198.Parent.Name == "SmithingStation" or l__Target__198.Parent.Parent.Name == "SmithingStation") and l__Target__198.Name ~= "Hammer" and l__Target__198.Name ~= "Trash" then
		local v199 = l__Target__198.Parent:FindFirstChild("Gem") or l__Target__198.Parent.Parent:FindFirstChild("Gem");
		if not v199 then
			return;
		end;
		local l__Parent__200 = v199.Parent;
		if l__Parent__200.User.Value == "" then
			l__Parent__200.User.Value = p31.Name;
			v199.Value = p32.Name;
			local l__Handle__201 = p32:FindFirstChild("Handle");
			l__Handle__201.Parent = l__Parent__200;
			ToolHandler.RemoveTool(p31, p32)
			l__Handle__201.Anchored = true;
			l__Handle__201.Position = l__Parent__200.GemPosition.Position;
		end;
	end;
end;
local l__HttpService__20 = game:GetService("HttpService");
function u8.bar(p33, p34)
	local u21 = nil;
	pcall(function()
		u21 = game.ReplicatedStorage.Requests.GetMouse:InvokeClient(p33);
	end);
	if not u21 then
		return;
	end;
	local l__Target__202 = u21.Target;
	local l__Character__203 = p33.Character;
	if (l__Character__203.HumanoidRootPart.Position - u21.Hit.p).magnitude > 10 then
		return;
	end;
	if (l__Target__202.Parent.Name == "SmithingStation" or l__Target__202.Parent.Parent.Name == "SmithingStation") and l__Target__202.Name ~= "Hammer" and l__Target__202.Name ~= "Trash" then
		local v204 = 0;
		local l__next__205 = next;
		local v206, v207 = l__Character__203:children();
		while true do
			local v208, v209 = l__next__205(v206, v207);
			if not v208 then
				break;
			end;
			v207 = v208;
			if v209:IsA("Tool") then
				v204 = v204 + 1;
				if v204 > 1 then
					return;
				end;
			end;		
		end;
		local v210 = l__Target__202.Parent:FindFirstChild("Contents") or l__Target__202.Parent.Parent:FindFirstChild("Contents");
		local l__Parent__211 = v210.Parent;
		if l__Parent__211.User.Value == p33.Name then
			local v212 = l__Target__202.Parent:FindFirstChild("Gem") or l__Target__202.Parent.Parent:FindFirstChild("Gem");
			if v212 and v212.Value ~= "" then
				return;
			end;
		else
			l__Parent__211.User.Value = p33.Name;
		end;
		local v213 = l__HttpService__20:JSONDecode(v210.Value);
		table.insert(v213, p34.Name);
		v210.Value = l__HttpService__20:JSONEncode(v213);
		l__Parent__211.Material.Color = p34.Handle.Color;
		p34:Destroy();
	end;
end;
function u8.replaceWeapon(p35, p36)
	if p36:FindFirstChild("Danger") then
		return;
	end;
	if p36:FindFirstChild("Replaced") then
		return;
	end;
	local v214 = game.ServerStorage.PlayerData:FindFirstChild(p36.Name);
	if not v214 then
		return;
	end;
	local l__PrimaryWeapon__215 = v214.Data.PrimaryWeapon;
	if l__PrimaryWeapon__215.Value == "Mythril Church Spear" then
		return;
	end;
	l__PrimaryWeapon__215.Value = p35.Name;
	p35:Destroy();
	local v216 = Instance.new("Folder", p36);
	v216.Name = "Replaced";
	game.Debris:AddItem(v216, 15);
end;
return u8;
