--!strict
--- Calculates ray origin and directions for attachment-based raycast points
-- @author Swordphin123

local solver = {}

--- Solve direction and length of the ray by comparing current and last frame's positions
-- @param point type
function solver:Solve(point: {[string]: any}): (Vector3, Vector3)
	--- If LastPosition is nil (caused by if the hitbox was stopped previously), rewrite its value to the current point position
	if not point.LastPosition then
		point.LastPosition = point.Instances[1].WorldPosition
	end

	local origin: Vector3 = point.Instances[1].WorldPosition
	local direction: Vector3 = point.Instances[1].WorldPosition - point.LastPosition

	return origin, direction
end

function solver:UpdateToNextPosition(point: {[string]: any}): Vector3
	return point.Instances[1].WorldPosition
end

function solver:Visualize(point: {[string]: any}): CFrame
	return CFrame.lookAt(point.Instances[1].WorldPosition, point.LastPosition)
end

return solver