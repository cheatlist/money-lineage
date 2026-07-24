local char = script.Parent

local hidden = {}

function hide(obj)
	if obj:IsA("BasePart") or obj:IsA("Decal") then
		if obj.Transparency == 1 or hidden[obj] then return end
		
		local tsp = obj.Transparency
		
		obj.Transparency = 1
		
		hidden[obj] = tsp
	end
end

function hideLive()
	for e,c in pairs(game.Workspace.Live:GetChildren()) do
		if (c.HumanoidRootPart.Position-char.HumanoidRootPart.Position).magnitude <= 60 and c~=char then
			for i,v in pairs(c:GetChildren()) do
				if v:FindFirstChild("FakeHumanoid") and v:FindFirstChild("Head") then
					hide(v.Head)
							
					for j,k in pairs(v.Head:GetChildren()) do
						if k:IsA("Decal") then
							hide(k)
						end
					end
				end
				
				if v:IsA("BasePart") then
					if v.Name == v.Parent.Name then
						hide(v)
					end
					
					if v.Name == "Head" then
						for e,c in pairs(v:GetChildren()) do
							if c:IsA("Decal") then
								hide(c)
							end
						end
					end
					
					if v.Name == "Torso" then
						for e,c in pairs(v:GetChildren()) do
							if c:IsA("Part") or c:IsA("UnionOperation") then
								hide(c)
							end
							if c:IsA("Decal") then
								hide(c)
							end
						end
					end
					
					if v.Name == "Hilt" or v.Name == "TomeHilt" then
						for g,h in pairs(v:GetChildren()) do
							if h:IsA("Part") or h:IsA("BasePart") then
								hide(h)
							elseif h:IsA("Model") then
								for g,m in pairs(h:GetChildren()) do
									if (m:IsA("Part") or m:IsA("BasePart")) and m.Transparency ~= 1 then
										hide(m)
									end
								end
							end
						end
					end
					
					if v.Name ~= "Hilt" and v.Name ~= "TomeHilt" and not game.CollectionService:HasTag(v,"FakeHead") and v.Name ~= "HumanoidRootPart" then
						hide(v)
					end
				end
				
				if v:IsA("Accessory") and v:FindFirstChild("Handle") then
					hide(v.Handle)
				end
			end
		end
	end
end

spawn(function()
	for e,c in pairs(game.Workspace.NPCs:GetChildren()) do
		if c:IsA("Model") then
			if (c.HumanoidRootPart.Position-char.HumanoidRootPart.Position).magnitude <= 60 and c~=char then
				for i,v in pairs(c:GetChildren()) do
					if v:IsA("Part") or v:IsA("BasePart") then
						if v.Name == "Head" then
							for e,c in pairs(v:GetChildren()) do
								if c:IsA("Decal") then
									hide(c)
								end
							end
						end
						
						if v.Name == "Hilt" or v.Name == "TomeHilt" then
							for g,h in pairs(v:GetChildren()) do
								if h:IsA("Part") or h:IsA("BasePart") then
									h.Transparency = 1
									hide(h)
								elseif h:IsA("Model") then
									for g,m in pairs(h:GetChildren()) do
										if (m:IsA("Part") or m:IsA("BasePart")) and m.Transparency ~= 1 then
											hide(m)
										end
									end
								end
							end
						end
						
						if v.Name ~= "Hilt" and v.Name ~= "TomeHilt" and not game.CollectionService:HasTag(v,"FakeHead") and v.Name ~= "HumanoidRootPart" then
							hide(v)
						end
					end
					
					if v:IsA("Accessory") and v:FindFirstChild("Handle") then
						hide(v.Handle)
					end
				end
			end
		end
	end
end)

spawn(function()
	hideLive()
end)

local timeel = 0
repeat
	timeel = timeel+wait()
until timeel >= 15 or char:FindFirstChild("Stun")

for obj,tsp in next,hidden do
	pcall(function()
		obj.Transparency = tsp
	end)
end

script:Destroy()

