--!strict
--- Main RaycastModuleV4 2021
-- @author Swordphin123

--[[
____________________________________________________________________________________________________________________________________________________________________________

	If you have any questions, feel free to message me on DevForum. Credits not neccessary but is appreciated.
	
	[ How To Use - Quick Start Guide ]
	
		1. Insert Attachments to places where you want your "hitbox" to be. For swords, I like to have attachments 1 stud apart and strung along the blade.
		2. Name those Attachments "DmgPoint" (so the script knows). You can configure what name the script will look for in the variables below.
		3. Open up a script. As an example, maybe we have a sword welded to the character or as a tool. Require this, and initialize:
				
				* Example Code
					
					local Damage = 10
					local Hitbox = RaycastHitbox.new(Character)
					
					Hitbox.OnHit:Connect(function(hit, humanoid)
						print(hit.Name)
						humanoid:TakeDamage(Damage)
					end)
					
					Hitbox:HitStart() --- Turns on the hitbox
					wait(10) --- Waits 10 seconds
					Hitbox:HitStop() --- Turns off the hitbox
		
		4. Profit. Refer to the API below for more information.
				

____________________________________________________________________________________________________________________________________________________________________________

	[ RaycastHitBox API ]

		* local RaycastHitbox = require(RaycastHitboxV4) ---Duh
				--- To use, insert this at the top of your scripts or wherever.


			[ FUNCTIONS ]

		* RaycastHitbox.new(Instance model | BasePart | nil)
				Description
					--- Preps the model and recursively finds attachments in it so it knows where to shoot rays out of later. If a hitbox exists for this
					--- object already, it simply returns the same hitbox.
				Arguments
					--- Instance:  (Like your character, a sword model, etc). Can be left nil in case you want an empty Hitbox or use SetPoints later
				Returns
					Instance HitboxObject
						
		* RaycastHitModule:GetHitbox(Instance model)
				Description
					--- Gets the HitboxObject if it exists.
				Returns
					--- HitboxObject if found, else nil
					
		
		
		* HitboxObject:SetPoints(Instance BasePart | Bone, table vectorPoints, string group)
				Description
					--- Merges existing Hitbox points with new Vector3 values relative to a part/bone position. This part can be a descendent of your original Hitbox model or
						can be an entirely different instance that is not related to the hitbox (example: Have a weapon with attachments and you can then add in more vector3
						points without instancing new attachments, great for dynamic hitboxes)
				Arguments
					--- Instance BasePart | Bone: Sets the part/bone that these vectorPoints will move in relation to the part's origin using Vector3ToWorldSpace
					--- table vectorPoints: Table of vector3 values.
					--- string group: optional group parameter
					
		* HitboxObject:RemovePoints(Instance BasePart | Bone, table vectorPoints)
				Description
					--- Remove given Vector3 values provided the part was the same as the ones you set in SetPoints
				Arguments
					--- Instance BasePart | Bone: Sets the part that these vectorPoints will be removed from in relation to the part's origin using Vector3ToWorldSpace
					--- table vectorPoints: Table of vector3 values.
		
		* HitboxObject:LinkAttachments(Instance attachment1, Instance attachment2)
				Description
					--- Set two attachments to be in a link. The Raycast module will raycast between these two points.
				Arguments
					--- Instance attachment1/attachment2: Attachment objects
					
		* HitboxObject:UnlinkAttachments(Instance attachment1)
				Description
					--- Removes the link of an attachment. Only needs the primary attachment (argument 1 of LinkAttachments) to work. Will automatically sever the connection
						to the second attachment.
				Arguments
					--- Instance attachment1: Attachment object
				
		* HitboxObject:HitStart(seconds)
				Description
					--- Starts drawing the rays. Will only damage the target once. Call HitStop to reset the target pool so you can damage the same targets again.
						If HitStart hits a target(s), OnHit event will be called.
				Arguments
					--- number seconds: Optional numerical value, the hitbox will automatically turn off after this amount of time has elapsed
					
		* HitboxObject:HitStop()
				Description
					--- Stops drawing the rays and resets the target pool. Will do nothing if no rays are being drawn from the initialized model.

		* HitboxObject.OnHit:Connect(returns: Instance part, returns: Instance humanoid, returns: RaycastResults, returns: String group)
				Description
					--- If HitStart hits a fresh new target, OnHit returns information about the hit target
				Arguments
					--- Instance part: Returns the part that the rays hit first
					--- Instance humanoid: Returns the Humanoid object 
					--- RaycastResults RaycastResults: Returns information about the last raycast results
					--- String group: Returns information on the hitbox's group
					
		* HitboxObject.OnUpdate:Connect(returns: Vector3 position)
				Description
					--- This fires every frame, for every point, returning a Vector3 value of its last position in space. Do not use expensive operations in this function.
		

			[ PROPERTIES ]

		* HitboxObject.RaycastParams: RaycastParams
				Description
					--- Takes in a RaycastParams object

		* HitboxObject.Visualizer: boolean
				Description
					--- Turns on or off the debug rays for this hitbox

		* HitboxObject.DebugLog: boolean
				Description
					--- Turns on or off output writing for this hitbox

		* HitboxObject.DetectionMode: number [1 - 3]
				Description
					--- Defaults to 1. Refer to DetectionMode subsection below for more information

			
			[ DETECTION MODES ]

		* RaycastHitbox.DetectionMode.Default
				Description
					--- Checks if a humanoid exists when this hitbox touches a part. The hitbox will not return humanoids it has already hit for the duration
					--- the hitbox has been active.

		* RaycastHitbox.DetectionMode.PartMode
				Description
					--- OnHit will return every hit part (in respect to the hitbox's RaycastParams), regardless if it's ascendant has a humanoid or not.
					--- OnHit will no longer return a humanoid so you will have to check it. The hitbox will not return parts it has already hit for the
					--- duration the hitbox has been active.

		* RaycastHitbox.DetectionMode.Bypass
				Description
					--- PERFORMANCE MAY SUFFER IF THERE ARE A LOT OF PARTS. Use only if necessary.
					--- Similar to PartMode, the hitbox will return every hit part. Except, it will keep returning parts even if it has already hit them.
					--- Warning: If you have multiple raycast or attachment points, each raycast will also call OnHit. Allows you to create your own
					--- filter system.
		
____________________________________________________________________________________________________________________________________________________________________________

--]]

-- Show where the red lines are going. You can change their colour and width in VisualizerCache
local SHOW_DEBUG_RAY_LINES: boolean = true

-- Allow RaycastModule to write to the output
local SHOW_OUTPUT_MESSAGES: boolean = true

-- The tag name. Used for cleanup.
local DEFAULT_COLLECTION_TAG_NAME: string = "_RaycastHitboxV4Managed"

--- Initialize required modules
local CollectionService: CollectionService = game:GetService("CollectionService")
local HitboxData = require(script.HitboxCaster)
local Signal = require(script.Signal)

local RaycastHitbox = {}
RaycastHitbox.__index = RaycastHitbox
RaycastHitbox.__type = "RaycastHitboxModule"

-- Detection mode enums
RaycastHitbox.DetectionMode = {
	Default = 1,
	PartMode = 2,
	Bypass = 3,
}

--- Creates or finds a hitbox object. Returns an hitbox object
-- @param required object parameter that takes in either a part or a model
function RaycastHitbox.new(object: any?)
	local hitbox: any

	if object and CollectionService:HasTag(object, DEFAULT_COLLECTION_TAG_NAME) then
		hitbox = HitboxData:_FindHitbox(object)
	else
		hitbox = setmetatable({
			RaycastParams = nil,
			DetectionMode = RaycastHitbox.DetectionMode.Default,
			HitboxRaycastPoints = {},
			HitboxPendingRemoval = false,
			HitboxStopTime = 0,
			HitboxObject = object,
			HitboxHitList = {},
			HitboxActive = false,
			Visualizer = SHOW_DEBUG_RAY_LINES,
			DebugLog = SHOW_OUTPUT_MESSAGES,
			OnUpdate = Signal:Create(),
			OnHit = Signal:Create(),
			Tag = DEFAULT_COLLECTION_TAG_NAME,
		}, HitboxData)

		hitbox:_Init()
	end

	return hitbox
end

--- Finds a hitbox object if valid, else return nil
-- @param Object instance
function RaycastHitbox:GetHitbox(object: any?)
	if object then
		return HitboxData:_FindHitbox(object)
	end
end

return RaycastHitbox