local spell = {}
-- Enslave Shrieker Spell
function sub(...)
	coroutine.wrap(...)()
end

local TweenService = game:GetService("TweenService")
local tagHumanoid = game.ServerStorage.Requests.TagHumanoid

spell.upperbound = 100
spell.lowerbound = 50
spell.signs = 5
spell.cost = 100

local spelleffect = game.ServerStorage.SpellEffects.BloodTie

function spell:Activate(char,castSuccess,currentprop)
	if game.CollectionService:HasTag(char,"Casting") then return end
	local play = game.Players:GetPlayerFromCharacter(char)
	local manacolor = game.ServerStorage.PlayerData[play.Name].ManaColor.Value

	if castSuccess == 0 then
		if char:FindFirstChild("BloodTied") then return end

		char.HumanoidRootPart.PerfectCast:Play()

		for _,ochar in next, workspace.Live:children() do
			if ochar:FindFirstChild("MonsterInfo") and ochar:FindFirstChild("Humanoid") and ochar.Humanoid.Health > 0 and not ochar:FindFirstChild("Summoned") and not ochar:FindFirstChild("Grabbed") then
				if ochar.MonsterInfo.Master.Value == char and ochar.MonsterInfo.MonsterType.Value == "Shrieker" then
					local rootpos = ochar.HumanoidRootPart.Position
					if (char.HumanoidRootPart.Position-rootpos).Magnitude < 100 then 
						ochar.Humanoid.Health = 0

						local pdata = game.ServerStorage.PlayerData:FindFirstChild(play.Name)

						pdata.BoundAmount.Value = math.clamp(pdata.BoundAmount.Value+1,0,3)
						--game.ServerStorage.Requests.LootDrop:Invoke(game.ServerStorage.Items["Bound Shrieker"],rootpos)
					end
				end
			end
		end
	else 			
		char.HumanoidRootPart.Diffusion:Play()
		if currentprop and currentprop:FindFirstChild("Backfire") then
			currentprop.Backfire.Color = ColorSequence.new(Color3.new(manacolor.r,manacolor.g,manacolor.b))
			currentprop.Backfire:Emit(15)
		end
	end
end

return spell