return {
	getID = function(p1)
		local v1 = p1:FindFirstChild("ID")
		if not v1 then
			local v3, v4 = game.CollectionService:GetTags(p1)
			while true do
				local v5, v6 = next(v3, v4)
				if not v5 then
					break
				end
				v4 = v5
				local v7 = v6:match("ID:(%S+)")
				if v7 then
					return v7
				end			
			end
		end
		return v1 and v1.Value
	end
}
