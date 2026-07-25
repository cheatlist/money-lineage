local u4 = require(game.ServerScriptService.Modules.EffectModule)

local function ApplyDragonSlayerPathProcs(character, enemy, info, humanoid)
	if character.Cooldowns:FindFirstChild("The Storm Herald") and not character.Cooldowns:FindFirstChild("The Storm Herald CD") and info.spear and math.random(1,10) == 1 then
		local CD = Instance.new("NumberValue")
		CD.Name = "The Storm Herald CD"
		CD.Value = 2
		CD.Parent = character.Cooldowns
		game.Debris:AddItem(CD, 10)

		local hitChars = {}

		local function recurse(depth,startp,endp,dam)
			if depth > 2 then return end

			u4.QuickLightning(startp,endp,0.2,8,"Lilac")

			local targ = nil
			local closestDist = nil
			for _,ochar in next,game.Workspace.Live:GetChildren() do
				if ochar ~= character and ochar:FindFirstChild("HumanoidRootPart") and not hitChars[ochar] then
					local dist = (ochar.HumanoidRootPart.Position-endp).Magnitude
					if dist < 100 and ((not targ) or dist < closestDist) then
						targ = ochar
						closestDist = dist
					end
				end
			end

			if targ then
				hitChars[targ] = true
				game.ServerStorage.Requests.TagHumanoid:Fire(character,targ,{mana=true,damage=dam,dexthunder=true,nodexsound=true,sigilthunder=true,move = "Chain Lightning"})

				coroutine.wrap(function()
					task.wait(0.15)

					if depth == 0 then
						u4.QuickLightning(character.HumanoidRootPart.Position,endp,0.2,8,"Lilac")
					elseif targ and targ.Parent == workspace.Live and targ:FindFirstChild("HumanoidRootPart") then
						u4.QuickLightning(endp,targ.HumanoidRootPart.Position,0.2,8,"Lilac")
					end
				end)()

				recurse(depth+1,endp,targ.HumanoidRootPart.Position,dam+5)
			end
		end

		recurse(0,character.HumanoidRootPart.Position,enemy.HumanoidRootPart.Position,10)
	end
	if character.Cooldowns:FindFirstChild("The Ember Wyrm") and not character.Cooldowns:FindFirstChild("The Ember Wyrm CD") and info.spear and math.random(1,10) == 1 then
		local CD = Instance.new("NumberValue")
		CD.Name = "The Ember Wyrm CD"
		CD.Value = 2
		CD.Parent = character.Cooldowns
		game.Debris:AddItem(CD, 10)

		u4.Explosion(CFrame.new(enemy.HumanoidRootPart.Position), 8, {
			mana = true,
			damage = 8,
			burn = true,
			burncolor = Color3.fromRGB(255, 90, 20),
			noenchant = true,
			move = "Ember Wyrm"
		}, nil, Color3.fromRGB(255, 100, 20), character)
	end
	if character.Cooldowns:FindFirstChild("The Abyssal Wyrm") and not character.Cooldowns:FindFirstChild("The Abyssal Wyrm CD") and info.spear and math.random(1,10) == 1 then
		local CD = Instance.new("NumberValue")
		CD.Name = "The Abyssal Wyrm CD"
		CD.Value = 2
		CD.Parent = character.Cooldowns
		game.Debris:AddItem(CD, 10)

		local toheal = info.damage * 0.3
		if humanoid.Health + toheal < humanoid.MaxHealth then
			humanoid.Health += toheal
		else
			humanoid.Health = humanoid.MaxHealth
		end
	end
end

return ApplyDragonSlayerPathProcs
