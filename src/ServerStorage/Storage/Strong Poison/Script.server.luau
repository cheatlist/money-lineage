local canuse = true
local handle = script.Parent.Handle
local commands = require(game.ServerScriptService.Modules.Commands)
local function create(name,deletetime,parent)
	if not parent then
		return
	end
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	if deletetime then
		game.Debris:AddItem(i, deletetime)
	end
	return i
end
local function stuncheck(c)
	if c:FindFirstChild("Stun")then
		return true
	end
	if c:FindFirstChild("NoDam")then
		return true
	end
	if c:FindFirstChild("Knocked")then
		return true
	end
	if c:FindFirstChild("Unconscious")then
		return true
	end
	if c:FindFirstChild("ActiveCast")then
		return true
	end
	if c:FindFirstChild("NoPotions") then
		return true
	end
	if c:FindFirstChild("NoHP") then
		return true
	end
end
script.Parent.Activated:Connect(function()
	local c = script.Parent.Parent
	if not c:FindFirstChild("Humanoid")then
		return
	end
	local p = game.Players:GetPlayerFromCharacter(c)
	if not p then
		return
	end
	if stuncheck(c)then
		return
	end
	if c:FindFirstChild("Drinking")then
		return
	end
	canuse = false
	c.Humanoid:LoadAnimation(script.Parent.Animation):Play()
	handle.Drinking:Play()
	handle.Cork.Transparency = 1
	script.Parent.Droppable:Destroy()
	create("Drinking",10,c)
	local isconstruct = game.ServerStorage.PlayerData[p.Name].Race.Value == "Construct"
	if not isconstruct then
		create("Action",2.2,c)
	else
		create("LightAttack",2.2,c)
	end
	for i = 1,10 do
		task.wait(0.2)
		if stuncheck(c)then
			create("Droppable",false,script.Parent)
			handle.Cork.Transparency = 0
			canuse = true
			c.Humanoid:UnequipTools()
			return
		end
	end
	if not c:FindFirstChild(script.Parent.Name)then
		create("Droppable",false,script.Parent)
		handle.Cork.Transparency = 0
		canuse = true
		return
	end
	local poisonseverity = script.Parent.PoisonValue.Value
	local symptomps = {}
	if poisonseverity >= 25 then
		table.insert(symptomps, "ManaStop")
	end
	if poisonseverity >= 50 then
		table.insert(symptomps, "Slowness")
	end
	if poisonseverity >= 75 then
		table.insert(symptomps, "Weakness")
	end
	if poisonseverity >= 100 then
		table.insert(symptomps, "Demise")
	end
	for i = 1,#symptomps do
		create(symptomps[i], 180, c)
	end

	commands.RemoveFromInventory(p,script.Parent.Name)
	script.Parent:Destroy()
end)