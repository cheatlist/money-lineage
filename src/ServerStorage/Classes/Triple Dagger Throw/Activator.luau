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
		presentBlocks = {"Charge", "Stun", "ReturnStun", "Action", "Blocking", "ActiveCast", "SpellBlocking"},
		presentTagBlocks = {"Unconscious", "Knocked"},
	})
end
local v3 = tick();
local l__TweenService__4 = game:GetService("TweenService");
local u2 = true;
local u3 = require(game.ServerScriptService.Modules.HitDetection);
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid;
local u1 = require(game.ServerScriptService.Modules.SamuraiModule);
function v1.Active(p1, p2, p3, p4)
	local u5 = nil;
	if ActionCheck() then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("Triple Dagger Throw") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Triple Dagger Throw"
	CD.Value = 10
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 10)
	local l__HumanoidRootPart__5 = p1.HumanoidRootPart;
	local l__Humanoid__6 = p1.Humanoid;
	local prescriptc = p1.HumanoidRootPart.CFrame
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play();
	u2 = false;
	wait(0.3);
	prescriptc = prescriptc * CFrame.new(p1.HumanoidRootPart.CFrame.X - prescriptc.X, p1.HumanoidRootPart.CFrame.Y - prescriptc.Y, p1.HumanoidRootPart.CFrame.Z - prescriptc.Z)
	p1.HumanoidRootPart.DaggerSlash1:Play();
	p4.Transparency = 1;
	local v7 = Instance.new("Folder");
	v7.Name = "NoJump";
	v7.Parent = p1;
	game.ServerStorage.Debris:Fire(v7, 1);
	if not p1:FindFirstChild("Disarm") then
	local v8 = Instance.new("Folder");
	v8.Name = "Disarm";
		v8.Parent = p1;
	end
	local v9 = false;
	local u6 = nil;
	pcall(function()
		u6 = _G.MouseData(p2);
	end);
	if not u6 then
		return;
	end;
	for v10 = -1, 1 do
		local v11 = game.ServerStorage.Weapons.ThrowDagger:Clone();
		v11.Parent = game.Workspace.Thrown;
		v11.Transparency = 0.5;
		v11.Color = Color3.new(0, 0, 0);
		Instance.new("BodyVelocity").Parent = v11;
		v11.TestTrail.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0));
		v11.TestTrail.Enabled = true;
		v11.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(v10, 0, -3) * CFrame.Angles(0, v10 * 6, 0);
		v11.BodyVelocity.Velocity = v11.CFrame.lookVector * 250;
		v11:SetNetworkOwner(nil);
		local u7 = {};
		local u8 = false;
		u5 = v9;
		v11.Touched:Connect(function(p5)
			if p5.Anchored == true and p5.Transparency ~= 1 then
				v11.ShadowEmitter:Emit(100);
				v11.Transparency = 1;
				v11.Anchored = true;
				p4.Transparency = 0;
				game.ServerStorage.Debris:Fire(v11, 1);
			end;
			if p5 and p5:IsDescendantOf(p1) then
				return;
			end;
			if p5 and p5.Name == v11.Name then
				return;
			end;
			local v13 = p5.Parent:findFirstChild("Humanoid") or p5.Parent.Parent:findFirstChild("Humanoid");
			if v13 and not u7[v13.Parent.Name] then
				v11.Anchored = true;
				v11.ShadowEmitter:Emit(100);
				v11.Transparency = 1;
				v11.Anchored = true;
				p4.Transparency = 0;
				if v13.Parent.HumanoidRootPart:FindFirstChild("BloodHit") and v13.Parent.HumanoidRootPart:FindFirstChild("DaggerHit") then
					v13.Parent.HumanoidRootPart.DaggerHit:Play();
					v13.Parent.HumanoidRootPart.BloodHit:Emit(30);
				end;
				u8 = true;
				u7[v13.Parent.Name] = true;
				l__TagHumanoid__4:Fire(p1, v13.Parent, {
					slash = true, 
					dagger = true, 
					physical = true,
					daggerthrow = true, 
					noenchant = true,
					nobackstab = true,
					damage = 10,
					move = "Triple Dagger Throw"
				});
				u5 = true;
				sub(function()
					game.ServerStorage.Debris:Fire(v11, 0.4);
				end);
			end;
		end);
		if v11 ~= nil then
			game.ServerStorage.Debris:Fire(v11, 1);
		end;
	end;
	
	if p1.Name == "rip_indra" then
		u2 = true;
		return
	end
	
	wait(10);
	u2 = true;
end;
return v1;
