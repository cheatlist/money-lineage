local v1 = {};
v1.upperbound = 100;
v1.lowerbound = 70;
v1.signs = 1;
v1.cost = 0;
v1.solanedict = true;
local l__Barrier__1 = game.ServerStorage.SpellEffects.NecroField;
local l__TweenService__2 = game:GetService("TweenService");
local u3 = {

};
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid;
local R3 = require(game.ServerScriptService.RotatedRegion3)

function Anchor(Target, Statement)
	if Statement then
		game.CollectionService:AddTag(Target, "FreezeRoot")
	else
		game.CollectionService:RemoveTag(Target, "FreezeRoot")
	end
end

local casting = false
local Windup = false

function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") or p2:FindFirstChild("ActiveCast") then
		return;
	end;
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
	local Loop = p2.Humanoid:LoadAnimation(script.Parent.Loop)
	Windup = true
	Anchor(p2, true)
	WindupAnim:Play()
	task.spawn(function()
		while Windup do
			local v17 = v7;
			if not v17 then
				v17 = true;
				v17 = (p2:FindFirstChild("Stun") or p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious"));
			end;
			v7 = v17;
			if v7 then
				WindupAnim:Stop()
				Windup = false
			end;
			task.wait(0.1)
		end
	end)

	l__HumanoidRootPart__6.NecroFieldCasting:Play()

	task.wait(0.5)

	if Windup == false then
		-- Interrupted (Stun/Knocked/Unconscious) or manually cancelled during windup. This branch
		-- used to return with no cleanup at all: FreezeRoot was never removed and the ActiveCast
		-- tag (which blocks every future cast, including trying to cast Dark Meadow again to
		-- "cancel" it) was never destroyed - permanently bugging the player out. Also, the poll
		-- loop above used to call Windup:Stop() (the boolean flag, not the animation) which threw
		-- and silently killed that coroutine before it ever set Windup = false, so this branch was
		-- never actually reached at all - fixed alongside this cleanup.
		WindupAnim:Stop()
		Anchor(p2, false)
		v5:Destroy()
		return
	end
	Windup = false
	Loop:Play()
	casting = true
	l__HumanoidRootPart__6.NecroFieldCast:Play()
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
	game.Debris:AddItem(v9, 60);
	local v7 = p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious") or not casting
	task.spawn(function()
		while casting and p2.Mana.Value > 0 do
			task.wait(0.1)
			local v17 = v7;
			if not v17 then
				v17 = true;
				v17 = (p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious") or not casting);
			end;
			v7 = v17;
			if v7 then
				casting = false
				break
			end;
			local Hitbox = R3.Cylinder(v9.CFrame, v9.Size + Vector3.new(10,0,0))
			Hitbox:GetHumanoids({p2}, function(humanoid)
				local p5 = humanoid
				local v10 = p5.Parent:FindFirstChild("Humanoid") or p5.Parent.Parent:FindFirstChild("Humanoid");
				if v10 then
					local l__Parent__11 = v10.Parent;
					if l__Parent__11 ~= p2 then
						local v12 = l__Parent__11 and game.Players:FindFirstChild(l__Parent__11.Name);
						local v13 = v12 and game.ServerStorage.PlayerData:FindFirstChild(l__Parent__11.Name);
						if v13 then
							if not l__Parent__11:FindFirstChild("Grabbed") then
								if not l__Parent__11:FindFirstChild("HitByField") then
									local hit = Instance.new("IntValue")
									hit.Name = "HitByField"
									hit.Parent = l__Parent__11
									game.Debris:AddItem(hit, .6)
									v10.RootPart.NecroFieldHit:Play();
									v10.RootPart.RuneCharge:Play();
									l__TagHumanoid__4:Fire(p2, l__Parent__11, {
										mana = true, 
										damage = 1.5, 
										nododge = true,
										necrofield = true,
										slow = true,
										physical = true,
										blockallsides = true,
										noenchant = true,
										move = "Dark Meadow"
									});
								end
							end;
						end;
					end
				end;
			end)
		end
		Anchor(p2, false)
		Loop:Stop()
		v9.Parent = workspace.Thrown;
		l__TweenService__2:Create(v9, TweenInfo.new(1), {
			Size = Vector3.new(0, 0, 0)
		}):Play();
		game.Debris:AddItem(v9, 1);
		v5:Destroy();
	end)
end;
function v1.Deactivate(p6, p7, p8)
	casting = false;
	Windup = false;
end;
return v1;
