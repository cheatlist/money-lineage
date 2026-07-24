wait(1)
game.Players.LocalPlayer.ChildRemoved:Connect(function(ch)
	if ch.Name == "Ingame" then
		script.Parent:Destroy()
	end
end)
local v1 = nil
local l__Parent__2 = script.Parent
local l__AreaFrame__3 = l__Parent__2:WaitForChild("AreaFrame")
local l__Title__4 = l__AreaFrame__3:WaitForChild("Title")
local l__Description__5 = l__AreaFrame__3:WaitForChild("Description")
local l__AreaMusic__6 = l__Parent__2:WaitForChild("AreaMusic")
local l__AreaMarkers__7 = workspace:WaitForChild("AreaMarkers")
local v8 = require(game.ReplicatedStorage.Info.AreaData)
local l__LocalPlayer__9 = game.Players.LocalPlayer
local v10 = l__LocalPlayer__9.Character
while not v10 do
	v10 = l__LocalPlayer__9.Character
end
local l__HumanoidRootPart__11 = v10:WaitForChild("HumanoidRootPart")
local v14 = game.ReplicatedStorage.Assets.FogCover:clone()
v14.Transparency = 1
game.CollectionService:AddTag(v14, "WeatherCover")
v1 = setmetatable({}, {
	__index = 1, 
	__tostring = 1, 
	__newindex = 1
})
for v15 = 1, 10 do
	v1 = setmetatable(v1, {
		__index = 1, 
		__tostring = 1, 
		__newindex = 1
	})
end
local v17 = ("Tango"):sub(1, 100)
local v18 = ("Theodora"):sub(1, 100)
local v19 = ("InvisIngredient"):sub(1, 100)
local v20 = ("HideOre"):sub(1, 100)
local v21 = ("PostDialogue"):sub(1, 100)
local v22 = ("StopClimb"):sub(1, 100)
local v23 = ("PlaceMoney"):sub(1, 100)
local v24 = ("PlaceTool"):sub(1, 100)
local v25 = ("Dodges"):sub(1, 100)
local v26 = ("ApplyFallDamage"):sub(1, 100)
local v27 = ("WakeupSleep"):sub(1, 100)
local v28 = ("SetManaChargeState"):sub(1, 100)
local currentSong = nil
local u3 = tick()
local u4 = Random.new()
local function wrap(...)
	coroutine.wrap(...)()
end
local l__Lighting__29 = game.Lighting
l__Lighting__29.areacolor.Enabled = true
local u6 = false
local u7 = nil
local l__FireServer__8 = Instance.new("RemoteEvent").FireServer
local u10 = ("SetCurrentArea"):sub(1, 100)
local u11 = tick()
local function u12(p2)
	if u6 then
		return
	end
	if u7 == p2 then
		return
	end
	u6 = true
	local v30 = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	if not u7 then
		v30 = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	end
	wrap(function()
		local v31 = v8.biomes[p2]
		local v32 = nil
		if v31 == "desert" or v31 == "oasis" then
			v32 = l__Lighting__29.desertcolor
		elseif v31 == "tundraoutside" then
			v32 = l__Lighting__29.tundracolor
		elseif v31 == "tundrainside" or v31 == "tundracastle" then
			v32 = l__Lighting__29.tundrainsidecolor
		elseif v31 == "lava" then
			v32 = l__Lighting__29.lavacolor
		else
			v32 = l__Lighting__29.defaultcolor
		end
		if v32 ~= nil then
			game.TweenService:Create(l__Lighting__29.areacolor, v30,{
				Brightness = v32.Brightness, 
				Contrast = v32.Contrast, 
				Saturation = v32.Saturation,
				TintColor = v32.TintColor
			}):Play()
		end
		local v33 = false
		if v31 ~= "tundrainside" then
			v33 = false
			if v31 ~= "tundraoutside" then
				v33 = v31 ~= "tundracastle"
			end
		end
		l__Lighting__29.SunRays.Enabled = v33
		local v34 = nil
		local v35 = nil
		local v36 = nil
		local v37 = nil
		local v38 = nil
		game.Lighting.GlobalShadows = true
		game.Lighting.ExposureCompensation = 0
		if v31 == "fullbright" then
			v34 = {
				Ambient = Color3.fromRGB(255, 255, 255)
			}
			v35 = {
				Value = 1.15
			}
			v36 = {
				Value = Color3.fromRGB(255, 255, 255)
			}
			v37 = {
				FogStart = 0, 
				FogEnd = 1000000
			}
			v38 = {
				Value = Color3.fromRGB(255, 255, 255)
			}
			game.Lighting.GlobalShadows = false
			game.Lighting.ExposureCompensation = -1.5
		elseif v31 == "forest" then
			v34 = {
				Ambient = Color3.fromRGB(20, 20, 20)
			}
			v35 = {
				Value = 1.15
			}
			v36 = {
				Value = Color3.fromRGB(163, 181, 177)
			}
			v37 = {
				FogStart = 0, 
				FogEnd = 750
			}
			v38 = {
				Value = Color3.fromRGB(91, 159, 157)
			}
		elseif v31 == "darkforest" then
			v34 = {
				Ambient = Color3.fromRGB(20, 20, 20)
			}
			v35 = {
				Value = 0.6
			}
			v36 = {
				Value = Color3.fromRGB(163, 181, 177)
			}
			v37 = {
				FogStart = 0, 
				FogEnd = 120
			}
			v38 = {
				Value = Color3.fromRGB(25, 85, 60)
			}
		elseif v31 == "cave" or v31 == "theabyss" then
			v34 = {
				Ambient = Color3.fromRGB(20, 20, 20)
			}
			v35 = {
				Value = 0
			}
			v36 = {
				Value = Color3.fromRGB(11, 13, 12)
			}
			v37 = {
				FogStart = 0, 
				FogEnd = 80
			}
			v38 = {
				Value = Color3.fromRGB(25, 44, 43)
			}
		elseif v31 == "darkcave" then
			v34 = {
				Ambient = Color3.fromRGB(20, 20, 20)
			}
			v35 = {
				Value = 0
			}
			v36 = {
				Value = Color3.fromRGB(11, 13, 12)
			}
			v37 = {
				FogStart = 0, 
				FogEnd = 50
			}
			v38 = {
				Value = Color3.fromRGB(17, 17, 17)
			}
		elseif v31 == "desert" or v31 == "oasis" then
			v34 = {
				Ambient = Color3.fromRGB(20, 20, 20)
			}
			v35 = {
				Value = 1.25
			}
			v36 = {
				Value = Color3.fromRGB(127, 126, 101)
			}
			v37 = {
				FogStart = 150, 
				FogEnd = 2000
			}
			v38 = {
				Value = Color3.fromRGB(147, 130, 109)
			}
		elseif v31 == "tundraoutside" then
			v34 = {
				Ambient = Color3.fromRGB(20, 20, 20)
			}
			v35 = {
				Value = 1.5
			}
			v36 = {
				Value = Color3.fromRGB(136, 136, 136)
			}
			v37 = {
				FogStart = 40, 
				FogEnd = 200
			}
			v38 = {
				Value = Color3.fromRGB(240, 255, 240)
			}
		elseif v31 == "tundrainside" or v31 == "tundracastle" then
			v34 = {
				Ambient = Color3.fromRGB(20, 20, 20)
			}
			v35 = {
				Value = 1.5
			}
			v36 = {
				Value = Color3.fromRGB(136, 136, 136)
			}
			v37 = {
				FogStart = 100, 
				FogEnd = 200
			}
			v38 = {
				Value = Color3.fromRGB(255, 255, 255)
			}
		elseif v31 == "lava" then
			v34 = {
				Ambient = Color3.fromRGB(20, 20, 20)
			}
			v35 = {
				Value = 0.5
			}
			v36 = {
				Value = Color3.fromRGB(239, 15, 15)
			}
			v37 = {
				FogStart = 100, 
				FogEnd = 1000
			}
			v38 = {
				Value = Color3.fromRGB(240, 255, 240)
			}
		elseif v31 == "spooky" then
			v34 = {
				Ambient = Color3.fromRGB(20, 20, 20)
			}
			v35 = {
				Value = 0.5
			}
			v36 = {
				Value = Color3.fromRGB(50, 50, 50)
			}
			v37 = {
				FogStart = 0, 
				FogEnd = 400
			}
			v38 = {
				Value = Color3.fromRGB(200, 125, 50)
			}
		end
		if v34 then
			game.TweenService:Create(l__Lighting__29, v30, v34):Play()
		end
		if v35 then
			game.TweenService:Create(l__Lighting__29.AreaBrightness, v30, v35):Play()
		end
		if v36 then
			game.TweenService:Create(l__Lighting__29.AreaOutdoor, v30, v36):Play()
		end
		if v37 then
			if v37.FogEnd then
				v37.FogEnd = v37.FogEnd * 1.5
			end
			game.TweenService:Create(l__Lighting__29, v30, v37):Play()
		end
		if v38 then
			game.TweenService:Create(l__Lighting__29.AreaFog, v30, v38):Play()
		end
		local v39 = true
		if v31 ~= "tundrainside" then
			v39 = true
			if v31 ~= "tundracastle" then
				v39 = true
				if v31 ~= "tundraoutside" then
					v39 = true
					if v31 ~= "darkforest" then
						v39 = true
						if v31 ~= "cave" then
							v39 = true
							if v31 ~= "darkcave" then
								v39 = true
								if v31 ~= "theabyss" then
									v39 = v31 == "spooky"
								end
							end
						end
					end
				end
			end
		end
		--[[
		if v39 then
			v14.Parent = workspace.Thrown
			game.TweenService:Create(v14, v30, {
				Transparency = 0
			}):Play()
		else
			game.TweenService:Create(v14, TweenInfo.new(1), {
				Transparency = 1
			}):Play()
			wrap(function()
				wait(1)
				v14.Parent = nil
			end)
		end
		]]
		u7 = p2
		l__FireServer__8(game.ReplicatedStorage.Requests.SetCurrentArea,u7)
		l__Title__4.Text = p2
		l__Title__4.Shadow.Text = p2
		local v40 = v8.descriptions[p2]or ""
		l__Description__5.Text = v40
		l__Description__5.Shadow.Text = v40
		l__AreaFrame__3.Visible = true
		game.TweenService:Create(l__Title__4, TweenInfo.new(0.3), {
			TextTransparency = 0, 
			TextStrokeTransparency = 0.7
		}):Play()
		game.TweenService:Create(l__Title__4.Shadow, TweenInfo.new(0.3), {
			TextTransparency = 0.8
		}):Play()
		wait(0.2)
		game.TweenService:Create(l__Description__5, TweenInfo.new(0.3), {
			TextTransparency = 0, 
			TextStrokeTransparency = 0.7
		}):Play()
		game.TweenService:Create(l__Description__5.Shadow, TweenInfo.new(0.3), {
			TextTransparency = 0.8
		}):Play()
		wait(3)
		game.TweenService:Create(l__Title__4, TweenInfo.new(0.3), {
			TextTransparency = 1, 
			TextStrokeTransparency = 1
		}):Play()
		game.TweenService:Create(l__Title__4.Shadow, TweenInfo.new(0.3), {
			TextTransparency = 1
		}):Play()
		game.TweenService:Create(l__Description__5, TweenInfo.new(0.3), {
			TextTransparency = 1, 
			TextStrokeTransparency = 1
		}):Play()
		game.TweenService:Create(l__Description__5.Shadow, TweenInfo.new(0.3), {
			TextTransparency = 1
		}):Play()
		wait(0.3)
		l__AreaFrame__3.Visible = false
		u6 = false
	end)
end
local function u13(p3)
	local songData = v8.songs[p3]or ""
	u3 = tick()
	local songToPlay = songData
	local fadeouttype = "normal"
	local divison = false
	if type(songData) == "table" then
		--songToPlay = songData[u4:NextInteger(1, #songData)]
		if songData.CombatSong then
			if game.Players.LocalPlayer:FindFirstChild("Danger") or game.Players.LocalPlayer:FindFirstChild("MortalDanger") then
				songToPlay = songData.CombatSong
				fadeouttype = "instant"
			else
				if currentSong == songData.CombatSong then
					fadeouttype = "instant"
					if songData.divison then
						divison = true
					end
				end
				songToPlay = songData.NormalSong
			end
		else
			songToPlay = songData[1]
		end
	end
	if currentSong == nil then
		fadeouttype = "normal"
	end
	if songToPlay == currentSong then
		return
	end
	currentSong = songToPlay
	wrap(function()
		if fadeouttype == "instant" then
			local clon = l__AreaMusic__6:clone()
			clon.SoundId = songToPlay
			clon.Playing = true
			clon.TimePosition = l__AreaMusic__6.TimePosition
			if divison then
				clon.TimePosition = l__AreaMusic__6.TimePosition/2
			end
			clon.Parent = l__AreaMusic__6.Parent
			--l__AreaMusic__6.SoundId = songToPlay
			game.TweenService:Create(l__AreaMusic__6, TweenInfo.new(.5), {
				Volume = 0
			}):Play()
			game.Debris:AddItem(l__AreaMusic__6,0.5)
			l__AreaMusic__6 = clon
		else
			if l__AreaMusic__6.Volume ~= 0 then
				game.TweenService:Create(l__AreaMusic__6, TweenInfo.new(0.35), {
					Volume = 0
				}):Play()
				wait(0.35)
			end
			if currentSong ~= songToPlay then
				return
			end
			l__AreaMusic__6:Stop()
			l__AreaMusic__6.SoundId = songToPlay
			if songToPlay ~= "" then
				l__AreaMusic__6:Play()
				local v43 = 0.1
				if p3 == "Cardinal Crossing" then
					v43 = 0.1
				end
				if p3 == "The Rift" then
					v43 = 0.01
				end
				if p3 == "The All-Dark" then
					v43 = 0.5
				end
				--[[if p3 == "The First Layer" or p3 == "The Temple of Altum" then
					v43 = 2.5
				end]]
				if p3 == "Castle Sanctuary" or p3 == "Southern Sanctuary" or p3 == "Central Sanctuary" then
					v43 = 0.25
				end
				game.TweenService:Create(l__AreaMusic__6, TweenInfo.new(0.35), {
					Volume = v43
				}):Play()
			end
		end
	end)
end
game:GetService("RunService").RenderStepped:connect(function()
	if tick() - u11 < 0.5 then
		return
	end
	local v44, v45 = workspace:FindPartOnRayWithWhitelist(Ray.new(l__HumanoidRootPart__11.Position, Vector3.new(0, 1000, 0)), { l__AreaMarkers__7 })
	local v46 = u7
	if v44 then
		v46 = v44.Name
	end
	if v46 ~= u7 then
		u12(v46)
	end
	if u3 + .5 < tick() then
		u13(v46)
	end
	local l__Value__47 = l__Lighting__29.TimeBrightness.Value
	l__Lighting__29.Brightness = l__Value__47 * l__Lighting__29.AreaBrightness.Value
	local v48 = 0.4 + l__Value__47 * 0.6
	local l__Value__49 = l__Lighting__29.AreaOutdoor.Value
	l__Lighting__29.OutdoorAmbient = Color3.new(l__Value__49.r * v48, l__Value__49.g * v48, l__Value__49.b * v48)
	local l__Value__50 = l__Lighting__29.AreaFog.Value
	l__Lighting__29.FogColor = Color3.new(l__Value__50.r * v48, l__Value__50.g * v48, l__Value__50.b * v48)
	v14.CFrame = l__HumanoidRootPart__11.CFrame
end)