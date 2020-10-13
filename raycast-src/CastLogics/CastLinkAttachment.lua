local Cast = {}
local Debugger = require(script.Parent.Debug.Debugger)

function Cast:solve(Point, bool)
	if bool then
		Debugger(Point.Attachment.WorldPosition - Point.Attachment0.WorldPosition, CFrame.new(Point.Attachment.WorldPosition, Point.Attachment0.WorldPosition))
	end

	return Point.Attachment.WorldPosition, Point.Attachment0.WorldPosition - Point.Attachment.WorldPosition
end

function Cast:lastPosition(Point)
	Point.LastPosition = Point.Attachment.WorldPosition
end

return Cast
