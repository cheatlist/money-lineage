script.Parent.Frame.Join.MouseButton1Click:Connect(function()
	if script.Parent.HouseName.Value~=""then
		script.RemoteEvent:FireServer()
		script.Parent:Destroy()
	end
end)
repeat wait()until script.Parent.HouseName.Value~=""
script.Parent.Frame.TextLabel.Text = "Would you like to join house "..script.Parent.HouseName.Value.."?"