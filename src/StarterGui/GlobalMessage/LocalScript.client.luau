local guis={}
local function UDScale(a,b)
	return UDim2.new(a,0,b,0)
end
local function UDOffset(a,b)
	return UDim2.new(0,a,0,b)
end
local Player = game.Players.LocalPlayer

function Notify(messg,tim)
	local plrs=game.Players:GetPlayers()
	local movenum
	if #guis < 1 then
		movenum=0
	else
		movenum=#guis * 30
	end
	local pgui = Player.PlayerGui
	local sg = Instance.new("ScreenGui",pgui)
	sg.Name = "Message"
	local frm = Instance.new("Frame",sg)
	frm.Size = UDScale(.1,0.075)
	frm.BackgroundColor = BrickColor.new("Really black")
	frm.BackgroundTransparency = 0.5
	frm.Style="DropShadow"
	frm.ZIndex = 6
	frm.Position = UDScale(1.1,0.85)
	table.insert(guis,frm)
	local msg = Instance.new("TextLabel",frm)
	msg.Name = "msg"
	msg.TextScaled=true
	msg.Text = tostring(messg)
	msg.Font = "ArialBold"
	msg.FontSize = "Size18"
	msg.TextColor = BrickColor.new("White")
	msg.Size = UDScale(1,1)
	msg.Position = UDScale(0,0)
	msg.BackgroundTransparency = 1
	msg.TextXAlignment = "Center"
	msg.ZIndex = 6
	frm:TweenPosition(UDScale(.9,0.85) - UDOffset(0,movenum), "Out", "Quad", 2.5)
	task.spawn(function() 
		wait(tim + 2.5)
		for i=1,#guis do
			if guis[i]==frm then
				table.remove(guis,i)
			end 
		end
		frm:TweenPosition(UDScale(1.1,0.85), "Out", "Quad", 2.5)
		wait(2.5)
		sg:Destroy()
	end)
end

game.ReplicatedStorage.Requests.ClientMessage.OnClientEvent:Connect(function(Message,tim)
	Notify(Message,tim or 2)
end)

game.ReplicatedStorage.Requests.GlobalMessage.OnClientEvent:Connect(function(Message)
	script.Parent.Sound:Play()

	script.Parent.Hint.Body.Message.Text = Message

	game.TweenService:Create(script.Parent.Hint,TweenInfo.new(0.75),{Position = UDim2.new(0,0,0,0)}):Play()
	wait(15)
	game.TweenService:Create(script.Parent.Hint,TweenInfo.new(0.75),{Position = UDim2.new(0,0,-0.5,0)}):Play()
end)