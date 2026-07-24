script.Parent.Frame.Join.Activated:Connect(function()
	if script.Parent.HouseName.Value~=""then
		script.RemoteEvent:FireServer()
		script.Parent:Destroy()
	end
end)
repeat wait()until script.Parent.HouseName.Value~=""
script.Parent.Frame.TextLabel.Text = "Would you like to change your race to "..script.Parent.HouseName.Value.."?"