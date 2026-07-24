function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
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
local model = game.ReplicatedStorage.Assets.Outfits.Helm:Clone()
local canuse = true
local equipped = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local mousetable = _G.MouseData(p2)
	if mousetable.Target.Name == "Water"then
		if mousetable.Target.Color ~= Color3.fromRGB(8,137,207)then
			script.Parent.DyeColor.Color = mousetable.Target.Color
		end
	else
		if script.Parent.DyeColor.Color ~= Color3.fromRGB(248,248,248)then
			for _,v in pairs(p1:GetChildren())do
				if v:IsA("Shirt")or v:IsA("Pants")then
					v.Color3 = script.Parent.DyeColor.Color
				end
			end
			local c = script.Parent.DyeColor.BrickColor.Color
			game.ServerStorage.PlayerData[p2.Name].DyeColor.Value = tostring(c.R*255)..","..tostring(c.G*255)..","..tostring(c.B*255)
			require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2,"Dye Packet")
			script.Parent:Destroy()
		end
	end
	wait(0.1)
	canuse = true
end)