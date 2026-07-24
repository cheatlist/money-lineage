script.Parent.MouseButton1Click:Connect(function()
	for i,v in pairs(game:GetDescendants()) do
		pcall(function()
			if v.Name ~= "Orb" and v.Name ~= "OrderField" then
				v.Material = Enum.Material.Plastic
			end
		end)
	end
	script.Parent.Parent.Parent:Destroy()
end)