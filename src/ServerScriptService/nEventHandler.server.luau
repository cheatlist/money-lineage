local DefaultData: {[string]: any} = {
	Hit = workspace.WorldEater.CFrame, 
	Target = workspace.WorldEater, 
	UnitRay = Ray.new(Vector3.new(),Vector3.new()), 
	X = 0, 
	Y = 0
}

local valid = {"Hit","Target","UnitRay","X","Y"}
local validTypes = {Hit = "CFrame", Target = "Instance", UnitRay = "Ray", X = "number", Y = "number"}

local Rem = game.ReplicatedStorage.MouseData
_G.MouseData = function(Targ)
	local Start: number = os.clock()
	local MouseResults
		MouseResults = Rem:InvokeClient(Targ)

	if not MouseResults then
		MouseResults = DefaultData
	else
		if typeof(MouseResults) ~= 'table'then
			warn("Possible exploited OnClientInvoke: " .. Targ.Name .. ' | ' .. Targ.UserId .. ' | Type: ' .. typeof(MouseResults))
			Targ:Kick('Stop exploiting remotes loser!')
			return
		end
	end
	for i,v in MouseResults do
		if not table.find(valid,i) then
			game.ServerStorage.Requests.SendWebhook:Fire(
				"MDATA ERROR",
				Targ.Name.." "..Targ.UserId.. " PING A DEVELOPER SOMEONE SENT A MOUSE INPUT THAT WASN'T ALLOWED!! Index: " .. tostring(i) .. " | Value: ".. tostring(v),
				"black",
				"Exploit"
			)
			Targ:Kick("what are you doing")
			break
		else
			if typeof(v) ~= validTypes[i] then
				game.ServerStorage.Requests.SendWebhook:Fire(
					"MDATA ERROR",
					Targ.Name.." "..Targ.UserId.. " PING A DEVELOPER SOMEONE SENT AN INSTANCE TYPE THROUGH MOUSE DATA WASN'T ALLOWED!! Index: " .. tostring(i) .. " | Value: ".. tostring(v) .. " | Type: ".. typeof(v),
					"black",
					"Exploit"
				)
				Targ:Kick("what are you doing")
				break
			end
		end
	end
	return MouseResults
end