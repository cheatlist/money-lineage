local v1 = {};
local l__Parent__2 = script.Parent;
local l__Parent__1 = l__Parent__2.Parent;
local v4 = tick();
local l__TweenService__5 = game:GetService("TweenService");
function buffedBySong(p1)
	local toReturn = false
	for i,v in pairs(p1:GetChildren()) do
		if v.Name == "MusicianBuff" and v.Value == script.Parent.Name then
			toReturn = true;
			break;		
		end
	end

	return toReturn;
end;

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end

local u2 = true;

script.Parent.Activated:Connect(function()
	local p2 = game.Players:GetPlayerFromCharacter(script.Parent.Parent)

	if p2 then
		local p3 = p2.Character
		local success, err = pcall(function()
			local Player, character = p2, p3
			p2, p3 = character, Player

			if ActionCheck(character) then 
				return 
			end

			if character:FindFirstChild("BardError") then
				return;
			end;

			if not u2 then
				return;
			end;
			u2 = false;
			local v11 = p2.Humanoid:LoadAnimation(script.Parent.Anim);
			v11:Play();
			local l__Song__12 = p2.HumanoidRootPart:FindFirstChild("Song");
			if l__Song__12 then
				l__Song__12:Destroy();
			end;
			local v13 = script.Song:Clone();
			v13.Parent = p2.HumanoidRootPart;
			v13:Play();
			--game.ReplicatedStorage.Requests.BardBegin:FireClient(p3, script.Parent.Name, v13);
			if game.CollectionService:HasTag(p2, "AptorgathQuestStart") then
				game.CollectionService:RemoveTag(p2, "AptorgathQuestStart");
				game.CollectionService:AddTag(p2, "AptorgathQuestAttempt");
			end;
			local v14 = 30;
			if p3.Backpack:FindFirstChild("GreatVolume") then
				v14 = v14 * 2;
			end;
			local l__TimeLength__15 = script.Song.TimeLength;
			local v16 = time();
			local lastname = game.ServerStorage.PlayerData[Player.Name].LastName.Value
			local v277
			for i,v in pairs(workspace.Live:GetChildren()) do
				if v ~= character and (v.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude <= 30 and game.Players:FindFirstChild(v.Name) and game.ServerStorage.PlayerData[v.Name].LastName.Value == lastname then
				 v277 = Instance.new("BoolValue");
					v277.Name = "SweetSoothing";
					v277.Value = true;
					v277.Parent = v;
				end
			end
			local v27 = Instance.new("BoolValue");
			v27.Name = "SweetSoothing";
			v27.Value = true;
			v27.Parent = workspace.Live[character.Name];
			
			local playingsong = Instance.new("BoolValue");
			playingsong.Name = "PlayingSong";
			playingsong.Value = true;
			playingsong.Parent = workspace.Live[character.Name];

			
			local a = Instance.new("StringValue");
			a.Name = "MusicianBuff";
			a.Value = script.Parent.Name;
			a.Parent = workspace.Live[character.Name];
			
			while l__Parent__2.Parent == p2 do
				task.wait(1);

				if p2:FindFirstChild("BardError") then
					break;
				end;
				if game.CollectionService:HasTag(p2, "Unconscious") then
					break;
				end;	
			end;
			if game.CollectionService:HasTag(p2, "AptorgathQuestAttempt") then
				game.CollectionService:RemoveTag(p2, "AptorgathQuestAttempt");
				game.CollectionService:AddTag(p2, "AptorgathQuestSuperFailed");
			end;
			local v28 = Instance.new("Accessory");
			v28.Name = "BardError";
			v28.Parent = p2;
			game.Debris:AddItem(v28, 3);
			v13:Stop();
			v13:Destroy();
			v11:Stop();
			a:Destroy()
			playingsong:Destroy()
			v27:Destroy()
			if v277 then
				v277:Destroy()
			end
			u2 = true;
		end)

		if err then
			warn("BARD ERROR: "..err)
		end

	end
end)