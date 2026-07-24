local module = {}

function sub(...)
	coroutine.wrap(...)()
end


function module.Active(p2,v4)
	if game.CollectionService:HasTag(p2,"Casting")or p2:FindFirstChild("ActiveCast")then
		return
	end

	if not script.Parent.Whitelist:FindFirstChild(v4.Name) then
		return
	end
	
	local v6 = {workspace.Live, workspace.AreaMarkers, workspace.Thrown, workspace.Terrain}
	local v7 = game.Lighting:GetSunDirection()
	local v8 = not workspace:FindPartOnRayWithIgnoreList(Ray.new(p2.HumanoidRootPart.Position, v7 * 2000), v6) and not workspace:FindPartOnRayWithIgnoreList(Ray.new(p2.HumanoidRootPart.Position + v7 * 500, v7 * -500), v6)
	p2.HumanoidRootPart.ShadowBlast:Play()
	local v9 = 0
	p2.HumanoidRootPart.ShadowEmitter2:Emit(100)
	for v10, v11 in pairs(workspace.Live:GetChildren()) do
		if (v11.Torso.Position - p2.Torso.Position).Magnitude <= 150 and v11 ~= p2 then
			for v12 = 1, 1 do
				local v13 = Instance.new("Attachment")
				v13.Name = "DarkAttachment"
				v13.Parent = p2.HumanoidRootPart
				v13.Position = v13.Position - Vector3.new(0, 3, 0)
				local v14 = game.ServerStorage.Assets.ShadowBeam:Clone()
				v14.Parent = workspace.Thrown
				v14.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, -3, -3)
				v14.Beam.Attachment0 = v14.Attachment
				v14.Beam.Attachment1 = v13
				local v15 = Instance.new("BodyVelocity")
				game.CollectionService:AddTag(v15, "AllowedBM")
				v15.MaxForce = Vector3.new(900000, 900000, 900000)
				v15.P = 5000
				v15.Velocity = v14.CFrame.lookVector * 70
				v15.Parent = v14
				pcall(function()
					v14:SetNetworkOwner(v4)
				end)
				game.Debris:AddItem(v14, 15)
				v14.Touched:Connect(function(p5)
					if v14.Anchored then
						return
					end
					if not p5.Parent then
						return
					end
					local v16 = p5.Parent:FindFirstChild("Humanoid") or p5.Parent.Parent:FindFirstChild("Humanoid")
					if not v16 or v16 == p2.Humanoid then
						return
					end
					
					if v16.Parent == p2 then
						return
					end
					local v17 = {workspace.Live, workspace.AreaMarkers, workspace.Thrown, workspace.Terrain}
					local v18 = game.Lighting:GetSunDirection()
					local v19 = not workspace:FindPartOnRayWithIgnoreList(Ray.new(v11.HumanoidRootPart.Position, v18 * 2000), v17) and not workspace:FindPartOnRayWithIgnoreList(Ray.new(p2.HumanoidRootPart.Position + v18 * 500, v18 * -500), v17)
					
					v11.HumanoidRootPart.ShadowEmitter:Emit(50)
					v14.Anchored = true
					v14.CFrame = p5.CFrame
					
					local v20 = Instance.new("Attachment")
					v20.Parent = v11.HumanoidRootPart
					v14.Beam.Attachment0 = v13
					v14.Beam.Attachment1 = v20
					
					game.ServerStorage.Requests.TagHumanoid:Fire(p2, v11,{
						mana = true, 
						manabreaker = true, 
						--manaknockup = true,
						curse = true, 
						curseeffect = true,
						injury = "leg",
						damage = 10, 
						dam = 10, 
						tendril = true,
						torture = true,
						move = "Shadow Tendrils"
					})
					
					local TendrilVelocity = Instance.new("BodyVelocity")
					game.CollectionService:AddTag(TendrilVelocity,"AllowedBM")
					TendrilVelocity.MaxForce = Vector3.new(0, math.huge, 0)
					TendrilVelocity.Velocity = Vector3.new(0, 150, 0)
					TendrilVelocity.Parent = v11.HumanoidRootPart
					
					task.delay(0.4, function()
						if TendrilVelocity and TendrilVelocity.Parent then
							TendrilVelocity:Destroy()
							TendrilVelocity = nil
						end
						
						local TendrilVelocity = Instance.new("BodyVelocity")
						game.CollectionService:AddTag(TendrilVelocity,"AllowedBM")
						TendrilVelocity.MaxForce = Vector3.new(0, math.huge, 0)
						TendrilVelocity.Velocity = Vector3.new(0, -150, 0)
						TendrilVelocity.Parent = v11.HumanoidRootPart
						
						game.Debris:AddItem(TendrilVelocity,0.4)
						task.wait(0.4)
						v11.HumanoidRootPart.breaker:Play()
						pcall(function()
							local Ragdoll = Instance.new("Accessory")
							Ragdoll.Name = "Knocked"
							Ragdoll.Parent = v11
							game:GetService("Debris"):AddItem(Ragdoll,2)
						end)
						if v11:FindFirstChild("Knocked") then
							p2.Humanoid.Health += 25
						end
					end)
					
					if v11:FindFirstChild("Blocking") then
						game:GetService("Debris"):AddItem(v14, 1)
					end
					game:GetService("Debris"):AddItem(v14, 6)
				end)
				local u5 = v9
				sub(function()
					while true do
						if v11 then
							v15.Velocity = v15.Velocity:Lerp(CFrame.new(v14.Position, v11.Torso.Position).LookVector * 70, 0.75)
						end
						u5 = u5 + wait()
						if not v14 then
							break
						end
						if not v14.Parent then
							break
						end
						if u5 >= 15 then
							break
						end
						if v14.Anchored then
							break
						end						
					end
					if u5 >= 15 and v14 then
						v14:Destroy()
					end
				end)
			end
		end
	end
end
return module