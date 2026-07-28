game.Players.LocalPlayer.ChildRemoved:Connect(function(ch)
	if ch.Name == "Ingame" then
		script.Parent:Destroy()
	end
end)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Requests = ReplicatedStorage:WaitForChild("Requests")
local SS = game:GetService("ServerStorage")

local Money = script.Parent.Money
local Insight = script.Parent.Insight
local DropFrame = script.Parent.DropFrame

local Opened = false

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character

while not Character do
	wait()
	Character = LocalPlayer.Character
end

repeat wait(0.1)until Character.Parent == workspace.Live or Character.Parent == workspace.Dead

function formatnumber(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

Money.Value.Text = formatnumber(Requests.Get:InvokeServer({"Money"}).Money)
--Money.Value.Shadow.Text = formatnumber(Requests.Get:InvokeServer({"Money"}).Money)
local oldMoney = tonumber(Money.Value.Text)
Requests.MoneyChanged.OnClientEvent:Connect(function(Number)
	Money.Value.Text = formatnumber(Number)
	--Money.Value.Shadow.Text = formatnumber(Number)
	script.Parent.MoneyChange:Play()
	oldMoney = Number
end)

Insight.Value.Text = formatnumber(Requests.Get:InvokeServer({"Insight"}).Insight)
--Insight.Value.Shadow.Text = formatnumber(Requests.Get:InvokeServer({"Insight"}).Insight)
local oldInsight = tonumber(Insight.Value.Text)
Requests.InsightChanged.OnClientEvent:Connect(function(Number)
	Insight.Value.Text = formatnumber(Number)
	--Insight.Value.Shadow.Text = formatnumber(Number)
	script.Parent.InsightChange:Play()
	oldInsight = Number
end)

-- Attractiveness (2026-07-28): same Get-then-Changed-event pattern as Money/Insight above.
-- floor()'d for display only - AttractivenessModule.compute keeps the underlying value
-- unrounded, since Mogging/NPC-gate thresholds compare against the exact computed number.
-- Defensive: the server-side Get handler now skips any field that doesn't exist yet on
-- PlayerData (see RequestHandler.server.luau), so .Attractiveness can come back nil until the
-- Studio Setup folder has this field - fall back to 0 rather than erroring on math.floor(nil).
local Attractiveness = script.Parent.Attractiveness
Attractiveness.Value.Text = formatnumber(math.floor(Requests.Get:InvokeServer({"Attractiveness"}).Attractiveness or 0))
Requests.AttractivenessChanged.OnClientEvent:Connect(function(Number)
	Attractiveness.Value.Text = formatnumber(math.floor(Number))
end)



Money.MouseButton1Click:Connect(function()
	Opened = not Opened
	DropFrame.Visible = Opened
end)

DropFrame.Submit.MouseButton1Click:Connect(function()
	if DropFrame.MoneyDrop.Text~=nil or DropFrame.MoneyDrop.Text~="nil"then
		if tonumber(DropFrame.MoneyDrop.Text)then
			Requests.Drop:FireServer(DropFrame.MoneyDrop.Text)
		end
	end
end)