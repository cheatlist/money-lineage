local v1 = false
script.Parent.Frame.CreateButton.MouseButton1Click:Connect(function()
	if not v1 then
		v1 = true
		local result = game.ReplicatedStorage.Requests.CreateHouse:InvokeServer(script.Parent.Frame.TextBox.Text)
		script.Parent.Frame.TextBox.PlaceholderText = tostring(result)
		script.Parent.Frame.TextBox.Text = ""
		v1 = false
		if result == "made house"then
			script.Parent:Destroy()
		end
	end
end)