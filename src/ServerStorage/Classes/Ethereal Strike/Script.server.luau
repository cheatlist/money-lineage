function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local canuse = true

-- TheBlade path: a piercing dash-spin (reuses the Shinobi Shadowrush aerial spin animation,
-- game.ServerStorage.Classes.Shadowrush.Animation3, per design ask). Landing it opens a short
-- follow-up window with two mutually exclusive options: cast Lethality for a buffed hit
-- (Lethality/Activator.luau checks for the "EtherealFollowup" marker this creates), or press
-- Ethereal Strike again to dash back the way you came (inverts direction via the "EtherealChain"
-- marker's Direction value) - which destroys "EtherealFollowup", forfeiting the Lethality option,
-- and opens a fresh chain window so you can keep dashing back and forth.
local function BladeEtherealStrike(p1, p2, data)
	local HumanoidRootPart = p1.HumanoidRootPart
	local chain = p1:FindFirstChild("EtherealChain")
	local direction
	if chain then
		direction = -chain.Direction.Value
		chain:Destroy()
	else
		if p1.Cooldowns:FindFirstChild("Ethereal Strike") then
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Ethereal Strike"
		CD.Value = 22.5
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 22.5)
		direction = HumanoidRootPart.CFrame.LookVector
	end
	if p1:FindFirstChild("EtherealFollowup") then
		p1.EtherealFollowup:Destroy()
	end
	p1.Humanoid:LoadAnimation(game.ServerStorage.Classes.Shadowrush.Animation3):Play()
	HumanoidRootPart.DaggerCharge:Play()
	local bv = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(bv, "AllowedBM")
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Velocity = direction * 100
	bv.Parent = HumanoidRootPart
	local hitAlready = {}
	local dashing = true
	task.spawn(function()
		while dashing do
			for _, v in pairs(game.Workspace.Live:GetChildren()) do
				if v ~= p1 and not hitAlready[v] and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
					if (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 6 then
						hitAlready[v] = true
						game.ServerStorage.Requests.TagHumanoid:Fire(p1, v, {
							physical = true,
							dagger = true,
							damage = 3,
							slash = true,
							noparry = true,
							blockbreak = true,
							nobackstab = true,
							move = "Ethereal Strike",
						})
					end
				end
			end
			task.wait(0.05)
		end
	end)
	task.wait(0.35)
	dashing = false
	bv:Destroy()
	local followup = Instance.new("Folder")
	followup.Name = "EtherealFollowup"
	followup.Parent = p1
	game.Debris:AddItem(followup, 1.5)
	local newChain = Instance.new("Folder")
	newChain.Name = "EtherealChain"
	local dir = Instance.new("Vector3Value")
	dir.Name = "Direction"
	dir.Value = direction
	dir.Parent = newChain
	newChain.Parent = p1
	game.Debris:AddItem(newChain, 1.5)
end

script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local blade = p2 and game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if blade and blade.Skills.Value:find("TheBlade") then
		BladeEtherealStrike(p1, p2, blade)
		return
	end
	if p1.Cooldowns:FindFirstChild("Ethereal Strike") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Ethereal Strike"
	CD.Value = 22.5
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 22.5)
	canuse = false
	local HumanoidRootPart = p1.HumanoidRootPart
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	local v1 = Instance.new("Folder")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,0.5)
	HumanoidRootPart.DaggerCharge:Play()
	task.wait(0.475)
	if not p1:FindFirstChild("Stun")then
		HumanoidRootPart.ShineStab:Play()
		local data = p2 and game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
		local hitInfo = {
			noparry = true,
			physical = true,
			dagger = true,
			blockbreak = true,
			noenchant = true,
			nobuff = true,
			knockback = true,
			slash = true,
			nobackstab = true,
			move = "Ethereal Strike"
		}
		if data and data.Skills.Value:find("TheToxin") then
			-- poison injection: small direct hit, most of the payload lands as stacks
			-- (applied centrally in TagHumanoid/Procs/FacelessPaths.luau)
			hitInfo.damage = 6
		elseif data and data.Skills.Value:find("TheMaster") then
			-- combo starter/extender: no hard knockback/ragdoll, just a stun + gentle push
			-- (applied in TagHumanoid/Procs/FacelessPaths.luau), and a lot less damage
			hitInfo.knockback = nil
			hitInfo.percent = 15
		else
			hitInfo.percent = 20
		end
		u3.magnitudeCheck(p1,HumanoidRootPart.Position,8,hitInfo)
	end
	task.wait(22.5)
	canuse = true
end)	