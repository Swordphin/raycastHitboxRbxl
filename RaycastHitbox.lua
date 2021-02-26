--[[
____________________________________________________________________________________________________________________________________________________________________________

	Created by Swordphin123 - 2020. If you have any questions, feel free to message me on DevForum. Credits not neccessary but is appreciated.
	
	[ How To Use - Quick Start Guide ]
	
		1. Insert Attachments to places where you want your "hitbox" to be. For swords, I like to have attachments 1 stud apart and strung along the blade.
		2. Name those Attachments "DmgPoint" (so the script knows). You can configure what name the script will look for in the variables below.
		3. Open up a script. As an example, maybe we have a sword welded to the character or as a tool. Require this, and initialize:
				
				* Example Code
					
					local Damage = 10
					local Hitbox = RaycastHitbox:Initialize(Character, {Character})
					
					Hitbox.OnHit:Connect(function(hit, humanoid)
						print(hit.Name)
						humanoid:TakeDamage(Damage)
					end)
					
					Hitbox:HitStart()
					wait(2)
					Hitbox:HitStop()
		
		4. Profit. Refer to the API below for more information.
				
	
____________________________________________________________________________________________________________________________________________________________________________

	[ RaycastHitBox API ]
	
		* local RaycastHitbox = require(RaycastHitbox) ---Duh
				--- To use, insert this at the top of your scripts or wherever.
				
				
		
		* RaycastHitbox:Initialize(Instance model, table ignoreList)
				Description
					--- Preps the model and recursively finds attachments in it so it knows where to shoot rays out of later.
				Arguments
					--- Instance model: Model instance (Like your character, a sword model, etc). May support Parts later.
					--- table ignoreList: Raycast takes in ignorelists. Heavily recommended to add in a character so it doesn't hurt itself in its confusion.
				Returns
					Instance HitboxObject 
					
		* RaycastHitbox:Deinitialize(Instance model)
				Description
					--- Removes references to the attachments and garbage collects values from the original init instance. Great if you are deleting the hitbox soon.
					--- The script will attempt to run this function automatically if the model ancestry was changed.
				Arguments
					--- Instance model: Same model that you initialized with earlier. Will do nothing if model was not initialized.
						
		* RaycastHitModule:GetHitbox(Instance model)
				Description
					--- Gets the HitboxObject if it exists.
				Returns
					--- HitboxObject if found, else nil
					
					
					
					
					
					
					
		* HitboxObject:DebugMode(boolean true/false)
				Description
					--- Turn the Hitbox DebugRays on or off during runtime.
				Arguments
					--- boolean: true for on, false for off.
		
		* HitboxObject:PartMode(boolean true/false)
				Description
					--- If true, OnHit will return every hit part (in respect to the hitbox's ignore list), regardless if it's ascendant has a humanoid or not. Defaults false.
					--- OnHit will no longer return a humanoid so you will have to check it. Performance may suffer if there are a lot of parts, use only if necessary.
				Arguments
					--- boolean: true for parts return, false for off.
		
		* HitboxObject:SetPoints(Instance part, table vectorPoints)
				Description
					--- Merges existing Hitbox points with new Vector3 values relative to a part position. This part can be a descendent of your original Hitbox model or can be
						an entirely different instance that is not related to the hitbox (example: Have a weapon with attachments and you can then add in more vector3 
						points without instancing new attachments, great for dynamic hitboxes)
				Arguments
					--- Instance part: Sets the part that these vectorPoints will move in relation to the part's origin using Vector3ToWorldSpace
					--- table vectorPoints: Table of vector3 values.
					
		* HitboxObject:RemovePoints(Instance part, table vectorPoints)
				Description
					--- Remove given Vector3 values provided the part was the same as the ones you set in SetPoints
				Arguments
					--- Instance part: Sets the part that these vectorPoints will be removed from in relation to the part's origin using Vector3ToWorldSpace
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

		* HitboxObject.OnHit:Connect(returns: Instance part, returns: Instance humanoid, returns: RaycastResults)
				Description
					--- If HitStart hits a fresh new target, OnHit returns information about the hit target
				Arguments
					--- Instance part: Returns the part that the rays hit first
					--- Instance humanoid: Returns the Humanoid object 
					--- Instance RaycastResults: Returns information about the last raycast results
					
		* HitboxObject.OnUpdate:Connect(returns: Vector3 position)
				Description
					--- This fires every frame, for every point, returning a Vector3 value of its last position in space. Do not use expensive operations in this function.
		
		
____________________________________________________________________________________________________________________________________________________________________________

--]]

local RaycastHitbox = { 
	Version = "3.3",
	AttachmentName = "DmgPoint",
	DebugMode = false,
	WarningMessage = false
}

--------

local Handler = require(script.MainHandler)
local HitboxClass = require(script.HitboxObject)

function RaycastHitbox:Initialize(object, ignoreList)
	assert(object, "You must provide an object instance.")
	
	local newHitbox = Handler:check(object)
	if not newHitbox then
		newHitbox = HitboxClass:new()
		newHitbox:config(object, ignoreList)
		newHitbox:seekAttachments(RaycastHitbox.AttachmentName, RaycastHitbox.WarningMessage)
		newHitbox.debugMode = RaycastHitbox.DebugMode
		Handler:add(newHitbox)
	end
	return newHitbox
end

function RaycastHitbox:Deinitialize(object) --- Deprecated
	Handler:remove(object)
end

function RaycastHitbox:GetHitbox(object)
   return Handler:check(object)
end

return RaycastHitbox
