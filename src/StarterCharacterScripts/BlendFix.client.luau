-- credit to arda and alr

local char = script.Parent
char:WaitForChild("Humanoid")
local Priorities = {Enum.AnimationPriority.Core, Enum.AnimationPriority.Idle, Enum.AnimationPriority.Movement, Enum.AnimationPriority.Action, Enum.AnimationPriority.Action2, Enum.AnimationPriority.Action3, Enum.AnimationPriority.Action4}
local Adjusted = {}
local CoreAnims = {}
local IdleAnims = {}
local MovementAnims = {}
local ActionAnims = {}
local Action2Anims = {}
local Action3Anims = {}
local Action4Anims = {}
game:GetService("RunService").Stepped:Connect(function()
	local AnimTable = char.Humanoid:GetPlayingAnimationTracks()
	for i,v in pairs(AnimTable) do
		if v.Priority == Enum.AnimationPriority.Core then
			table.insert(CoreAnims, v)
		elseif v.Priority == Enum.AnimationPriority.Idle then
			table.insert(IdleAnims, v)
		elseif v.Priority == Enum.AnimationPriority.Movement then
			table.insert(MovementAnims, v)
		elseif v.Priority == Enum.AnimationPriority.Action then
			table.insert(ActionAnims, v)
		elseif v.Priority == Enum.AnimationPriority.Action2 then
			table.insert(Action2Anims, v)
		elseif v.Priority == Enum.AnimationPriority.Action3 then
			table.insert(Action3Anims, v)
		elseif v.Priority == Enum.AnimationPriority.Action4 then
			table.insert(Action4Anims, v)
		end
	end
	local max = 0
	for i = 1,#CoreAnims do
		local v = CoreAnims[i]
		if i ~= #CoreAnims then
			if not Adjusted[v] then
				Adjusted[v] = {OldWeight = v.WeightCurrent}
			end
			if v.WeightCurrent ~= 0.0001 then
				v:AdjustWeight(0.0001)
			end
		else
			if Adjusted[v] and v.WeightCurrent ~= Adjusted[v].OldWeight then
				v:AdjustWeight(Adjusted[v].OldWeight)
			end
		end
	end

	for i = 1,#IdleAnims do
		local v = IdleAnims[i]
		if i ~= #IdleAnims then
			if not Adjusted[v] then
				Adjusted[v] = {OldWeight = v.WeightCurrent}
			end
			if v.WeightCurrent ~= 0.0001 then
				v:AdjustWeight(0.0001)
			end
		else
			if Adjusted[v] and v.WeightCurrent ~= Adjusted[v].OldWeight then
				v:AdjustWeight(Adjusted[v].OldWeight)
			end
		end
	end

	for i = 1,#MovementAnims do
		local v = MovementAnims[i]
		if i ~= #MovementAnims then
			if not Adjusted[v] then
				Adjusted[v] = {OldWeight = v.WeightCurrent}
			end
			if v.WeightCurrent ~= 0.0001 then
				v:AdjustWeight(0.0001)
			end
		else
			if Adjusted[v] and v.WeightCurrent ~= Adjusted[v].OldWeight then
				v:AdjustWeight(Adjusted[v].OldWeight)
			end
		end
	end

	for i = 1,#ActionAnims do
		local v = ActionAnims[i]
		if i ~= #ActionAnims then
			if not Adjusted[v] then
				Adjusted[v] = {OldWeight = v.WeightCurrent}
			end
			if v.WeightCurrent ~= 0.0001 then
				v:AdjustWeight(0.0001)
			end
		else
			if Adjusted[v] and v.WeightCurrent ~= Adjusted[v].OldWeight then
				v:AdjustWeight(Adjusted[v].OldWeight)
			end
		end
	end

	for i = 1,#Action2Anims do
		local v = Action2Anims[i]
		if i ~= #Action2Anims then
			if not Adjusted[v] then
				Adjusted[v] = {OldWeight = v.WeightCurrent}
			end
			if v.WeightCurrent ~= 0.0001 then
				v:AdjustWeight(0.0001)
			end
		else
			if Adjusted[v] and v.WeightCurrent ~= Adjusted[v].OldWeight then
				v:AdjustWeight(Adjusted[v].OldWeight)
			end
		end
	end

	for i = 1,#Action3Anims do
		local v = Action3Anims[i]
		if i ~= #Action3Anims then
			if not Adjusted[v] then
				Adjusted[v] = {OldWeight = v.WeightCurrent}
			end
			if v.WeightCurrent ~= 0.0001 then
				v:AdjustWeight(0.0001)
			end
		else
			if Adjusted[v] and v.WeightCurrent ~= Adjusted[v].OldWeight then
				v:AdjustWeight(Adjusted[v].OldWeight)
			end
		end
	end

	for i = 1,#Action4Anims do
		local v = Action4Anims[i]
		if i ~= #Action4Anims then
			if not Adjusted[v] then
				Adjusted[v] = {OldWeight = v.WeightCurrent}
			end
			if v.WeightCurrent ~= 0.0001 then
				v:AdjustWeight(0.0001)
			end
		else
			if Adjusted[v] and v.WeightCurrent ~= Adjusted[v].OldWeight then
				v:AdjustWeight(Adjusted[v].OldWeight)
			end
		end
	end
end)
