local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
v1.upperbound = 95;
v1.lowerbound = 60;
v1.signs = 0;
v1.cost = 1;
local v3 = {
	upperbound = 95,
	lowerbound = 60,
	signs = 0,
	cost = 1
};
local l__Gate__2 = game.ServerStorage.SpellEffects.Gate;
local u3 = require(game.ReplicatedStorage.Info.WarpData);
local u4 = {
	--KheiBackfire = true,
	AbyssPit = true,
	AllDark = true
};
local l__TweenService__5 = game:GetService("TweenService");
local u6 = {
	["Ice Dragon"] = true
};
local u7 = require(game.ReplicatedStorage.Modules.VectorMaths);
-- Module-level (not per-player) so this is a true server-wide 30s cooldown shared across every
-- Gate cast by every player, matching "a 30 second cooldown" on the announcement itself, not a
-- new per-player Gate cooldown (2026-07-29, "#1 Ranked Chad has gated to..." announcement).
local lastChadGateAnnounce = 0

function v1.Activate(p1, p2, p3, p4)
end;

function v3.Activate(p7, p8, p9, p10, p11)
	if workspace:FindFirstChild("IsPriv") then
		return
	end
	if not (not game.CollectionService:HasTag(p8, "Casting")) or not (not p8:FindFirstChild("ActiveCast")) or p8:FindFirstChild("Action") then
		return
	end
	if game.CollectionService:HasTag(p8, "Swimming") then
		return
	end
	local l__Mana__64 = p8.Mana
	local v65 = game.Players:GetPlayerFromCharacter(p8)
	local v66 = v65 and game.ServerStorage.PlayerData:FindFirstChild(v65.Name)
	if v66 then
		local l__Value__67 = v66.ManaColor.Value
	end
	if not p11[script.Parent.Name] and v66.Race.Value ~= "Azael" then
		--return
	end
	local l__Humanoid__68 = p8:FindFirstChild("Humanoid")
	local v69 = l__Humanoid__68 and p8:FindFirstChild("Head") and p8:FindFirstChild("HumanoidRootPart")
	if not v69 then
		return
	end
	if l__Mana__64.Value < v1.cost then
		return
	end
	l__Mana__64.Value = math.max(l__Mana__64.Value - v1.cost, 0)
	local v70 = Instance.new("Accessory")
	v70.Name = "ActiveCast"
	v70.Parent = p8
	local v71 = Instance.new("NumberValue")
	v71.Name = "SpeedBoost"
	v71.Parent = p8.Boosts
	v71.Value = -6
	p8.Humanoid:LoadAnimation(script.SnapAnim):Play()
	local v72 = script.Snap:clone()
	v72.Parent = v69
	v72:Play()
	game.Debris:AddItem(v72, 2)
	local v73 = Instance.new("Attachment", v69)
	v73.Name = "VortexAttachment"
	local v74 = l__Gate__2.VortexParticle:clone()
	v74.Parent = v73
	v69.PerfectCast:Play()
	local v75 = 0
	local v76 = {}
	for i,v in pairs(game.ServerStorage.Classes.ObeliskSkills:children()) do
		local v79 = string.gsub(v.Name, "Obelisk", "")
		local v80 = game.ServerStorage.WarpPoints:FindFirstChild(v79)
		local v81 = string.gsub(v79, "Khei", "")
		if v80 then
			v76[string.lower(v81)] = v80
			v75 += 1
		end
	end
	local v82 = {}
	for v83, v84 in pairs(game.ServerStorage.WarpPoints:children()) do
		if v84.Name ~= "Ratriel" and v84.Name ~= "Lastiel" and v84.Name ~= "CastleRock" and v84.Name ~= "AzaelOffice" and v84.Name ~= "norp" and v84.Name ~= "Expanse" and v84.Name ~= "eggyweggy" then
			table.insert(v82, v84)
		end
	end
	local l__Value__85 = v66.Race.Value
	local u13 = false
	local u14 = nil
	local u15 = nil

	-- Build location name list for the client GUI
	local locationNames = {}
	for k, _ in pairs(v76) do
		table.insert(locationNames, k)
	end

	-- Splits "tundra 7" into a location-name candidate ("tundra") and a sub-location candidate
	-- ("7") - a typed sub-location is just the trailing word/number after the location name.
	local function splitLocationAndSub(text)
		local lastSpace = nil
		for i = #text, 1, -1 do
			if text:sub(i, i) == " " then
				lastSpace = i
				break
			end
		end
		if not lastSpace then
			return text, nil
		end
		return text:sub(1, lastSpace - 1), text:sub(lastSpace + 1)
	end

	-- Show a simple textbox on the client (typed, not a button list) and wait for their input.
	-- "cancel" always aborts the teleport entirely, even on a backcast (miscast). Otherwise, on a
	-- proper cast an unrecognized location name just fizzles (no teleport); on a backcast the
	-- destination is randomized regardless of what was typed - same as before, just re-driven off
	-- typed text instead of a button click.
	local GateRequest = game.ReplicatedStorage.Requests.GateLocationRequest
	local result = nil
	local invokeSuccess = pcall(function()
		result = GateRequest:InvokeClient(v65, locationNames)
	end)

	local typedText = result and result.text and result.text:match("^%s*(.-)%s*$") or nil
	if typedText == "" then
		typedText = nil
	end

	if not invokeSuccess or not typedText then
		u13 = true
	elseif string.lower(typedText) == "cancel" then
		u13 = true
	elseif p9 == 0 or v66.Race.Value == "Azael" and not v65:FindFirstChild("Danger") then
		local wholeLower = string.lower(typedText)
		local locationPart, subPart = splitLocationAndSub(wholeLower)
		if subPart and v76[locationPart] then
			u14 = v76[locationPart]
			if tonumber(subPart) then
				u15 = subPart
			else
				u15 = string.upper(string.sub(subPart, 1, 1)) .. string.lower(string.sub(subPart, 2))
			end
		elseif v76[wholeLower] then
			u14 = v76[wholeLower]
		else
			u13 = true
		end
	else
		u14 = v82[math.random(1, #v82)]
	end

	v71:Destroy()
	v70:Destroy()
	v74.Enabled = false
	game.Debris:AddItem(v73, 3)

	if u14 then
		if v65:FindFirstChild("Danger") then
			u15 = nil
		end
		local v91 = u15 and u14 and u14:FindFirstChild(u15)
		if not v91 then
			local v92 = u14:GetChildren()
			if tonumber(u15) then
				v91 = v92[tonumber(u15)]
			else
				v91 = v92[math.random(1, #v92)]
			end
		end
		if not v91 then
			return
		end
		local l__Position__93 = v91.Position
		local v94, v95, v96 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v69.Position, Vector3.new(0, -20, 0)), { workspace.Live, workspace.Terrain, workspace.NPCs, workspace.Thrown, workspace.Destructibles, workspace.Ingredients })
		if not v94 then
			return
		end
		local l__Grabbing__118 = p8:FindFirstChild("Grabbing")
		if l__Grabbing__118 then
			local v119 = game.Players:FindFirstChild(l__Grabbing__118.Value.Name)
			local v120 = v119
			if v120 then
				local enemydata = game.ServerStorage.PlayerData[v120.Name]
				local StoryMarker = game:GetService("HttpService"):JSONDecode(enemydata.StoryMarker.Value)
				if StoryMarker["NoGate"] then
					if StoryMarker["NoGate"] == true then
						return
					end
				end
			end
		end
		local v97 = Instance.new("Part")
		v97.BrickColor = BrickColor.White()
		v97.Material = "Neon"
		v97.Transparency = 0
		v97.Anchored = true
		v97.CanCollide = false
		v97.Size = Vector3.new(8, 2, 8)
		v97.CFrame = CFrame.new(v95, v95 + v96) * CFrame.Angles(math.rad(-90), 0, 0)
		local v98 = Instance.new("CylinderMesh", v97)
		v98.Scale = Vector3.new(0, 0.05, 0)
		local v99 = script.Open:clone()
		v99.Parent = v97
		v97.Parent = workspace.Thrown
		game:GetService'Debris':AddItem(v97, 5)
		game.TweenService:Create(v98, TweenInfo.new(1), {
			Scale = Vector3.new(1, 0.01, 1)
		}):Play()
		v99:Play()
		-- "#1 Ranked Chad has gated to <location>" server-wide announcement (added 2026-07-29,
		-- by request). v66.Prestige.Value is the Chad/Mog rank (see MogRankHandler.server.luau -
		-- Prestige used to be Grip-rank, now replaced). Fires for any successful teleport,
		-- including a randomized backcast destination - from an observer's perspective the #1
		-- Chad still visibly gated somewhere. Location label built from u14 (the destination
		-- WarpPoints folder) and u15 (the sub-location, if any) to roughly match the
		-- "desert1"-style example given in the request.
		if v66.Prestige.Value == 1 and os.time() - lastChadGateAnnounce >= 30 then
			lastChadGateAnnounce = os.time()
			local locationLabel = string.lower(u14.Name .. (u15 and tostring(u15) or ""))
			local chadFirstName = v66.FirstName.Value
			local chadLastName = v66.LastName.Value
			task.spawn(function()
				require(game.ServerScriptService.Modules.AlertModule).broadcast("#1 Ranked Chad "..chadFirstName.." "..chadLastName.." has gated to "..locationLabel)
			end)
		end
		local v100 = Instance.new("Folder", p8)
		v100.Name = "NoFall"
		game.Debris:AddItem(v100, 5)
		local l__Grabbing__101 = p8:FindFirstChild("Grabbing")
		if l__Grabbing__101 then
			local v102 = game.Players:FindFirstChild(l__Grabbing__101.Value.Name)
			local v103 = v102 and v102.Character
			if v103 then
				local v104 = Instance.new("Folder", v103)
				v104.Name = "NoFall"
				game.Debris:AddItem(v104, 5)
				local v999 = Instance.new("Vector3Value")
				v999.Name = "TPSafe"
				v999.Parent = v103
				game.Debris:AddItem(v999, 4)
			end
		end
		local v105 = CFrame.new(l__Position__93) * CFrame.new(math.random(-2, 2), 0, math.random(-2, 2))
		wait(0.5)
		if u4[u14.Name] then
			l__TweenService__5:Create(v97, TweenInfo.new(0.5), {
				Color = Color3.new(0.68, 0, 0)
			}):Play()
		end
		local v106 = Instance.new("Vector3Value")
		v106.Name = "TPSafe"
		v106.Value = v105.Position
		v106.Parent = p8
		for _,v in pairs(p8:GetDescendants()) do
			if v.Name == "PULLING" or v.Name == "pullTo" then
				v:Destroy()
			end
		end
		game.Debris:AddItem(v106, 4)
		if not l__Humanoid__68.SeatPart and not l__Humanoid__68.Sit then
			v69.CFrame = v105
		end
		if p8:FindFirstChild("Torch") and p8.Torch.Lit.Value then
			local v107 = Instance.new("Accessory")
			v107.Name = "EXTINGUISH"
			v107.Parent = p8.Torch
		else
			local v108 = game.Players:GetPlayerFromCharacter(p8)
			if v108 and (v108.Backpack:FindFirstChild("Torch") and v108.Backpack.Torch.Lit.Value) then
				local v109 = Instance.new("Accessory")
				v109.Name = "EXTINGUISH"
				v109.Parent = v108.Backpack.Torch
			end
		end

		local u16 = {}
		local v110 = v97.Touched:Connect(function(p13)
			local v111 = p13.Parent:FindFirstChild("Humanoid") or p13.Parent and p13.Parent.Parent:FindFirstChild("Humanoid")
			if not v111 then
				return
			end
			if u16[v111] then
				return
			end
			local l__Parent__112 = v111.Parent
			local v113 = l__Parent__112 and v111.RootPart
			if not v113 or v111.Health <= 0 then
				return
			end
			if l__Parent__112:FindFirstChild("CantCast") then
				return
			end
			if l__Parent__112:FindFirstChild("Executing") or game.CollectionService:HasTag(l__Parent__112,"BeingExecuted")then
				return
			end
			if l__Parent__112:FindFirstChild("Interrogated") or l__Parent__112:FindFirstChild("Interrogating") then
				return
			end
			if l__Parent__112:FindFirstChild("Grabbed")then
				return
			end
			if l__Parent__112:FindFirstChild("Knocked")then
				return
			end
			if v111.SeatPart then
				return
			end
			if game.CollectionService:HasTag(l__Parent__112, "Swimming") then
				return
			end
			if u6[l__Parent__112.Name] then
				return
			end
			if string.find(l__Parent__112.Name, "Terra Serpent") then
				return
			end
			local l__Position__114 = v113.Position
			if (u7:getClosestPosition(v97, l__Position__114) - l__Position__114).magnitude > 20 then
				return
			end
			local v115 = game.Players:GetPlayerFromCharacter(l__Parent__112)
			local v116 = v115 and game.ServerStorage.PlayerData:FindFirstChild(v115.Name)
			if v116 and v116.Lives.Value <= 0 and not l__Parent__112:FindFirstChild("LichSummon") and not v115:FindFirstChild("LichSummon") then
				return
			end
			if v116 and v116.StoryMarker.Value then
				local storymarker = game:GetService("HttpService"):JSONDecode(v116.StoryMarker.Value)
				if storymarker["NoGate"] then
					if storymarker["NoGate"] == true then
						return
					end
				end
			end
			local l__Grabbing__118 = l__Parent__112:FindFirstChild("Grabbing")
			if l__Grabbing__118 then
				local v119 = game.Players:FindFirstChild(l__Grabbing__118.Value.Name)
				local v120 = v119
				if v120 then
					local enemydata = game.ServerStorage.PlayerData[v120.Name]
					local StoryMarker = game:GetService("HttpService"):JSONDecode(enemydata.StoryMarker.Value)
					if StoryMarker["NoGate"] then
						if StoryMarker["NoGate"] == true then
							return
						end
					end
				end
			end
			local v117 = Instance.new("Accessory")
			v117.Name = "NoFall"
			v117.Parent = l__Parent__112
			game.Debris:AddItem(v117, 3)
			local l__Grabbing__118 = l__Parent__112:FindFirstChild("Grabbing")
			if l__Grabbing__118 then
				local v119 = game.Players:FindFirstChild(l__Grabbing__118.Value)
				local v120 = v119 and v119.Character
				if v120 then
					local v121 = Instance.new("Accessory")
					v121.Name = "NoFall"
					v121.Parent = v120
					game.Debris:AddItem(v121, 4)
					local v999 = Instance.new("Accessory")
					v999.Name = "TPSafe"
					v999.Parent = v120
					game.Debris:AddItem(v999, 4)
				end
			end
			local v122 = Instance.new("Vector3Value")
			v122.Name = "TPSafe"
			v122.Value = v105.Position
			v122.Parent = l__Parent__112
			game.Debris:AddItem(v122, 3)
			if l__Parent__112:FindFirstChild("Torch") and l__Parent__112.Torch.Lit.Value then
				local v123 = Instance.new("Accessory")
				v123.Name = "EXTINGUISH"
				v123.Parent = l__Parent__112.Torch
			else
				local v124 = game.Players:GetPlayerFromCharacter(l__Parent__112)
				if v124 and (v124.Backpack:FindFirstChild("Torch") and v124.Backpack.Torch.Lit.Value) then
					local v125 = Instance.new("Accessory")
					v125.Name = "EXTINGUISH"
					v125.Parent = v124.Backpack.Torch
				end
			end
			u16[v111] = true
			l__Parent__112:PivotTo(CFrame.new(l__Position__93) * CFrame.new(math.random(-2, 2), 0, math.random(-2, 2)))
			wait(1)
			u16[v111] = false
		end)
		wait(4)
		v110:Disconnect()
		local v126 = script.Close:clone()
		v126.Parent = v97
		v126:Play()
		game.TweenService:Create(v98, TweenInfo.new(0.5), {
			Scale = Vector3.new(0, 0.01, 0)
		}):Play()
		game.Debris:AddItem(v97, 1.5)
	end
end;
v1.alternate = v3;
return v1;
