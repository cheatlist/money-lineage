local v1 = {}
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true
	end
	if l__Parent__1:FindFirstChild("Charge") then
		return true
	end
	if l__Parent__1:FindFirstChild("Stun") then
		return true
	end
	if l__Parent__1:FindFirstChild("ReturnStun") then
		return true
	end
	if l__Parent__1:FindFirstChild("Action") then
		return true
	end
	if l__Parent__1:FindFirstChild("Blocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("SpellBlocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("ActiveCast") then
		return true
	end
	if l__Parent__1:FindFirstChild("Unconscious")then
		return true
	end
	if l__Parent__1:FindFirstChild("Knocked")then
	else
		return
	end
	return true
end
local v3 = tick()
local l__TweenService__4 = game:GetService("TweenService")
function buffCheck(p1)
	if l__Parent__1:FindFirstChild("SigilBuff") then
		l__Parent__1.SigilBuff:Destroy()
	end
	for i,v in pairs(p1:GetChildren()) do
		if v.Name == "SigilPtcl" or v.Name == "SigilPartEffect" or v.Name == "SigilSound" or v.Name == "SigilLight" then
			v:Destroy()
		end
	end
end
local u2 = true
local l__TweenService__3 = game:GetService("TweenService")
local u4 = require(game.ServerScriptService.Modules.HitDetection)
function v1.Active(p2, p3, p4, p5)
	if ActionCheck() then
		return
	end
	if game.CollectionService:HasTag(p2, "Knocked") then
		return
	end
	if p2.Cooldowns:FindFirstChild("Dark Eruption") then
		return
	end
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	local cursedflame = false
	if playerdata.Skills.Value:find("TheCursedFlame") then
		cursedflame = true
	end
	if p2:FindFirstChild("SigilBuff") and (p2:FindFirstChild("SigilBuff").Value == "BlackFlame" or p2:FindFirstChild("SigilBuff").Value == "CursedFlame") then
		local CD = Instance.new("NumberValue")
		CD.Name = "Dark Eruption"
		CD.Value = 15
		CD.Parent = p2.Cooldowns
		game.Debris:AddItem(CD, 15)
		local l__HumanoidRootPart__5 = p2.HumanoidRootPart
		local l__Humanoid__6 = p2.Humanoid
		p2.Humanoid:LoadAnimation(script.Parent.iceA):Play()
		local v7 = Instance.new("Accessory")
		v7.Name = "HeavyAttack"
		v7.Parent = p2
		game:GetService("Debris"):AddItem(v7, 1)
		local v8 = Instance.new("Accessory")
		v8.Name = "NoJump"
		v8.Parent = p2
		game:GetService("Debris"):AddItem(v8, 1)
		local v9 = Instance.new("Accessory")
		v9.Name = "Action"
		v9.Parent = p2
		game:GetService("Debris"):AddItem(v9, 1.2)
		wait(0.5)
		local amount = 4
		if cursedflame == true then
			amount = 5
		end
		for v10 = 1, amount do
			local v11, v12, v13 = workspace:FindPartOnRayWithIgnoreList(Ray.new((p2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -17 * v10)).p, Vector3.new(0, -50, 0)), { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns })
			if v11 then
				local v14 = game.ServerStorage.Assets.DarkPyre:Clone()
				if cursedflame == true then
					v14 = game.ServerStorage.Assets.CursedPyre:Clone()
				end
				game:GetService("Debris"):AddItem(v14, 4)
				local HitRingSize = v14.HitRing.SlashRing.Size
				local SlashRingSize = v14.HitRing.SlashRing.Size
				v14:SetPrimaryPartCFrame(CFrame.new(v12))
				v14.HitRing.Size = Vector3.new(0, 0, 0)
				v14.HitRing.SlashRing.Size = Vector3.new(0, 0, 0)
				v14.Parent = game.Workspace.Thrown
				l__TweenService__3:Create(v14.HitRing, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = HitRingSize,
					Transparency = 0,
				}):Play()
				l__TweenService__3:Create(v14.HitRing.SlashRing, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = SlashRingSize,
					Transparency = 0,
				}):Play()
				local firecolor = Color3.fromRGB(0,0,0)
				local damageactual = 15
				if cursedflame == true then
					firecolor = Color3.fromRGB(0, 255, 0)
					damageactual = 20
				end
				spawn(function()
					wait(0.5)
					v14.HitRing.Hit:Play()
					u4.magnitudeCheck(p2, Vector3.new(v12.X, v12.Y, v12.Z), 20, {
						mana = true,
						damage = damageactual,
						nododge = true,
						manaknockupself = true,
						downbypass = true,
						antimanaburn = true,
						wraithfire = true,
						monkbreaker = true,
						damageazael = true,
						burncolor = firecolor,
						move = "Dark Eruption"
					}, false, false)
					for v15, v16 in pairs(v14.HitRing.Attachment:GetChildren()) do
						if v16:IsA("ParticleEmitter") then
							v16.Enabled = true
						end
					end
					wait(0.75)
					for v17, v18 in pairs(v14.HitRing.Attachment:GetChildren()) do
						if v18:IsA("ParticleEmitter") then
							v18.Enabled = false
						end
					end
					l__TweenService__3:Create(v14.HitRing, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, 0), 
						Transparency = 1
					}):Play()
					l__TweenService__3:Create(v14.HitRing.SlashRing, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, 0), 
						Transparency = 1
					}):Play()
				end)
			end
			wait(0.25)
		end
		wait(15)
		u2 = true
	end
end
return v1