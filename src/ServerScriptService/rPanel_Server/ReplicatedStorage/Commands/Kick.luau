local Kick = {}

Kick.Name = "Kick"
Kick.Description = "Kicks the given player out of the game"
Kick.Icon = "rbxassetid://15269328856"
Kick.Parameters = {
	[1] = {
		Type = "T{Player}",
		Name = "Targets",
		Required = true,
	},
	[2] = {
		Type = "string",
		Name = "Message",
		Required = false,
	}
}

function Kick:OnExecute(Args)
	local Executee: Player = Args.Executee
	local Targets: {[number]: Player} = Args.Targets
	local Message: string? = Args.Message
	
	for i,v in Targets do
		v:Kick(Message or nil)
	end
	return true
end

return Kick
