--[[
	AnythingEater "Eat" button (added 2026-07-29) - replaces the old "/e eat <item>" chat command
	("I want the item eating to work by clicking with the item instead of typing a command since
	some players dont have access to roblox chat"). Shows a button whenever the local player has
	the AnythingEater injury AND has a Tool equipped; clicking fires Requests.EatEquipped, and the
	server (RequestHandler.server.luau) resolves and consumes whatever's actually equipped.

	AnythingEater is read via the Character-parented "AnythingEater" Accessory marker
	(MoggingModule.grantTimedInjury creates this alongside the real PlayerData.Injuries.Value
	entry specifically so client scripts can see it - ServerStorage.PlayerData never replicates,
	same reasoning already documented for the Rage/Squeamish markers this mirrors).

	Fully code-built (Instance.new), same zero-Studio-asset-debt approach as StarterGui/AlertGui -
	only the Requests.EatEquipped RemoteEvent itself needs Studio placement.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local FoodCategories = require(game.ReplicatedStorage.Info.FoodCategories)
-- WaitForChild, not a bare dot-index (2026-07-29, fixing the actual reason eating still didn't
-- work): RequestHandler.server.luau now creates this RemoteEvent at runtime rather than depending
-- on manual Studio placement, but that's still a separate script racing against this one at game
-- start - WaitForChild tolerates that ordering instead of erroring if this script happens to run
-- first.
local EatEquippedEvent = game.ReplicatedStorage.Requests:WaitForChild("EatEquipped", 10)

local screenGui = script.Parent

local button = Instance.new("TextButton")
button.Name = "EatButton"
button.AnchorPoint = Vector2.new(0.5, 1)
button.Position = UDim2.new(0.5, 0, 1, -170)
button.Size = UDim2.new(0, 180, 0, 40)
button.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
button.BackgroundTransparency = 0.1
button.BorderSizePixel = 0
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Text = "Eat"
button.Visible = false
button.AutoButtonColor = true
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(235, 175, 70)
stroke.Thickness = 1.5
stroke.Transparency = 0.4
stroke.Parent = button

local currentTool = nil

local function refresh()
	local character = LocalPlayer.Character
	if not character then
		button.Visible = false
		currentTool = nil
		return
	end

	local hasInjury = character:FindFirstChild("AnythingEater") ~= nil
	local tool = character:FindFirstChildWhichIsA("Tool")
	currentTool = tool

	if hasInjury and tool and not FoodCategories.FOOD_ITEMS[tool.Name] and not FoodCategories.POTION_ITEMS[tool.Name] then
		button.Text = "Eat "..tool.Name
		button.Visible = true
	else
		button.Visible = false
	end
end

button.MouseButton1Click:Connect(function()
	if currentTool and EatEquippedEvent then
		EatEquippedEvent:FireServer()
	end
end)

local characterConnections = {}
local function clearCharacterConnections()
	for _, connection in ipairs(characterConnections) do
		connection:Disconnect()
	end
	table.clear(characterConnections)
end

local function hookCharacter(character)
	clearCharacterConnections()
	refresh()
	table.insert(characterConnections, character.ChildAdded:Connect(refresh))
	table.insert(characterConnections, character.ChildRemoved:Connect(refresh))
end

if LocalPlayer.Character then
	hookCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(hookCharacter)
LocalPlayer.CharacterRemoving:Connect(function()
	clearCharacterConnections()
	button.Visible = false
	currentTool = nil
end)
