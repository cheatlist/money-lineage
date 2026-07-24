local l__LocalPlayer__1 = game.Players.LocalPlayer;
local l__Menu__2 = script.Parent:WaitForChild("Menu");
l__Menu__2.MouseButton1Click:connect(function()
	if not l__Menu__2.Visible then
		return;
	end;
	game.ReplicatedStorage.Requests.ReturnToMenu:FireServer()
	l__Menu__2.Visible = false;
end);
wait(5);
l__Menu__2.Visible = true;