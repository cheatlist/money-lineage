	local UserInputService = game:GetService("UserInputService")
local TridentModule = require(game.ServerScriptService.Modules.TridentModule)
local TagHumanoid = game.ServerStorage.Requests.TagHumanoid
local GetMouse = game.ReplicatedStorage.Requests.GetMouse
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid;
local TweenService = game:GetService("TweenService")

function sub(...)
	coroutine.wrap(...)();
end;

local Debounce = false
local HoldingM1 = false

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Character)
	return ActionCheckModule(Character, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Stun","ReturnStun","Action","Blocking","SpellBlocking","Climbing","ActiveCast","Immortal"},
		presentTagBlocks = {"Unconscious","Knocked"},
		healthAtOrBelow = 0,
	})
end

script.Parent.Activated:Connect(function()
	local u5 = nil;
	local Character = script.Parent.Parent
	local Player = game.Players:GetPlayerFromCharacter(Character)
	if Debounce then
		return
	end
	if ActionCheck(Character) then
		return
	end
	if not TridentModule.wieldTrident(Player) then
		return
	end
	local NewTrack = false
	local Cancelled = false
	local Charge = 0
	Debounce = true
	local Animation = Character.Humanoid:LoadAnimation(script.Parent.Anim)
	local v9 = false;
	Animation:Play()
	Animation:GetMarkerReachedSignal("charging"):Connect(function()
		while GetMouse:InvokeClient(Player).MouseDown and game:GetService("RunService").Heartbeat:Wait() do
			if NewTrack then
				break
			end
			Charge += 0.05
			Animation:AdjustSpeed(0.1)
		end
		Animation:AdjustSpeed(1)
	end)
	Animation:GetMarkerReachedSignal("charged"):Connect(function()
		NewTrack = true
		if Charge >= 1.2 then
			Character.HumanoidRootPart.SpearEmit:Emit(30)
		end
		while GetMouse:InvokeClient(Player).MouseDown and game:GetService("RunService").Heartbeat:Wait() do
			Animation:AdjustSpeed(0)
		end
		Animation:AdjustSpeed(1)
	end)
	Animation:GetMarkerReachedSignal("throw"):Connect(function()
		local Action = Instance.new("Accessory")
		Action.Name = "Action"
		Action.Parent = Character
		game:GetService("Debris"):AddItem(Action,1)
		local Mouse = _G.MouseData(Player)
		local PlayerWeapon = Character:FindFirstChild("Hilt"):FindFirstChild("Pronged Mythril Spear")
		if not Mouse then
			return
		end
		if not PlayerWeapon then
			return
		end
		PlayerWeapon.Transparency = 1

		local Trident = game.ServerStorage.Weapons["Pronged Mythril Spear"]:Clone();	
		Trident.Parent = game.Workspace.Thrown
		local bv = Instance.new("BodyVelocity",Trident);
		bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		Trident.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(180), 0);
		Trident.BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * 250;
		Trident:SetNetworkOwner(nil);
		local BubbleAura = game.ServerStorage.Assets.Trident.BubbleAura:Clone()
		BubbleAura.Parent = Trident
		BubbleAura.Enabled = false
		BubbleAura.Lifetime = NumberRange.new(1.5, 2)
		BubbleAura.Speed = NumberRange.new(20, 100)
		BubbleAura:Emit(30)	
		local u7 = {};
		local u8 = false;
		u5 = v9;
		local howmanytimeshit = 0;
		Trident.Touched:Connect(function(p5)
			if p5 and p5:IsDescendantOf(Character) then
				return;
			end;
			print(p5:GetFullName())
			if p5.Anchored == true and p5.Transparency ~= 1 then
				Trident.Transparency = 1;
				Trident.Anchored = true;
				howmanytimeshit += 1
				if howmanytimeshit > 3 then
					game.ServerStorage.Debris:Fire(Trident, 5);
				end
			end;
			if p5 and p5.Name == Trident.Name then
				return;
			end;
			local v13 = p5.Parent:findFirstChild("Humanoid") or p5.Parent.Parent:findFirstChild("Humanoid");
			if v13 and not u7[v13.Parent.Name] then
				Trident.Anchored = true;
				Trident.Transparency = 1;
				Trident.Anchored = true;
				u8 = true;
				u7[v13.Parent.Name] = true;
				l__TagHumanoid__4:Fire(Character, v13.Parent, {
					physical = true, 
					spear = true, 
					damage = 15, 
					slash = true, 
					blade = true,
				});
				u5 = true;
				sub(function()
					game.ServerStorage.Debris:Fire(Trident, 0.4);
				end);
			end;
			local info = TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
			local goals = {Transparency = 0}
			local tween = game:GetService("TweenService"):Create(PlayerWeapon,info,goals)
			tween:Play()
		end);
		if Trident ~= nil then
			game.ServerStorage.Debris:Fire(Trident, 1);
			task.wait(1)
			local info = TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
			local goals = {Transparency = 0}
			local tween = game:GetService("TweenService"):Create(PlayerWeapon,info,goals)
			tween:Play()
		end;
	end)
	task.wait(10)
	Debounce = false
end)