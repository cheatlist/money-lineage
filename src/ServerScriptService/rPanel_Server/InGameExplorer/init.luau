return function()
	--[[ InGameExplorer Server 

	READ InGameExplorer.README for setup instructions!
	
]]

	local HttpService = game:GetService("HttpService")


	local ReplicatedFirst = game:GetService("ReplicatedFirst")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")


	--[[ Periodically retry getting the latest API dump ]]

	local APIDump
	local success
	while true do
		success,APIDump = pcall(function() return HttpService:GetAsync("https://github.com/MaximumADHD/Roblox-Client-Tracker/raw/roblox/API-Dump.json") end)
		if success and APIDump then
			APIDump = HttpService:JSONDecode(APIDump)
			break
		end
		task.wait(1)
	end

	local Reflection
	while true do
		success,Reflection = pcall(function() return HttpService:GetAsync("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml") end)
		if success and Reflection then
			break
		end
		task.wait(1)
	end


	local ReplicatedFolder = ReplicatedStorage:WaitForChild("rPanel_ReplicatedStorage")
	local InGameExplorerShared = ReplicatedFolder:WaitForChild("InGameExplorer_Shared")

	local RepShared = ReplicatedFolder:WaitForChild("InGameExplorerShared")
	RepShared.Parent = InGameExplorerShared

	RepShared = require(RepShared)


	local RemoteFunction = Instance.new("RemoteFunction")
	RemoteFunction.Parent = InGameExplorerShared
	RemoteFunction.Name = "InGameExplorer_RemoteFunction"

	local RemoteEvent = Instance.new("RemoteEvent")
	RemoteEvent.Parent = InGameExplorerShared
	RemoteEvent.Name = "InGameExplorer_RemoteEvent"

	--[[ Parse API dump ]]
	local ExplorerOrder = {}
	for match in Reflection:gmatch("<Properties>(.-)</Properties>") do
		local name = match:match([=[<string name="Name">(.-)</string>]=])
		local order = match:match([=[<string name="ExplorerOrder">(.-)</string>]=])
		if name and order then
			ExplorerOrder[name] = order
		end
	end
	local Classes = {}
	local Enums = {}
	for i,class in APIDump.Classes do
		Classes[class.Name] = class
	end
	for i,enum in APIDump.Enums do
		local items = {}
		for i,v in enum.Items do
			table.insert(items,v.Name)
		end
		Enums[enum.Name] = items
	end

	for className,class in Classes do
		local properties = {}
		for i,property in class.Members do 
			if property.MemberType ~= "Property" then
				continue
			end
			local Tags = property.Tags
			if Tags then
				local temp = {}
				for i,v in Tags do 
					temp[v] = true
				end
				Tags = temp
			end
			local name = property.Name
			properties[name] = {property.Category,property.ValueType.Name,Tags,name}
		end
		table.sort(properties,function(a,b) return a.name < b.name end)
		class.Properties = properties
	end
	for className,class in Classes do
		local explorerOrder = ExplorerOrder[className]
		if explorerOrder then
			class.ExplorerOrder = explorerOrder
		end
		local categorizedProperties = {}
		local properties = class.Properties
		local superClass = class 
		while true do
			if not superClass.Superclass then
				break
			end
			superClass = Classes[superClass.Superclass]
			if not superClass then
				break
			end
			for i,v in superClass.Properties do 
				properties[i] = v
			end
		end

		local map = {}
		for propertyName,v in properties do
			local category,valueType,Tags,name = unpack(v)
			local categoryList = map[category]
			if not categoryList then
				categoryList = {}
				map[category] = categoryList
			end
			table.insert(categoryList,{propertyName = propertyName,valueType = valueType,tags = Tags})
		end

		for category,list in map do
			table.sort(list,function(a,b) return a.propertyName < b.propertyName end)
			table.insert(categorizedProperties,{name = category,list = list})
		end

		table.sort(categorizedProperties,function(a,b) return a.name < b.name end)
		class.Categorized_Properties = categorizedProperties
	end
	--

	local function ChildSortFunction(a, b)
		local aClass = a.ClassName and Classes[a.ClassName]
		local bClass = b.ClassName and Classes[b.ClassName]

		local aOrder = tonumber((aClass and aClass.ExplorerOrder) or 2^53)
		local bOrder = tonumber((bClass and bClass.ExplorerOrder) or 2^53)

		return if aOrder ~= bOrder then aOrder < bOrder else a.Name < b.Name
	end

	local ServerViewList = {
		"Workspace",
		"Players",
		"Lighting",
		"MaterialService",
		"ReplicatedFirst",
		"ReplicatedStorage",
		"ServerScriptService",
		"ServerStorage",
		"StarterGui",
		"StarterPack",
		"StarterPlayer",
		"SoundService"
	}

	function InitInstance(listening, inst)
		local id = listening.IdCounter
		listening.IdCounter += 1

		local instanceDetails = {
			Instance = inst,
			Id = id,
			Name = inst.Name,
			ClassName = inst.ClassName,
			Connections = {},

			Children = inst:GetChildren(),
			ChildIndices = {},

			Listening = false
		}

		if inst == game then
			for i = #instanceDetails.Children, 1, -1 do
				local child = instanceDetails.Children[i]

				if not table.find(ServerViewList, child.ClassName) then
					table.remove(instanceDetails.Children, i)
				end
			end
		end

		for i,v in instanceDetails.Children do
			instanceDetails.ChildIndices[v] = i
		end

		listening.InstancesById[instanceDetails.Id] = instanceDetails
		listening.InstancesByObject[instanceDetails.Instance] = instanceDetails

		instanceDetails.Connections.NameChanged = inst:GetPropertyChangedSignal("Name"):Connect(function()
			instanceDetails.Name = inst.Name
			RemoteEvent:FireClient(listening.Player, "Update", instanceDetails.Id, { Name = instanceDetails.Name })
		end)

		instanceDetails.Connections.ChildAdded = inst.ChildAdded:Connect(function(child)
			if inst == game then
				if not table.find(ServerViewList, child.ClassName) then
					return
				end
			end

			local index = #instanceDetails.Children + 1
			instanceDetails.Children[index] = child
			instanceDetails.ChildIndices[child] = index

			if instanceDetails.Listening then
				local childDetails = InitInstance(listening, child)

				RemoteEvent:FireClient(listening.Player, "Init", instanceDetails.Id, {
					Id = childDetails.Id,
					Name = childDetails.Name,
					ClassName = childDetails.ClassName,
					HasChildren = #childDetails.Children > 0
				})
			else
				if #instanceDetails.Children == 1 then
					RemoteEvent:FireClient(listening.Player, "Update", instanceDetails.Id, { HasChildren = true })
				end
			end
		end)

		instanceDetails.Connections.ChildRemoved = inst.ChildRemoved:Connect(function(child)
			local index = instanceDetails.ChildIndices[child]
			if not index then return end

			local finalIndex = #instanceDetails.Children
			local final = instanceDetails.Children[finalIndex]

			instanceDetails.Children[index] = final
			instanceDetails.ChildIndices[final] = index

			instanceDetails.Children[finalIndex] = nil
			instanceDetails.ChildIndices[child] = nil

			if instanceDetails.Listening then
				local childDetails = assert(listening.InstancesByObject[child])
				ClearInstance(listening, childDetails)
			else
				if #instanceDetails.Children == 0 then
					RemoteEvent:FireClient(listening.Player, "Update", instanceDetails.Id, { HasChildren = false })
				end
			end
		end)

		return instanceDetails
	end

	function ClearInstance(listening, instanceDetails, skipUpdate)
		if instanceDetails.Listening then
			ClearInstanceListeners(listening, instanceDetails, true)
		end

		for i,v in instanceDetails.Connections do
			v:Disconnect()
		end

		listening.InstancesById[instanceDetails.Id] = nil
		listening.InstancesByObject[instanceDetails.Id] = nil

		if not skipUpdate then
			RemoteEvent:FireClient(listening.Player, "Remove", instanceDetails.Id)
		end
	end

	function InitInstanceListeners(listening, instanceDetails)
		assert(not instanceDetails.Listening)

		instanceDetails.Listening = true

		local children = {}

		for _,child in instanceDetails.Children do
			local childDetails = InitInstance(listening, child)

			table.insert(children, {
				Id = childDetails.Id,
				Name = childDetails.Name,
				ClassName = childDetails.ClassName,
				HasChildren = #childDetails.Children > 0
			})
		end

		RemoteEvent:FireClient(listening.Player, "Update", instanceDetails.Id, { Children = children })
	end

	function ClearInstanceListeners(listening, instanceDetails, skipUpdate)
		assert(instanceDetails.Listening)

		instanceDetails.Listening = false

		for _,child in instanceDetails.Children do
			local childDetails = assert(listening.InstancesByObject[child])
			ClearInstance(listening, childDetails, true)
		end

		if not skipUpdate then
			RemoteEvent:FireClient(listening.Player, "Update", instanceDetails.Id, { HasChildren = #instanceDetails.Children > 0 })
		end
	end

	local ListeningPlayers = {}

	local function StopSelectingInstance(player)
		local listening = ListeningPlayers[player]
		if listening then
			local maid = listening.SelectedInstanceMaid 
			if maid then
				maid:Cleanup()
			end
			listening.SelectedInstance = nil
		end
	end
	local function SelectInstance(player,id)
		if id then
			local listening = ListeningPlayers[player]
			if listening then
				StopSelectingInstance(player)
				local instanceDetails = assert(listening.InstancesById[id])

				if not instanceDetails then
					return
				end

				local instance = instanceDetails.Instance

				local instanceTable = {}

				local classInfo = Classes[instanceDetails.ClassName]
				if not classInfo then
					return
				end

				--[[ Filter out bad properties to send ]]
				for i,info in classInfo.Categorized_Properties do
					local properties = info.list
					for i,propertyInfo in properties do
						local propertyName = propertyInfo.propertyName

						local success,currentValue = pcall(function()
							return instance[propertyName]
						end)

						if not success then
							continue
						end

						local valueType = propertyInfo.valueType
						local tags = propertyInfo.tags

						if tags and (tags.Deprecated or tags.NotScriptable or tags.Hidden) then
							continue
						end

						instanceTable[propertyName] = currentValue
					end
				end

				local attributes = instance:GetAttributes()
				instanceTable.AttributesList = attributes

				local Tree,EventMaid = RepShared:Open(player,instance,classInfo,RemoteEvent)

				listening.SelectedInstance = Tree
				listening.SelectedInstanceMaid = EventMaid
				instanceTable.FullName = instance:GetFullName()


				RemoteEvent:FireClient(player,"OpenProperties",instanceDetails.Id,instanceTable)
			end
		end
	end
	local function RequestPropertyChange(player,path,val)
		local listening = ListeningPlayers[player]
		if listening then
			local selectedInstance = listening.SelectedInstance
			if not selectedInstance then
				return
			end
			if not path or (val == nil) then
				return
			end

			task.spawn(function()
				local foundChild = RepShared:FindFromPath(path,selectedInstance)
				if foundChild then
					if foundChild.SetValue then
						foundChild.SetValue(val)
					end
				end
			end)
		end
	end

	local function StartListening(player, id)
		local listening = ListeningPlayers[player]

		if not listening then
			assert(not id)

			listening = {
				InstancesById = {},
				InstancesByObject = {},
				SelectedInstance = nil,
				Player = player,
				IdCounter = 0
			}

			ListeningPlayers[player] = listening
		end

		if id then
			local instanceDetails = assert(listening.InstancesById[id])
			InitInstanceListeners(listening, instanceDetails)

		else
			assert(not listening.Root)

			local rootDetails = InitInstance(listening, game)
			listening.Root = rootDetails

			RemoteEvent:FireClient(listening.Player, "Init", nil, {
				Id = rootDetails.Id,
				Name = rootDetails.Name,
				ClassName = rootDetails.ClassName,
				HasChildren = #rootDetails.Children > 0
			})
		end
	end

	local function StopListening(player, id)
		local listening = ListeningPlayers[player]
		if not listening then return end

		StopSelectingInstance(player)

		if id == nil then
			ListeningPlayers[player] = nil

			for _,inst in listening.InstancesById do
				for i,v in inst.Connections do
					v:Disconnect()
				end
			end

			RemoteEvent:FireClient(listening.Player, "Remove", nil)
		else
			local instanceDetails = assert(listening.InstancesById[id])
			ClearInstanceListeners(listening, instanceDetails)
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		StopListening(player, nil)
	end)

	RemoteEvent.OnServerEvent:Connect(function(player, message, ...)
		if typeof(message) ~= "string" then
			return
		end

		if not player:IsA("Player") then
			return
		end
		
		local ExplorerPermissions = player:GetAttribute("ExplorerPermissions")
		if not ExplorerPermissions then
			return
		end
		
		local Permissions = HttpService:JSONDecode(ExplorerPermissions)

		if (not table.find(Permissions, "Explorer")) then
			return
		end
		
		if message == "RequestPropertyChange" then
			if (not table.find(Permissions, "ExplorerWrite")) then
				return
			end
			local path,value = ...
			if typeof(path) == "table" then
				warn(string.format("Requesting Property Change %s: %s %s", player.Name, HttpService:JSONEncode(path), tostring(value)))
			else
				warn(string.format("Requesting Property Change %s: %s %s", player.Name, tostring(path), tostring(value)))
			end
		end
		
		if message == "StartListening" or message == "StopListening" then
			if (not table.find(Permissions, "ExplorerServer")) then
				return
			end
		end

		if message == "StartListening" then
			local id = ...
			StartListening(player, id)

		elseif message == "StopListening" then
			local id = ...
			StopListening(player, id)
		elseif message == "SelectInstance" then
			local id = ... 
			SelectInstance(player,id)
		elseif message == "RequestPropertyChange" or message == "RequestAttributeChange" then
			local path,value = ...
			RequestPropertyChange(player,path,value)
		end
	end)

	RemoteFunction.OnServerInvoke = function(player)
		local ExplorerPermissions = player:GetAttribute("ExplorerPermissions")
		if not ExplorerPermissions then
			return
		end

		local Permissions = HttpService:JSONDecode(ExplorerPermissions)

		if (not table.find(Permissions, "Explorer")) then
			return
		end
		return {Classes,Enums}
	end
end