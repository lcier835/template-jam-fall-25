extends Node2D

var laserSegments: Array[Sprite2D] = []

@export var enabled = true

func _ready() -> void:
	for i in range(10):
		var current = $Fizzlermiddle.duplicate()
		laserSegments.append(current)
		self.add_child(current)
		
	$Fizzlermiddle.visible = false

func _process(_delta: float) -> void:
	hideCurrentLasers()
	if enabled: placeLasers()

func disableLaser():
	enabled = false

func enableLaser():
	enabled = true

func hideCurrentLasers():
	for l in laserSegments:
		l.visible = false

func placeLaser(start: Vector2, end: Vector2, index: int, angle: int):
	var verticalLaser = (angle % 2) == 0
	laserSegments[index].visible = true
	laserSegments[index].global_position = (start + end) / 2
	laserSegments[index].global_rotation = 0.0 if verticalLaser else (PI / 2)
	laserSegments[index].scale.y = max(abs(start.x - end.x), abs(start.y - end.y)) / 16

func placeLasers():
	$RayCast2D.position = Vector2(0, -32)
	var index = 0
	var oldStartPoint = $RayCast2D.global_position
	var newStartPoint: Vector2
	var angle = (global_rotation + (PI * 2)) / (PI / 2)
	angle = int(round(angle) + 2) % 4
	while index < laserSegments.size():
		$RayCast2D.global_position = oldStartPoint
		$RayCast2D.global_rotation = angle * (PI / 2) + PI
		$RayCast2D.force_raycast_update()
		
		newStartPoint = $RayCast2D.get_collision_point()
		placeLaser(oldStartPoint, newStartPoint, index, angle)
		
		var collider = $RayCast2D.get_collider()
		if get_tree().get_nodes_in_group("LaserInteract").find(collider) != -1:
			if collider is Cube || collider.get_parent() is Cube:
				oldStartPoint = collider.global_position
				if collider is not Cube: angle = (collider.get_parent().angle + 2) % 4
				else: angle = (collider.angle + 2) % 4
				index += 1
				continue
			if collider is LaserCatcher:
				collider.powered = true
				return
		
		var continueAfterward = false
		for p in get_tree().get_nodes_in_group("Portals"):
			var distanceX = newStartPoint.x - p.position.x
			var distanceY = newStartPoint.y - p.position.y
			var finalDistance = 64
			if(abs(distanceX) == 32.0) && abs(distanceY) < 32.0:
				finalDistance = distanceY
			elif(abs(distanceY) == 32.0) && abs(distanceX) < 32.0:
				finalDistance = distanceX
			
			if finalDistance != 64: #don't return in case it could go through other portal
				if(angle > 1): finalDistance *= -1
				var otherPortal: Portal = null
				
				for p2 in get_tree().get_nodes_in_group("Portals"):
					if p2.orangePortal != p.orangePortal: otherPortal = p2
				if otherPortal == null: continue
				
				angle = (otherPortal.angle + 2) % 4
				oldStartPoint = otherPortal.position
				match angle:
					0: oldStartPoint += Vector2(finalDistance, 32)
					1: oldStartPoint += Vector2(-32, finalDistance)
					2: oldStartPoint += Vector2(-finalDistance, -32)
					3: oldStartPoint += Vector2(32, -finalDistance)
					_: pass
				
				index += 1
				continueAfterward = true
				continue
		if continueAfterward: continue
		return
