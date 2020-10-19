--- @Swordphin123, wao such minimalism

local connection = {}
connection.__index = connection

function connection:Create()
	return setmetatable({}, connection)
end

function connection:Connect(Listener)
	self[1] = self[1] or Listener
end

function connection:Fire(...)
	local newThread = coroutine.create(self[1])
	coroutine.resume(newThread, ...)
end

function connection:Delete()
	self[1] = nil
end

return connection