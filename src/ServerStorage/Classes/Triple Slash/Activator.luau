local v1 = {};
local l__Parent__2 = script.Parent.Parent;
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__3 = game:GetService("TweenService");
local l__SlashWave__4 = game.ServerStorage.Assets.Katana.SlashWave;
en = true;
en2 = true
local u1 = require(game.ServerScriptService.Modules.SamuraiModule);
local u2 = require(game.ServerScriptService.Modules.HitDetection);
function v1.Active(p1, p2, p3, p4)
	if u1.ActionCheck(p1)then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return
	end
	if p1.Cooldowns:FindFirstChild("Triple Slash") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Triple Slash"
	CD.Value = 9
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 9)
	en = false;
	local v5 = u1.isCalm(p1);
	local v6 = u1.hasParticles(p1)
	local l__HumanoidRootPart__6 = p1.HumanoidRootPart;
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	local handOfGod = playerdata and playerdata.Skills.Value:find("HandOfGod")
	local shura = playerdata and playerdata.Skills.Value:find("Shura")
	local selftaught = playerdata and playerdata.Skills.Value:find("Selftaught")
	if selftaught then
		-- Selftaught's Triple Slash: a single heavy slash instead of a 3-hit combo, trading
		-- combo damage for a stacking Bleed DoT (TagHumanoid's generic info.bleed handler,
		-- itself reusing the existing Bloodprism enchant's own blood sound/particle assets -
		-- "reuse assets and sounds" per the design brief). Stops the shared Anim right after its
		-- one "slash" marker fires instead of letting the rest of the 3-hit animation play out.
		local anim = p1.Humanoid:LoadAnimation(script.Parent.Anim)
		anim:Play(0.1, 1, 1.1)
		p1.HumanoidRootPart.SworderEmit:Emit(30)
		local charge = l__HumanoidRootPart__6.SwordCharge:Clone()
		charge.PlaybackSpeed = l__HumanoidRootPart__6.SwordCharge.PlaybackSpeed * 0.7
		charge.Volume = l__HumanoidRootPart__6.SwordCharge.Volume * 1.5
		charge.Parent = l__HumanoidRootPart__6
		charge:Play()
		game.Debris:AddItem(charge, 3)
		local connection
		connection = anim:GetMarkerReachedSignal("slash"):Connect(function()
			if connection then
				connection:Disconnect()
			end
			p4.TestTrail.Enabled = true
			local slash = l__HumanoidRootPart__6.KatanaSlash:Clone()
			slash.PlaybackSpeed = l__HumanoidRootPart__6.KatanaSlash.PlaybackSpeed * 0.7
			slash.Volume = l__HumanoidRootPart__6.KatanaSlash.Volume * 1.5
			slash.Parent = l__HumanoidRootPart__6
			slash:Play()
			game.Debris:AddItem(slash, 3)
			u2.magnitudeCheck(p1, l__HumanoidRootPart__6.Position, 13, {
				damage = 6,
				physical = true,
				slash = true,
				katana = true,
				bleed = true,
				move = "Triple Slash",
			}, true)
			anim:Stop()
			task.wait(0.1)
			p4.TestTrail.Enabled = false
		end)
		wait(9)
		en = true
		return
	end
	local v7 = nil;
	if shura then
		-- Shura's Sixtuple Slash always uses the plain (untrained) animation, replayed twice -
		-- deliberately not stacking with the TripleSlashTraining 4th-hit variant, to keep this a
		-- clean 2x3=6 rather than an awkward 2x4=8 edge case
		v7 = p1.Humanoid:LoadAnimation(script.Parent.Anim)
	elseif v6 then
		v7 = p1.Humanoid:LoadAnimation(script.Parent.Anim2)
	else
		v7 = p1.Humanoid:LoadAnimation(script.Parent.Anim)
	end
	v7:Play(0.1, 1, handOfGod and 0.9 or 1.3);
	local originalTrailColor = nil
	if shura then
		originalTrailColor = p4.TestTrail.Color
		p4.TestTrail.Color = ColorSequence.new(Color3.fromRGB(139, 0, 0))
	end
	local v8 = Instance.new("Folder");
	game.Debris:AddItem(v8, 1.3);
	v8.Name = "HeavyAttack";
	v8.Parent = p1;
	p1.HumanoidRootPart.SworderEmit:Emit(30);
	l__HumanoidRootPart__6.SwordCharge:Play();
	local u3 = 0;
	if shura then
		v7.Stopped:Connect(function()
			if u3 < 6 then
				v7:Play(0.1, 1, 1.3)
			end
		end)
	end

	local u4 = {
		damage = handOfGod and 10 or 7,
		physical = true,
		slash = true,
		katana = true,
		move = "Triple Slash"
	};
	if handOfGod then
		-- "fully true": once it starts landing, the rest of the combo can't be
		-- dodged/parried/blocked out of - the closest approximation of a true combo
		-- using existing Info flags, since this codebase has no dedicated concept for one
		u4.stun = 0.6
		u4.nododge = true
		u4.noparry = true
		u4.blockbreak = true
	end
	v7:GetMarkerReachedSignal("slash"):Connect(function()
		p4.TestTrail.Enabled = true;
		if handOfGod then
			local slash = l__HumanoidRootPart__6.KatanaSlash:Clone()
			slash.PlaybackSpeed = l__HumanoidRootPart__6.KatanaSlash.PlaybackSpeed * 0.8
			slash.Volume = l__HumanoidRootPart__6.KatanaSlash.Volume * 1.5
			slash.Parent = l__HumanoidRootPart__6
			slash:Play()
			game.Debris:AddItem(slash, 3)
		else
			l__HumanoidRootPart__6.KatanaSlash:Play();
		end
		u3 = u3 + 1;
		local p = game.Players:GetPlayerFromCharacter(p1)
		if shura then
			if u3 == 6 then
				u4.damage = 10;
				u4.knockback = true;
			end;
		elseif p.Backpack:FindFirstChild("TripleSlashTraining") and p1:FindFirstChild("Particles") then
			if u3 == 4 then
				u4.damage = handOfGod and 15 or 10;
				u4.knockback = true;
			end;
		else
			if u3 == 3 then
				u4.damage = handOfGod and 15 or 10;
				u4.knockback = true;
			end;
		end
		
		--da tween
		local function Tween(Object, Time, Customization, EasingStyle, EasingDirection)
			local tweenInfo = TweenInfo.new(
				Time,
				EasingStyle,
				EasingDirection
			)

			game:GetService("TweenService"):Create(Object, tweenInfo, Customization):Play()
		end
		--
		
		v7:GetMarkerReachedSignal("summonKatana"):Connect(function()
			local ShadowKatana = game.ReplicatedStorage.Assets.ShadowKatana:Clone()
			script.Parent.abyssattack3:Play()
			ShadowKatana.Parent = p1["Left Arm"]
			Tween(ShadowKatana, 0.50, {Transparency = 0.48}, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
			ShadowKatana.KatanaWeld.Part0 = ShadowKatana
			ShadowKatana.KatanaWeld.Part1 = p1["Left Arm"]
			game.Debris:AddItem(ShadowKatana,2)
		end)

		v7:GetMarkerReachedSignal("unsummonKatana"):Connect(function()
			local ShadowKatana = p1["Left Arm"]:FindFirstChild("ShadowKatana")
			Tween(ShadowKatana, 1, {Transparency = 1}, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
		end)
		u2.magnitudeCheck(p1, l__HumanoidRootPart__6.Position, 13, u4, true);
		-- Shura plays through the same 3 slash VFX twice (u3 goes 1-6), so reuse the existing
		-- "TriSlash1/2/3" client assets both passes rather than needing new "TriSlash4/5/6" ones
		local fxIndex = shura and (((u3 - 1) % 3) + 1) or u3
		if u3 == 1 then
			spawn(function()
				wait(0.007);
				if p.Backpack:FindFirstChild("TripleSlashTraining") and p1:FindFirstChild("Particles") then
					game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("TriSlash2" .. fxIndex, v6, l__HumanoidRootPart__6, p4)
				else
					game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("TriSlash" .. fxIndex, v5, l__HumanoidRootPart__6, p4);
				end
			end);
			return;
		end;
		if p.Backpack:FindFirstChild("TripleSlashTraining") and p1:FindFirstChild("Particles") then
			game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("TriSlash2" .. fxIndex, v6, l__HumanoidRootPart__6, p4)
		else
			game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("TriSlash" .. fxIndex, v5, l__HumanoidRootPart__6, p4)
		end
	end);
	v7:GetMarkerReachedSignal("slashend"):Connect(function()
		p4.TestTrail.Enabled = false;
	end);
	local v9 = 9
	if v5 then
		v9 = 6;
	end;
	wait(v9);
	if originalTrailColor then
		p4.TestTrail.Color = originalTrailColor
	end
	en = true;
end;
function v1.Active2(p5, p6, p7, p8)
	if u1.ActionCheck(p5) then
		return
	end
	if p5:FindFirstChild("Knocked") then
		return
	end
	if not p6.Backpack:FindFirstChild("TripleSlashTraining")then
		return
	end
	if p5.Cooldowns:FindFirstChild("Triple Slash M2") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Triple Slash M2"
	CD.Value = 20
	CD.Parent = p5.Cooldowns
	game.Debris:AddItem(CD, 20)
	en2 = true


	local anim = p5.Humanoid:LoadAnimation(script.Parent.Anim3)
	local l__HumanoidRootPart__4 = p5.HumanoidRootPart

	local u6 = {
		damage = p8.Stats.Damage.Value + 4, 
		physical = true, 
		slash = true, 
		katana = true,
		move = "Triple Slash"
	}
	anim:Play()
	p8.TestTrail.Enabled = true
	script.M2.Wind:Play()
	l__HumanoidRootPart__4.Greatswordcharge:Play()
	u2.magnitudeCheck(p5, l__HumanoidRootPart__4.Position, p8.Stats.Length.Value + 6, u6, true)

	u1.disspear(p5)

	local plr = game.Players:GetPlayerFromCharacter(p5)
	u1.Impact(plr, "Backhand")
	u1.Impact(plr, "Ring2")
	u1.appear(p5)
	p8.TestTrail.Enabled = false
	en2 = false
	wait(20)
	en2 = true
end	
return v1;
