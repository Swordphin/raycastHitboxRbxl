local Cast = {}
local Debugger = require(script.Parent.Debug.Debugger)

function Cast:solve(Point, bool)
	if not Point.LastPosition then
		Point.LastPosition = Point.Attachment.WorldPosition
	end
	
	if bool then
		Debugger(Point.Attachment.WorldPosition - Point.LastPosition, CFrame.new(Point.Attachment.WorldPosition, Point.LastPosition))
	end
	return Point.LastPosition, Point.Attachment.WorldPosition - Point.LastPosition
end

function Cast:lastPosition(Point)
	Point.LastPosition = Point.Attachment.WorldPosition	
end

return Cast
