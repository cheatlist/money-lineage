local module = {}
local EMBLEM_SIZE = 9
function module:generateFrame(seed, bgcolor, fgcolor)
	bgcolor = bgcolor or Color3.new(0.1, 0.1, 0.1)
	fgcolor = fgcolor or Color3.new(1, 1, 1)
	local emRNG = Random.new(seed)
	local tab = {}
	local size = EMBLEM_SIZE
	size = size % 2 == 0 and size + 1 or size
	local border = math.ceil(size / 2)
	for y = 1, size do
		tab[y] = {}
		for x = 1, size do
			if x <= border then
				if emRNG:NextInteger(1, 2) == 1 then
					tab[y][x] = true
				end
			else
				local factor = (x - border) * 2
				local counterpart = tab[y][x - factor]
				if counterpart then
					tab[y][x] = true
				end
			end
		end
	end
	local frame = Instance.new("Frame")
	frame.Name = "Emblem"
	frame.Size = UDim2.new(0, 90, 0, 90)
	frame.BackgroundTransparency = 1
	for y = 1, size do
		local runon
		for x = 1, size do
			if tab[y][x] then
				if runon then
					local bg = runon[1]
					local fg = runon[2]
					local pos = bg.Position
					local bgsz = bg.Size
					bg.Size = UDim2.new(bgsz.X.Scale + 1 / size, 0, bgsz.Y.Scale, 0)
					bg.Position = UDim2.new(pos.X.Scale + 0.5 / size, 0, pos.Y.Scale, 0)
					local fgsz = fg.Size
					fg.Size = UDim2.new(fgsz.X.Scale + 1 / size, 0, fgsz.Y.Scale, 0)
					fg.Position = UDim2.new(pos.X.Scale + 0.5 / size, 0, pos.Y.Scale, 0)
				else
					local pos = Vector2.new(1 / size * (x - 0.5), 1 / size * (y - 0.5))
					local bg = Instance.new("Frame")
					bg.Parent = frame
					bg.AnchorPoint = Vector2.new(0.5, 0.5)
					bg.Position = UDim2.new(pos.x, 0, pos.y, 0)
					bg.Size = UDim2.new(0.05 + 1 / size, 0, 0.05 + 1 / size, 0)
					bg.BorderSizePixel = 0
					bg.BackgroundColor3 = bgcolor
					bg.ZIndex = 1
					bg.Name = "Back"
					local fg = Instance.new("Frame")
					fg.Parent = frame
					fg.AnchorPoint = Vector2.new(0.5, 0.5)
					fg.Position = UDim2.new(pos.x, 0, pos.y, 0)
					fg.Size = UDim2.new(1 / size, 0, 1 / size, 0)
					fg.BorderSizePixel = 0
					fg.BackgroundColor3 = fgcolor
					fg.ZIndex = 2
					fg.Name = "Front"
					runon = {bg, fg}
				end
			else
				runon = nil
			end
		end
	end
	return frame
end
return module