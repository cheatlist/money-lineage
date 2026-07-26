	local u3 = require(game.ServerScriptService.Modules.HitDetection)
	local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
	local function ActionCheck(Parent)
		return ActionCheckModule(Parent, {
			presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		})
	end

	-- TheBlade path: a quick spin around a tight circle (circumference 12 studs), reusing the same
	-- Shadowrush aerial-variant animation Ethereal Strike's Blade branch already reuses
	-- (game.ServerStorage.Classes.Shadowrush.Animation3), ticking damage every step like that move's
	-- aerial spin loop does (no per-target hit cap, just repeated magnitudeCheck ticks).
	local RADIUS = 85 / (2 * math.pi)
	local DURATION = 0.3
	local TICK = 0.05
	local RANGE = 6

	script.Parent.Activated:Connect(function()
		local p1 = script.Parent.Parent
		if ActionCheck(p1) then
			return
		end
		if p1.Cooldowns:FindFirstChild("Spite") then
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Spite"
		CD.Value = 17
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 17)

		local HumanoidRootPart = p1.HumanoidRootPart
		local anim = p1.Humanoid:LoadAnimation(script.Parent.Animation3)
		anim:Play()
		HumanoidRootPart.DaggerCharge:Play()

		local origin = HumanoidRootPart.Position
		local right = HumanoidRootPart.CFrame.RightVector
		local forward = HumanoidRootPart.CFrame.LookVector
		local pkt = {
			physical = true,
			dagger = true,
			slash = true,
			damage = 5,
			blockbreak = true,
			noparry = true,
			nobackstab = true,
			move = "Spite",
		}

		local elapsed = 0
	while elapsed < DURATION do
			anim:Play()
			local angle = (elapsed / DURATION) * (2 * math.pi)
			local offset = right * (RADIUS * math.cos(angle)) + forward * (RADIUS * math.sin(angle))
			local tangent = (-right * math.sin(angle) + forward * math.cos(angle)).Unit
			local newPos = origin + offset
			HumanoidRootPart.CFrame = CFrame.new(newPos, newPos + tangent)
			u3.magnitudeCheck(p1, HumanoidRootPart.Position, RANGE, pkt, false)
			task.wait(TICK)
			elapsed += TICK
		end
	end)
