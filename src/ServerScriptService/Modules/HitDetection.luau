local TagHumanoid = game.ServerStorage.Requests.TagHumanoid
local FindFirstChild = game.FindFirstChild
local GetChildren = game.GetChildren
local Module = {}

local function facingenemy(rootpos,part,enemypart)
	if (-(rootpos-enemypart)).Unit:Dot(part.CFrame.LookVector)>0 then
		return true
	end
end

function Module.magnitudeCheck(Character,RootPos,Range,Info,bruhing,facecheck,liluzivert)
	local hit = false
	local Enemies = {}
	local LiveChildren = GetChildren(workspace.Live)
	for i = 1,#LiveChildren do
		local v = LiveChildren[i]
		if not facecheck or Info.aoe then
			if v == Character and not Info.Geyser then
				continue
			end
		end
		if FindFirstChild(v,"Boosts")then
			if FindFirstChild(v,"HumanoidRootPart")and
				FindFirstChild(v,"Torso")and
				v.Humanoid.Health >0
			then
				table.insert(Enemies,v)
			end
		end
	end
	if #Enemies < 1 then
		return
	end
	--for _ = 1,2 do
	--if hit then
	--return hit
	--end
	local tormov = {}
	if liluzivert then
		for i = 1,#Enemies do
			local v = Enemies[i]
			if not (v and v:FindFirstChild("HumanoidRootPart") and Character and Character:FindFirstChild("HumanoidRootPart") and math.abs((Character.HumanoidRootPart.CFrame:Inverse() * v:FindFirstChild("HumanoidRootPart").CFrame).X) <= 10 and math.abs((Character.HumanoidRootPart.CFrame:Inverse() * v:FindFirstChild("HumanoidRootPart").CFrame).Y) <= 5) then
				table.insert(tormov, v)
			end
		end
	end
	if #tormov > 0 then
		for i = 1,#tormov do
			if table.find(Enemies, tormov[i]) then
				table.remove(Enemies, table.find(Enemies, tormov[i]))
			end
		end
	end
	for i = 1,#Enemies do
		local v = Enemies[i]
		if not Info.aoe and not facecheck then
			if not facingenemy(RootPos,Character.HumanoidRootPart,v.HumanoidRootPart.Position) and not (v:FindFirstChild("isgettingshouldered") and Character:FindFirstChild("isusingshoulder")) then
				continue
			end
		end
		if (v.HumanoidRootPart.Position-RootPos).Magnitude < Range and not v:FindFirstChild("Grabbed") then
			if Info.grabmove then
				if not v:FindFirstChild("Blocking") then
					hit = v
				end
			else
				hit = true
			end
			TagHumanoid:Fire(Character,v,Info)
		elseif (v.HumanoidRootPart.Position-RootPos).Magnitude < Range * 1.2 and not v:FindFirstChild("Grabbed") and game.ServerStorage.PlayerData:FindFirstChild(Character.Name) and game.ServerStorage.PlayerData[Character.Name].Enchant.Value:find("Rift Gem") and (Character:FindFirstChild("HasWeapon") or game.ServerStorage.PlayerData[Character.Name].PrimaryWeapon.Value == "Caestus") and not Info.noenchant and math.random(1, 4)<=1+(Info.damage*0.2) then

			--local hit = workspace:FindPartOnRay(Ray.new(Character.HumanoidRootPart.Position, Character.HumanoidRootPart.Position + v.HumanoidRootPart.Position), {workspace.AreaMarkers, Character, workspace.Thrown}, true,true)
			local hit = workspace:FindPartOnRayWithIgnoreList(Ray.new(Character.HumanoidRootPart.Position, v.HumanoidRootPart.Position - Character.HumanoidRootPart.Position), {workspace.AreaMarkers, Character, workspace.Thrown})
			if hit and hit:IsDescendantOf(workspace.Live) then
				hit = true
				Info.warp = true
				TagHumanoid:Fire(Character, v, Info)
			end
		end
	end
	if hit then
		return hit
	end
	--wait()
	--if FindFirstChild(Character,"Stun")or FindFirstChild(Character,"NoDam")then
	--return
	--end
	--end
end

function Module.magnitudeCheckNew(Character,RootPos,Range,Info,bruhing,facecheck)
	local hit = false
	local Enemies = {}
	local LiveChildren = GetChildren(workspace.Live)
	if Character and Character:FindFirstChild("HumanoidRootPart") then
		Info["lookvec"] = Character.HumanoidRootPart.CFrame.LookVector.Unit
	end
	for i = 1,#LiveChildren do
		local v = LiveChildren[i]
		if not facecheck or Info.aoe then
			if v == Character then
				if Info.Pebble and Info.Pebble == true then
					if  (v.HumanoidRootPart.Position - Info.PebbleModel.Position).Magnitude <= Info.Distance then 
						local Danger = Instance.new("Accessory",game:GetService("Players"):GetPlayerFromCharacter(Character))
						Danger.Name = "Danger"
						game.Debris:AddItem(Danger,15)
					end
				end
				continue
			end
		end
		if FindFirstChild(v,"Boosts")then
			if Info.selfhit then
				if FindFirstChild(v,"HumanoidRootPart")and
					FindFirstChild(v,"Torso")and
					v.Humanoid.Health > 0
				then
					table.insert(Enemies,v)
				end
			else
				if FindFirstChild(v,"HumanoidRootPart")and
					FindFirstChild(v,"Torso")and
					v.Humanoid.Health > 0 and
					v ~= Character
				then
					table.insert(Enemies,v)
				end
			end
		end
	end
	if #Enemies < 1 then
		return
	end
	--for _ = 1,2 do
	--if hit then
	--return hit
	--end
	for i = 1,#Enemies do
		local v = Enemies[i]
		if not Info.aoe and not facecheck then
			if not facingenemy(RootPos,Character.HumanoidRootPart,v.HumanoidRootPart.Position) and not (v:FindFirstChild("isgettingshouldered") and Character:FindFirstChild("isusingshoulder")) then
				continue
			end
		end
		if (v.HumanoidRootPart.Position-RootPos).Magnitude < Range and not v:FindFirstChild("Grabbed") then
			hit = true
			TagHumanoid:Fire(Character,v,Info)
		end
	end
	return hit
	--wait()
	--if FindFirstChild(Character,"Stun")or FindFirstChild(Character,"NoDam")then
	--return
	--end
	--end
end
function Module.SMag(info)
	if info.origin and info.range then
		local detected = {}
		for _,v in pairs(workspace.Live:GetChildren()) do
			if v:FindFirstChild("Humanoid")and v:FindFirstChild("HumanoidRootPart")then
				if v:FindFirstChildOfClass("ForceField") or v:FindFirstChild("Immortal")then
					continue
				end
				local result = (v:FindFirstChild("HumanoidRootPart").Position-info.origin.p).Magnitude < info.range
				if info.length then
					result = result and (info.origin:Inverse() * v:FindFirstChild("HumanoidRootPart").CFrame).Z < info.length
				end
				if info.width then
					result = result and math.abs((info.origin:Inverse() * v:FindFirstChild("HumanoidRootPart").CFrame).X) < info.width
				end
				if info.height then
					result = result and math.abs((info.origin:Inverse() * v:FindFirstChild("HumanoidRootPart").CFrame).Y) < info.height
				end
				if result then
					if info.user and v ~= info.user and not table.find(detected,v)then
						table.insert(detected,v)
						game.ServerStorage.Requests.TagHumanoid:Fire(info.user,v,info.tags)
					end
				end
			end
		end
	end
end

function Module.aoeCombatTag(character,position,range)
	local Enemies = {};
	for _,v in pairs(workspace.Live:GetChildren())do
		if v == character then
			continue;
		end;
		if v:FindFirstChild("Boosts")and not v:FindFirstChildWhichIsA("ForceField")then
			if v:FindFirstChild("HumanoidRootPart")and
				v:FindFirstChild("Torso")and
				v.Humanoid.Health >0
			then
				table.insert(Enemies,v);
			end;
		end;
	end;
	if #Enemies < 1 then
		return;
	end;
	for _,v in pairs(Enemies)do
		if (position-v.HumanoidRootPart.Position).Magnitude < range then
			game.ServerStorage.Requests.TagHumanoid:Fire(character,v,{
				nostun = true,
				noenchant = true,
				damage = 0,
			});
		end;
	end;
end;
function Module.mortalCombatTag(character,position,range)
	local Enemies = {};
	for _,v in pairs(workspace.Live:GetChildren())do
		if v == character then
			continue;
		end;
		if v:FindFirstChild("Boosts")and not v:FindFirstChildWhichIsA("ForceField")then
			if v:FindFirstChild("HumanoidRootPart")and
				v:FindFirstChild("Torso")and
				v.Humanoid.Health >0
			then
				table.insert(Enemies,v);
			end;
		end;
	end;
	if #Enemies < 1 then
		return;
	end;
	for _,v in pairs(Enemies)do
		if (position-v.HumanoidRootPart.Position).Magnitude < range then
			game.ServerStorage.Requests.TagHumanoid:Fire(character,v,{
				mortaldanger = true
			});
		end;
	end;
end;

return Module