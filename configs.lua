local ConfigSystem = {}

local HttpService = game:GetService("HttpService")

local function Color3ToTable(Color3)
	return {
		["R"] = Color3.R,
		["G"] = Color3.G,
		["B"] = Color3.B
	}
end

local function TableToColor3(Table)
	return Color3.fromRGB(Table["R"] * 255,Table["G"] * 255,Table["B"] * 255)
end

local function shallowcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

local function Compare(Table,Default)
	local TableCopy = {}
	for Index,Value in pairs(Default) do
		TableCopy[Index] = Index
	end
	for Index,Value in pairs(Table) do
		if Index ~= TableCopy[Index] then
			Table[Index] = nil
		end
	end
end

function ConfigSystem.WriteJSON(Table)
    local TableCopy = shallowcopy(Table)
	for Index,Value in pairs(TableCopy) do
		if typeof(Value) == "Color3" then
			TableCopy[Index] = Color3ToTable(Value)
		end
	end
	return HttpService:JSONEncode(TableCopy)
end

function ConfigSystem.ReadJSON(JSON,Default)
	local Table = HttpService:JSONDecode(JSON)
	Compare(Table,Default)
	for Index,Value in pairs(Table) do
		if typeof(Value) == "table" and (Value["R"] and Value["G"] and Value["B"]) then
			Table[Index] = TableToColor3(Value)
		end
	end
	return Table
end

return ConfigSystem
