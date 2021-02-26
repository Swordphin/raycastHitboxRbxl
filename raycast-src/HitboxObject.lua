-- [[ Services ]]
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

-- [[ Variables ]]
local MAIN = script.Parent

local CastAttachment  = require(MAIN.CastLogics.CastAttachment)
local CastVectorPoint = require(MAIN.CastLogics.CastVectorPoint)
local CastLinkAttach  = require(MAIN.CastLogics.CastLinkAttachment)

local Signal = require(MAIN.Tools.Signal)
local clock = os.clock


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
	self.endTime = 0
	self.OnHit = Signal:Create()
	self.OnUpdate = Signal:Create()
	self.raycastParams = RaycastParams.new()
	self.raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	self.raycastParams.FilterDescendantsInstances = ignoreList or {}
	
	self.object = object
	CollectionService:AddTag(self.object, "RaycastModuleManaged")
end

function Hitbox:SetPoints(object, vectorPoints, groupName)
	if object and (object:IsA("BasePart") or object:IsA("MeshPart") or object:IsA("Attachment")) then
		for _, vectors in ipairs(vectorPoints) do
			if typeof(vectors) == "Vector3" then
				local Point = {
					IsAttachment = object:IsA("Attachment"),
					RelativePart = object, 
					Attachment = vectors,
					LastPosition = nil,
					group = groupName,
					solver = CastVectorPoint
				}
				table.insert(self.points, Point)
			end
		end
	end
end

function Hitbox:RemovePoints(object, vectorPoints)
	if object then
		if object:IsA("BasePart") or object:IsA("MeshPart") then --- for some reason it doesn't recognize meshparts unless I add it in
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
		local group = primaryAttachment:FindFirstChild("Group")
		local Point = {
			RelativePart = nil,
			Attachment = primaryAttachment,
			Attachment0 = secondaryAttachment,
			LastPosition = nil,
			group = group and group.Value,
			solver = CastLinkAttach
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
			local group = attachment:FindFirstChild("Group")
			local Point = {
				Attachment = attachment, 
				RelativePart = nil, 
				LastPosition = nil, 
				group = group and group.Value,
				solver = CastAttachment
			}
			table.insert(self.points, Point)
		end
	end
	
	if canWarn then
		if #self.points <= 0 then
			warn(string.format("\n[[RAYCAST WARNING]]\nNo attachments with the name '%s' were found in %s. No raycasts will be drawn. Can be ignored if you are using SetPoints.",
				attachmentName, self.object.Name)
			)
		else
			print(string.format("\n[[RAYCAST MESSAGE]]\n\nCreated Hitbox for %s - Attachments found: %s", 
				self.object.Name, #self.points)
			)
		end
	end
end

function Hitbox:Destroy()
	if self.deleted then return end
	if self.OnHit then self.OnHit:Delete() end
	if self.OnUpdate then self.OnUpdate:Delete() end
	
	self.points = nil
	self.active = false
	self.deleted = true
end

function Hitbox:HitStart(seconds)
	self.active = true
	
	if seconds then
		assert(type(seconds) == "number", "Argument #1 must be a number!")
		
		local minSeconds = 1 / 60 --- Seconds cannot be under 1/60th
		
		if seconds <= minSeconds or seconds == math.huge then
			seconds = minSeconds
		end
		
		self.endTime = clock() + seconds
	end
end

function Hitbox:HitStop()
	if self.deleted then return end
	
	self.active = false
	self.endTime = 0
	table.clear(self.targetsHit)
end

function Hitbox:PartMode(bool)
	self.partMode = bool
end

function Hitbox:DebugMode(bool)
	self.debugMode = bool
end

return HitboxObject
