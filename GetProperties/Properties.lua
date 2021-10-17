--@author : KLNX
--- 10/16/21
--- Property mapper
--- Since Roblox does not have their own GetProperties method

--@Services
local HttpService = game:GetService("HttpService")

--@Libraries
local Modules = script.Parent
local Signal = require(script:WaitForChild('FastSignal')); -- pobammer's FastSignal
local fetch = require(Modules:WaitForChild('fetch')); -- sentanos' ProxyService

--@Export module functions
local PropertyModule = {}

--@Public functions
function PropertyModule:HasProperty(Object, Property)
	local PropertyData;
	local HAS_PROPERTY,_ = pcall(function()
		PropertyData = Object[tostring(Property)]
	end)
	
	return HAS_PROPERTY, PropertyData
end

--- Optimization stuff lel
local _HasProperty = PropertyModule.HasProperty

function PropertyModule:CreateVirtualMap(Object)
	--- All retrieved property values can be accessed by => MAP_OBJECT.Properties.PROPERTY_NAME.Data
	--- A relatively quick method of getting properties?
	--- The property map will also include functions; e.g. GetChildren, GetActor, ChildAdded
	
	if (not self.isLoaded) then return error("Properties module has not loaded yet") end -- Make sure our classes have loaded
	local _Start = os.clock() -- Debugging
	local Object_Information = {} -- Our property map
	local robloxApiDumpClasses = self.propertyMap.Classes
	
	Object_Information.Properties = {}
	for index, Class_Information in pairs(robloxApiDumpClasses) do
		--- Property_Information : {}
		local Property_Class = Class_Information.Name
		local Property_SuperClass = Class_Information.Superclass
		
		if (Object:IsA(Property_Class) or Object:IsA(Property_SuperClass)) then -- If this object is apart of this class
			local Property_Members = Class_Information.Members
			
			for ListIndex, Property_Information in pairs(Property_Members) do
				if (not Object_Information.Properties[Property_Information.Name]) then -- If we haven't already added this?
					local _HasProperty, PropertyData = _HasProperty(Object, Property_Information.Name)
					if (_HasProperty) then -- If the object truly has this property
						Object_Information.Properties[Property_Information.Name] = {
							Data = PropertyData,
							DataString = tostring(PropertyData), -- string
							PropertyName = Property_Information.Name, -- string
							PropertyType = Property_Information.ValueType, -- {}
							PropertyTags = Property_Information.Tags, -- {}
							Checked = os.clock() -- Keep track of when we listed this property
						}
					end
				end
			end
		end
	end
	
	Object_Information.Attributes = {} -- Add support for attributes
	local Object_Attributes = Object:GetAttributes()
	for AttributeName, AttributeValue in pairs(Object_Attributes) do
		Object_Information.Attributes[AttributeName] = {
			Data = AttributeValue,
			DataString = tostring(AttributeValue),
			Checked = os.clock() -- Keep track of when we listed this attribute
		}
	end
	
	Object_Information.__PropertyData = { TimeTaken = (os.clock() - _Start) }
	return Object_Information -- Our property map
end

function PropertyModule:Init()
	self.isLoaded = false
	self.Loaded = Signal.new()
	
	coroutine.wrap(function()
		--- Loading the current API classes actually takes quite a bit
		
		local studioVersion = fetch:GetAsync("http://setup.roblox.com/versionQTStudio").body -- You can use "Get" if you don't have GetAsync
		local robloxApiDump = HttpService:JSONDecode(fetch:GetAsync("http://setup.roblox.com/"..studioVersion.."-API-Dump.json").body)
		local propertyMap = robloxApiDump or error("Properties API did not load correctly")
		
		self.propertyMap = propertyMap
		self.isLoaded = true
		self.Loaded:Fire(os.clock()) -- Tell our connections that we've loaded
		self.Loaded:Destroy() -- Destroy the signal
	end)()
	
	return self
end

--@Aliases
PropertyModule.GetProperties = PropertyModule.CreateVirtualMap

return PropertyModule
