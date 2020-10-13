local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local CastAttachment = require(script.Parent.CastLogics.CastAttachment)
local CastVectorPoint = require(script.Parent.CastLogics.CastVectorPoint)
local CastLinkAttachment = require(script.Parent.CastLogics.CastLinkAttachment)

local Service = script.Parent.Service --- Used for determining if the RunService should be running

--------

local HitboxObject = {}
local Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox:__tostring() 
	return string.format("Hitbox for instance %s [%s]", self.object.Name, self.object.ClassName)
end

function HitboxObject:new()
    return setmetatable({}, Hitbox)
end

function Hitbox:config(object, ignoreList)
	self.active = false
	self.deleted = false
	self.partMode = false
	self.debugMode = false
	self.points = {}
	self.targetsHit = {}
	self.bindable = Instance.new("BindableEvent")
	self.OnHit = self.bindable.Event
	self.raycastParams = RaycastParams.new()
	self.raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	self.raycastParams.FilterDescendantsInstances = ignoreList or {}
	
	self.object = object
	self.object.AncestryChanged:Connect(function()
		if not workspace:IsAncestorOf(self.object) and not Players:IsAncestorOf(self.object) then
			self:cleanup()
		end
	end)
end

function Hitbox:SetPoints(object, vectorPoints)
	if object and object:IsA("BasePart") then
		for _, vectors in ipairs(vectorPoints) do
			if typeof(vectors) == "Vector3" then
				local Point = {RelativePart = object, Attachment = vectors, LastPosition = nil, solver = CastVectorPoint}
				table.insert(self.points, Point)
			end
		end
	end
end

function Hitbox:RemovePoints(object, vectorPoints)
	if object then
		if object:IsA("BasePart") or object:IsA("MeshPart") then
			for i = 1, #self.points do
				local Point = self.points[i]
				for _, vectors in ipairs(vectorPoints) do
					if typeof(Point.Attachment) == "Vector3" and Point.Attachment == vectors and Point.RelativePart == object then
						self.points[i] = nil
					end
				end
			end
		end
	end
end

function Hitbox:LinkAttachments(primaryAttachment, secondaryAttachment)
	if primaryAttachment:IsA("Attachment") and secondaryAttachment:IsA("Attachment") then
		local Point = {
			RelativePart = nil,
			Attachment = primaryAttachment,
			Attachment0 = secondaryAttachment,
			LastPosition = nil,
			solver = CastLinkAttachment
		}
		table.insert(self.points, Point)
	end
end

function Hitbox:UnlinkAttachments(primaryAttachment)
	for i, Point in ipairs(self.points) do
		if Point.Attachment and Point.Attachment == primaryAttachment then
			table.remove(self.points, i)
			break
		end
	end
end

function Hitbox:seekAttachments(attachmentName, canWarn)
	if #self.points <= 0 then
		table.insert(self.raycastParams.FilterDescendantsInstances, workspace.Terrain)
	end
	for _, attachment in ipairs(self.object:GetDescendants()) do
		if attachment:IsA("Attachment") and attachment.Name == attachmentName then
			local Point = {Attachment = attachment, RelativePart = nil, LastPosition = nil, solver = CastAttachment}
			table.insert(self.points, Point)
		end
	end
	
	if canWarn then
		if #self.points <= 0 then
			warn(string.format("\n[[RAYCAST WARNING]]\nNo attachments with the name '%s' were found in %s. No raycasts will be drawn. Can be ignored if you are using SetPoints.", attachmentName, self.object.Name))
		else
			print(string.format("\n[[RAYCAST MESSAGE]]\n\nCreated Hitbox for %s - Attachments found: %s", self.object.Name, #self.points))
		end
	end
end

function Hitbox:cleanup()
	if self.deleted then return end
	
	self.bindable:Destroy()
	self.OnHit = nil
	self.points = nil
	self.active = false
	self.deleted = true
	Service:Fire()
end

function Hitbox:HitStart()
	if self.deleted then return end
	
	self.active = true
	Service:Fire()
end

function Hitbox:HitStop()
	self.active = false
end

function Hitbox:PartMode(bool)
	self.partMode = bool
end

function Hitbox:DebugMode(bool)
	self.debugMode = bool
end

return HitboxObject
