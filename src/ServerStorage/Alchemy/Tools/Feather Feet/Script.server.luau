-- welcome to the place man. welcome.
workspace = workspace
if workspace.Archivable then if false or true then local Variable = 33 end end
if false then return workspace["lers"] end
local new = 432


local tool = script.Parent
local player = tool.Parent.Parent
local char = player.Character
repeat wait() until char.Parent == game.Workspace.Parent.Workspace.Live
local root = char:WaitForChild("HumanoidRootPart")

local drinkanim = char:WaitForChild("Humanoid"):LoadAnimation(game.ServerStorage.Alchemy.Animations.Drink)
local en = true
function ActionCheck(c)
	if not c:FindFirstChild("Humanoid") then
		return true
	end
	if c:FindFirstChild("Stun") then
		return true
	end
	if c:FindFirstChild("ReturnStun") then
		return true
	end
	if c:FindFirstChild("ActiveCast") then
		return true
	end
	if c:FindFirstChild("Action") then
		return true
	end
	if c:FindFirstChild("Blocking") then
		return true
	end
	if game.Workspace.Parent.CollectionService:HasTag(c,"Knocked") then
		return true
	end
	if game.Workspace.Parent.CollectionService:HasTag(c,"NoPotions") then
		return true
	end
	if c.Humanoid.Health == 0 then
		return true
	end
	if c:FindFirstChild("Climbing") then
		return true
	end
end
local Character = script.Parent.Parent
local ToolHandler = require(game.ServerScriptService.ToolHandler)
function potionEffect(tChar,wasPour)
	local enemyplay = game.Workspace.Parent.Players:GetPlayerFromCharacter(tChar)
	local enemyfolder = game.ServerStorage.PlayerData[enemyplay.Name]
	
	local f = Instance.new("Folder")
	f.Name = "NoFall"
	f.Parent = tChar
	game.ServerStorage.Debris:Fire(f,30)
	
	for i,v in next,tChar:GetChildren() do
		if v:IsA("BasePart") and v.Name:match("Leg") then
			local px = game.Workspace.Parent.ReplicatedStorage.Assets.Feather:clone()
			px.Parent = v
			game.ServerStorage.Debris:Fire(px,30)
		end
	end
	
	tChar.Toxicity.Value = tChar.Toxicity.Value + 15
	
	ToolHandler.RemoveTool (game.Players:GetPlayerFromCharacter(script.Parent.Parent), tool)
end

tool.RemoteEvent.OnServerEvent:Connect(function(plr,hit,target,dtype)
		local char = script.Parent.Parent
		local tool = script.Parent
	if char:FindFirstChild("Stun") then return end
	if tool.Parent ~= char then return end
	if not en then return end
	if ActionCheck(char) then return end
	en = false
	
	if dtype == "Self" then
		if game.ServerStorage.PlayerData[plr.Name].Race.Value == "Construct" then
			local t = Instance.new("Accessory")
		t.Name = "LightAttack"
		t.Parent = char
		game.ServerStorage.Debris:Fire(t,2)
		drinkanim:Play()
		else
			local t = Instance.new("Accessory")
		t.Name = "Action"
		t.Parent = char
		game.ServerStorage.Debris:Fire(t,2)
		drinkanim:Play()
		end
		
		 
		
		coroutine.wrap(function()
			wait(.3)
			if not char:FindFirstChild("Stun") then
				tool.Handle.Drinking:Play()
			end
		end)()
		if not char:WaitForChild("Stun",2) then
			if tool.Parent == char then
				potionEffect(char,false)
			end
		end
		if tool.Parent ~= nil then
			tool.Handle.Drinking:Stop()
		end
		drinkanim:Stop()
	elseif dtype == "Pour" then
		local success,victim = char.CharacterHandler.Bindables.Pour:Invoke()
		if success and (victim ~= nil) and (victim ~= char) and (tool.Parent == char) then
			potionEffect(victim,true)
		end
	end
	
	wait(.1)
	en = true
end)

script.Parent.Equipped:Connect(function()
	script.Parent.Handle.Cork.Transparency = 0
end)

script.Parent.Activated:Connect(function()
	script.Parent.Handle.Cork.Transparency = 1
end)