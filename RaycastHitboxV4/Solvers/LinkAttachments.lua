--!strict
--- Calculates ray origin and directions for attachment-based raycast points
-- @author Swordphin123

local solver = {}

--- Solve direction and length of the ray by comparing both attachment1 and attachment2's positions
-- @param point type
function solver:Solve(point: {[string]: any}): (Vector3, Vector3)
	local origin: Vector3 = point.Instances[1].WorldPosition
	local direction: Vector3 = point.Instances[2].WorldPosition - point.Instances[1].WorldPosition

	return origin, direction
end

function solver:UpdateToNextPosition(point: {[string]: any}): Vector3
	return point.Instances[1].WorldPosition
end

function solver:Visualize(point: {[string]: any}): CFrame
	return CFrame.lookAt(point.Instances[1].WorldPosition, point.Instances[2].WorldPosition)
end

return solver