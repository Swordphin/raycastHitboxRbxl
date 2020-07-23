local Cast = {}
local Debugger = require(script.Parent.Debug.Debugger)

function Cast:solve(Point, bool)	
	local RelativePartToWorldSpace = Point.RelativePart.Position + Point.RelativePart.CFrame:VectorToWorldSpace(Point.Attachment)
	if not Point.LastPosition then
		Point.LastPosition = RelativePartToWorldSpace
	end
	
	if bool then
		Debugger(RelativePartToWorldSpace - Point.LastPosition, CFrame.new(RelativePartToWorldSpace, Point.LastPosition))
	end

	return Point.LastPosition, RelativePartToWorldSpace - (Point.LastPosition and Point.LastPosition or Vector3.new()), RelativePartToWorldSpace
end

function Cast:lastPosition(Point, RelativePartToWorldSpace)
	Point.LastPosition = RelativePartToWorldSpace
end

return Cast
