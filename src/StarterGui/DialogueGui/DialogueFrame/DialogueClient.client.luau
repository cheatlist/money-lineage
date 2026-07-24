--SynapseX Decompiler

local mainFrame = script.Parent
local nameTag = mainFrame:WaitForChild("NameTag")
local containerFrame = mainFrame:WaitForChild("Container")
local choicesFrame = mainFrame:WaitForChild("Choices")
local textSize = 20
local dialogueRemote = game.ReplicatedStorage.Requests.Dialogue
local dialogueclientRemove = game.ReplicatedStorage.Requests.DialogueNoNPCClient
local END_CHOICE = "Bye"
local lastRequest = 0
local Title = {
	["YA'ALDA"] = "THE GOD NEEDLE",
	["Oracle"] = "The Seer",
	Kalvey = "The Sedulous",
	["As'endo"] = "Keeper of the Infernal Secrets"
}
function renderText(speakerName, textPrompt, choices, endchoice)
	containerFrame:ClearAllChildren()
	choicesFrame:ClearAllChildren()
	mainFrame.Visible = true
	nameTag.Text = speakerName
	nameTag.Shadow.Text = nameTag.Text
	local GetTitle = Title[speakerName]
	if GetTitle then
		nameTag.TitleTag.Text = GetTitle
		nameTag.TitleTag.Shadow.Text = GetTitle
		nameTag.TitleTag.Visible = true
		nameTag.Position = UDim2.new(0, 25, 0, -24)
	else
		nameTag.TitleTag.Visible = false
		nameTag.Position = UDim2.new(0, 25, 0, -4)
	end
	choices = choices or {}
	if endchoice == "" then
		
	else
		table.insert(choices, endchoice)
	end
	
	
	for i, v in pairs(choices) do
		do
			local choiceFrame = Instance.new("Frame")
			choiceFrame.Name = v
			choiceFrame.BackgroundTransparency = 1
			choiceFrame.Position = UDim2.new((i - 1) / #choices, 0, 0, 0)
			choiceFrame.Size = UDim2.new(1 / #choices, 0, 1, 0)
			local choiceText = Instance.new("TextButton", choiceFrame)
			choiceText.BackgroundTransparency = 1
			choiceText.TextSize = 22
			choiceText.Font = Enum.Font.SourceSans
			choiceText.Text = v
			choiceText.TextColor3 = Color3.new(0.8, 0.8, 0.8)
			choiceText.AnchorPoint = Vector2.new(0.5, 0.5)
			choiceText.Position = UDim2.new(0.5, 0, 0.5, 0)
			choiceText.Size = UDim2.new(1, 0, 1, 10)
			choiceText.TextWrapped = true
			choiceText.TextTruncate = Enum.TextTruncate.None
			choiceText.ZIndex = 3
			local choiceShadow = choiceText:clone()
			choiceShadow.AnchorPoint = Vector2.new(0, 0)
			choiceShadow.ZIndex = 2
			choiceShadow.TextColor3 = Color3.new()
			choiceShadow.TextTransparency = 0.8
			choiceShadow.Size = UDim2.new(1, 0, 1, 0)
			choiceShadow.Position = UDim2.new(0, 1, 0, 1)
			choiceShadow.Parent = choiceText
			local choiceBack = script.Shadow:clone()
			choiceBack.Parent = choiceFrame
			choiceBack.Position = UDim2.new(0, 0, 0, 1)
			choiceText.MouseButton1Click:connect(function()
				if lastRequest + 0.2 > tick() then
					return
				end
				lastRequest = tick()
				if v == endchoice then
					dialogueRemote:FireServer({exit = true})
				else
					dialogueRemote:FireServer({choice = v})
				end
			end)
			choiceText.MouseEnter:connect(function()
				game.TweenService:Create(choiceText, TweenInfo.new(0.1), {
					TextColor3 = Color3.new(1, 1, 1)
				}):Play()
				game.TweenService:Create(choiceShadow, TweenInfo.new(0.1), {TextTransparency = 0.7}):Play()
			end)
			choiceText.MouseLeave:connect(function()
				game.TweenService:Create(choiceText, TweenInfo.new(0.3), {
					TextColor3 = Color3.new(0.8, 0.8, 0.8)
				}):Play()
				game.TweenService:Create(choiceShadow, TweenInfo.new(0.2), {TextTransparency = 0.8}):Play()
			end)
			choiceFrame.Parent = choicesFrame
		end
	end
	local fontModes = {bold = false, italic = false}
	local charSizes = {}
	local chars = {}
	local charNum = 0
	for m in string.gmatch(textPrompt, ".") do
		local font = Enum.Font.SourceSans
		local skipChar = false
		if m == "*" then
			fontModes.bold = not fontModes.bold
			skipChar = true
		elseif m == "_" then
			fontModes.italic = not fontModes.italic
			skipChar = true
		end
		if fontModes.bold then
			font = Enum.Font.SourceSansBold
		elseif fontModes.italic then
			font = Enum.Font.SourceSansItalic
		end
		if not skipChar then
			charNum = charNum + 1
			chars[charNum] = m
			if not charSizes[charNum] then
				charSizes[charNum] = {
					char = m,
					size = game.TextService:GetTextSize(m, textSize, font, Vector2.new(100, 100)),
					font = font
				}
			end
		end
	end
	local renderModes = {shadow = false, shake = false}
	local curX = 0
	local curY = 0
	local cadencePos = 0
	local curWord = 0
	local lastChar = ""
	for i, m in pairs(chars) do
		do
			local oCad = cadencePos
			local skipChar = false
			if m == "%" then
				renderModes.shadow = not renderModes.shadow
				skipChar = true
			elseif m == "$" then
				renderModes.strike = not renderModes.strike
				skipChar = true
			elseif m == "{" then
				renderModes.shake = true
				skipChar = true
			elseif m == "}" then
				renderModes.shake = false
				skipChar = true
			elseif m == "_" or m == "*" then
				skipChar = true
			end
			if not skipChar then
				do
					local size = charSizes[i].size
					local curWordSize = 0
					if not string.match(m, "%s") and string.match(lastChar, "%s") then
						for wi, wm in pairs(chars) do
							if i <= wi and charSizes[wi] then
								if string.match(wm, " ") then
									break
								end
								curWordSize = curWordSize + charSizes[wi].size.x
							end
						end
					end
					if curX + curWordSize > 450 then
						cadencePos = cadencePos + 0.1
						oCad = cadencePos
						curX = 0
						curY = curY + size.y
					end
					local ox = curX
					local oy = curY
					if not string.match(m, "%s") then
						do
							local letter = Instance.new("TextLabel", containerFrame)
							letter.Position = UDim2.new(0, ox, 0, oy)
							letter.Size = UDim2.new(0, size.x, 0, size.y + 8)
							letter.Text = m
							letter.Font = charSizes[i].font
							letter.BackgroundTransparency = 1
							letter.TextTransparency = 0.5
							letter.ZIndex = 8
							letter.Visible = false
							letter.TextColor3 = Color3.new(1, 1, 1)
							letter.TextXAlignment = Enum.TextXAlignment.Left
							spawn(function()
								wait(oCad)
								letter.Visible = true
								letter.TextSize = textSize + 8
								game.TweenService:Create(letter, TweenInfo.new(0.15), {TextSize = textSize, TextTransparency = 0}):Play()
							end)
							if renderModes.shake then
								spawn(function()
									wait(math.random() / 10)
									repeat
										letter.Position = UDim2.new(0, ox + math.random(0, 1), 0, oy + math.random(0, 1))
										wait()
									until not letter or not letter.Parent
								end)
							end
							if renderModes.shadow then
								do
									local shadowLetter = Instance.new("TextLabel", letter)
									shadowLetter.Position = UDim2.new(0, 1, 0, 1)
									shadowLetter.Size = UDim2.new(0, size.x, 0, size.y + 8)
									shadowLetter.Text = m
									shadowLetter.Font = charSizes[i].font
									shadowLetter.TextSize = textSize
									shadowLetter.BackgroundTransparency = 1
									shadowLetter.TextTransparency = 1
									shadowLetter.ZIndex = 7
									shadowLetter.Visible = false
									shadowLetter.TextColor3 = Color3.new(0.8, 0.8, 0.8)
									shadowLetter.TextXAlignment = Enum.TextXAlignment.Left
									spawn(function()
										wait(oCad + 0.2)
										shadowLetter.Visible = true
										game.TweenService:Create(shadowLetter, TweenInfo.new(0.1), {TextTransparency = 0.6}):Play()
									end)
								end
							end
							if renderModes.strike then
								do
									local strike = Instance.new("Frame", letter)
									strike.Position = UDim2.new(0, 0, 1, -(textSize - 8))
									strike.Size = UDim2.new(0, 0, 0, 1)
									strike.ZIndex = 8
									strike.BorderSizePixel = 0
									strike.BackgroundColor3 = letter.TextColor3
									spawn(function()
										wait(oCad + 0.4)
										game.TweenService:Create(strike, TweenInfo.new(0.04), {
											Size = UDim2.new(1, 0, 0, 1)
										}):Play()
									end)
								end
							end
						end
					end
					if curX ~= 0 or not string.match(m, "%s") then
						curX = curX + size.x
					end
					if string.match(m, "%s") then
						cadencePos = cadencePos + 0.01
					elseif m == "," then
						cadencePos = cadencePos + 0.2
					elseif m == "." then
						cadencePos = cadencePos + 0.3
					elseif m == "?" or m == "!" then
						cadencePos = cadencePos + 0.1
					else
						cadencePos = cadencePos + 0.03
					end
					lastChar = m
				end
			end
		end
	end
end
function exitDialogue()
	mainFrame.Visible = false
end
dialogueRemote.OnClientEvent:connect(function(data)
	local speaker = data.speaker or "???"
	if data.exit then
		exitDialogue()
	elseif data.msg then
		renderText(speaker, data.msg, data.choices, data.endchoice)
	end
end)

dialogueclientRemove.OnClientEvent:Connect(function(data)
	game.ReplicatedStorage.Requests.DialogueNoNPC:FireServer("SpellChange")
end)