local spell = {}
-- Blood Drain Spell
function sub(...)
    coroutine.wrap(...)()
end
 
local TweenService = game:GetService("TweenService")
local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local effectsMod = require(game.ServerScriptService.Modules.EffectModule)

spell.upperbound = 100
spell.lowerbound = 0
spell.signs = 0
spell.cost = 0
spell.nofx = true

local spelleffect = game.ServerStorage.SpellEffects.Sukari
function spell:Activate(char,castSuccess,currentprop)
	if game.CollectionService:HasTag(char,"Casting") or char:FindFirstChild("ActiveCast") then return end
	if char:FindFirstChild("ChLightCD") then return end

	local mana = char.Mana
	local play = game.Players:GetPlayerFromCharacter(char)
	local manacolor = game.ServerStorage.PlayerData[play.Name].ManaColor.Value
	local root = char.HumanoidRootPart
	
	local mouse
	pcall(function()
		mouse = require(game.ServerStorage.Modules.RemoteLib).getMouse(play)
	end)
	if not (mouse and (root.Position - mouse.Hit.p).Magnitude < 100) then return end
	local oldMouse = mouse
	
	if castSuccess == 0 then
		if char:FindFirstChild("EndCast") then return end
		game.ReplicatedStorage.Requests.StopSprint:FireClient(play)
		
		local h = Instance.new("Accessory")
		h.Name = "ActiveCast"
		h.Parent = char
		
		mana.Value = math.max(mana.Value-spell.cost,0)
		
		local anim = char.Humanoid:LoadAnimation(script.Snap)
		anim:Play()
		
		root.LittleShock:Play()
		
		local sukAttach = spelleffect.DummyPart.SnapSukAttach:Clone()
		sukAttach.Parent = char["Right Arm"]
	
		wait(0.2)
		
		local snapSound = script.SnapSound:Clone()
		snapSound.Parent = root
		snapSound:Play()

		sukAttach.SukStatic.Enabled = false
		
		
		pcall(function()
			mouse = require(game.ServerStorage.Modules.RemoteLib).getMouse(play) or mouse
		end)
		
		if (root.Position - mouse.Hit.p).Magnitude > 100 then 
			mouse = oldMouse
		end
		
		local hitChars = {}
		local live = workspace.Live:GetChildren()
		
		local function recurse(depth,startp,endp,dam)
			if depth > 4 then return end
			
			
			effectsMod.QuickLightning(startp,endp,0.2,8,"Cyan")
			
			local targ = nil
			local closestDist = nil
			for _,ochar in next,live do
				if ochar ~= char and ochar:FindFirstChild("HumanoidRootPart") and not hitChars[ochar] then
					local dist = (ochar.HumanoidRootPart.Position-endp).Magnitude
					if dist < 100 and ((not targ) or dist < closestDist) then
						targ = ochar
						closestDist = dist
					end
				end
			end
			
			if targ then
				hitChars[targ] = true
				tagHumanoid:Fire(char,targ,{mana=true,damage=dam,dexthunder=true,nodexsound=true,sigilthunder=true,move = "Chain Lightning"})
				
				coroutine.wrap(function()
					wait(0.15)
					
					if depth == 0 then
						effectsMod.QuickLightning(sukAttach.WorldPosition,endp,0.2,8,"Cyan")
					elseif targ and targ.Parent == workspace.Live and targ:FindFirstChild("HumanoidRootPart") then
						effectsMod.QuickLightning(endp,targ.HumanoidRootPart.Position,0.2,8,"Cyan")
					end
				end)()
				
				recurse(depth+1,endp,targ.HumanoidRootPart.Position,dam+5)
			end
		end
		
		recurse(0,sukAttach.WorldPosition,mouse.Hit.p,10)
		
		h:Destroy()
		
		local cd = Instance.new("Accessory")
		cd.Name = "ChLightCD"
		cd.Parent = char
		game.ServerStorage.Debris:Fire(cd,0.15)
		
		game.ServerStorage.Debris:Fire(sukAttach,0.3)
	end
end

return spell