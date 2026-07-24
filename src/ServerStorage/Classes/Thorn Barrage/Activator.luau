-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
local l__Parent__1 = script.Parent.Parent;
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge", "Stun", "ReturnStun", "Action", "Blocking", "SpellBlocking", "ActiveCast"},
		presentTagBlocks = {"Unconscious", "Knocked"},
	})
end
local v3 = tick();
local l__TweenService__4 = game:GetService("TweenService");
local u2 = true;
local u3 = require(game.ServerScriptService.Modules.HitDetection);
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid;
function v1.Active(p1, p2, p3, p45)
	local u5 = nil;
	if ActionCheck() then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("Thorn Barrage") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Thorn Barrage"
	CD.Value = 15
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 15)
	local l__HumanoidRootPart__5 = p1.HumanoidRootPart;
	local l__Humanoid__6 = p1.Humanoid;
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play();
	u2 = false;
	wait(0.3);
	p1.HumanoidRootPart.DaggerSlash1:Play();
	local v7 = Instance.new("Folder");
	v7.Name = "NoJump";
	v7.Parent = p1;
	game.ServerStorage.Debris:Fire(v7, 1);
	local v9 = Instance.new("Folder");
	v9.Name = "Action";
	v9.Parent = p1;
	game.ServerStorage.Debris:Fire(v9, 0.5);
	local v10 = false;
	local u6 = nil;
	pcall(function()
		u6 = _G.MouseData(p2);
	end);
	if not u6 then
		return;
	end;
	local v11 = {};
	for v12 = -2, 2 do
		local v13 = game.ServerStorage.Weapons.ThrowThorn:Clone();
		v13.Transparency = 0.5;
		v13.Color = Color3.new(0, 0.333333, 0);
		Instance.new("BodyVelocity").Parent = v13;
		v13.TestTrail.Color = ColorSequence.new(Color3.fromRGB(170, 85, 255));
		v13.TestTrail.Enabled = true;
		v13.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1);
		v13.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(v12, 0, -2) * CFrame.Angles(0, v12 * 6, 0);
		v13.Parent = game.Workspace.Thrown;
		v13.BodyVelocity.Velocity = v13.CFrame.lookVector * 250;
		v13:SetNetworkOwner(nil);
		local u7 = false;
		u5 = v10;
		v13.Touched:Connect(function(p4)
			if p4.Anchored == true then
				v13.ShadowEmitter:Emit(25);
				v13.Transparency = 1;
				v13.Anchored = true;
				
				game.ServerStorage.Debris:Fire(v13, 1);
			end;
			if p4 and p4:IsDescendantOf(p1) then
				return;
			end;
			if p4 and p4.Name == v13.Name then
				return;
			end;
			if p4 and not p4:IsDescendantOf(workspace.Live) then
				return;
			end;
			local v15 = p4.Parent:findFirstChild("Humanoid") or p4.Parent.Parent:findFirstChild("Humanoid");
			local v16 = v15 and v15.Parent;
			local v17 = v16 and v11[v16.Name] or 0;
			if v16 and v17 < 3 then
				if v16:FindFirstChild("Blocking") or v16:FindFirstChild("SpellBlocking") then
					return;
				end;
				u3.aoeCombatTag(p1, v13.Position, 40);
				v13.Anchored = true;
				v13.ShadowEmitter:Emit(25);
				v13.Transparency = 1;
				v13.Anchored = true;
				p45.Transparency = 0;
				if v16.HumanoidRootPart:FindFirstChild("BloodHit") and v16.HumanoidRootPart:FindFirstChild("DaggerHit") then
					v16.HumanoidRootPart.DaggerHit:Play();
					v16.HumanoidRootPart.BloodHit:Emit(30);
				end;
				u7 = true;
				v11[v16.Name] = v17 + 1;
				l__TagHumanoid__4:Fire(p1, v15.Parent, {
					slash = true, 
					dagger = true, 
					blade = true,
					noenchant = true,
					damage = 5, 
					poison = true, 
					daggerthrow = true,
					move = "Thorn Barrage"
				});
				u5 = true;
				sub(function()
					game.ServerStorage.Debris:Fire(v13, 0.4);
				end);
			end;
		end);
		if v13 ~= nil then
			game.ServerStorage.Debris:Fire(v13, 1);
			
		end;
	end;
	wait(15);
	u2 = true;
end;
return v1;
