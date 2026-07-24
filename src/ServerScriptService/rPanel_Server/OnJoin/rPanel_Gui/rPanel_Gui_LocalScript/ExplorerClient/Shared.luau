local Fusion = require(script.Parent.Modules.Fusion)

local Shared = {
	SelectedInstance = Fusion.Value(nil),
	ServerView = Fusion.Value(false),
	ToolEnabled = Fusion.Value(false),
	WidgetEnabled = Fusion.Value(false),
	ExportFrameEnabled = Fusion.Value(false)
}
Shared.ListeningServer = Fusion.Computed(function()
	return Shared.ServerView:get() and Shared.ToolEnabled:get()
end)

return Shared
