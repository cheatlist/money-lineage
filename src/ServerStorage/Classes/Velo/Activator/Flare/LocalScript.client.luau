-- Decompiled with the Synapse X Luau decompiler.

local l__CurrentCamera__1 = game.Workspace.CurrentCamera;
local l__Character__2 = game.Players.LocalPlayer.Character;
if (CFrame.new(l__CurrentCamera__1.CFrame.p, script.Parent.Point.Value).lookVector - l__CurrentCamera__1.CFrame.lookVector).magnitude < 0.5 then
	script.Parent.Frame.Visible = true;
	script.Parent.Frame.BackgroundTransparency = 0;
	wait(0.5);
	for v3 = 1, 50 do
		wait();
		script.Parent.Frame.BackgroundTransparency = v3 / 50;
	end;
end;
