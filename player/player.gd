class_name Player extends RigidBody2D

# how far through the animation the charater is in a range between [0 and 4)
var animation_frame: float = 0
# counts up as you move when it passes 1, a walking sound effect is played
var sound_delay: float = 0.5
var angle: int = 0

# The values on an exported varrible is merely the default value
# to control the actual value, look in the of what used this script (the player)

# the speed the tries to move at when a movement key is pressed
var mov_speed: float = 15000
# how quick to animate the player's movement based on their speed
var anim_speed: float = 0.03
var walk_sfx_speed: float = 0.035
# how far the interaction hitbox is from the player
var interaction_hitbox_distance: float = 32

var portalTeleportSpeed: float = 0.3
var portal1: Portal
var portal2: Portal
var portalTeleportProgress: float = 2
var drownAfterAnimation: float = 1

var inputVector: Vector2

var basePlayerColor = Color(1, 1, 1)
var cloneColor = Color(0.75, 0.75, 1.0, 0.5)

@export var bluePortalgun = true
@export var orangePortalgun = true

@onready var portalScene = preload("res://portals/portal.tscn")
@onready var portalrejectScene = preload("res://portals/portalreject.tscn")
var lastSafeSpot: Vector2

var heldObject: Cube

var displacementFieldOffset := Vector2(0, 0)
var displacedByField := false

var movementEnabled = true

func updateKeys():
	if !movementEnabled:
		return
	var upEvent = Input.is_action_just_pressed(&"up") || Input.is_action_just_released(&"up")
	var downEvent = Input.is_action_just_pressed(&"down") || Input.is_action_just_released(&"down")
	var leftEvent = Input.is_action_just_pressed(&"left") || Input.is_action_just_released(&"left")
	var rightEvent = Input.is_action_just_pressed(&"right") || Input.is_action_just_released(&"right")
	if !upEvent && !downEvent && !leftEvent && !rightEvent:
		return
	
	var keyboard_movement_vector = Vector2()
	if Input.is_action_pressed(&"up"):
		keyboard_movement_vector.y -= 1
	if Input.is_action_pressed(&"down"):
		keyboard_movement_vector.y += 1
	if Input.is_action_pressed(&"left"):
		keyboard_movement_vector.x -= 1
	if Input.is_action_pressed(&"right"):
		keyboard_movement_vector.x += 1
	
	inputVector = keyboard_movement_vector

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# quit game, highest priority
	if Input.is_action_pressed("close"):
		get_tree().change_scene_to_file("res://titlescreen/titlescreen.tscn")
		for i in 8:
			Musichandler.disableLayer(i)
		Musichandler.enableLayer(8)
	
	updateKeys()
	$Portalshot.modulate.a -= delta * 3
	
	if portalTeleportProgress < 2:
		portallingProcess(delta)
		return
	
	if drownAfterAnimation < 1:
		angle = int(floor(drownAfterAnimation * 8)) % 4
		updateSprite(0, 0)
		inputVector = Vector2(0, 0)
		$Sprite2D.modulate.a = 1 - drownAfterAnimation
		drownAfterAnimation += delta
		if drownAfterAnimation >= 1:
			$Sprite2D.modulate.a = 1
			global_position = lastSafeSpot
			angle = 2
			collision_mask = 1
	
	if heldObject == null && movementEnabled:
		if Input.is_action_just_pressed("blueportal") && bluePortalgun: shootPortal(false)
		if Input.is_action_just_pressed("orangeportal") && orangePortalgun: shootPortal(true)
	
	if not inputVector.is_zero_approx() && !Input.is_action_pressed("strafe"):
		# set animation direction
		if inputVector.y == 1: # down
			angle = 2
		elif inputVector.y == -1: #up
			angle = 0
		elif inputVector.x == 1: # right
			angle = 1
		elif inputVector.x == -1: # left
			angle = 3
		
	if heldObject != null:
		$InteractionArea/InteractionHitbox.position = Vector2(0, 0)
	else:
		match angle:
			0: $InteractionArea/InteractionHitbox.position = Vector2(0, -interaction_hitbox_distance)
			1: $InteractionArea/InteractionHitbox.position = Vector2(interaction_hitbox_distance, 0)
			2: $InteractionArea/InteractionHitbox.position = Vector2(0, interaction_hitbox_distance)
			3: $InteractionArea/InteractionHitbox.position = Vector2(-interaction_hitbox_distance, 0)
	
	
	var actingLinearVelocityLength := (250 if linear_velocity.length() > 1 else 0)
	
	updateSprite(actingLinearVelocityLength, delta)
	processDisplacement(delta)
	sound_delay += delta * walk_sfx_speed * actingLinearVelocityLength
	if sound_delay > 1.0:
		sound_delay = fmod(sound_delay, 1.0)
		if Musichandler.masterVolume == 1:
			$StepSFX.play()

func processDisplacement(_delta: float):
	if displacedByField:
		$PortalRaycast.position = Vector2(0, 16) + displacementFieldOffset
		$NormalRaycast.position = Vector2(0, 16) + displacementFieldOffset
		$CloneSprite.position = $Sprite2D.position + displacementFieldOffset
		$CloneSprite.visible = true
		$CloneSprite.modulate = $Sprite2D.modulate * cloneColor
	else:
		$PortalRaycast.position = Vector2(0, 16)
		$NormalRaycast.position = Vector2(0, 16)
		$CloneSprite.visible = false

func angleToVector(ang) -> Vector2:
	match(ang):
		0: return Vector2(0, -1)
		1: return Vector2(1, 0)
		2: return Vector2(0, 1)
		3: return Vector2(-1, 0)
		_: return Vector2(0, 0)

func updateSprite(speed: float, delta: float):
	animation_frame = fmod(delta * anim_speed * speed + animation_frame, 4)
	$Sprite2D.frame = floori(animation_frame) + angle * 4
	$CloneSprite.frame = floori(animation_frame) + angle * 4
	
	$Sprite2D.position = Vector2(0, -8)
	$Sprite2D.global_position = ($Sprite2D.global_position / 4).round() * 4

# For like _process, but runs at a fixed frame rate
# better for physics realated code
func _physics_process(delta: float) -> void:
	var goal_movement_vector: Vector2 = inputVector * delta * mov_speed
	linear_velocity = goal_movement_vector
	if heldObject != null:
		var goalPosition = global_position + angleToVector(angle) * 64
		heldObject.goalPos = goalPosition

func _input(event: InputEvent) -> void:
	if !movementEnabled: return
	if event.is_action_pressed(&"interact"):
		if heldObject && heldObject.has_method(&"_unuse"):
			if $InteractionArea.get_overlapping_bodies().find(heldObject) == -1:
				heldObject._unuse(self)
			else:
				if heldObject.has_method("jiggle"): heldObject.jiggle()
		else:
			interact()

# finds any (physics) bodies or areas that are in the interaction hitbox
# then calls their _interacted_by_player if they have that method passing the player
# note that that interactable object needs to have collision layer 2 enabled
func interact() -> void:
	for area in $InteractionArea.get_overlapping_areas():
		if area.has_method(&"_interacted_by_player"):
			area._interacted_by_player(self)
			return
	for bodies in $InteractionArea.get_overlapping_bodies():
		if bodies.has_method(&"_interacted_by_player"):
			bodies._interacted_by_player(self)
			return

func startPortalTransition(fromPortal: Portal, toPortal: Portal):
	if portalTeleportProgress < 2: return
	portal1 = fromPortal
	portal2 = toPortal
	portalTeleportProgress = 0
	lastSafeSpot = portal1.position + (angleToVector(portal1.angle) * 72)
	
	#rotate input
	var angleOffset = (portal2.angle - portal1.angle + 6) % 4
	inputVector = inputVector.rotated(PI * angleOffset / 2)
	pass

func portallingProcess(delta: float) -> void:
	var endDistance: int = 56
	if angle == 0: endDistance = 68
	if angle == 2: endDistance = 40
	
	if portal1 == null || portal2 == null:
		global_position = lastSafeSpot
		portalTeleportProgress = 3
		$Sprite2D.modulate = basePlayerColor
		return
	
	if portalTeleportProgress < 1:
		angle = (portal1.angle + 2) % 4
		global_position = lerp(portal1.position + (angleToVector(angle) * -32), portal1.position, portalTeleportProgress)
		var goalColor = portal1.sprite.modulate
		goalColor.a = 0
		$Sprite2D.modulate = lerp(basePlayerColor, goalColor, portalTeleportProgress)
	
	else:
		angle = (portal2.angle) % 4
		global_position = lerp(portal2.position, portal2.position + (angleToVector(angle) * endDistance), portalTeleportProgress - 1)
		var goalColor = portal1.sprite.modulate
		goalColor.a = 0
		$Sprite2D.modulate = lerp(goalColor, basePlayerColor, portalTeleportProgress - 1)
		
	if heldObject != null:
		heldObject.modulate.a = $Sprite2D.modulate.a
	
	portalTeleportProgress += (delta * 2) / portalTeleportSpeed
	updateSprite(250, delta)
	if portalTeleportProgress > 2: 
		global_position = portal2.position + (angleToVector(angle) * endDistance)
		$Sprite2D.modulate = basePlayerColor
	
	processDisplacement(delta)

func getCameraPos() -> Vector2:
	if portalTeleportProgress < 2:
		var pos1 = portal1.position + (angleToVector((portal1.angle + 2) % 4) * -32)
		var pos2 = portal2.position + (angleToVector((portal2.angle) % 4) * 40)
		var t = portalTeleportProgress / 2
		t = t * t * (3.0 - (2.0 * t))
		return lerp(pos1, pos2, t)
	elif displacedByField:
		return global_position + displacementFieldOffset / 2
	else:
		return global_position

func shootPortal(orange: bool):
	
	if orange:
		$Portalshot.modulate = Color(1, 0.5, 0, 0.5)
	else:
		$Portalshot.modulate = Color(0, 0.5, 1, 0.5)
	
	$Portalshot.position = angleToVector(angle) * 80
	if displacedByField: $Portalshot.position += displacementFieldOffset
	$Portalshot.rotation = angle * (PI / 2)
	
	$PortalRaycast.target_position = angleToVector(angle) * 5000
	$NormalRaycast.target_position = angleToVector(angle) * 5000
	$PortalRaycast.force_raycast_update()
	$NormalRaycast.force_raycast_update()
	if $PortalRaycast.get_collision_point() == $NormalRaycast.get_collision_point() && $PortalRaycast.is_colliding():
		var portalPos = $PortalRaycast.get_collision_point()
		portalPos += angleToVector(angle) * 32
		if angle % 2 == 0:
			portalPos.x = floor(portalPos.x / 64) * 64 + 32
			portalPos.y = floor(portalPos.y / 64) * 64 + 32
			portalPos.y = round(portalPos.y)
		else:
			portalPos.y = floor(portalPos.y / 64) * 64 + 32
			portalPos.x = floor(portalPos.x / 64) * 64 + 32
			portalPos.x = round(portalPos.x)
		
		var newPortal = portalScene.instantiate()
		newPortal.position = portalPos
		newPortal.angle = (angle + 2) % 4
		newPortal.orangePortal = orange
		
		# first see if portal should be rejected
		for p in get_tree().get_nodes_in_group("Portals"):
			if p.orangePortal != orange && portalPos == p.position:
				portalReject(orange)
				return
		
		# then after confirming wall is empty clear all portals of current color
		for p in get_tree().get_nodes_in_group("Portals"):
			if p.orangePortal == orange:
				p.queue_free()
		
		get_tree().get_current_scene().add_child(newPortal)
		newPortal.updateSprite(0)
	else:
		portalReject(orange)

func waterBodyEntered(_body: Node2D):
	if drownAfterAnimation >= 1:
		drownAfterAnimation = 0
		collision_mask = 0
		if heldObject != null && heldObject is Cube:
			heldObject._fizzle()

func _fizzle():
	for p in get_tree().get_nodes_in_group("Portals"):
			if p.placedByPlayer:
				p.queue_free()

func portalReject(orange):
	var pr = portalrejectScene.instantiate()
	pr.rotation = angle * (PI / 2) + PI
	if orange:
		pr.modulate = Color(1, 0.5, 0, 1)
	else:
		pr.modulate = Color(0, 0.5, 1, 1)
	pr.global_position = $NormalRaycast.get_collision_point()
	get_tree().get_current_scene().add_child(pr)
