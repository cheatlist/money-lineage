local M1Cooldown: boolean = false
local M2Cooldown: boolean = false

local VerdienModules = game.ServerStorage.VerdienModules
local VerdienModule = require(VerdienModules.VerdienModule)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local module = {
	upperbound = 100;
	lowerbound = 75;
	signs = 12;
	cost = 100;
	tool = script.Parent;
}

local snapModule = {
	upperbound = 85,
	lowerbound = 75,
	signs = 0,
	cost = 10,
	tool = script.Parent,
}

local function canRoot(p7): boolean
	if p7:FindFirstChild("Knocked") or p7:FindFirstChild("Blocking") then
		return false;
	end
	return true;
end;

function module.Activate(Player, Character, isCast)
	if not (not CollectionService:HasTag(Character, "Casting")) or not (not Character:FindFirstChild("ActiveCast")) or Character:FindFirstChild("ConeCD") then
		return;
	end;
	local Mana = Character.Mana;
	if Mana.Value <= 0 then
		return;
	end
	if isCast ~= 0 then
		Character.HumanoidRootPart.Diffusion:Play()
		return
	end
	Mana.Value = math.max(Mana.Value - 100, 0);
	VerdienModule:grow(Character, 1);
end

function snapModule.Activate(Player, Character, isCast)
	Player = Players:GetPlayerFromCharacter(Character);
	if CollectionService:HasTag(Character, "Casting") then
		return;
	end;
	local Mana = Character.Mana;	

	
	if ServerStorage.PlayerData[Player.Name].Class.Value ~= "Florist" and (ServerStorage.PlayerData[Player.Name].Race.Value~='Navaran')then
		return warn("Non Florist/Navaran tried to use Verdien snap");
	end

	Character.Humanoid:LoadAnimation(script.Snap2):Play()

	local l__Value__30: string = Player.leaderstats.LastName.Value;

	if isCast == 0 then
		Mana.Value = math.max(Mana.Value - snapModule.cost, 0);
		VerdienModule:snapEffect(Character, true);

		task.wait(0.1);
		for i,v in ipairs(workspace.Live:GetChildren()) do
			local HRP = v:FindFirstChild'HumanoidRootPart'
			if HRP and(HRP.Position - Character.HumanoidRootPart.Position).Magnitude <= 40 and canRoot(v) then
				local v33 = ServerStorage.PlayerData:FindFirstChild(v.Name) and game.Players:GetPlayerFromCharacter(v) and game.Players:GetPlayerFromCharacter(v).leaderstats.LastName.Value;
				if not v33 or (l__Value__30 == "" or  game.Players:GetPlayerFromCharacter(v).leaderstats.LastName.Value ~= l__Value__30) and v ~= Character then
					task.spawn(function()
						VerdienModule:rootCharacter(v, Character, "Verdien", 8, 1.25, 1.75);
					end)
				end;
			end
		end
	else
		task.spawn(function()
			VerdienModule:rootCharacter(Character, Character, "Verdien", 8, 1.25, 1.75)
		end)
	end
end

module.alternate = snapModule;
return module