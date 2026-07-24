local module = {}
local ts = game:GetService("TweenService")

function ActionCheck(Parent)
	if Parent:FindFirstChild("EquipWarmup") then
		warn("A")
		return true
	end
	if Parent:FindFirstChild("Stun") then
		warn("B")
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		warn("C")
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		warn("D")
		return true
	end
	if Parent:FindFirstChild("Action") then
		warn("E")
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		warn("F")
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
		warn("G")
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		warn("H")
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		warn("I")
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		warn("J")
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return false
end

module.Active2 = function(c, p, _, _)
	if game.CollectionService:HasTag(c,"BARDCD") then
		return
	end
	if not c:FindFirstChild("BardCombo") then
		return
	end
	if ActionCheck(c) then
		return
	end
		local AOE = Instance.new("Part")
		AOE.Parent = workspace
		AOE.CFrame = c.HumanoidRootPart.CFrame
		AOE.Shape = "Ball"
		AOE.Anchored = true
		AOE.CanCollide = false
		AOE.CanTouch = false
		AOE.Transparency = 0.7
		AOE.Color = Color3.new(0.388235, 0.898039, 1)
		AOE.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		AOE.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
		ts:Create(AOE, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = AOE.Size + Vector3.new(30,30,30)}):Play()
		ts:Create(AOE, TweenInfo.new(0.20, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 1}):Play()
		game:GetService("Debris"):AddItem(AOE, 3)
		
		local s = script.aoesfx:Clone()
		s.Parent = c.HumanoidRootPart
		s:Play()
		game:GetService("Debris"):AddItem(s, 2)
		game.CollectionService:AddTag(c,"BARDCD")
		for _, v in next, workspace.Live:GetChildren() do
			if (v.HumanoidRootPart.Position - c.HumanoidRootPart.Position).Magnitude <= 30 and v ~= c then
				game.ServerStorage.Requests.TagHumanoid:Fire(c, v, {damage = 15, bypassblock = true, knockback = true, mana = true, bardragdoll = true, noenchant = true, disarm = true,})
			end
		end
		c:FindFirstChild("BardCombo").Value = 0
		task.wait(35)
		game.CollectionService:RemoveTag(c,"BARDCD")

end

return module
