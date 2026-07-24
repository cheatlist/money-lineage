local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local TridentModule = require(game.ServerScriptService.Modules.TridentModule)
local TagHumanoid = game.ServerStorage.Requests.TagHumanoid
local hitdetect = require(game.ServerScriptService.Modules.HitDetection)
local GetMouse = game.ReplicatedStorage.Requests.GetMouse

local Debounce = false
local Deb2 = false
local HoldingM1 = false
local speed = 105

function ActionCheck(Character)
	if not Character:FindFirstChild("Humanoid") then
		return true
	end
	if Character:FindFirstChild("Stun") then
		return true
	end
	if Character:FindFirstChild("ReturnStun") then
		return true
	end
	if Character:FindFirstChild("Action") then
		return true
	end
	if Character:FindFirstChild("Blocking") then
		return true
	end
	if Character:FindFirstChild("SpellBlocking") then
		return true
	end
	if Character.Humanoid.Health == 0 then
		return true
	end
	if Character:FindFirstChild("Climbing") then
		return true
	end
	if Character:FindFirstChild("ActiveCast") then
		return true
	end
	if game.CollectionService:HasTag(Character, "Unconscious") then
		return true
	end
	if game.CollectionService:HasTag(Character, "Knocked") then
		return true
	end
	if Character:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end

local dmgtable = {
	physical = true, 
	spear = true, 
	slash = true, 
	damage = 8, 
	stun = 6,
}
local dmgtable2 = {
	waterspikes2 = true, 
}
local dmgtable3 = {
	physical = true, 
	spear = true, 
	slash = true,
	blockbreak = true,
	noparry = true,
	damage = 9, 
	stun = 6,
}
script.Parent.Activated:Connect(function()
	local Character = script.Parent.Parent
	local Player = game.Players:GetPlayerFromCharacter(Character)
	local PData = game.ServerStorage.PlayerData[Player.Name]
	local Upgraded = Player.Backpack:FindFirstChild("HarpoonUpgraded")
	if Debounce then
		return
	end
	if ActionCheck(Character) then
		return
	end
	if not TridentModule.wieldTrident(Player) then
		return
	end
	local p1 = Player
	local data = game.ServerStorage.PlayerData[p1.Name]
	local wl = true
	if data.PrimaryWeapon.Value ~= "Pronged Mythril Spear" then wl = false end
	if wl == false then return end
	local NewTrack = false
	local Cancelled = false
	local Charge = 0
	Debounce = true
	task.delay(20, function()
		Debounce = false
	end)
	if Upgraded then
		speed = 165
	end
	--local HeavyAttack = Instance.new("Accessory")
	--HeavyAttack.Name = "HeavyAttack"
	--HeavyAttack.Parent = Character
	local Animation = Character.Humanoid:LoadAnimation(script.Parent.Anim)
	Animation:Play()
	Character.HumanoidRootPart.DisarmStrike:Play()
	Animation:GetMarkerReachedSignal("charging"):Connect(function()
		while GetMouse:InvokeClient(Player).MouseDown and game:GetService("RunService").Heartbeat:Wait() do
			--if Character:FindFirstChild("HeavyAttack") == nil then
			--	print("No heavy attack")
			--	return
			--end
			if NewTrack then
				break
			end
			if Upgraded then
				Charge += 0.40
				print(Charge)
				Animation:AdjustSpeed(0.4)
			else
				Charge += 0.10
				print(Charge)
				Animation:AdjustSpeed(0.2)
			end
		end
		Animation:AdjustSpeed(1)
	end)
	Animation:GetMarkerReachedSignal("charged"):Connect(function()
		--if Character:FindFirstChild("HeavyAttack") == nil then
		--	print("No heavy attack")
		--	return
		--end
		NewTrack = true
		if Charge >= 1.2 then
			Character.HumanoidRootPart.SpearEmit:Emit(30)
			Character.HumanoidRootPart.CrazySound:Play()
		end
		while GetMouse:InvokeClient(Player).MouseDown and game:GetService("RunService").Heartbeat:Wait() do
			--if Character:FindFirstChild("HeavyAttack") == nil then
			--	print("No heavy attack")
			--	return
			--end
			Animation:AdjustSpeed(0)
		end
		Animation:AdjustSpeed(1)
	end)
	Animation:GetMarkerReachedSignal("throw"):Connect(function()
		local PlayerWeapon = Character:FindFirstChild("Hilt"):FindFirstChild("Pronged Mythril Spear")
		if not PlayerWeapon then
			PlayerWeapon = Character:FindFirstChild("Hilt"):FindFirstChild("Fairfrozen")
		end
		if not PlayerWeapon then
			--HeavyAttack:Destroy()
			return
		end
		--if Character:FindFirstChild("HeavyAttack") == nil then
		--	print("No heavy attack")
		--	return
		--end
		--HeavyAttack:Destroy()
		Character.HumanoidRootPart.HammerThrow:Play()
		local Action = Instance.new("Accessory")
		Action.Name = "Action"
		Action.Parent = Character
		if not _G.Debris then repeat task.wait() until _G.Debris end
		_G.Debris:AddItem(Action,1)
		local Mouse = _G.MouseData(Player)
		if not Mouse then
			return
		end

		local Trident = PlayerWeapon:Clone()
		Trident.Name = Character.Name.. "Trident"
		Trident.PropWeld:Destroy()
		Trident.Weld:Destroy()
		Trident:ClearAllChildren()
		Trident.Parent = game.Workspace.Thrown
		local bv = Instance.new("BodyVelocity", Trident)
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = Character.HumanoidRootPart.CFrame.lookVector * speed
		Trident.CFrame *= CFrame.fromEulerAnglesXYZ(0,math.rad(0), math.rad(90))
		CollectionService:AddTag(bv, "AllowedBM")
		Trident:SetNetworkOwner(nil)

		local lasttarget
		task.spawn(function()
			while Trident.Parent == game.Workspace.Thrown do
				for i,v in pairs(game.Workspace.Live:GetChildren()) do 
					if v and v ~= Character and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild(Character.Name.. "Harpoon") == nil and (v.HumanoidRootPart.CFrame.Position - Trident.Position).Magnitude < 8 then
						if Upgraded and Trident:FindFirstChild("ALREADYSTUCK") == nil and v:FindFirstChild("CurseBlocking") == nil and v:FindFirstChild("SpellBlocking") == nil then
							local stucktosomeone = Instance.new("Accessory", Trident)
							stucktosomeone = "ALREADYSTUCK"
							lasttarget = v
							if Trident:FindFirstChild("BodyVelocity") then
								Trident.BodyVelocity:Destroy()
							end
							Trident.Parent = lasttarget
							TagHumanoid:Fire(Character,lasttarget, dmgtable3)
							local toobjectthing = Trident.CFrame:toObjectSpace(v.Torso.CFrame)
							local WeldThing = Instance.new("Weld")
							WeldThing.Part0 = lasttarget.Torso
							WeldThing.Part1 = Trident
							WeldThing.C0 = (toobjectthing - toobjectthing.p) * CFrame.new(math.random(-10, 10) / 100, math.random(-10, 10) / 100, math.random(-10, 10) / 100)
							WeldThing.Parent = Trident
							local antihit = Instance.new("Accessory", lasttarget)
							antihit.Name = Character.Name.. "Harpoon"
							if not _G.Debris then repeat task.wait() until _G.Debris end
							_G.Debris:AddItem(antihit, 3)
							local harpooned = Instance.new("Accessory", lasttarget)
							harpooned.Name = Character.Name.. "Harpooned"
							if not _G.Debris then repeat task.wait() until _G.Debris end
							_G.Debris:AddItem(harpooned, 30)
							if not _G.Debris then repeat task.wait() until _G.Debris end
							_G.Debris:AddItem(Trident, 40)
							task.delay(20, function()
								if Trident.Parent == nil then
									return
								end
								game:GetService("TweenService"):Create(Trident,TweenInfo.new(0.45),{Transparency = 1}):Play()
								local BubbleAura = game.ServerStorage.Assets.Trident.BubbleAura:Clone()
								BubbleAura.Parent = Trident
								BubbleAura.Enabled = false
								BubbleAura.Lifetime = NumberRange.new(1.5, 2)
								BubbleAura.Speed = NumberRange.new(20, 100)
								BubbleAura:Emit(30)
								if not _G.Debris then repeat task.wait() until _G.Debris end
								_G.Debris:AddItem(BubbleAura,1)
								if not _G.Debris then repeat task.wait() until _G.Debris end
								_G.Debris:AddItem(Trident,3)
							end)
							break
						else
							local antihit = Instance.new("Accessory", v)
							antihit.Name = Character.Name.. "Harpoon"
							if not _G.Debris then repeat task.wait() until _G.Debris end
							_G.Debris:AddItem(antihit, 3)
							TagHumanoid:Fire(Character,v, dmgtable)
							break
						end
					end
				end
				task.wait(0.01)
			end
		end)

		task.delay(2,function()
			if Trident.Parent ~= game.Workspace.Thrown then
				return
			end
			if Trident:IsDescendantOf(game.Workspace)then
				if Trident:FindFirstChild("BodyVelocity") then
					Trident.BodyVelocity:Destroy()
				end
				Trident.Anchored = true
			end
			game:GetService("TweenService"):Create(Trident,TweenInfo.new(0.45),{Transparency = 1}):Play()
			local BubbleAura = game.ServerStorage.Assets.Trident.BubbleAura:Clone()
			BubbleAura.Parent = Trident
			BubbleAura.Enabled = false
			BubbleAura.Lifetime = NumberRange.new(1.5, 2)
			BubbleAura.Speed = NumberRange.new(20, 100)
			BubbleAura:Emit(30)
			if not _G.Debris then repeat task.wait() until _G.Debris end
			_G.Debris:AddItem(BubbleAura,1)
			if not _G.Debris then repeat task.wait() until _G.Debris end
			_G.Debris:AddItem(Trident,3)
		end)
	end)
end)
