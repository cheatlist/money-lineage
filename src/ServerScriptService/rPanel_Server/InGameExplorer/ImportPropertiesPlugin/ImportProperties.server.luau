--[[ Lets you import properties copied to your clipboard from the Export button in-game 
	To install, right click on ImportPropertiesPlugin and save as a local plugin
]]

if not plugin then
	return
end

local HttpService = game:GetService("HttpService")

local toolbar = plugin:CreateToolbar("InGameExplorer")
local button = toolbar:CreateButton("Import", "Import Properties", "http://www.roblox.com/asset/?id=15303465988")
button.ClickableWhenViewportHidden = true

local Modules = script.Parent.Modules
local Components = script.Parent.Components
local Maid = require(Modules.Maid)
local ValueToString,StringToValue = unpack(require(Modules.DataConverter))

local ToolMaid = Maid.new()

local Fusion = require(Modules.Fusion)

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


local CoreGui = game:GetService("CoreGui")
pcall(function()
	CoreGui.InGameExplorer_ImportUI:Destroy()
end)
local UI = script.Parent.InGameExplorer_ImportUI
UI.Enabled = false
UI.Parent = CoreGui

local ImportFrame = UI.ImportFrame
local ImportList = UI.ImportList

local ToolEnabled = Fusion.Value(false)
local DropdownEnabled = Fusion.Value(false)

local ProcessPaths = {}

local function GetList(text)
	local success,jsonTable = pcall(function()
		return HttpService:JSONDecode(text)
	end)
	local function decode(list)
		for propertyName,value in list do 
			local success,realValue = pcall(function() return StringToValue(value) end)
			if success and realValue then
				list[propertyName] = realValue
			else
				list[propertyName] = nil
			end
		end
	end
	if success and jsonTable then
		for namePath,data in jsonTable do
			decode(data.attributes)
			decode(data.properties)
		end
		return jsonTable
	end
end
local function GetInstanceFromNamePath(namePath)
	local root = game
	local list = string.split(namePath,".")
	local foundInstance
	for i,v in list do 
		local instance = root:FindFirstChild(v)
		if instance then
			if i == #list then
				foundInstance = instance
			end
			root = instance
		else
			break
		end
	end
	if foundInstance then
		local parent = foundInstance.Parent
		local duplicateFound
		for i,v in parent:GetChildren() do
			if v == foundInstance then
				continue
			end
			if v.Name == foundInstance.Name then 
				duplicateFound = true
				break
			end
		end
		return foundInstance,duplicateFound		
	end
end

local function ProcessList(list)
	table.clear(ProcessPaths)
	DropdownEnabled:set(true)
	for namePath,data in list do
		local instance,duplicate = GetInstanceFromNamePath(namePath)
		if instance and not duplicate then
			local process = Fusion.Value(true)
			local checkBox = Checkbox{
				Text = namePath,
				Value = process,
				OnChange = function(val)
					process:set(val)
				end,
				Parent = ImportList.ScrollingFrame,
				Size = UDim2.new(1,0,0,25)
			}
			Instance.new("UIPadding",checkBox).PaddingLeft = UDim.new(0,5)
			ToolMaid:Add(checkBox)
			ProcessPaths[namePath] = {process = process,namePath = namePath,data = data}
		end
	end	
end


local function CloseTool()
	ToolEnabled:set(false)
	DropdownEnabled:set(false)
end

local function FinalProcessList()
	if not ProcessPaths then
		return
	end
	
	for i,info in ProcessPaths do
		if not info.process:get() then
			continue
		end
		local instance = GetInstanceFromNamePath(info.namePath)
		if not instance then
			continue
		end
		local data = info.data
		for propertyName,propertyValue in data.properties do
			local success,err = pcall(function()
				instance[propertyName] = propertyValue
			end)
			if success then
				print(string.format("Wrote property %s to %s - value: %s",propertyName,info.namePath,tostring(propertyValue)))
			end
		end
		for attributeName,attributeValue in data.attributes do
			local success,err = pcall(function()
				instance:SetAttribute(attributeName,attributeValue)
			end)
			if success then
				print(string.format("Wrote attribute %s to %s - value: %s",attributeName,info.namePath,tostring(attributeValue)))
			end
		end
	end
	
	CloseTool()
end

ImportList.Button.MouseButton1Down:Connect(function()
	FinalProcessList()
end)
ImportList.Cancel.MouseButton1Down:Connect(CloseTool)
ImportFrame.Button.MouseButton1Down:Connect(CloseTool)

button.Click:Connect(function()
	if ToolEnabled:get() == true then
		ToolEnabled:set(false)
	else
		ToolEnabled:set(true)
		local connection
		connection = ImportFrame.TextBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				connection:Disconnect()
				
				local list = GetList(ImportFrame.TextBox.Text)
				if list then
					ProcessList(list)
				else
					ToolEnabled:set(false)
				end
			end
		end)
		ToolMaid:Add(function()
			ImportFrame.TextBox:ReleaseFocus()
			ImportFrame.TextBox.Text = ""
		end)
		ToolMaid:Add(connection)
	end
end)

Fusion.Observer(ToolEnabled):onChange(function()
	if not ToolEnabled:get() then
		ToolMaid:Cleanup()
	end
end)
Fusion.Hydrate(UI)
{
	Enabled = ToolEnabled	
}
Fusion.Hydrate(ImportFrame)
{
	Visible = Fusion.Computed(function()
		return ToolEnabled:get() and not DropdownEnabled:get()
	end)
}
Fusion.Hydrate(ImportList)
{
	Visible = DropdownEnabled
}


