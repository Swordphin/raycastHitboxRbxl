local HitboxesConfigured = 0
local ActiveHitboxes = {}
local Handler = {}

local HeartbeatConnection
local RunService = game:GetService("RunService")

local Service = script.Parent.Service

--------

local Service_Stop = function(forceStop)
	if (HitboxesConfigured <= 0 or forceStop) and HeartbeatConnection then
		HeartbeatConnection:Disconnect()
		HeartbeatConnection = nil
		print("stoppin")
	end
end

local Service_Run = function()
	if HeartbeatConnection then return end	
	
	HeartbeatConnection = RunService.Heartbeat:Connect(function()
		local IsActive = false
		for Index, Object in pairs(ActiveHitboxes) do
			if Object.deleted then
				Handler:remove(Index)
			else
				for _, Point in ipairs(Object.points) do
					if Object.active then
						IsActive = true
						
						local rayStart, rayDir, RelativePointToWorld = Point.solver:solve(Point, Object.debugMode)
						local raycastResult = workspace:Raycast(rayStart, rayDir, Object.raycastParams)
						Point.solver:lastPosition(Point, RelativePointToWorld)
						
						if raycastResult then
							local hitPart = raycastResult.Instance
							if not Object.partMode then
								local Target = hitPart.Parent
								if Target and not Object.targetsHit[Target] then
									local Humanoid = Target:FindFirstChildOfClass("Humanoid")
									if Humanoid then
										Object.targetsHit[Target] = true
										Object.bindable:Fire(hitPart, Humanoid, raycastResult)
									end
								end
							else
								if not Object.targetsHit[hitPart] then
									Object.targetsHit[hitPart] = true
									Object.bindable:Fire(hitPart, nil, raycastResult)
								end
							end
						end
					else
						Point.LastPosition = nil
						Object.targetsHit = {}
					end
				end
			end
		end
		if not IsActive then
			--- If all hitbox rays are stopped, no need to continue the heartbeat
			
			Service_Stop(true)
		end
	end)
end

Service.Event:Connect(function()
	Service_Run()
end)

function Handler:add(hitboxObject)
	assert(typeof(hitboxObject) ~= "Instance", "Make sure you are initializing from the Raycast module, not from this handler.")
	
	HitboxesConfigured = HitboxesConfigured + 1
	ActiveHitboxes[hitboxObject.object] = hitboxObject
end

function Handler:remove(object)
	if ActiveHitboxes[object] then
		HitboxesConfigured = HitboxesConfigured - 1
		ActiveHitboxes[object]:cleanup()
		setmetatable(ActiveHitboxes[object], nil)
		ActiveHitboxes[object] = nil
		Service_Stop()
	end
end

function Handler:check(object, canWarn)
	if ActiveHitboxes[object] then
		if canWarn then
			warn("This hitbox already exists!")
		end
		return ActiveHitboxes[object]
	end
end

return Handler
