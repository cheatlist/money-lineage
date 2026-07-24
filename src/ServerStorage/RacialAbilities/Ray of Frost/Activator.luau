local spell = {}
-- Blood Drain Spell
function sub(...)
    coroutine.wrap(...)()
end
 
local TweenService = game:GetService("TweenService")
local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local effectsMod = require(game.ServerScriptService.Modules.EffectModule)

spell.upperbound = 100
spell.lowerbound = 70
spell.signs = 0
spell.cost = 0
spell.nofx = true

local ts = TweenService



local Up=Vector3.new(0,1,0)
local function IsInCylinder(Cylinder,Point)
    local Size=Cylinder.Size * Cylinder.Mesh.Scale
    local Relative=Point-Cylinder.Position
    local Line=Cylinder.CFrame:vectorToWorldSpace(Up)
    local Dot=Line:Dot(Relative)
    return Dot<Size.y/2
        and Dot>-Size.y/2 
        and (Relative-Dot*Line).magnitude<(math.min(Size.x,Size.z)/2)+1 -- offset of 2 
end

local spelleffect = game.ServerStorage.SpellEffects.Altair
function spell:Activate(char,castSuccess,currentprop)
	if game.CollectionService:HasTag(char,"Casting") or char:FindFirstChild("ActiveCast") then return end
	if char:FindFirstChild("ColdRayCD") then return end

	local mana = char.Mana
	local play = game.Players:GetPlayerFromCharacter(char)
	local manacolor = game.ServerStorage.PlayerData[play.Name].ManaColor.Value
	local root = char.HumanoidRootPart
	local hum = char.Humanoid
	
	local mouse
	pcall(function()
		mouse = require(game.ServerStorage.Modules.RemoteLib).getMouse(play)
	end)
	if not mouse then return end
	
	if castSuccess == 0 then
		if char:FindFirstChild("EndCast") then return end
		game.ReplicatedStorage.Requests.StopSprint:FireClient(play)
		
		local h = Instance.new("Accessory")
		h.Name = "ActiveCast"
		h.Parent = char
		
		local cd = Instance.new("Accessory")
		cd.Name = "ColdRayCD"
		cd.Parent = char
		game.ServerStorage.Debris:Fire(cd,20)
	
		local handle = spelleffect.Handle:Clone()
		handle.Name = "AltairHandle"
		local w = Instance.new("Weld")
		w.Part0 = char.Hilt
		w.Part1 = handle
		w.Parent = handle
		handle.Parent = char
		game.ServerStorage.Debris:Fire(handle,3)
		
		mana.Value = math.max(mana.Value-spell.cost,0)
		
		local anim = hum:LoadAnimation(script.Anim)
		
		anim:Play(0.1,1,0)
		handle.Charge:Play()
		handle.ChargeParticle.Enabled=true
		handle.ChargeParticle2.Enabled=true
		ts:Create(handle.Mesh,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Scale=Vector3.new(50,50,50)}):Play()
		handle.Transparency=0.7
		wait(0.1)
		
		local act = Instance.new("Accessory")
		act.Name = "Action"
		Instance.new("Accessory",act).Name = "NoDelete"
		act.Parent = char
		game.ServerStorage.Debris:Fire(act,3)
		
		anim.TimePosition=0.4
		anim:AdjustSpeed(1)
		
		handle.Sound:Play()
		handle.ChargeParticle.Enabled=false
		handle.ChargeParticle2.Enabled=false 
		
		pcall(function()
			mouse = require(game.ServerStorage.Modules.RemoteLib).getMouse(play) or mouse
		end)
		local mousehit = mouse.Hit.p
		
		local force = Instance.new("CFrameValue")
		force.Name = "ForceCamCF"
		force.Value = CFrame.new(root.Position+Vector3.new(0,5,0),Vector3.new(mousehit.X,root.Position.Y,mousehit.Z)) * CFrame.new(0,0,18)
		force.Parent = char
		
		root.CFrame = CFrame.new(root.Position,Vector3.new(mousehit.X,root.Position.Y,mousehit.Z))
		
		local beam = spelleffect.Beam:clone()
		local dis =200
		
		beam.CFrame = CFrame.new(handle.Position,mousehit)*CFrame.new(0,0,-1-(((dis/2)*(beam.Mesh.Scale.Y/dis))))*CFrame.Angles(math.rad(90),0,0)
		beam.Parent=game.Workspace.Thrown
		ts:Create(beam.Mesh,TweenInfo.new(dis/500,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Scale=Vector3.new(2,dis,2)}):Play()
		ts:Create(beam.End,TweenInfo.new(dis/500,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Position=Vector3.new(0,-(dis/2),0)}):Play()
		ts:Create(beam.Attachment,TweenInfo.new(dis/500,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Position=Vector3.new(0,dis/2,0)}):Play()

		local over = false
		local frozenTable = {}
		coroutine.wrap(function()
			local r2 = game:GetService("RunService").Heartbeat
			local cc = 0 
			local live = workspace.Live:GetChildren()
			
			handle.FireParticle.Enabled = true
			handle.FireParticle2.Enabled = true
			
			repeat
				beam.CFrame = CFrame.new(handle.Position,mousehit)*CFrame.new(0,0,-1-(((dis/2)*(beam.Mesh.Scale.Y/dis))))*CFrame.Angles(math.rad(90),0,0)
				cc =cc + 1
				if cc >=4  then
					cc=0
					for a,b in pairs(live) do			
						if b and b:findFirstChild("HumanoidRootPart") and not b.HumanoidRootPart:IsDescendantOf(char) then
							if IsInCylinder(beam,b.HumanoidRootPart.Position) then
								local pkt = {damage=2,mana=true,noenchant=true,tempchange=-0.01,move = "Ray of Frost"}
								if not frozenTable[b] then
									pkt.icecase=5
									
									local ac2 = Instance.new("Accessory")
									ac2.Name = "Action"
									ac2.Parent = b
									game.ServerStorage.Debris:Fire(ac2,1)
								
									frozenTable[b] = true
									local fr = Instance.new("Accessory")
									fr.Name = "FreezeRoot"
									fr.Parent = b
									game.ServerStorage.Debris:Fire(fr,1)
																	
									b.HumanoidRootPart.Anchored = true
									
									coroutine.wrap(function()
										wait(1)
										b.HumanoidRootPart.Anchored = false
									end)()
								end
								tagHumanoid:Fire(char,b,pkt)
							end
						end
					end 
					local r = math.random(15,25)/10
					beam.Mesh.Scale=Vector3.new(r,beam.Mesh.Scale.Y,r)
					local a= beam.Mesh.Scale.X*(1/0.05)*1.15
					handle.Mesh.Scale=Vector3.new(a,a, a)  
				end
				r2:wait()
			until over
			
			
			
			
		end)()
		
		wait(0.2)
		anim:AdjustSpeed(0)
		wait(0.3)
		wait(1.5/2) 
		
		coroutine.wrap(function()
			for i=1,10 do
				wait(0.3/10)
				beam.Beam.Transparency = NumberSequence.new(i/10)
			end
		end)()
		
		ts:Create(beam,TweenInfo.new(0.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Transparency=1}):Play()
		ts:Create(handle,TweenInfo.new(0.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Transparency=1}):Play()
	 	ts:Create(beam.Mesh,TweenInfo.new(0.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Scale=Vector3.new(0,dis,0)}):Play()
		
		handle.FireParticle.Enabled = false
		handle.FireParticle2.Enabled = false
		
		wait(0.5)	
		
		force:Destroy()
		
		act:Destroy()
		over=true
		beam:Destroy() 
		anim:Stop()
		handle:Destroy()
		h:Destroy()
		
		local cd = Instance.new("Accessory")
		cd.Name = "ColdRayCD"
		cd.Parent = char
		game.ServerStorage.Debris:Fire(cd,6)
	end
end

return spell