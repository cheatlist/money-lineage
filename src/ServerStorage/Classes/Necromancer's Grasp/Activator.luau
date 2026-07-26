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
local v3 = tick()
local l__TweenService__4 = game:GetService("TweenService")
local u2 = true
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid
local v1 = {}
v1.upperbound = 30
v1.lowerbound = 10
v1.signs = 1
v1.cost = 25
function v1.Activate(p2, p1, p3)
	local u5 = nil;
	if ActionCheck() then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	local l__HumanoidRootPart__5 = p1.HumanoidRootPart;
	local l__Humanoid__6 = p1.Humanoid;
	local prescriptc = p1.HumanoidRootPart.CFrame
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play();
	local v7 = Instance.new("Folder");
	v7.Name = "NoJump";
	v7.Parent = p1;
	game.ServerStorage.Debris:Fire(v7, 1);
	u2 = false;
	local cancelat = false
	local stuncheck = p1.ChildAdded:Connect(function(child)
		if child.Name == "Stun" then
			cancelat = true
		end
	end)
	task.wait(0.2)
	stuncheck:Disconnect()
	local Particle1 = game.ServerStorage.SpellEffects.Grasp.Particle1:Clone()
	Particle1.Parent = p1["Right Arm"].SpearAttach
	local Particle2 = game.ServerStorage.SpellEffects.Grasp.Particle2:Clone()
	Particle2.Parent = p1["Right Arm"].SpearAttach
	l__HumanoidRootPart__5.Firesound:Play()
	game.Debris:AddItem(Particle1, 0.3)
	game.Debris:AddItem(Particle2, 0.3)
	if cancelat then u2 = true return end
	local v9 = false;
	task.wait(0.3)
	local v11 = game.ServerStorage.SpellEffects.Grasp:Clone()
	v11.Parent = game.Workspace.Thrown;
	v11.Transparency = 0.5;
	Instance.new("BodyVelocity").Parent = v11;
	
	v11.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
	v11.BodyVelocity.Velocity = l__HumanoidRootPart__5.CFrame.lookVector * 150;
	
	v11:SetNetworkOwner(nil);
	local u7 = {};
	local u8 = false;
	u5 = v9;
	v11.Touched:Connect(function(p5)
		if p5 and p5:IsDescendantOf(p1) then
			return;
		end;
		if p5 and p5.Name == v11.Name then
			return;
		end;
		local v13 = p5.Parent:findFirstChild("Humanoid") or p5.Parent.Parent:findFirstChild("Humanoid");
		if v13 and not u7[v13.Parent.Name] then
			v11.Anchored = true;
			v11.Death:Play()
			v11.Transparency = 1;
			v11.Anchored = true;
			u8 = true;
			u7[v13.Parent.Name] = true;
			local TendrilVelocity = Instance.new("BodyVelocity")
			game.CollectionService:AddTag(TendrilVelocity,"AllowedBM")
			TendrilVelocity.MaxForce = Vector3.new(0, math.huge, 0)
			TendrilVelocity.Velocity = Vector3.new(0, 50, 0)
			TendrilVelocity.Parent = v13.Parent.HumanoidRootPart
			task.delay(0.4, function()
				if TendrilVelocity and TendrilVelocity.Parent then
					TendrilVelocity:Destroy()
					TendrilVelocity = nil
				end

				local TendrilVelocity = Instance.new("BodyVelocity")
				game.CollectionService:AddTag(TendrilVelocity,"AllowedBM")
				TendrilVelocity.MaxForce = Vector3.new(0, math.huge, 0)
				TendrilVelocity.Velocity = Vector3.new(0, -75, 0)
				TendrilVelocity.Parent = v13.Parent.HumanoidRootPart

				game.Debris:AddItem(TendrilVelocity,0.4)
				task.wait(0.4)
				pcall(function()
					local Ragdoll = Instance.new("Accessory")
					Ragdoll.Name = "Knocked"
					Ragdoll.Parent = v11
					game:GetService("Debris"):AddItem(Ragdoll,2)
				end)
				if v11:FindFirstChild("Knocked") then
					p2.Humanoid.Health += 25
				end
			end)
			l__TagHumanoid__4:Fire(p1, v13.Parent, {
				slamdown = true,
				damage = 15,
				cursestack = true,
				blockbreak = true,
				noenchant = true,
				move = "Necromancer's Grasp"
			});
			u5 = true;
			sub(function()
				game.ServerStorage.Debris:Fire(v11, 10);
			end);
		end;
	end);
	if v11 ~= nil then
		game.ServerStorage.Debris:Fire(v11, 10);
	end;
	task.wait(10);
	u2 = true;
end;
return v1;
