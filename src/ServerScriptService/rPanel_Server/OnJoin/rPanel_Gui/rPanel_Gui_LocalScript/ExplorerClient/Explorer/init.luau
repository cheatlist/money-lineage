local ContextAction = game:GetService("ContextActionService")

local Explorer = {}

local Components = script.Parent.Components
local Modules = script.Parent.Modules

local Shared = require(script.Parent.Shared)
local Fusion = require(Modules.Fusion)
local Maid = require(Modules.Maid)
local InstanceIcons = require(script.InstanceIcons)

local StudioComponents = Components.StudioComponents
local Slider = require(StudioComponents.Slider)
local Label = require(StudioComponents.Label)
local Background = require(StudioComponents.Background)
local Button = require(StudioComponents.Button)
local ProgressBar = require(StudioComponents.ProgressBar)
local Checkbox = require(StudioComponents.Checkbox)
local BoxBorder = require(StudioComponents.BoxBorder)
local TextInput = require(StudioComponents.TextInput)
local ScrollFrame = require(StudioComponents.ScrollFrame)
local VerticalExpandingList = require(StudioComponents.VerticalExpandingList)
local Dropdown = require(StudioComponents.Dropdown)
local ColorPicker = require(StudioComponents.ColorPicker)
local IconButton = require(StudioComponents.IconButton)
local Loading = require(StudioComponents.Loading)
local VerticalCollapsibleSection = require(StudioComponents.VerticalCollapsibleSection)

local ExplorerMaid = Maid.new()

local CachedNumOpenDescendants = {}
local CachedButtons = {}

local function ChildSortFunction(a, b)
	local aClass = a.ClassName and Explorer.Classes[a.ClassName]
	local bClass = b.ClassName and Explorer.Classes[b.ClassName]
	
	local aOrder = tonumber((aClass and aClass.ExplorerOrder) or 2^53)
	local bOrder = tonumber((bClass and bClass.ExplorerOrder) or 2^53)
			
	return if aOrder ~= bOrder then aOrder < bOrder else a.Name < b.Name
end

local function GetSortedChildren(instance)
	local children = instance:GetChildren()
	table.sort(children, ChildSortFunction)
	return children
end

local ClientView = {
	"Workspace",
	"Players",
	"Lighting",
	"ReplicatedStorage"
}

local ExplorerPadding = 15
local ButtonHeight = 20

function BinSearch(list, entry, sortFn)
	local left = 1
	local right = #list

	while left <= right do
		local middle = math.floor((left + right) / 2)

		if ChildSortFunction(entry, list[middle]) then
			right = middle - 1
		else
			left = middle + 1
		end
	end

	return left
end

function Explorer:InitEntry(entry, initChildren)
	local instance = entry.Instance
	
	if not entry.ClassName then
		entry.ClassName = instance.ClassName
		entry.Name = instance.Name
		
		entry.NameChanged = instance:GetPropertyChangedSignal("Name"):Connect(function()
			entry.Name = instance.Name
			self:RefreshExplorer(true)
		end)
		
		entry.ChildAdded = instance.ChildAdded:Connect(function(child)
			if instance == game then
				if not table.find(ClientView, child.ClassName) then
					return
				end
			end
			
			if entry.Children then
				local childEntry = self:InitEntry({ Instance = child, Parent = entry }, false)
				local index = BinSearch(entry.Children, childEntry, ChildSortFunction)
				
				table.insert(entry.Children, index, childEntry)
				self:RefreshExplorer()
			else
				if entry.HasChildren == false then
					entry.HasChildren = true
					self:RefreshExplorer(true)
				end
			end
		end)
		
		entry.ChildRemoved = instance.ChildRemoved:Connect(function(child)
			if instance == game then
				if not table.find(ClientView, child.ClassName) then
					return
				end
			end
			
			if entry.Children then
				for i,v in entry.Children do
					if v.Instance == child then
						table.remove(entry.Children, i)
						self:ClearEntry(v)
						break
					end
				end
				
				self:RefreshExplorer()
			else
				if entry.HasChildren == true then
					entry.HasChildren = nil
					self:RefreshExplorer(true)
				end
			end
		end)
	end
	
	if not entry.Children and initChildren then
		entry.Children = instance:GetChildren()
		entry.HasChildren = nil
		
		for i = #entry.Children, 1, -1 do
			local child = entry.Children[i]
			
			if instance == game then
				if not table.find(ClientView, child.ClassName) then
					table.remove(entry.Children, i)
					continue
				end
			end
			
			entry.Children[i] = self:InitEntry({ Instance = child, Parent = entry }, false)
		end
		
		table.sort(entry.Children, ChildSortFunction)
	end
	
	return entry
end

function Explorer:ClearEntryChildren(entry)
	if entry.Children then
		local children = entry.Children
		entry.Children = nil
		
		for i,v in children do
			self:ClearEntry(v)
		end
	end
end

function Explorer:ClearEntry(entry)
	self:ClearEntryChildren(entry)
	
	if entry.NameChanged then
		entry.NameChanged:Disconnect()
		entry.NameChanged = nil
		
		entry.ChildAdded:Disconnect()
		entry.ChildAdded = nil
		
		entry.ChildRemoved:Disconnect()
		entry.ChildRemoved = nil
	end
end

function Explorer:CreateButton()
	local cachedButton = {
		Button = self.InstanceTemplate:Clone(),
		Instance = nil
	}
	
	local instanceButton = cachedButton.Button
	
	local instanceButtonFrame = instanceButton.Frame
	local instanceButtonHover = instanceButton.Hover
	local instanceButtonSelected = instanceButton:FindFirstChild("Selected")
	
	instanceButton.MouseEnter:Connect(function()
		local instance = cachedButton.Instance
		if not instance then return end
		
		if Shared.ListeningServer:get() then
			if self.ServerSelected == instance.Id then
				return
			end
		else
			if Shared.SelectedInstance:get() == instance then
				return
			end
		end
		
		if self.HoveredButton then
			self.HoveredButton.Visible = false
		end
		
		self.HoveredButton = instanceButtonHover
		instanceButtonHover.Visible = true
	end)
	
	instanceButton.MouseLeave:Connect(function()
		local instance = cachedButton.Instance
		if not instance then return end
		
		if self.HoveredButton == instanceButtonHover then
			self.HoveredButton = nil
			instanceButtonHover.Visible = false
		end
	end)
	
	instanceButton.MouseButton1Down:Connect(function()
		local instance = cachedButton.Instance
		if not instance then return end
		
		instanceButtonSelected.Visible = true
		
		if Shared.ListeningServer:get() then
			self.ServerSelected = instance.Id
			Shared.RemoteEvent:FireServer("SelectInstance", instance.Id)
		else
			Shared.SelectedInstance:set(instance)
		end
		
		self:RefreshExplorer(true)
	end)
	
	instanceButtonFrame.Arrow.MouseButton1Down:Connect(function()
		local instance = cachedButton.Instance
		if not instance then return end
		
		if Shared.ListeningServer:get() then
			if self.ServerIsExpanded[instance.Id] then
				self.ServerIsExpanded[instance.Id] = nil
				Shared.RemoteEvent:FireServer("StopListening", instance.Id)
			else
				self.ServerIsExpanded[instance.Id] = true
				Shared.RemoteEvent:FireServer("StartListening", instance.Id)
			end
		else
			if self.IsExpanded[instance] then
				self.IsExpanded[instance] = nil
			else
				self.IsExpanded[instance] = true
			end
		end
		
		--[[ Trigger explorer refresh ]]
		self:RefreshExplorer()
	end)
	
	return cachedButton
end

function Explorer:UpdateExplorer(Parent, entry, layer, order,  index, drawStart, drawEnd)
	local ServerView = Shared.ListeningServer:get()
	
	local IsCollapsed = true
	
	local instanceChildren
	local instance
	
	if ServerView then
		instance = entry
		IsCollapsed = not self.ServerIsExpanded[instance.Id]
		
		instanceChildren = instance.Children
	else
		instance = entry.Instance
		IsCollapsed = not self.IsExpanded[instance]
		
		if IsCollapsed then
			self:ClearEntryChildren(entry)
		else
			self:InitEntry(entry, true)
		end
		
		instanceChildren = entry.Children
	end
	
	if index >= drawStart and index <= drawEnd then
		local HasChildren = false
		
		if ServerView then
			HasChildren = if instanceChildren then #instanceChildren > 0 else instance.HasChildren
		else
			if not instanceChildren and entry.HasChildren == nil then
				entry.HasChildren = instance:FindFirstChildWhichIsA("Instance") ~= nil
			end
			
			HasChildren = if instanceChildren then #instanceChildren > 0 else entry.HasChildren
		end
		
		local instanceName = instance.Name
		local cachedButton = CachedButtons[index - drawStart + 1]
		
		if not cachedButton then
			cachedButton = self:CreateButton()
			CachedButtons[index - drawStart + 1] = cachedButton
		end
		
		cachedButton.Instance = instance
		
		local instanceButton = cachedButton.Button
		--instanceButton.LayoutOrder = order
		instanceButton.Name = instanceName
		instanceButton.Parent = self.ExplorerWindow
		instanceButton.Position = UDim2.new(0, 0, 0, index * ButtonHeight)

		local instanceButtonFrame = instanceButton.Frame
		local instanceButtonHover = instanceButton.Hover
		local instanceButtonSelected = instanceButton:FindFirstChild("Selected")

		instanceButtonFrame.InstanceName.Text = instanceName
		instanceButtonFrame.Arrow.Rotation = IsCollapsed and -90 or 0
		
		--

		--[[ Instance icons ]]
		local instanceIcon = instanceButtonFrame.IconButton.Icon
		InstanceIcons(instance.ClassName,instanceIcon,"px_32")
		--

		local paddingx = layer * ExplorerPadding

		if (not HasChildren) and layer == 0 then
			paddingx -= ExplorerPadding
		end

		instanceButtonFrame.UIPadding.PaddingLeft = UDim.new(0,paddingx)
		instanceButtonFrame.Arrow.Visible = HasChildren
		
		local selectedInstance = Shared.SelectedInstance:get()
		
		local IsSelected
		if ServerView then
			IsSelected = self.ServerSelected == instance.Id
		else
			IsSelected = selectedInstance == instance
		end

		instanceButtonSelected.Visible = IsSelected
	end
	
	index += 1
	order += 1
	
	if not IsCollapsed and instanceChildren then
		local cachedNumOpenDescendants = CachedNumOpenDescendants[entry]
		local skipChildren = false
		
		if cachedNumOpenDescendants and index + cachedNumOpenDescendants <= drawStart then
			skipChildren = true
			index += cachedNumOpenDescendants
		end
		
		if not skipChildren then
			local startIndex = index
			
			for i = 1, #instanceChildren do 
				local child = instanceChildren[i]
				
				if CachedNumOpenDescendants[child] and index + 1 + CachedNumOpenDescendants[child] <= drawStart then
					index += 1 + CachedNumOpenDescendants[child]
					continue
				end
				
				order, index = self:UpdateExplorer(instance, child, layer + 1, order,  index, drawStart, drawEnd)
				
				if cachedNumOpenDescendants and index > drawEnd then
					index = startIndex + cachedNumOpenDescendants
					break
				end
			end
			
			if not cachedNumOpenDescendants then
				CachedNumOpenDescendants[entry] = index - startIndex
			end
		end
	end
	
	return order, index
end

function Explorer:RefreshExplorer(keepCache)
	if not Shared.ToolEnabled:get() then
		return
	end
	
	self.ShouldRefreshOnCanvasChanged = false
	
	ExplorerMaid:Cleanup()
	
	if not keepCache then
		table.clear(CachedNumOpenDescendants)
	end
	
	local canvasPos = self.ExplorerWindow.CanvasPosition
	local drawStart = math.max(0, math.floor(canvasPos.Y / ButtonHeight) - 5)
	local drawEnd = math.ceil((canvasPos.Y + self.ExplorerWindow.AbsoluteWindowSize.Y) / ButtonHeight) + 5
	
	local order, index
	
	if Shared.ListeningServer:get() then
		if self.LatestTree then
			order, index = self:UpdateExplorer(nil, self.LatestTree, 0, 0,  0, drawStart, drawEnd)
		end
	else
		if not self.LatestClientTree then
			self.LatestClientTree = { Instance = game }
		end
		
		order, index = self:UpdateExplorer(nil, self.LatestClientTree, 0, 0,  0, drawStart, drawEnd)
	end
	
	for i = #CachedButtons, math.max(1, index - drawStart + 1), -1 do
		CachedButtons[i].Button:Destroy()
		CachedButtons[i] = nil
	end
	
	self.ExplorerWindow.CanvasSize = UDim2.new(0, 0, 0, index * ButtonHeight)
	self.ExplorerWindow.CanvasPosition = canvasPos
	
	if math.abs(self.ExplorerWindow.CanvasPosition.Y - canvasPos.Y) > 1 and not self.ScrollFix then
		-- If canvas size changing caused canvasposition to change, we gotta refresh again
		self.ScrollFix = true
		self:RefreshExplorer(true)
		self.ScrollFix = nil
	end
	
	self.ShouldRefreshOnCanvasChanged = true
end

function Explorer:Init(UI,Classes)
	Explorer.Classes = Classes
	local Body = UI.Explorer.Body
	local TopBar = Body.TopBar
	local ExplorerWindow = Body.ScrollingFrame
	local InstanceTemplate = ExplorerWindow.InstanceTemplate:Clone()
	ExplorerWindow.InstanceTemplate:Destroy()
	
	self.InstanceTemplate = InstanceTemplate
	self.ExplorerWindow = ExplorerWindow
	
	self.ExplorerWindow:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if self.ShouldRefreshOnCanvasChanged then
			self:RefreshExplorer(true)
		end
	end)
	
	self.ExplorerWindow:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		if self.ShouldRefreshOnCanvasChanged then
			self:RefreshExplorer(true)
		end
	end)
	
	local ServerViewBox = Checkbox 
	{

		Size = UDim2.fromOffset(250,32),
		Position = UDim2.fromOffset(5,0),
		Parent = TopBar,
		LayoutOrder = 0,
		Text = "Server View",
		Value = Shared.ServerView,
		OnChange = function(newValue)
			Shared.ServerView:set(newValue)
		end,
		Visible = true
	}
	
	
	Fusion.Observer(Shared.ListeningServer):onChange(function()
		local listening = Shared.ListeningServer:get()
		
		if listening then
			ExplorerMaid:Cleanup()
			Shared.RemoteEvent:FireServer("StartListening", nil)
		else
			ExplorerMaid:Cleanup()
			Shared.RemoteEvent:FireServer("StopListening", nil)
			self:RefreshExplorer()
		end
	end)
	
	self.ServerInstances = {}
	self.ServerIsExpanded = {}
	self.ServerIsSelected = {}
	
	self.IsExpanded = {}
	self.IsSelected = {}
	
	local refreshing
	
	local function Remove(instance)
		self.ServerInstances[instance.Id] = nil
		self.ServerIsExpanded[instance.Id] = nil
		
		if self.ServerSelected == instance.Id then
			self.ServerSelected = nil
		end
		
		if instance.Children then
			local children = instance.Children
			instance.Children = nil
			
			for i,v in children do
				Remove(v)
			end
		end
		
		if instance.Parent and instance.Parent.Children then
			local index = assert(table.find(instance.Parent.Children, instance))
			table.remove(instance.Parent.Children, index)
		end
		
		refreshing = refreshing or task.defer(function()
			refreshing = nil
			self:RefreshExplorer()
		end)
	end
	
	Shared.RemoteEvent.OnClientEvent:Connect(function(message, ...)
		if message == "Init" then
			local parentId, details = ...
			local parent
			
			if parentId == nil then
				assert(not self.LatestTree)
				self.LatestTree = details
			else
				parent = self.ServerInstances[parentId]
				details.Parent = parent
				
				local index = BinSearch(parent.Children, details, ChildSortFunction)
				table.insert(parent.Children, index, details)
			end
			
			self.ServerInstances[details.Id] = details
			
			if details.Children then
				for i,v in details.Children do
					self.ServerInstances[v.Id] = v
					v.Parent = details
				end
				
				table.sort(details.Children, ChildSortFunction)
			end
			
			refreshing = refreshing or task.defer(function()
				refreshing = nil
				self:RefreshExplorer()
			end)
		
		elseif message == "Update" then
			local instanceId, changes = ...
			local inst = assert(self.ServerInstances[instanceId])
			
			if changes.HasChildren ~= nil and inst.Children then
				-- We set HasChildren to a value when server stops replicating children, so clear Children here
				local children = inst.Children
				inst.Children = nil
				
				for i,v in children do
					Remove(v)
				end
			end
			
			for i,v in changes do
				inst[i] = v
			end
			
			if changes.Children then
				for i,v in changes.Children do
					self.ServerInstances[v.Id] = v
					v.Parent = inst
				end
				
				table.sort(changes.Children, ChildSortFunction)
			end
			
			refreshing = refreshing or task.defer(function()
				refreshing = nil
				self:RefreshExplorer()
			end)
		
		elseif message == "Remove" then
			local instanceId = ...
			
			if instanceId == nil then
				self.LatestTree = nil
				self.ServerInstances = {}
				self.ServerIsExpanded = {}
				self.ServerSelected = nil
				return
			end
			
			local instance = assert(self.ServerInstances[instanceId])
			Remove(instance)
		end
	end)
	
	self:RefreshExplorer()
	
	Fusion.Hydrate(UI.Explorer)
	{
		Visible = Fusion.Computed(function()
			return Shared.ExportFrameEnabled:get() == false
		end)
	}
	
	Fusion.Observer(Shared.ToolEnabled):onChange(function()
		local enabled = Shared.ToolEnabled:get()
		ExplorerMaid:Cleanup()
		self:RefreshExplorer()
	end)
end

return Explorer
