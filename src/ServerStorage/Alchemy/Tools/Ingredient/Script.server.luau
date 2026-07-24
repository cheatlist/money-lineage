
local tool = script.Parent
local hs = game.Workspace.Parent:GetService("HttpService")
local toolHandler = require(game:GetService("ServerScriptService").ToolHandler)
local range = 10
local en = true

local quantityVal = tool:FindFirstChild("Quantity")

function ActionCheck()
	local char = tool.Parent
	if not char:FindFirstChild("Humanoid") then
		return true
	end
	if char:FindFirstChild("Stun") then
		return true
	end
	if char:FindFirstChild("ReturnStun") then
		return true
	end
	if char:FindFirstChild("ActiveCast") then
		return true
	end
	if char:FindFirstChild("LightAttack") then
		return true
	end
	if char:FindFirstChild("Action") then
		return true
	end
	if char:FindFirstChild("Blocking") then
		return true
	end
	if char:FindFirstChild("SpellBlocking") then
		return true
	end
	if char.Humanoid.Health == 0 then
		return true
	end
	if game.Workspace.Parent.CollectionService:HasTag(char,"NoPotions") then
		return true
	end
	if game.Workspace.Parent.CollectionService:HasTag(char,"Knocked") then
		return true
	end
	if char:FindFirstChild("Climbing") then
		return true
	end
end

tool.RemoteEvent.OnServerEvent:Connect(function(plr,hit,target)
	if not en then return end
	
	local char = tool.Parent
	local player = game.Workspace.Parent.Players:GetPlayerFromCharacter(char)
	if plr ~= player then return end
	
	if ActionCheck() then return end
	
	en = false
	
	local drop = tool:FindFirstChild("Droppable")
	if drop then
		drop.Name = "OccupiedDroppable"
	end
	
	local isVamp = game.CollectionService:HasTag(char,"Vampirism")
	local noEat = false
	for i,v in next,char:children() do
		if v.Name == "NoEat" and game.CollectionService:HasTag(char,"Vampirism") then
			noEat = true
		end
	end
	
	if target.Parent.Name == "AlchemyStation" or target.Parent.Parent.Name == "AlchemyStation" then
		if target.Name ~= "Bucket" and target.Name ~= "Ladle" then
			if (char.HumanoidRootPart.Position-hit.p).magnitude > range then en = true return end
			
			local toolCount = 0
			for i,v in next,char:children() do
				if v:IsA("Tool") then
					toolCount += 1
					if toolCount > 1 then en = true return end
				end
			end
			
			local v_contents = target.Parent:FindFirstChild("Contents") or target.Parent.Parent:FindFirstChild("Contents") 
			local station = v_contents.Parent
			if station.User.Value ~= player.Name then
				station.User.Value = player.Name
			end
			
			local contents = hs:JSONDecode(v_contents.Value)
			table.insert(contents,tool.Name)
			v_contents.Value = hs:JSONEncode(contents)
			station.Water.Splash:Play()
			
			if quantityVal and quantityVal.Value > 1 then
				quantityVal.Value = quantityVal.Value-1
			else
				toolHandler.RemoveTool(plr, tool)
			end	
		end
	elseif game.ServerStorage.PlayerData[player.Name].Skills.Value:find("Herbivore") and not noEat then
		if not isVamp or tool.Name == "Blood Thorn" then
			local Race = game.ServerStorage.PlayerData[player.Name].Race.Value
			char.Stomach.Value = char.Stomach.Value + 25
			local anim = char.Humanoid:LoadAnimation(script.Parent.Animation)
			anim:Play()
			
			wait(.6)
			
			if tool.Name == "Blood Thorn" and Race ~= "Azael" and Race ~= "Cameo" and Race ~= "Metascroom" and Race ~= "Scroom" and Race ~= "Fischeran" and Race ~= "Gaian" then
				if not isVamp and not char:FindFirstChild("Phoenix") then
					game.ServerStorage.Requests.Injure:Invoke(plr,"vampirism",true)
				end
				char.Stomach.Value = char.Stomach.Value + 25
				game.ServerStorage.PlayerData[player.Name].Feeds.Value += 1
			end
			
			if quantityVal and quantityVal.Value > 1 then
				quantityVal.Value = quantityVal.Value-1
			else
				tool:Destroy()
				toolHandler.RemoveTool(plr, tool)
			end
		end
	end
		
	if tool.Parent then
		if drop then
			drop.Name = "Droppable"
		end
	end
		
	wait(.1)
	en = true
end)
