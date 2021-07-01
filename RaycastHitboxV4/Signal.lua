--- @Swordphin123, wao such minimalism

local connection = {}
connection.__index = connection

function connection:Create()
	return setmetatable({}, connection)
end

function connection:Connect(Listener)
	self[1] = Listener
end

function connection:Fire(...)
	if not self[1] then return end

	local newThread = coroutine.create(self[1])
	coroutine.resume(newThread, ...)
end

function connection:Destroy()
	self[1] = nil
end

return connection