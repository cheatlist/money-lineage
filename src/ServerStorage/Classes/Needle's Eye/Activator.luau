local v2 = {}
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local v3 = tick()
local l__TweenService__4 = game:GetService("TweenService")
local u2 = true
local function u3(p1, p2)
	local v5 = p1.Origin - p2
	local l__Direction__6 = p1.Direction
	return p2 + (v5 - v5:Dot(l__Direction__6) / l__Direction__6:Dot(l__Direction__6) * l__Direction__6)
end
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid
function v2.Active(p3, p4, p5, p6)
	if ActionCheck() then
		return
	end
	if p3:FindFirstChild("Knocked")then
		return true
	end
	if p3.Cooldowns:FindFirstChild("Needle's Eye") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Needle's Eye"
	CD.Value = 10
	CD.Parent = p3.Cooldowns
	game.Debris:AddItem(CD, 10)
	local l__HumanoidRootPart__7 = p3.HumanoidRootPart
	local v8 = Instance.new("Accessory")
	v8.Name = "Action"
	Instance.new("Folder", v8).Name = "NoDelete"
	v8.Parent = p3
	u2 = false
	local v9 = p3.Humanoid:LoadAnimation(script.Parent:FindFirstChild("Animation"))
	v9:Play()
	task.wait(0.4)
	if not p3:FindFirstChild("Stun") and not game.CollectionService:HasTag(p3, "Knocked") then
		local v10 = Instance.new("Accessory")
		v10.Name = "WalkThrough"
		v10.Parent = p3
		game.Debris:AddItem(v10, 0.5)
		for _,v15 in pairs(p3:GetChildren())do
			if v15:IsA("BasePart") and v15.Name ~= "HumanoidRootPart" and not v15.Anchored then
				pcall(function()
					game.PhysicsService:SetPartCollisionGroup(v15, "WalkThrough")
				end)
			end		
		end
		task.wait(0.1)
		local l__Position__16 = l__HumanoidRootPart__7.Position
		p3.HumanoidRootPart.OwlSlash:Play()
		local v17 = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(v17, "AllowedBM")
		v17.MaxForce = Vector3.new(80000, 0, 80000)
		v17.P = 2000
		v17.Velocity = l__HumanoidRootPart__7.CFrame.lookVector * 150
		v17.Parent = p3.HumanoidRootPart
		game.Debris:AddItem(v17, 0.2)
		task.wait(0.25)
		local l__Position__18 = l__HumanoidRootPart__7.Position
		local l__magnitude__19 = (l__Position__16 - l__Position__18).magnitude
		local v20 = CFrame.new(l__Position__16, l__Position__18)
		local v21 = v20 - v20.p
		local v22 = Ray.new(l__Position__18, v20.LookVector * l__magnitude__19)
		local v23 = {
			physical = true,
			damage = 7, 
			sword = true, 
			slash = true, 
			noenchant = true,
			move = "Needle's Eye"
		}
		for _,v28 in pairs(workspace.Live:GetChildren())do
			local l__HumanoidRootPart__29 = v28:FindFirstChild("HumanoidRootPart")
			if l__HumanoidRootPart__29 and v28:FindFirstChild("Humanoid") and v28 ~= p3 and ((l__HumanoidRootPart__29.Position - l__Position__18).magnitude < 14 or (u3(v22, l__HumanoidRootPart__29.Position) - l__HumanoidRootPart__29.Position).magnitude < 14 and (l__HumanoidRootPart__29.Position - l__Position__16).magnitude < l__magnitude__19 + 15) then
				spawn(function()
					for v30 = 1, 4 do
						local v31 = script.SlashLine:clone()
						v31.CFrame = CFrame.new(l__HumanoidRootPart__29.Position + Vector3.new(math.random(-10, 10) / 10, math.random(-10, 10) / 10, math.random(-10, 10) / 10)) * v21
						v31.Parent = workspace.Thrown
						game.Debris:AddItem(v31, 0.5)
						game.TweenService:Create(v31, TweenInfo.new(0.2), {
							Transparency = 1
						}):Play()
						game.TweenService:Create(v31.Mesh, TweenInfo.new(0.2), {
							Scale = Vector3.new(1, 1, 5)
						}):Play()
						l__TagHumanoid__4:Fire(p3, v28, v23)
						task.wait(0.1)
					end
				end)
			end		
		end
	else
		v9:Stop()
	end
	game:GetService("Debris"):AddItem(v8, 0.25)
	task.wait(10)
	u2 = true
end
return v2