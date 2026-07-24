local Tool = script.Parent
local Handle = Tool.Handle
local play = Tool.Parent.Parent
repeat
	wait()
until play.Character
local char = play.Character

local effmod = require(game.ServerScriptService.Modules.EffectModule)

local PE1 = Handle.Attachment.ParticleEmitter
local PE2 = Handle.Attachment.ParticleEmitter2
local PL = Handle.Attachment.PointLight

local AE = Handle.Attachment.Ardorian
local AL = Handle.Attachment.ArdorLight

local lit = Tool.Lit
local percentLit = Tool.PercentLit
local timer = 0

local boost = Instance.new("NumberValue")
boost.Name = "ColdResist"
boost.Value = 0.5

script.Parent.Handle.Touched:Connect(function(part)
	if (part:FindFirstChild("SigilPtcl") and part:FindFirstChild("SigilLight")) or part.Name == "Campfire" or part.Name == "Fire" and part.Parent:IsA("Model") then
		Handle.Light:Play()
		
		if char:FindFirstChild("Boosts") then
			boost.Parent = char.Boosts
		end
		
		if lit.Value == false then
			lit.Value = true
			percentLit.Value = 100
			
			if not Tool:FindFirstChild("ARDOR") then
				timer = 180
				PE2.Enabled = true
				PL.Enabled = true
			else
				timer = 240
				AE.Enabled = true
				AL.Enabled = true
			end
			PE1.Enabled = true
			
			
			repeat
				PE2.Rate = 60 * (timer/180)
				PL.Range = 25 * (timer/180)
				
				if Tool:FindFirstChild("ARDOR") then
					PE1.Rate = 10 * (timer/240)
				else
					PE1.Rate = 10 * (timer/180)
				end
				
				AE.Rate = 60 * (timer/240)
				AL.Range = 25 * (timer/240)
				
				percentLit.Value = (timer/180)
				
				timer = timer - 1
				
				if Tool:FindFirstChild("EXTINGUISH") then
					Tool.EXTINGUISH:Destroy()
					timer = 0
				elseif game.CollectionService:HasTag(char,"Unconscious") then
					timer = 0
				end
				wait(1)
			until timer == 0 or (Tool.Parent:FindFirstChild("Humanoid") and Tool.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Swimming) 
			
			boost.Parent = Tool
			
			percentLit.Value = 0
			
			lit.Value = false
			
			PE1.Enabled = false
			PE2.Enabled = false
			PL.Enabled = false
			AE.Enabled = false
			AL.Enabled = false
			
			if Tool:FindFirstChild("ARDOR") then Tool.ARDOR:Destroy() end
		else
			if part:FindFirstChild("SigilPtcl") and part:FindFirstChild("SigilLight") and Tool:FindFirstChild("ARDOR") then
				timer = 0
				effmod.Explosion(Handle.CFrame,30,65,true,Color3.fromRGB(85,0,127))
			else
				if not Tool:FindFirstChild("ARDOR") then
					timer = 180
				else
					timer = 240
				end
			end
		end
	end
end)

script.Parent.ChildAdded:Connect(function(child)
	if child.Name == "ARDOR" then
		Handle.Light:Play()
		if lit.Value == false then
			lit.Value = true
			timer = 180
			percentLit.Value = 100
			
			if not Tool:FindFirstChild("ARDOR") then
				PE2.Enabled = true
				PL.Enabled = true
			else
				AE.Enabled = true
				AL.Enabled = true
			end
			PE1.Enabled = true
			
			
			
			
			repeat
				PE2.Rate = 60 * (timer/180)
				PL.Range = 25 * (timer/180)
				
				if Tool:FindFirstChild("ARDOR") then
					PE1.Rate = 10 * (timer/240)
				else
					PE1.Rate = 10 * (timer/180)
				end
				
				AE.Rate = 60 * (timer/240)
				AL.Range = 25 * (timer/240)
				
				percentLit.Value = (timer/180)
				
				timer = timer - 1
				
				if Tool:FindFirstChild("EXTINGUISH") then
					Tool.EXTINGUISH:Destroy()
					timer = 0
				elseif game.CollectionService:HasTag(char,"Unconscious") then
					timer = 0
				end
				wait(1)
			until timer == 0 or (Tool.Parent:FindFirstChild("Humanoid") and Tool.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Swimming) 
			
			boost.Parent = Tool
			
			percentLit.Value = 0
			
			lit.Value = false
			
			PE1.Enabled = false
			PE2.Enabled = false
			PL.Enabled = false
			AE.Enabled = false
			AL.Enabled = false
			
			if Tool:FindFirstChild("ARDOR") then Tool.ARDOR:Destroy() end
		else
			PE2.Enabled = false
			PL.Enabled = false
			AE.Enabled = true
			AL.Enabled = true
			timer = 240
		end
	end
end)

script.Parent.Equipped:Connect(function()
	local char = Tool.Parent
	if char:FindFirstChild("Boosts") and lit.Value then
		boost.Parent = char.Boosts
	end
end)

script.Parent.Unequipped:Connect(function()
	boost.Parent = Tool
end)