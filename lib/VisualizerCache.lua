--!strict
--- Cache LineHandleAdornments or create new ones if not in the cache
-- @author Swordphin123

-- Debug / Test ray visual options
local DEFAULT_DEBUGGER_RAY_COLOUR: Color3 = Color3.fromRGB(255, 0, 0)
local DEFAULT_DEBUGGER_RAY_WIDTH: number = 4
local DEFAULT_DEBUGGER_RAY_NAME: string = "_RaycastHitboxDebug%s"
local DEFAULT_FAR_AWAY_CFRAME: CFrame = CFrame.new(0, math.huge, 0)

local cache = {}
cache.__index = cache
cache.__type = "RaycastHitboxVisualizerCache"
cache._AdornmentInUse = {
	[1] = {},
	[2] = {},
	[3] = {},
}
cache._AdornmentInReserve = {
	[1] = {},
	[2] = {},
	[3] = {},
}

--- AdornmentData type
export type AdornmentData = {
	Adornment: LineHandleAdornment | CylinderHandleAdornment | BoxHandleAdornment,
	LastUse: number
}

--- Internal function to create an AdornmentData type
--- Creates a LineHandleAdornment and a timer value
function cache:_CreateAdornment(ShapecastMode: number): AdornmentData
	if ShapecastMode == 1 then
		local line: LineHandleAdornment = Instance.new("LineHandleAdornment")
		line.Name = string.format(DEFAULT_DEBUGGER_RAY_NAME, "Line")
		line.Color3 = DEFAULT_DEBUGGER_RAY_COLOUR
		line.Thickness = DEFAULT_DEBUGGER_RAY_WIDTH

		line.Length = 0
		line.CFrame = DEFAULT_FAR_AWAY_CFRAME

		line.Adornee = workspace.Terrain
		line.Parent = workspace.Terrain

		return {
			Adornment = line,
			LastUse = 0
		}
	elseif ShapecastMode == 2 then
		local cylinder: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
		cylinder.Name = string.format(DEFAULT_DEBUGGER_RAY_NAME, "Cylinder")
		cylinder.Color3 = DEFAULT_DEBUGGER_RAY_COLOUR

		cylinder.Radius = 0
		cylinder.Height = 0
		cylinder.CFrame = DEFAULT_FAR_AWAY_CFRAME

		cylinder.Adornee = workspace.Terrain
		cylinder.Parent = workspace.Terrain

		return {
			Adornment = cylinder,
			LastUse = 0
		}
	elseif ShapecastMode == 3 then
		local box: BoxHandleAdornment = Instance.new("BoxHandleAdornment")
		box.Name = string.format(DEFAULT_DEBUGGER_RAY_NAME, "Box")
		box.Color3 = DEFAULT_DEBUGGER_RAY_COLOUR

		box.Size = Vector3.zero
		box.CFrame = DEFAULT_FAR_AWAY_CFRAME

		box.Adornee = workspace.Terrain
		box.Parent = workspace.Terrain

		return {
			Adornment = box,
			LastUse = 0
		}
	end
end

--- Gets an AdornmentData type. Creates one if there isn't one currently available.
function cache:GetAdornment(ShapecastMode: number): AdornmentData?
	if #cache._AdornmentInReserve[ShapecastMode] <= 0 then
		--- Create a new LineAdornmentHandle if none are in reserve
		local adornment: AdornmentData = cache:_CreateAdornment(ShapecastMode)
		table.insert(cache._AdornmentInReserve[ShapecastMode], adornment)
	end

	local adornment: AdornmentData? = table.remove(cache._AdornmentInReserve[ShapecastMode], 1)

	if adornment then
		adornment.Adornment.Visible = true
		adornment.LastUse = os.clock()
		table.insert(cache._AdornmentInUse[ShapecastMode], adornment)
	end

	return adornment
end

--- Returns an AdornmentData back into the cache.
-- @param AdornmentData
function cache:ReturnAdornment(adornment: AdornmentData)
	local ShapecastMode: number = 1
	if adornment.Adornment:IsA("LineHandleAdornment") then
		adornment.Adornment.Length = 0
		ShapecastMode = 1
	elseif adornment.Adornment:IsA("CylinderHandleAdornment") then
		adornment.Adornment.Radius = 0
		adornment.Adornment.Height = 0
		ShapecastMode = 2
	elseif adornment.Adornment:IsA("BoxHandleAdornment") then
		adornment.Adornment.Size = Vector3.zero
		ShapecastMode = 3
	end

	adornment.Adornment.Visible = false
	adornment.Adornment.CFrame = DEFAULT_FAR_AWAY_CFRAME
	table.insert(cache._AdornmentInReserve[ShapecastMode], adornment)
end

--- Clears the cache in reserve. Should only be used if you want to free up some memory.
--- If you end up turning on the visualizer again for this session, the cache will fill up again.
--- Does not clear adornments that are currently in use.
function cache:Clear()
	for _, reserveCache in cache._AdornmentInReserve do
		for i = #reserveCache, 1, -1 do
			if reserveCache[i].Adornment then
				reserveCache[i].Adornment:Destroy()
			end

			table.remove(reserveCache, i)
		end
	end
end

return cache