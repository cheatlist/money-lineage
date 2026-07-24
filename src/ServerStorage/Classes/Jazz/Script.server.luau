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

function ActionCheck(Parent)
	if Parent:FindFirstChild("EquipWarmup") then
		return true
	end
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
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
			
			
			local playingsong = Instance.new("BoolValue");
			playingsong.Name = "PlayingSong";
			playingsong.Value = true;
			playingsong.Parent = workspace.Live[character.Name];
			
			game.ReplicatedStorage.Requests.BardBegin:FireClient(p3, script.Parent.Name, v13);
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

			local data = game.ServerStorage.PlayerData[character.Name]
			local lastname = data:FindFirstChild("LastName")
			local InHouse = if lastname.Value == "" then false else true
			local housename = lastname.Value
			
			while l__Parent__2.Parent == p2 do
				task.wait(1);
				pcall(function()
					for v17, v18 in pairs(workspace.Live:GetChildren()) do
						if time() - v16 > 3 and game.Players:FindFirstChild(v18.Name) then
							if workspace.Live:FindFirstChild(v18.Name) and (not workspace.Live[v18.Name]:FindFirstChild("ViniferaBuff")) and (p2.Torso.Position - v18.Torso.Position).Magnitude < v14 and not buffedBySong(v18) then
								if InHouse then
									if game.ServerStorage.PlayerData[v18.Name].LastName.Value == housename then
										if not character:FindFirstChild("ViniferaBuff") then
											local v27 = Instance.new("NumberValue");
											v27.Name = "ViniferaBuff";
											v27.Value = 1;
											v27.Parent = workspace.Live[v18.Name];
											game.Debris:AddItem(v27, 5);

											local a = Instance.new("StringValue");
											a.Name = "MusicianBuff";
											a.Value = script.Parent.Name;
											a.Parent = workspace.Live[v18.Name];
											game.Debris:AddItem(a, 5);
										end
									end
								else
									if not character:FindFirstChild("ViniferaBuff") then
										local v27 = Instance.new("NumberValue");
										v27.Name = "ViniferaBuff";
										v27.Value = 1;
										v27.Parent = workspace.Live[v18.Name];
										game.Debris:AddItem(v27, 5);

										local a = Instance.new("StringValue");
										a.Name = "MusicianBuff";
										a.Value = script.Parent.Name;
										a.Parent = workspace.Live[v18.Name];
										game.Debris:AddItem(a, 5);
									end
								end
							end;
						end;
					end;
				end);
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
			playingsong:Destroy()
			u2 = true;
		end)

		if err then
			warn("BARD ERROR: "..err)
		end

	end
end)