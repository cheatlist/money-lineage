local module = {}

module.__index = module

local RS = game:GetService("ReplicatedStorage")

local ReplicatedModules = RS:FindFirstChild("ReplicatedModules")

local Maid = require(ReplicatedModules.Maid)
local Signal = require(ReplicatedModules.Signal)

function module.new(Player)
	local self = setmetatable({}, module)
	
	self.Player = Player
	
	self.Maid = Maid.new()
	self.Signal = Signal.new()
	
	self.Maid:GiveTask(self.Signal)
	return self
end

function module:Destroy()
	self.Maid:DoCleaning()
end

return module
