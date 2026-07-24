local lua = {}
lua.instance = {}

lua.contains = function(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

lua.Switch = function(value, switch)
	if not switch["default"] then
		switch["default"] = function() end
	end
	local f = switch[value]
	if(f) then
		return f
	else
		return switch["default"]
	end
end

return lua
