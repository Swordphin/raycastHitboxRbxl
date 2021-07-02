--!strict
--- Cache LineHandleAdornments or create new ones if not in the cache
-- @author Swordphin123

-- Debug / Test ray visual options
local DEFAULT_DEBUGGER_RAY_COLOUR: Color3 = Color3.fromRGB(255, 0, 0)
local DEFAULT_DEBUGGER_RAY_WIDTH: number = 4
local DEFAULT_DEBUGGER_RAY_NAME: string = "_RaycastHitboxDebugLine"
local DEFAULT_FAR_AWAY_CFRAME: CFrame = CFrame.new(0, math.huge, 0)

local cache = {}
cache.__index = cache
cache.__type = "RaycastHitboxVisualizerCache"
cache._AdornmentInUse = {}
cache._AdornmentInReserve = {}

--- AdornmentData type
export type AdornmentData = {
	Adornment: LineHandleAdornment,
	LastUse: number
}

--- Internal function to create an AdornmentData type
--- Creates a LineHandleAdornment and a timer value
function cache:_CreateAdornment(): AdornmentData
	local line: LineHandleAdornment = Instance.new("LineHandleAdornment")
	line.Name = DEFAULT_DEBUGGER_RAY_NAME
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
end

--- Gets an AdornmentData type. Creates one if there isn't one currently available.
function cache:GetAdornment(): AdornmentData?
	if #cache._AdornmentInReserve <= 0 then
		--- Create a new LineAdornmentHandle if none are in reserve
		local adornment: AdornmentData = cache:_CreateAdornment()
		table.insert(cache._AdornmentInReserve, adornment)
	end

	local adornment: AdornmentData? = table.remove(cache._AdornmentInReserve, 1)

	if adornment then
		adornment.Adornment.Visible = true
		adornment.LastUse = os.clock()
		table.insert(cache._AdornmentInUse, adornment)
	end

	return adornment
end

--- Returns an AdornmentData back into the cache.
-- @param AdornmentData
function cache:ReturnAdornment(adornment: AdornmentData)
	adornment.Adornment.Length = 0
	adornment.Adornment.Visible = false
	adornment.Adornment.CFrame = DEFAULT_FAR_AWAY_CFRAME
	table.insert(cache._AdornmentInReserve, adornment)
end

--- Clears the cache in reserve. Should only be used if you want to free up some memory.
--- If you end up turning on the visualizer again for this session, the cache will fill up again.
--- Does not clear adornments that are currently in use.
function cache:Clear()
	for i = #cache._AdornmentInReserve, 1, -1 do
		if cache._AdornmentInReserve[i].Adornment then
			cache._AdornmentInReserve[i].Adornment:Destroy()
		end

		table.remove(cache._AdornmentInReserve, i)
	end
end

return cache