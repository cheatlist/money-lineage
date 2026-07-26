-- Decompiled with the Synapse X Luau decompiler.

local v1 = require(game.ServerScriptService.Modules.DangerHandler);
local v2 = {};
local l__Parent__1 = script.Parent.Parent;
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","ActiveCast","Action","Blocking","SpellBlocking"},
		presentTagBlocks = {"Unconscious","Knocked"},
	})
end;
local v3 = tick();
local u2 = true;
local u3 = {
	Dexerius = true, 
	Yreol = true
};
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid;
local l__TweenService__5 = game:GetService("TweenService");
local u6 = false;

local function setInvisible(character, transparency)
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			v.Transparency = transparency
		elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
			v.Handle.Transparency = transparency
		end
	end
end

-- TheBlade path: fast vertical slash, heavy endlag on a whiff, invisible Chain-Lethality-style
-- flurry + a knockback finisher on a hit. `buffed` is true when this was reached via Ethereal
-- Strike's post-dash follow-up window (see Ethereal Strike/Script.server.luau) - it searches a
-- much wider radius and, once a target is found at all, blinks p1 right up to them before the
-- hit lands (mirrors the existing Dagger/Bane blink-strike convention), so range/facing/dodging
-- can't cause a whiff anymore - only "no target anywhere nearby" can.
local function BladeLethality(p1, p2, data, buffed)
	local HumanoidRootPart = p1.HumanoidRootPart
	local target, targetDist = nil, buffed and 40 or 9
	for _, v in pairs(game.Workspace.Live:GetChildren()) do
		if v ~= p1 and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			local dist = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
			if dist < targetDist and (buffed or (HumanoidRootPart.CFrame:inverse() * v.HumanoidRootPart.CFrame).Z < 0) then
				target, targetDist = v, dist
			end
		end
	end
	if not target then
		-- whiffed: heavy endlag, punished for missing
		local endlag = Instance.new("Folder")
		endlag.Name = "Action"
		endlag.Parent = p1
		game.Debris:AddItem(endlag, 1.4)
		HumanoidRootPart.DaggerSlash1:Play()
		return
	end
	if buffed then
		local targetRoot = target.HumanoidRootPart
		local approachDir = HumanoidRootPart.Position - targetRoot.Position
		approachDir = approachDir.Magnitude > 0.01 and approachDir.Unit or Vector3.new(0, 0, 1)
		HumanoidRootPart.CFrame = CFrame.new(targetRoot.Position + approachDir * 3, targetRoot.Position)
	end
	local mult = buffed and 1.4 or 1
	l__TagHumanoid__4:Fire(p1, target, {
		physical = true,
		dagger = true,
		damage = 3 * mult,
		slash = true,
		blockbreak = true,
		nobackstab = true,
		move = "Lethality",
	})
	local v12 = Instance.new("NumberValue");
	v12.Name = "Transparency";
	v12.Value = 1;
	v12.Parent = p1.Boosts;
	for i = 1, 6 do
		if not target or target.Parent ~= game.Workspace.Live or target.Humanoid.Health <= 0 then
			break
		end
		l__TagHumanoid__4:Fire(p1, target, {
			physical = true,
			dagger = true,
			damage = 2.5 * mult,
			slash = true,
			executes = true,
			nobackstab = true,
			nobuff = true,
			move = "Lethality",
		})
		task.wait(0.06)
	end
	v12:Destroy()
	if target and target.Parent == game.Workspace.Live and target:FindFirstChild("HumanoidRootPart") then
		local bv = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(bv, "AllowedBM")
		bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bv.Velocity = (target.HumanoidRootPart.Position - HumanoidRootPart.Position).Unit * 65 + Vector3.new(0, 15, 0)
		bv.Parent = target.HumanoidRootPart
		game.Debris:AddItem(bv, 0.3)
	end
end

function v2.Active(p1, p2, p3, p45)
	if ActionCheck() then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	local data = game.ServerStorage.PlayerData[p2.Name]
	-- TheMaster path: slightly more damage per hit, and the post-flurry recovery is cut way
	-- down so it functions as a combo extender (you can chain straight into an M1 string
	-- instead of eating the usual 0.7s lockout) - see the `master` uses below.
	local master = data.Skills.Value:find("TheMaster")
	if data.Skills.Value:find("TheBlade") then
		if p1.Cooldowns:FindFirstChild("Lethality") then
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Lethality"
		CD.Value = 30
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 30)
		local buffed = p1:FindFirstChild("EtherealFollowup") ~= nil
		if buffed then
			p1.EtherealFollowup:Destroy()
			if p1:FindFirstChild("EtherealChain") then
				p1.EtherealChain:Destroy()
			end
		end
		BladeLethality(p1, p2, data, buffed)
		return
	end
	if p1.Cooldowns:FindFirstChild("Lethality") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Lethality"
	CD.Value = 30
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 30)
	p3 = p45
	local l__HumanoidRootPart__4 = p1.HumanoidRootPart;
	local l__Humanoid__5 = p1.Humanoid;
	if p2.Backpack:FindFirstChild("Chain Lethality") then
		local v6 = Instance.new("Folder");
		v6.Name = "NoJump";
		v6.Parent = p1;
		game.Debris:AddItem(v6, 1);
		u2 = false;
		local v7 = nil;
		if not p45:FindFirstChild("LethalTrail") then
			v7 = script.Parent.LethalTrail:Clone();
			v7.Attachment0 = p45:WaitForChild("Attachment1");
			v7.Attachment1 = p3:WaitForChild("Attachment2");
			v7.Parent = p45;
		elseif p45:FindFirstChild("LethalTrail") then
			v7 = p45:FindFirstChild("LethalTrail");
		end;
		local v8 = l__Humanoid__5:LoadAnimation(script.Parent:FindFirstChild("AnimationL"));
		local v9 = 1.05;
		if game.CollectionService:HasTag(p1, "BrokenArm") then
			v9 = 0.8;
		end;
		v8:Play(0.1, 1, v9 * 1.45);
		local u7 = false;
		v8.KeyframeReached:Connect(function(p4)
			if p4 == "toss" and p3:FindFirstChild("TestTrail") then
				p3.TestTrail.Enabled = true;
			end;
			if p4 == "slice" then
				if p3:FindFirstChild("TestTrail") then
					p3.TestTrail.Enabled = false;
				end;
				if math.random(1, 2) == 1 then
					l__HumanoidRootPart__4.DaggerSlash2:Play();
				else
					l__HumanoidRootPart__4.DaggerSlash1:Play();
				end;
				v7.Enabled = true;
			end;
			if p4 == "trueslice" then
				u7 = true;
			end;
			if p4 == "end" then
				v7.Enabled = false;
			end;
		end);
		task.wait(0.55);
		spawn(function()
			task.wait(0.1);
			v7.Enabled = false;
		end);
		local v10 = {};
		local v11 = false;
		for v15, v16 in pairs(game.Workspace.Live:GetChildren()) do
			local v17 = v16:IsA("Model") and v16 or nil;
			if not v10[v17] and v17:FindFirstChild("Humanoid") and v17:FindFirstChild("HumanoidRootPart") and v17 ~= p1 and not v17:FindFirstChild("Hitboxes") and (l__HumanoidRootPart__4.Position - v17.HumanoidRootPart.Position).magnitude <= 8.5 and ((l__HumanoidRootPart__4.CFrame:inverse() * v17.HumanoidRootPart.CFrame).Z < 0 and v17.Humanoid.Health > 0 and not p1:FindFirstChild("Stun")) then
				local v18 = game.Players:GetPlayerFromCharacter(v17);
				v10[v17] = true;
				local u8 = v11;
				spawn(function()
					for v19 = 1, 6 do
						if u3[v17.Name] then
							game.Debris:AddItem(v17, 2);
						end;
						l__TagHumanoid__4:Fire(p1, v17, {
							physical = true,
							dagger = true,
							noenchant = true,
							damage = master and 4.5 or 4,
							slash = true,
							executes = true,
							nobackstab = true,
							nobuff = true,
							move = "Lethality"
						});
						u8 = true;
						local v20 = script.Parent:FindFirstChild("effect"):Clone();
						v20.CFrame = v17.HumanoidRootPart.CFrame * CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) * CFrame.Angles(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
						v20.Parent = game.Workspace;
						v20:WaitForChild("DaggerHit"):Play();
						game.Debris:AddItem(v20, 1);
						local v21 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
						local v22 = l__TweenService__5:Create(v20:WaitForChild("Mesh"), v21, {
							Scale = Vector3.new(1, 1, 1)
						}):Play();
						local v23 = l__TweenService__5:Create(v20, v21, {
							Transparency = 1
						}):Play();
						task.wait(0.04);
					end;
					p1.HumanoidRootPart.CFrame = v16.HumanoidRootPart.CFrame;
					if u8 then
						for v24, v25 in pairs(game.Workspace.Live:GetChildren()) do
							if not v10[v25] and v25:FindFirstChild("Torso") and (v25.Torso.Position - p1.Torso.Position).magnitude <= 60 and v25 ~= p1 and v25 ~= v17 then
								v10[v25] = true;
								for v26 = 1, 6 do
									l__TagHumanoid__4:Fire(p1, v25, {
										physical = true,
										dagger = true,
										noenchant = true,
										damage = master and 4.5 or 4,
										slash = true,
										executes = true,
										nobackstab = true,
										nobuff = true,
										move = "Lethality"
									});
									local v27 = script.Parent:FindFirstChild("effect"):Clone();
									v27.CFrame = v25.HumanoidRootPart.CFrame * CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) * CFrame.Angles(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
									v27.Parent = game.Workspace;
									v27:WaitForChild("DaggerHit"):Play();
									game.Debris:AddItem(v27, 1);
									local v28 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
									local v29 = l__TweenService__5:Create(v27:WaitForChild("Mesh"), v28, {
										Scale = Vector3.new(1, 1, 1)
									}):Play();
									local v30 = l__TweenService__5:Create(v27, v28, {
										Transparency = 1
									}):Play();
									task.wait(0.04);
								end;
							end;
						end;
					end;
				end);
			end;		
		end;
		u6 = false;
	else
		local v31 = Instance.new("Folder");
		v31.Name = "HeavyAttack";
		v31.Parent = p1;
		game.Debris:AddItem(v31, 0.55);
		local v32 = Instance.new("Folder");
		v32.Name = "NoJump";
		v32.Parent = p1;
		game.Debris:AddItem(v32, 1);
		u2 = false;
		local v33 = nil;
		if not p3:FindFirstChild("LethalTrail") then
			v33 = script.Parent.LethalTrail:Clone();
			v33.Attachment0 = p3:WaitForChild("Attachment1");
			v33.Attachment1 = p3:WaitForChild("Attachment2");
			v33.Parent = p3;
		elseif p3:FindFirstChild("LethalTrail") then
			v33 = p3:FindFirstChild("LethalTrail");
		end;
		local v34 = l__Humanoid__5:LoadAnimation(script.Parent:FindFirstChild("AnimationL"));
		local v35 = 1.05;
		if game.CollectionService:HasTag(p1, "BrokenArm") then
			v35 = 0.8;
		end;
		v34:Play(0.1, 1, v35 * 1.45);
		local u9 = false;
		v34.KeyframeReached:Connect(function(p5)
			if p5 == "toss" and p3:FindFirstChild("TestTrail") then
				p3.TestTrail.Enabled = true;
			end;
			if p5 == "slice" then
				if p3:FindFirstChild("TestTrail") then
					p3.TestTrail.Enabled = false;
				end;
				if math.random(1, 2) == 1 then
					l__HumanoidRootPart__4.DaggerSlash2:Play();
				else
					l__HumanoidRootPart__4.DaggerSlash1:Play();
				end;
				v33.Enabled = true;
			end;
			if p5 == "trueslice" then
				u9 = true;
			end;
			if p5 == "end" then
				v33.Enabled = false;
			end;
		end);
		task.wait(0.55);
		spawn(function()
			task.wait(0.1);
			v33.Enabled = false;
		end);
		for v39, v40 in pairs(game.Workspace.Live:GetChildren()) do
			local v41 = v40:IsA("Model") and v40 or nil;
			if v41 and v41:FindFirstChild("Humanoid") and v41:FindFirstChild("HumanoidRootPart") and v41 ~= p1 and not v41:FindFirstChild("Hitboxes") and (l__HumanoidRootPart__4.Position - v41.HumanoidRootPart.Position).magnitude <= 8.5 and ((l__HumanoidRootPart__4.CFrame:inverse() * v41.HumanoidRootPart.CFrame).Z < 0 and v41.Humanoid.Health > 0 and not p1:FindFirstChild("Stun")) then
				local v42 = game.Players:GetPlayerFromCharacter(v41);
				spawn(function()
					for v43 = 1, 6 do
						l__TagHumanoid__4:Fire(p1, v41, {
							physical = true,
							dagger = true,
							damage = master and 2.5 or 2,
							noenchant = true,
							nobackstab = true,
							slash = true,
							executes = true,
							nobuff = true,
							move = "Lethality"
						});
						local v44 = script.Parent:FindFirstChild("effect"):Clone();
						v44.CFrame = v41.HumanoidRootPart.CFrame * CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) * CFrame.Angles(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
						v44.Parent = game.Workspace;
						v44:WaitForChild("DaggerHit"):Play();
						game.Debris:AddItem(v44, 1);
						local v45 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
						local v46 = l__TweenService__5:Create(v44:WaitForChild("Mesh"), v45, {
							Scale = Vector3.new(1, 1, 1)
						}):Play();
						local v47 = l__TweenService__5:Create(v44, v45, {
							Transparency = 1
						}):Play();
						task.wait(0.04);
					end;
				end);
				p1.Torso.CFrame = p1.Torso.CFrame * CFrame.new(0, 0, -8);
			end;		
		end;
		local v48 = Instance.new("Folder");
		v48.Name = "Action";
		v48.Parent = p1;
		-- TheMaster path: barely any recovery, so the flurry functions as a combo extender
		-- into an M1 string instead of a hard stop
		game.Debris:AddItem(v48, master and 0.1 or 0.7);
		u6 = false;
	end;
	
	task.wait(30);
	u2 = true;
end;
return v2;
