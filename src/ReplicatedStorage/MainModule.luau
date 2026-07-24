local module = {}

function module.return_instance(string)
	for _, v in pairs(game:GetDescendants()) do
		if tostring(v) == string then
			return v
		end
	end
	return nil
end

return module