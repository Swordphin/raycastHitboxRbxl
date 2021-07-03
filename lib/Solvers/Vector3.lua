--!strict
--- Calculates ray origin and directions for vector-based raycast points
-- @author Swordphin123

local solver = {}

local EMPTY_VECTOR: Vector3 = Vector3.new()

--- Solve direction and length of the ray by comparing current and last frame's positions
-- @param point type
function solver:Solve(point: {[string]: any}): (Vector3, Vector3)
	--- Translate localized Vector3 positions to world space values
	local originPart: BasePart = point.Instances[1]
	local vector: Vector3 = point.Instances[2]
	local pointToWorldSpace: Vector3 = originPart.Position + originPart.CFrame:VectorToWorldSpace(vector)

	--- If LastPosition is nil (caused by if the hitbox was stopped previously), rewrite its value to the current point position
	if not point.LastPosition then
		point.LastPosition = pointToWorldSpace
	end

	local origin: Vector3 = point.LastPosition
	local direction: Vector3 = pointToWorldSpace - (point.LastPosition or EMPTY_VECTOR)

	point.WorldSpace = pointToWorldSpace

	return origin, direction
end

function solver:UpdateToNextPosition(point: {[string]: any}): Vector3
	return point.WorldSpace
end

function solver:Visualize(point: {[string]: any}): CFrame
	return CFrame.lookAt(point.WorldSpace, point.LastPosition)
end

return solver