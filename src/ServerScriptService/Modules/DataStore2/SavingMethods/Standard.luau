-- Standard saving of data stores
-- The key you provide to DataStore2 is the name of the store with GetDataStore
-- GetAsync/UpdateAsync are then called based on the user ID
local DataStoreServiceRetriever = require(script.Parent.Parent.DataStoreServiceRetriever)
local Promise = require(script.Parent.Parent.Promise)

local Standard = {}
Standard.__index = Standard



	function Standard:Get(id, store)
	return Promise.async(function(resolve)
		resolve(store:GetAsync(id))
	end)
end

function Standard:Set(value, id, store)
	return Promise.async(function(resolve)
		store:UpdateAsync(id, function()
			return value
		end)

		resolve()
	end)
end

function Standard.new(dataStore2)
	setmetatable(dataStore2, Standard)
	Standard.userId = dataStore2.UserId
	Standard.dataStore = game:GetService("DataStoreService"):GetDataStore(dataStore2.Name)
end


return Standard

