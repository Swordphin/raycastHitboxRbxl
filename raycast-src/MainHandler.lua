local HitboxesConfigured = 0
local ActiveHitboxes = {}
local Handler = {}

local HeartbeatConnection
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

--------

local CastAttachment = require(script.Parent.CastLogics.CastAttachment)
local CastVectorPoint = require(script.Parent.CastLogics.CastVectorPoint)
local CastLinkAttachment = require(script.Parent.CastLogics.CastLinkAttachment)

local Service_Stop = function(forceStop)
	if HitboxesConfigured <= 0 or forceStop then
		HeartbeatConnection:Disconnect()
		HeartbeatConnection = nil
	end
end

local Service_Run = function()
	if HeartbeatConnection then return end	
	
	HeartbeatConnection = RunService.Heartbeat:Connect(function()
		local IsActive = false
		for Index, Object in pairs(ActiveHitboxes) do
			if Object.deleted then
				Handler:remove(Index)
				return
			end
			if Object.active then
				IsActive = true
				for _, Point in ipairs(Object.points) do
					local rayStart
					local rayDir
					local RelativePointToWorld 
					local method
					if Point.RelativePart then
						method = CastVectorPoint
						rayStart, rayDir, RelativePointToWorld = method:solve(Point, Object.debugMode)
					elseif Point.Attachment0 == nil and typeof(Point.Attachment) == "Instance" then
						method = CastAttachment
						rayStart, rayDir = method:solve(Point, Object.debugMode)
					elseif Point.Attachment0 then
						method = CastLinkAttachment
						rayStart, rayDir = method:solve(Point, Object.debugMode)
					end
					
					if rayStart then
						local raycastResult = workspace:Raycast(rayStart, rayDir, Object.raycastParams)
						method:lastPosition(Point, RelativePointToWorld)
						
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

CollectionService:GetInstanceAddedSignal("RaycastEnabled"):Connect(function()
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
