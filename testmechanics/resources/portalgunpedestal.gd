class_name PGunPedestal extends Area2D

@export var shootUp = true
@export var shootRight = true
@export var shootDown = true
@export var shootLeft = true
@export var shootOrange = false

@onready var portalScene = preload("res://portals/portal.tscn")

var timer: float = 0
var used = false
var angle = 0
var turnSpeed = 2

func _interacted_by_player(_player: Player):
	print("used")
	if shootOrange:
		_player.orangePortalgun = true
	else:
		_player.bluePortalgun = true
	used = true
	timer = 1

func _process(delta: float) -> void:
	if used:
		$Sprite2D.frame = 4 if timer > 0 else 5
		timer -= delta
		return
	
	if timer > 1:
		timer = 0
		angle += 1
		if angle > 3:
			angle = 0
	
	$Sprite2D.frame = angle
	
	if timer < 0.5 && (timer + delta / turnSpeed) > 0.5:
		#shoot portal
		match angle:
			0: 
				if shootUp: shootPortal() 
				else: timer = 1
			1: 
				if shootRight: shootPortal() 
				else: timer = 1
			2: 
				if shootDown: shootPortal() 
				else: timer = 1
			3: 
				if shootLeft: shootPortal() 
				else: timer = 1
		pass
	
	timer += delta / turnSpeed

func angleToVector(ang) -> Vector2:
	match(ang):
		0: return Vector2(0, -1)
		1: return Vector2(1, 0)
		2: return Vector2(0, 1)
		3: return Vector2(-1, 0)
		_: return Vector2(0, 0)

func shootPortal():
	$PortalRaycast.target_position = angleToVector(angle) * 5000
	$NormalRaycast.target_position = angleToVector(angle) * 5000
	$PortalRaycast.force_raycast_update()
	$NormalRaycast.force_raycast_update()
	if $PortalRaycast.get_collision_point() == $NormalRaycast.get_collision_point() && $PortalRaycast.is_colliding():
		var portalPos = $PortalRaycast.get_collision_point()
		portalPos += angleToVector(angle) * 32
		if angle % 2 == 0:
			portalPos.x = floor(portalPos.x / 64) * 64 + 32
			portalPos.y = round(portalPos.y)
		else:
			portalPos.y = floor(portalPos.y / 64) * 64 + 32
			portalPos.x = round(portalPos.x)
		
		var newPortal = portalScene.instantiate()
		newPortal.position = portalPos
		newPortal.angle = (angle + 2) % 4
		newPortal.orangePortal = shootOrange
		newPortal.placedByPlayer = false
		
		# first see if portal should be rejected
		for p in get_tree().get_nodes_in_group("Portals"):
			if p.orangePortal != shootOrange && portalPos == p.position:
				return
		
		# then after confirming wall is empty clear all portals of current color
		for p in get_tree().get_nodes_in_group("Portals"):
			if p.orangePortal == shootOrange:
				p.queue_free()
		
		get_tree().get_current_scene().add_child(newPortal)
		newPortal.updateSprite(0)
