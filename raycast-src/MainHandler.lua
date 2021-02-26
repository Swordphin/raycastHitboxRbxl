-- [[ Services ]]
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- [[ Constants ]]
local SYNC_RATE = RunService.Heartbeat
local MAIN = script.Parent

-- [[ Variables ]
local ActiveHitboxes = {}
local Handler = {}
local clock = os.clock


--------
function Handler:add(hitboxObject)
	assert(typeof(hitboxObject) ~= "Instance", "Make sure you are initializing from the Raycast module, not from this handler.")
	table.insert(ActiveHitboxes, hitboxObject)
end

function Handler:remove(object)
	for i in ipairs(ActiveHitboxes) do
		if ActiveHitboxes[i].object == object then
			ActiveHitboxes[i]:Destroy()
			setmetatable(ActiveHitboxes[i], nil)
			table.remove(ActiveHitboxes, i)
		end
	end
end

function Handler:check(object)
	for _, hitbox in ipairs(ActiveHitboxes) do
		if hitbox.object == object then
			return hitbox
		end
	end
end

function OnTagRemoved(object)
	Handler:remove(object)
end

CollectionService:GetInstanceRemovedSignal("RaycastModuleManaged"):Connect(OnTagRemoved)


--------
SYNC_RATE:Connect(function()
	for Index, Object in ipairs(ActiveHitboxes) do
		if Object.deleted then
			Handler:remove(Object.object)
		else
			for _, Point in ipairs(Object.points) do
				if not Object.active then
					Point.LastPosition = nil
				else
					local rayStart, rayDir, RelativePointToWorld = Point.solver:solve(Point, Object.debugMode)
					local raycastResult = workspace:Raycast(rayStart, rayDir, Object.raycastParams)
					Point.solver:lastPosition(Point, RelativePointToWorld)

					if raycastResult then
						local hitPart = raycastResult.Instance
						local findModel = not Object.partMode and hitPart:FindFirstAncestorOfClass("Model")
						local humanoid = findModel and findModel:FindFirstChildOfClass("Humanoid")
						local target = humanoid or (Object.partMode and hitPart)

						if target and not Object.targetsHit[target] then
							Object.targetsHit[target] = true
							Object.OnHit:Fire(hitPart, humanoid, raycastResult, Point.group)
						end
					end
					
					if Object.endTime > 0 then
						if Object.endTime <= clock() then
							Object.endTime = 0
							Object:HitStop()
						end
					end
					
					Object.OnUpdate:Fire(Point.LastPosition)
				end
			end
		end
	end
end)

return Handler
