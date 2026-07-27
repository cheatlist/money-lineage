local FindFirstChild = game.FindFirstChild
local GetChildren = game.GetChildren
local CollectionService = game:GetService("CollectionService")

local function create(name,deletetime,parent)
	if (name == "Knocked" or name == "Unconscious") and (parent:FindFirstChild("WakingUp") or game.CollectionService:HasTag(parent, "GettingUp")) then
		return
	end
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	if (name == "Knocked" and game.Players:FindFirstChild(parent.Name)) and game.ServerStorage.PlayerData[parent.Name].Injuries.Value:find("BrokenRib") then
		if deletetime then
			game.Debris:AddItem(i, deletetime * 1.25)
		end
		for i,v in pairs(parent:GetChildren()) do
			if v.Name == "Knocked" then
				if deletetime then
					game.Debris:AddItem(v, deletetime * 1.25)
				end
			end
		end
	elseif name == "Knocked" then
		if deletetime then
			game.Debris:AddItem(i, deletetime)
		end
		for i,v in pairs(parent:GetChildren()) do
			if v.Name == "Knocked" then
				if deletetime then
					game.Debris:AddItem(v, deletetime)
				end
			end
		end
	else
		if deletetime then
			game.Debris:AddItem(i, deletetime)
		end
	end
	return i
end

local function changetransparency(enemy,transparency)
	enemy.Torso.Transparency = transparency
	for _,v in pairs(GetChildren(enemy.Torso))do
		if v:IsA("Motor6D")then
			v.Part1.Transparency = transparency
		end
	end
	for i,v in pairs(enemy:GetDescendants()) do
		if v.Name == "EnchantEffect" then
			if transparency == 1 then
				v.Enabled = false
			else
				v.Enabled = true
			end
		end
	end
end

local function plantedcheck(v)
	if FindFirstChild(v,"Planted")then
		return true
	else
		return false
	end
end

local function wrap(...)
	coroutine.wrap(...)()
end

local function bodyvelocitycheck(c, checkit)
	--[[local children = GetChildren(c.HumanoidRootPart)
	for i = 1,#children do
		local v = children[i]
		if v.ClassName == "BodyVelocity"then
			v:Destroy()
		end
	end]]

end

local function hitknockback(root,parent)
	if not plantedcheck(parent.Parent)then
		bodyvelocitycheck(parent.Parent)
		if not parent:FindFirstChild("hitBV") then
			local bv = Instance.new("BodyVelocity")
			CollectionService:AddTag(bv,"AllowedBM")
			bv.Name = "hitBV"
		--[[local novel = Instance.new("Accessory")
		novel.Name = "noveloc"
		novel.Parent = parent.Parent
		game.Debris:AddItem(novel,0.175)]]
			bv.P = 1250
			bv.MaxForce = Vector3.new(9e9,0,9e9)
			bv.Velocity = root.CFrame.LookVector.unit*15
			bv.Parent = parent
			game.Debris:AddItem(bv,0.2)
		end
	end
end

local function soundplay(part,sound,pitch)
	if FindFirstChild(part,sound)then
		local sound = part[sound]
		if pitch then
			sound.Pitch = tonumber(pitch)
		end
		sound:Play()
	end
end

local function Send(Title, Content, Color)
	game.ServerStorage.Requests.SendWebhook:Fire(
		Title,
		Content,
		Color
	)
end

local function getCurseCount(Character)
	local count = 0;
	for i,v in pairs(Character.HumanoidRootPart:GetChildren()) do
		if v.Name == "Cursey" and v.Enabled == true then
			count += 1
		end
	end
	return count
end

local function getToxinStackCount(Character)
	local count = 0
	for i,v in pairs(Character.HumanoidRootPart:GetChildren()) do
		if v.Name == "ToxinStack" and v.Enabled == true then
			count += 1
		end
	end
	return count
end

local function addToxinStack(enemy, maxStacks)
	if enemy.Boosts and enemy.Boosts:FindFirstChild("CurseEffectImmune") then
		return
	end
	if getToxinStackCount(enemy) >= (maxStacks or 8) then
		return
	end
	local stack = game.ServerStorage.Assets.Cursey:Clone()
	stack.Name = "ToxinStack"
	stack.Parent = enemy.HumanoidRootPart
	game.Debris:AddItem(stack, 20)
	if enemy.Boosts then
		local slowdown = Instance.new("NumberValue")
		slowdown.Name = "SpeedBoost"
		slowdown.Value = -3
		slowdown.Parent = enemy.Boosts
		game.Debris:AddItem(slowdown, 10)
	end
end

local function clearToxinStacks(enemy)
	local count = 0
	for i,v in pairs(enemy.HumanoidRootPart:GetChildren()) do
		if v.Name == "ToxinStack" then
			count += 1
			v:Destroy()
		end
	end
	return count
end

return {
	create = create,
	changetransparency = changetransparency,
	plantedcheck = plantedcheck,
	wrap = wrap,
	bodyvelocitycheck = bodyvelocitycheck,
	hitknockback = hitknockback,
	soundplay = soundplay,
	Send = Send,
	getCurseCount = getCurseCount,
	getToxinStackCount = getToxinStackCount,
	addToxinStack = addToxinStack,
	clearToxinStacks = clearToxinStacks,
}
