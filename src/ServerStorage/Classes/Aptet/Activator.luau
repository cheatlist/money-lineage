local v1 = {} 
function sub(...)
	coroutine.wrap(...)() 
end 
v1.upperbound = 0 
v1.lowerbound = 0 
v1.signs = 0 
v1.cost = 2 
local l__TweenService__1 = game:GetService("TweenService") 
function desummonEffect(p1)
	local l__WeaponTake__2 = game.ServerStorage.SpellEffects.WeaponTake 
	local v3 = l__WeaponTake__2.summon:Clone() 
	v3.Parent = p1 
	v3:play() 
	local v4 = l__WeaponTake__2.Glow:Clone() 
	v4.Parent = p1 
	v4.Range = 0 
	local v5 = TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) 
	local v6 = l__TweenService__1:Create(p1, v5, {
		Color = Color3.fromRGB(245, 205, 48), 
		Transparency = 0.4
	}):Play() 
	local v7 = l__TweenService__1:Create(v4, v5, {
		Range = 6
	}):Play() 
	wait(0.8) 
	local v8 = l__WeaponTake__2.LightCube:Clone() 
	game.Debris:AddItem(v8, 3.5) 
	v8.Transparency = 1 
	v8:ClearAllChildren() 
	v8.CFrame = p1.CFrame 
	v8.Parent = game.Workspace 
	local v9 = l__WeaponTake__2.breakweapon:Clone() 
	v9.Parent = v8 
	v9:Play() 
	local v10 = 1 - 1 
	while true do
		local v11 = l__WeaponTake__2.LightCube:Clone() 
		game.Debris:AddItem(v11, 3) 
		local v12 = p1.Size.X / 2 
		local v13 = p1.Size.Y / 2 
		local v14 = p1.Size.Z / 2 
		v11.CFrame = p1.CFrame * CFrame.new(math.random(-v12, v12), math.random(-v13, v13), math.random(-v14, v14)) 
		v11.Parent = game.Workspace 
		local v15 = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) 
		local v16 = l__TweenService__1:Create(v11, v15, {
			CFrame = CFrame.new(p1.CFrame.X, p1.CFrame.Y, p1.CFrame.Z) * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)), 
			Transparency = 1
		}):Play() 
		local v17 = l__TweenService__1:Create(v11.PointLight, v15, {
			Range = 0
		}):Play() 
		if 0 <= 1 then
			if v10 < 8 then

			else
				break 
			end 
		elseif 8 < v10 then

		else
			break 
		end 
		v10 = v10 + 1 	
	end 
	p1:Destroy() 
end 
local l__WeaponWithdraw__2 = game.ServerStorage.SpellEffects.WeaponWithdraw 
function v1.Activate(p2, p3, p4, p5)

	if game.CollectionService:HasTag(p3, "Casting") then
		return 
	end 
	local v18 = game.Players:GetPlayerFromCharacter(p3) 
	local v19 = v18 and game.ServerStorage.PlayerData:FindFirstChild(v18.Name) 
	local l__SpecMeta__20 = game.ServerStorage.PlayerData[v18.Name].SpecMeta 
	local v21 = v19 and v18.Backpack.ManaColor.Value
	local v22 = v21 and v18:FindFirstChild("GetWeaponSelection") 
	if not v22 then
		return 
	end 
	if not v21 or not p3:FindFirstChild("HumanoidRootPart") then
		return 
	end 
	if p3.Mana.Value < v1.cost then
		return 
	end 
	if game.ServerStorage.PlayerData[v18.Name].PrimaryWeapon.Value ~= "" then
		return 
	end 
	local v23 = v22:InvokeClient(v18) 
	if not v23 then
		return 
	end 
	local v24 = game:GetService("HttpService"):JSONDecode(l__SpecMeta__20.Value) 
	if v24[v23] < 1 then
		return 
	end 
	if v24[v23] == 1 then
		v24[v23] = nil
		l__SpecMeta__20.Value = game:GetService("HttpService"):JSONEncode(v24) 
	elseif v24[v23] > 1 then
		v24[v23] = v24[v23] - 1 
		l__SpecMeta__20.Value = game:GetService("HttpService"):JSONEncode(v24) 
	end 
	local v25 = Instance.new("Folder") 
	v25.Name = "Action" 
	v25.Parent = p3 
	game.Debris:AddItem(v25, 2) 
	p3.Humanoid.AutoRotate = false 
	local v26 = p3.Humanoid:LoadAnimation(script.AptetAnim) 
	v26:Play() 
	wait(0.15) 
	local v27 = l__WeaponWithdraw__2.summon:Clone() 
	game.Debris:AddItem(v27, 3) 
	v27.Parent = p3.Torso 
	v27:Play() 
	if v24[v23] > 0 then
		v24[v23] = v24[v23] - 1 
		l__SpecMeta__20.Value = game:GetService("HttpService"):JSONEncode(v24) 
		game.ServerStorage.PlayerData[v18.Name].PrimaryWeapon.Value = v23 
	end 
	script.Parent.Parent = v18.Backpack 
	wait(0.1) 
	local l__next__28 = next 
	local v29, v30 = v18.Backpack:GetChildren() 
	while true do
		local v31, v32 = l__next__28(v29, v30) 
		if not v31 then
			break 
		end 
		v30 = v31 
		if v32:FindFirstChild("PrimaryWeapon") then
			v32.Parent = p3 
		end 	
	end 
	wait(0.1) 
	local l__next__33 = next 
	local v34, v35 = p3.Hilt:GetChildren() 
	while true do
		local v36, v37 = l__next__33(v34, v35) 
		if not v36 then
			break 
		end 
		v35 = v36 
		if v37:FindFirstChild("Prop") then
			v37.Transparency = 1 
		end 	
	end 
	local v38 = game.ServerStorage.verto:FindFirstChild(v23) 
	local v39 = v38.Size.X 
	if v39 < v38.Size.Y then
		v39 = v38.Size.Y 
	end 
	if v39 < v38.Size.Z then
		v39 = v38.Size.Z 
	end 
	local v40 = {} 
	local v41 = math.floor(math.floor(v39) / 0.4) 
	local v42 = p3["Right Arm"].CFrame * CFrame.new(0, -1.2, 0) 
	for v43 = 1, v41 do
		local v44 = l__WeaponWithdraw__2.LightCube:Clone() 
		game.Debris:AddItem(v44, 2.5) 
		table.insert(v40, v44) 
		v44.Transparency = 1 
		local v45 = CFrame.new(p3["Right Arm"].CFrame.X, p3["Right Arm"].CFrame.Y, p3["Right Arm"].CFrame.Z) 
		v44.CFrame = v45 * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)) 
		v44.Parent = game.Workspace 
		local v46 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) 
		local v47 = v42 * CFrame.new(math.random(-14, 14) / 100, -0.4 * v43 + 0.4, math.random(-2, 2) / 100) 
		local v48 = l__TweenService__1:Create(v44, v46, {
			CFrame = v47, 
			Transparency = 0.6
		}):Play() 
		if v43 < v41 / 3 or math.random(1, 2) == 1 and v43 < v41 / 1.2 then
			local v49 = l__WeaponWithdraw__2.LightCube:Clone() 
			game.Debris:AddItem(v49, 2.5) 
			table.insert(v40, v49) 
			v49.Parent = game.Workspace 
			v49.CFrame = v45 * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)) 
			local v50 = l__TweenService__1:Create(v49, v46, {
				CFrame = v47 * CFrame.new(-0.30000000000000004, 0, math.random(-2, 2) / 100), 
				Transparency = 0.6
			}):Play() 
		end 
		wait(0.015) 
	end 
	wait(0.3) 
	for v51 = 1, #v40 do
		local v52 = l__TweenService__1:Create(v40[v51], TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play() 
	end 
	wait(0.1) 
	local v53 = nil 
	local v54 = nil 
	local l__next__55 = next 
	local v56, v57 = p3.Hilt:GetChildren() 
	while true do
		local v58, v59 = l__next__55(v56, v57) 
		if not v58 then
			break 
		end 
		v57 = v58 
		if v59:FindFirstChild("Prop") then
			v59.Transparency = 0.4 
			v53 = v59.Color 
			v59.BrickColor = BrickColor.new("Bright yellow") 
			v59.Color = Color3.fromRGB(245, 205, 48) 
			v54 = v59 
		end 	
	end 
	for v60 = 1, #v40 do
		local v61 = l__TweenService__1:Create(v40[v60], TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play() 
		wait(0.005) 
	end 
	if v54 ~= nil then
		local v62 = l__TweenService__1:Create(v54, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Color = v53, 
			Transparency = 0
		}):Play() 
	end 
	wait(0.15) 
	p3.Humanoid.AutoRotate = true 
	v26:Stop() 
end 
local u3 = {
	upperbound = 0, 
	lowerbound = 0, 
	signs = 2, 
	cost = 40, 
	Activate = function(p6, p7, p8, p9)
		if game.CollectionService:HasTag(p7, "Casting") then
			return 
		end 
		local v63 = game.Players:GetPlayerFromCharacter(p7) 
		local v64 = v63 and game.ServerStorage.PlayerData:FindFirstChild(v63.Name) 
		local l__SpecMeta__65 = game.ServerStorage.PlayerData[v63.Name].SpecMeta 
		local v66 = v64 and v63.Backpack.ManaColor.Value
		local v67 = v66 and v63:FindFirstChild("GetWeaponSelection") 
		if not v67 then
			return 
		end 
		local v68 = v66 and p7:FindFirstChild("HumanoidRootPart") 
		if not v68 then
			return 
		end 
		local v69 = v67:InvokeClient(v63) 
		if not v69 then
			return 
		end 
		local v70 = game:GetService("HttpService"):JSONDecode(l__SpecMeta__65.Value) 
		if v70[v69] == 0 then
			return 
		end 
		if v70[v69] == 0 then
			v70[v69] = nil
			l__SpecMeta__65.Value = game:GetService("HttpService"):JSONEncode(v70) 
		elseif v70[v69] > 1 then
			v70[v69] = v70[v69] - 1 
			l__SpecMeta__65.Value = game:GetService("HttpService"):JSONEncode(v70) 
		end 
		local v71 = game.ServerStorage.verto:FindFirstChild(v69):Clone() 
		game.Debris:AddItem(v71, 60) 
		local v72 = v71.Size.X 
		if v72 < v71.Size.Y then
			v72 = v71.Size.Y 
		end 
		if v72 < v71.Size.Z then
			v72 = v71.Size.Z 
		end 
		local v73 = l__WeaponWithdraw__2.soundpt:Clone() 
		game.Debris:AddItem(v73, 3) 
		v73.CFrame = v68.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(math.rad(180), 0, 0) 
		v73.Parent = game.Workspace 
		v73.summon:Play() 
		local v74 = {} 
		local v75 = math.floor(math.floor(v72) / 0.4) 
		local l__CFrame__76 = v73.CFrame 
		for v77 = 1, v75 do
			local v78 = l__WeaponWithdraw__2.LightCube:Clone() 
			game.Debris:AddItem(v78, 3) 
			table.insert(v74, v78) 
			v78.Transparency = 1 
			local v79 = CFrame.new(v73.CFrame.X, v73.CFrame.Y, v73.CFrame.Z) 
			v78.CFrame = v79 * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)) 
			v78.Parent = game.Workspace 
			local v80 = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) 
			local v81 = l__CFrame__76 * CFrame.new(math.random(-14, 14) / 100, -0.4 * v77 + 0.4, math.random(-2, 2) / 100) 
			local v82 = l__TweenService__1:Create(v78, v80, {
				CFrame = v81, 
				Transparency = 0.6
			}):Play() 
			if v77 < v75 / 3 or math.random(1, 2) == 1 and v77 < v75 / 1.2 then
				local v83 = l__WeaponWithdraw__2.LightCube:Clone() 
				game.Debris:AddItem(v83, 3) 
				table.insert(v74, v83) 
				v83.Parent = game.Workspace 
				v83.CFrame = v79 * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)) 
				local v84 = l__TweenService__1:Create(v83, v80, {
					CFrame = v81 * CFrame.new(-0.30000000000000004, 0, math.random(-2, 2) / 100), 
					Transparency = 0.6
				}):Play() 
			end 
			wait(0.04) 
		end 
		wait(0.8) 
		for v85 = 1, #v74 do
			local v86 = l__TweenService__1:Create(v74[v85], TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Transparency = 0
			}):Play() 
		end 
		wait(0.25) 
		v71:ClearAllChildren() 
		v71.Anchored = true 
		v71.CanCollide = false 
		v71.CFrame = v73.CFrame * CFrame.new(0, -(v72 / 2), 0) * CFrame.Angles(0, math.rad(90), math.rad(-90)) 
		v71.Transparency = 0.4 
		v71.BrickColor = BrickColor.new("Bright yellow") 
		v71.Parent = game.Workspace 
		for v87 = 1, #v74 do
			local v88 = l__TweenService__1:Create(v74[v87], TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play() 
			wait(0.03) 
		end 
		local v89 = l__TweenService__1:Create(v71, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Color = v71.Color, 
			Transparency = 0
		}):Play() 
		wait(0.3) 
		v71.CanCollide = true 
		v71.Anchored = false 
		v71:SetNetworkOwner(nil)
		local v90 = Instance.new("ClickDetector") 
		v90.MaxActivationDistance = 10 
		v90.Name = "PickUp" 
		v90.Parent = v71 
		local u4 = true 
		v90.MouseClick:connect(function(p10)
			local v91 = game.ServerStorage.PlayerData:FindFirstChild(p10.Name) 
			if not v91 then
				return 
			end 
			if not u4 then
				return 
			end 
			u4 = false 
			game.ServerStorage.PlayerData[v91.Name].PrimaryWeapon.Value = v69 
			v71:Destroy() 
		end) 
	end
} 
v1.alternate = u3 
return v1 

