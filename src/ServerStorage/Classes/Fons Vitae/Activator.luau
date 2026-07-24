local module = {}

function Wrap(...)
	coroutine.wrap(...)()
end

local M1Cooldown = false
local M2Cooldown = false
module.upperbound = 100
module.lowerbound = 80
module.signs = 10
module.cost = 100
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local SpellModule = require(ServerScriptService.Modules.SpellModule)
local Danger = require(ServerScriptService.Modules.DangerHandler)
local VerdienModules = ServerStorage.VerdienModules
local VerdienModule = require(VerdienModules.VerdienModule)
local TagHumanoid = ServerStorage.Requests.TagHumanoid

local function canRoot(p7): boolean
	if p7:FindFirstChild("Knocked") or p7:FindFirstChild("Blocking") then
		return false;
	end
	return true;
end;

local cauldron = false
local canuse = true
function module.Active(a, z, cast, no)
	local Player = z;
	local Character = z.Character
	if not canuse then return end
	if CollectionService:HasTag(Character, "Casting") then
		return;
	end;
	local Mana = Character.Mana;
	
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	
	local p2 = game.Players:GetPlayerFromCharacter(Character)
	local u4 = _G.MouseData(p2);
	if not u4 then
		return;
	end;
	local l__p__49 = u4.Hit.p;
	if (l__p__49 - HumanoidRootPart.Position).magnitude > 50 then
		return;
	end;
	if not workspace:FindPartOnRayWithIgnoreList(Ray.new(HumanoidRootPart.CFrame.p, Vector3.new(0, -10, 0)), { workspace.AreaMarkers, workspace.MonsterSpawns, workspace.Live }) then
		return;
	end;
	canuse = false
	Character.Humanoid:LoadAnimation(script.Snap2):Play()

	local l__Value__30: string = Player.leaderstats.LastName.Value;

	Mana.Value = math.max(Mana.Value - module.cost, 0);
	VerdienModule:snapEffect(Character, true);
	
	local v52 = nil;
	local v53 = 10;
	for v54, v55 in pairs(game.Workspace.Live:GetChildren()) do
		local l__HumanoidRootPart__56 = v55:FindFirstChild("HumanoidRootPart");
		if l__HumanoidRootPart__56 and (l__HumanoidRootPart__56.Position - l__p__49).magnitude <= 10 and (l__HumanoidRootPart__56.Position - l__p__49).magnitude < v53 and v55 ~= Character and not v55:FindFirstChild("Immortal") and not v55:FindFirstChildOfClass("ForceField") then
			v53 = (v55.Torso.Position - l__p__49).magnitude;
			v52 = v55;
		end;
	end;
	
	if v52 and canRoot(v52) then
		task.wait(0.1);
		local HRP = v52:FindFirstChild'HumanoidRootPart'
		if HRP and(HRP.Position - Character.HumanoidRootPart.Position).Magnitude <= 40 and canRoot(v52) then
			local v33 = ServerStorage.PlayerData:FindFirstChild(v52.Name) and game.Players:GetPlayerFromCharacter(v52) and game.Players:GetPlayerFromCharacter(v52).leaderstats.LastName.Value;
			if not v33 or (l__Value__30 == "" or  game.Players:GetPlayerFromCharacter(v52).leaderstats.LastName.Value ~= l__Value__30) and v52 ~= Character then
				task.spawn(function()
					VerdienModule:rootCharacter(v52, Character, "Verdien", 8, 1.25, 1.75);
					task.wait(0.1)
					TagHumanoid:Fire(v52, v52, {
						mana = true, 
						damage = 10, 
						manabreaker = true,
						nododge = true,
						rootstab = true,
						move = "Fons Vitae"
					});
					
					if ServerStorage.PlayerData:FindFirstChild(Player.Name).Hybrid.Value ~= "" then
						local immortal = Instance.new("Accessory")
						immortal.Name = "Immortal"
						immortal.Parent = v52
						game.Debris:AddItem(immortal, 3)
					end
				end)
			end;
		end
	end
	task.wait(17)
	canuse = true
end

function detoxify(enemy, Character)
	local Toxicity = enemy.Toxicity
	if 10 < Toxicity.Value then
		local toRemove = 50 < Toxicity.Value / 4 and Toxicity.Value / 4 or 50;
		toRemove = toRemove / 5
		if 100 < Toxicity.Value / 4 then
			toRemove = 100;
		end;

		local Detoxify = VerdienModules.Detoxify:Clone();
		Detoxify.Parent = Character.Torso;
		Detoxify:Play();
		Debris:AddItem(Detoxify, 15);

		local Shards = VerdienModules.Shards:Clone();
		Shards.Parent = Character.Torso;
		Shards:Emit(25);
		Debris:AddItem(Shards, 5);

		toRemove = Toxicity.Value - toRemove;
		if Toxicity.Value < toRemove then
			toRemove = 0;
		end;
		Toxicity.Value = toRemove;

		TagHumanoid:Fire(Character, enemy, {
			damage = 5,
			poison = true,
			bypassfischdodge = true,
			noenchant = true,
			move = "Fons Vitae"
		})
	end;
end;
local u6 = {
	upperbound = 100, 
	lowerbound = 80, 
	signs = 0, 
	cost = 100,
}
function u6.Activate(Player, Character, cast, no)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	local p9, Status = Character, workspace.Live[Player.Name]
	if CollectionService:HasTag(Character, "Casting") or Status:FindFirstChild("ActiveCast") then
		return
	end




	local Mana, v27 = Character.Mana, Player;

	if not game.ServerStorage.PlayerData[Player.Name].Skills.Value:find("Fons Vitae M2") then
		return;
	end

	Character.Humanoid:LoadAnimation(script.Snap2):Play()

	local l__Value__30 = game.ServerStorage.PlayerData[Player.Name].LastName.Value;

	if Mana.Value <= 0 then
		return;
	end
	if cast == 0 then
		Mana.Value = math.max(Mana.Value - 100, 0);
		VerdienModule:snapEffect(Character, true);
		for i,v in pairs(workspace.Live:GetChildren()) do
			if (v.Torso.Position - Character.HumanoidRootPart.Position).Magnitude <= 50 and v ~= Character and (not workspace.Live[v.Name]:FindFirstChild("Knocked") and game.Players:FindFirstChild(v.Name) and v:FindFirstChild("Toxicity")) then
				detoxify(v, Character);
			end;
		end;
	else
		detoxify(Character, Character);
	end
end
module.alternate = u6
return module