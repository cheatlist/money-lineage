return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local HttpService = game:GetService("HttpService")

	local Modules = script.Modules
	local Explorer = require(script.Explorer)
	local PropertiesExplorer = require(script.PropertiesExplorer)
	local Maid = require(Modules.Maid)
	local Fusion = require(Modules.Fusion)

	local Player = Players.LocalPlayer
	local PlayerGui = Player.PlayerGui

	local UI = script.Parent.Parent:WaitForChild("Main"):WaitForChild("ExplorerFrame")

	--[[ Wait for Remotes ]]

	local ReplicatedFolder = ReplicatedStorage:WaitForChild("rPanel_ReplicatedStorage")
	local InGameExplorerShared = ReplicatedFolder:WaitForChild("InGameExplorer_Shared")
	local RemoteFunction = InGameExplorerShared:WaitForChild("InGameExplorer_RemoteFunction")
	local RemoteEvent = InGameExplorerShared:WaitForChild("InGameExplorer_RemoteEvent")
	local RepShared = require(InGameExplorerShared:WaitForChild("InGameExplorerShared"))

	--[[ Loaded ]]

	local Classes,Enums = unpack(RemoteFunction:InvokeServer())

	local Shared = require(script.Shared)
	Shared.RemoteEvent = RemoteEvent
	Shared.RemoteFunction = RemoteFunction

	local ExportFrame = UI.ExportFrame
	Fusion.Hydrate(ExportFrame)
	{
		Visible = Shared.ExportFrameEnabled
	}
	local ExportBox = ExportFrame.TextBox
	Fusion.Observer(Shared.ExportFrameEnabled):onChange(function()
		local enabled = Shared.ExportFrameEnabled:get()
		if enabled then
			ExportBox.Text = HttpService:JSONEncode(RepShared.PropertyChanges)
			ExportBox:CaptureFocus()
			ExportBox.SelectionStart = 0
			ExportBox.CursorPosition = #ExportBox.Text + 1
		end
	end)
	local ExportClose = ExportFrame.Button
	ExportClose.MouseButton1Down:Connect(function()
		Shared.ExportFrameEnabled:set(false)
	end)

	Explorer:Init(UI,Classes)
	PropertiesExplorer:Init(UI,Classes,Enums)
end
