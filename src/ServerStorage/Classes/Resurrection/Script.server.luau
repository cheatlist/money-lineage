local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Commands = require(ServerScriptService:FindFirstChild("Modules"):WaitForChild("Commands"))
local TagHumanoid = ServerStorage:FindFirstChild("Requests"):WaitForChild("TagHumanoid")

local Used: boolean = false

local function ActionCheck(aisar)
	if aisar:FindFirstChild("Knocked") then
		return false
	end
	return true
end

script.Parent.Activated:Connect(function()
	local player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
	if player then
		local character = player.Character
		
		if character:FindFirstChild("ResGlobalCD") then
			return
		end

		if Used then return end

		if ActionCheck(character) then
			return
		end
		if game.ServerStorage.PlayerData[player.Name].LastRessed.Value == game.ServerStorage.PlayerData[player.Name].DaysSurvived.Value then
			return
		end
		if game.ServerStorage.PlayerData[player.Name].ResGrip.Value == false then
			return
		end
		game.ServerStorage.PlayerData[player.Name].ResGrip.Value = false
		game.ServerStorage.PlayerData[player.Name].GalvExcept.Value = game.ServerStorage.PlayerData[player.Name].DaysSurvived.Value

		local s = script.Parent.Roar:clone()
		s.Parent = player.Character.Torso
		s:Play()
		game.Debris:AddItem(s,2.5)

		local RessurrectionBoost = Instance.new("NumberValue")
		RessurrectionBoost.Name = "SpeedBoost"
		RessurrectionBoost.Parent = character["Boosts"]

		local ShinobiRuby = Instance.new("Accessory")
		ShinobiRuby.Name = "ShinobiRuby"
		ShinobiRuby.Parent = character

		RessurrectionBoost:SetAttribute("ResurrectionBuff", true)

		local EyeVisual = game.ReplicatedStorage.Assets.ResurrectionEYE:Clone()

		local EyeWeld = Instance.new("Weld")
		EyeWeld.Part0 = character.Head
		EyeWeld.Part1 = EyeVisual

		EyeVisual.Parent = character.Head
		EyeWeld.Parent = character.Head

		game.Debris:AddItem(ShinobiRuby, 30)
		game.Debris:AddItem(EyeVisual, 30)
		game.Debris:AddItem(RessurrectionBoost, 30)
		game.Debris:AddItem(EyeWeld, 30)

		local ShinobiResurrection = game.ReplicatedStorage.Assets.ShinobiResurrection:Clone()
		ShinobiResurrection.Parent = workspace.Thrown
		ShinobiResurrection.CFrame = character.HumanoidRootPart.CFrame
		
		character.Humanoid.Health = character.Humanoid.MaxHealth / 2

		for _,v in pairs(character:GetChildren())do
			if v.Name == "Knocked"or v.Name == "Unconscious"or v.Name == "Action"or v.Name == "NoDam"or v.Name == "FreezeRoot"then
				v:Destroy()
			end
		end

		for _,live in pairs(workspace.Live:GetChildren()) do
			if live:FindFirstChild("Torso") and live:FindFirstChild("HumanoidRootPart") and live ~= character then
				if (live.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude <= 15 then
					TagHumanoid:Fire(character, live, {
						damage = 15;
						physical = true;
						strongknockback = true,
						move = "Resurrection"
					})
				end
			end
		end

		TweenService:Create(ShinobiResurrection, TweenInfo.new(0.35), {
			Transparency = 0;
			CFrame = character.HumanoidRootPart.CFrame;
		}):Play()

		TweenService:Create(ShinobiResurrection, TweenInfo.new(0.35), {
			Transparency = 0;
			Size = Vector3.new(15, 15, 15);
		}):Play()

		task.wait(0.35)

		TweenService:Create(ShinobiResurrection, TweenInfo.new(0.35), {
			Transparency = 1;
			Size = Vector3.new(0,0,0);
		}):Play()

		task.wait(0.35)

		ShinobiResurrection:Destroy()
		
		local v3 = Instance.new("Accessory")
		v3.Name = "ResGlobalCD"
		v3.Parent = character
		game.Debris:AddItem(v3,300)

	end
end)