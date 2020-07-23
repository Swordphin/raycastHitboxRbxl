local Debris = game:GetService("Debris")

return function(distance, newCFrame)
	local beam = Instance.new("Part")
	beam.BrickColor = BrickColor.new("Bright red")
	beam.Material = Enum.Material.Neon
	beam.Anchored = true
	beam.CanCollide = false
	beam.Name = "RaycastHitboxDebugPart"
	
	local Dist = (distance).Magnitude
	beam.Size = Vector3.new(0.1, 0.1, Dist)
	beam.CFrame = newCFrame * CFrame.new(0, 0, -Dist / 2)
	
	beam.Parent = workspace.Terrain
	Debris:AddItem(beam, 1)
end
