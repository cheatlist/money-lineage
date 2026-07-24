while true do
	task.wait(120)
	script.Parent.Disabled = true
	task.wait(.5)
	script.Parent.Disabled = false
end