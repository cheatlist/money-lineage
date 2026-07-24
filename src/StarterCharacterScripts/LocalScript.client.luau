local LocalPlayer = game:GetService("Players").LocalPlayer
local playerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
local controls = playerModule:GetControls()
controls:Disable()
wait()
controls:Enable()