local DangerHandler, Live = {
	Dangers = {}
}, workspace.Live;
DangerHandler.__index = DangerHandler;

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat;

function DangerHandler:createTable(Player)
	DangerHandler.Dangers[Player.Name] = {}
end

function DangerHandler:removeTable(Player)
	DangerHandler.Dangers[Player.Name] = nil;
end

function DangerHandler:removeAllDangers(Player)
	if not DangerHandler.Dangers[Player.Name] then return end;
	for i,v in pairs(DangerHandler.Dangers[Player.Name]) do
		table.remove(DangerHandler.Dangers[Player.Name], i)
	end
	
	for i,v in pairs(Player:GetChildren()) do
		if v.Name == "Danger" then
			v:Destroy();
		end
	end
end

function DangerHandler:getCharacter(Tag)
	local strTable = string.split(Tag, ":")
	
	if #strTable <= 0 then warn"dumb" return nil end;
	if typeof(strTable[1]) ~= "string" then warn"no string" return nil end;
	if not Live:FindFirstChild(strTable[1]) then return nil end;
	return Live[strTable[1]]
end

function DangerHandler:isTagged(Player)
	local isTag = false;
	
	for i,v in pairs(DangerHandler.Dangers) do
		if i == Player.Name and #v > 0 then
			isTag = true;
			break;
		end
	end
	
	return isTag;
end

function DangerHandler:getEntity(Target)
	local Danger = {}; Danger.__index = Danger;
	
	if not Target or (Target and not Target.Parent) then
		return nil;
	end
	
	if (not Target:IsA("Player")) and Target:FindFirstChild("Humanoid") then
		Target = (Players:GetPlayerFromCharacter(Target) or nil)
		
		if not Target then return nil end;
	end
	
	function Danger:removeTag(...)
		local args = ({...})
		if #args < 1 then return end;
		
		local Tag, isDangerFolder, FoundPlayer = args[1], args[2], nil
		for i,v in pairs(DangerHandler.Dangers) do
			if table.find(v, Tag) then
				FoundPlayer = Players:FindFirstChild((tostring(i) or "nil"))
				table.remove(v, table.find(v, Tag));
			end
		end
		
		if not FoundPlayer or not(FoundPlayer:IsDescendantOf(game))then return end;
		
		for i,v in pairs(FoundPlayer:GetChildren()) do
			if v.Name == "Danger" and v:GetAttribute("Tag") == Tag then
				v:Destroy()
			end
		end
		
		if isDangerFolder and isDangerFolder.Parent then
			isDangerFolder:Destroy()
		end
	end
	
	function Danger:createTag(...)
		local args = ({...})
		
		if #args < 2 then return end;
		local Tag, dangerTable = args[1], args[2]
		if typeof(dangerTable) ~= "table" then return end;
		local lifeSpan = (dangerTable.lifespan or 90);
		
		if not DangerHandler.Dangers[Target.Name] then
			return
		end;
		local Player = Target;
		if not Player then return end;
		task.spawn(function()
			table.insert(DangerHandler.Dangers[Target.Name], Tag)
			
			local DangerFolder, startTime = Player:FindFirstChild("Danger"), time()
			
			if DangerFolder then
				if DangerFolder.LifeSpan.Value + lifeSpan >= 90 then
					DangerFolder.LifeSpan.Value = 90
				else
					DangerFolder.LifeSpan.Value += lifeSpan
				end
			else
				DangerFolder = Instance.new("NumberValue")
				DangerFolder.Name = "Danger"
				DangerFolder.Parent = Player
				DangerFolder:SetAttribute("Tag", Tag)
	
				local LifeSpan = Instance.new("NumberValue")
				LifeSpan.Name = "LifeSpan"
				LifeSpan.Value = lifeSpan
				LifeSpan.Parent = DangerFolder
			end
			DangerFolder.Value = startTime
		
			while Heartbeat:Wait() do
				if (DangerFolder.Parent and time() - DangerFolder.Value >= DangerFolder.LifeSpan.Value and not Player.Character:FindFirstChild("Grabbed")) or (not DangerFolder.Parent) then
					Danger:removeTag(Tag)
					break;
				end
				
				local EnemyCharacter = (DangerHandler:getCharacter(Tag) or nil)
				if not EnemyCharacter or (EnemyCharacter and not EnemyCharacter.Parent) then
					Danger:removeTag(Tag, DangerFolder)
					break;
				end
			end
		end)
	end
	
	return Danger;
end

return DangerHandler