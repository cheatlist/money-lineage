local Effects = {
	
}

for i,v in pairs(script.Effects:children()) do
	local Activator = v:IsA("ModuleScript") and require(v)
	
	if Activator then
		for i,v in pairs(Activator) do
			Effects[i] = v
		end
	end
end

game.ReplicatedStorage.Requests.ClientEffect.OnClientEvent:Connect(function(EffectName, Properties)
	local Effect = Effects[EffectName]
	
	if Effect then
		Effect(Properties)
	end
end)