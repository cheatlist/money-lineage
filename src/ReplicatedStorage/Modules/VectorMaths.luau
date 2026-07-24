return {
	getClosestPosition = function(p1, p2, p3, p4)
		local v1 = p4 or CFrame.new()
		local v2 = (p2.CFrame * v1):pointToObjectSpace(p3)
		local v3 = p2.Size / 2
		local v4 = Vector3.new(math.clamp(v2.X, -v3.X, v3.X), math.clamp(v2.Y, -v3.Y, v3.Y), math.clamp(v2.Z, -v3.Z, v3.Z))
		local v5 = Vector3.new(math.abs(v4.X) == v3.X and math.sign(v4.X) or 0, math.abs(v4.Y) == v3.Y and math.sign(v4.Y) or 0, math.abs(v4.Z) == v3.Z and math.sign(v4.Z) or 0)
		local v6
		if v5.magnitude == 0 then
			v6 = Vector3.new(0, 1, 0)
		else
			v6 = v5.unit
		end
		return p2.CFrame * v1 * v4, (p2.CFrame * v1):vectorToWorldSpace(v6)
	end
}
