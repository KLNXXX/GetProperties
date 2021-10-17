local Properties = require(PATH.TO.MODULE):Init()

--- Signal collection
Properties.Loaded:Connect(function(LoadFinish)
	local TestObject = Instance.new("Part")
	TestObject:SetAttribute("Cool", true)
	
	print(Properties:CreateVirtualMap(TestObject))	
end)

--- Alternate method of waiting for load
Properties.Loaded:Wait()

local TestObject = Instance.new("Part")
TestObject:SetAttribute("Cool", true)
print(Properties:CreateVirtualMap(TestObject))