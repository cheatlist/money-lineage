return function(name,deletetime,parent)
	coroutine.wrap(function()
		local folder = Instance.new("Accessory")
		folder.Name = name
		folder.Parent = parent
		wait(deletetime)
		folder:Destroy()
	end)()
end