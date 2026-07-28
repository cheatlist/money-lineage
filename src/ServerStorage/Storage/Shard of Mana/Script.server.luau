

function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("Action") then
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
end

local HS = game:GetService("HttpService")

local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	
	if ActionCheck(p1) then
		return
	end
	if not canuse then
		return
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	if not p2 then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not data then
		return
	end
	local StoryMarker = HS:JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ascension"] or not StoryMarker["Ascension"]["Castellan"] or StoryMarker["Ascension"]["Castellan"] ~= "Started" then
		return
    end
	canuse = false
	
	StoryMarker["Ascension"]["Castellan"] = "SlayedMage"
	StoryMarker["Ascension"]["NoAs'endo"] = false
	data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2, script.Parent.Name)
	script.Parent:Destroy()
end)

