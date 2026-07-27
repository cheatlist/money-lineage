

local v1 = {}
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked"},
	})
end
local v3 = tick()
local l__TweenService__4 = game:GetService("TweenService")
local u2 = true
function v1.Active(p2, p3, p4, p5)
	if ActionCheck() then
		return
	end
	if p2:FindFirstChild("VanguardBuff") then
		return
	end
	if not p2:FindFirstChild("Aether") then
		return
	end
	if p2:FindFirstChild("Aether").Value < 21 then
		return
	end
	if p2.Cooldowns:FindFirstChild("Azure Ignition") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Azure Ignition"
	CD.Value = 10
	CD.Parent = p2.Cooldowns
	game.Debris:AddItem(CD, 10)
	spawn(function()
		--_G.System.Event:FireClient(game.Players:GetPlayerFromCharacter(p2), "SetCDIndicator", {script.Parent.Name, 5})
		task.wait(10)
		u2 = true
	end)
	u2 = false
	local l__HumanoidRootPart__5 = p2.HumanoidRootPart
	local fxpart = game.ServerStorage.SpellEffects.AzureFx:Clone()
	fxpart.Parent = p5
	local weld = Instance.new("Weld")
	weld.Parent = fxpart
	weld.Part0 = fxpart
	weld.Part1 = p5
	if p5 then
		fxpart.bfBeam.Attachment1 = p5.Attachmentz
		fxpart.bfBeam.Attachment0 = p5.Attachment1
		fxpart.bfBeam.Enabled = false
	end
	-- Checked against server-only PlayerData instead of p3.Backpack - Backpack is replicated to
	-- the owning client, so a spoofed "ChargeMastery" Instance there would be trusted the same
	-- way a spoofed Character Instance would.
	local p3data = game.ServerStorage.PlayerData:FindFirstChild(p3.Name)
	if not (p3data and p3data.Skills.Value:find("ChargeMastery")) and not p2:FindFirstChild("VanguardBuff") then
		local v6 = Instance.new("Accessory")
		v6.Name = "HeavyAttack"
		v6.Parent = p2
		game:GetService("Debris"):AddItem(v6, 1)
		local v7 = Instance.new("Accessory")
		v7.Name = "NoJump"
		v7.Parent = p2
		game:GetService("Debris"):AddItem(v7, 1)
		local v8 = Instance.new("Accessory")
		v8.Name = "Action"
		v8.Parent = p2
		game:GetService("Debris"):AddItem(v8, 1.2)
		p2.Humanoid:LoadAnimation(script.Parent:FindFirstChild("Animation")):Play()
		task.wait(0.5)
		fxpart.flamecircle:Emit(5)
		fxpart.swooshy:Emit(20)
		task.wait(0.2)
	else
		fxpart.flamecircle:Emit(5)
		fxpart.swooshy:Emit(20)
	end
	local v9 = Instance.new("Folder")
	v9.Name = "VanguardBuff"
	v9.Parent = p2
	local v2 = Instance.new("NumberValue")
	v2.Name = "AttackSpeedBoost"
	v2.Value = 4
	v2.Parent = p2.Boosts
	fxpart.bfBeam.Enabled = true
	fxpart.bfBeam.Enabled = true
	fxpart.Blueflame.Enabled = true
	fxpart.sparkish.Enabled = true
	local v15 = script.Parent:FindFirstChild("FireLoop"):Clone()
	v15.Parent = p5
	v15:Play()
	local v16 = script.Parent:FindFirstChild("Ignite"):Clone()
	v16.Parent = p5
	v16:Play()
end
return v1

