class_name Player extends RigidBody2D

# how far through the animation the charater is in a range between [0 and 4)
var animation_frame: float = 0
# counts up as you move when it passes 1, a walking sound effect is played
var sound_delay: float = 0.5
var angle: int = 0

# The values on an exported varrible is merely the default value
# to control the actual value, look in the of what used this script (the player)

# the speed the tries to move at when a movement key is pressed
@export var mov_speed: float = 15000
# how quickly the player goes to theu desired speed
@export var mov_speed_correction: float = 10
# how quick to animate the player's movement based on their speed
@export var anim_speed: float = 0.03
@export var walk_sfx_speed: float = 0.035
@export var sprite: Sprite2D
# how far the interaction hitbox is from the player
@export var interaction_hitbox_distance: float = 32
@export var interaction_hitbox: CollisionShape2D
@export var interaction_area: Area2D
@export var step_sfx: AudioStreamPlayer

@export var portalTeleportSpeed: float = 0.3
var portal1: Portal
var portal2: Portal
var portalTeleportProgress: float = 2
var drownAfterAnimation: float = 1

var inputVector: Vector2

var bluePortalgun = true
var orangePortalgun = true

@export var portalRaycast: RayCast2D 
@export var normalRaycast: RayCast2D 
@onready var portalScene = preload("res://portals/portal.tscn")
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
	updateKeys()
	
	if portalTeleportProgress < 2:
		portallingProcess(delta)
		return
	
	if drownAfterAnimation < 1:
		angle = int(floor(drownAfterAnimation * 8)) % 4
		updateSprite(0, 0)
		inputVector = Vector2(0, 0)
		sprite.modulate.a = 1 - drownAfterAnimation
		drownAfterAnimation += delta
		if drownAfterAnimation >= 1:
			sprite.modulate.a = 1
			position = lastSafeSpot
			angle = 2
			collision_mask = 1
	
	if heldObject == null && movementEnabled:
		if Input.is_action_just_pressed("blueportal") && bluePortalgun: shootPortal(false)
		if Input.is_action_just_pressed("orangeportal") && orangePortalgun: shootPortal(true)
	
	if not inputVector.is_zero_approx():
		# set animation direction
		if inputVector.y == 1: # down
			interaction_hitbox.position = Vector2(0, interaction_hitbox_distance)
			angle = 2
		elif inputVector.y == -1: #up
			interaction_hitbox.position = Vector2(0, -interaction_hitbox_distance)
			angle = 0
		elif inputVector.x == 1: # right
			interaction_hitbox.position = Vector2(interaction_hitbox_distance, 0)
			angle = 1
		elif inputVector.x == -1: # left
			interaction_hitbox.position = Vector2(-interaction_hitbox_distance, 0)
			angle = 3
	if heldObject != null:
		interaction_hitbox.position = Vector2(0, 0)
	
	var actingLinearVelocityLength := (250 if linear_velocity.length() > 1 else 0)
	
	updateSprite(actingLinearVelocityLength, delta)
	processDisplacement(delta)
	sound_delay += delta * walk_sfx_speed * actingLinearVelocityLength
	if sound_delay > 1.0:
		sound_delay = fmod(sound_delay, 1.0)
		step_sfx.play()

func processDisplacement(_delta: float):
	if displacedByField:
		$PortalableRaycast.position = Vector2(0, 16) + displacementFieldOffset
		$NormalRaycast.position = Vector2(0, 16) + displacementFieldOffset
		$CloneSprite.position = sprite.position + displacementFieldOffset
		$CloneSprite.visible = true
		$CloneSprite.modulate.a = sprite.modulate.a / 2
	else:
		$PortalableRaycast.position = Vector2(0, 16)
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
	sprite.frame = floori(animation_frame) + angle * 4
	$CloneSprite.frame = floori(animation_frame) + angle * 4
	
	sprite.position = Vector2(0, -8)
	sprite.global_position = (sprite.global_position / 4).round() * 4

# For like _process, but runs at a fixed frame rate
# better for physics realated code
func _physics_process(delta: float) -> void:
	var goal_movement_vector: Vector2 = inputVector * delta * mov_speed
	linear_velocity = goal_movement_vector
	if heldObject != null:
		var goalPosition = position + angleToVector(angle) * 64
		heldObject.goalPos = goalPosition

func _input(event: InputEvent) -> void:
	if !movementEnabled: return
	if event.is_action_pressed(&"interact"):
		if heldObject && heldObject.has_method(&"_unuse"):
			heldObject._unuse(self)
		else:
			interact()

# finds any (physics) bodies or areas that are in the interaction hitbox
# then calls their _interacted_by_player if they have that method passing the player
# note that that interactable object needs to have collision layer 2 enabled
func interact() -> void:
	for area in interaction_area.get_overlapping_areas():
		if area.has_method(&"_interacted_by_player"):
			area._interacted_by_player(self)
			return
	for bodies in interaction_area.get_overlapping_bodies():
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
	
	
	if portalTeleportProgress < 1:
		angle = (portal1.angle + 2) % 4
		position = lerp(portal1.position + (angleToVector(angle) * -32), portal1.position, portalTeleportProgress)
		var goalColor = portal1.sprite.modulate
		goalColor.a = 0
		sprite.modulate = lerp(Color(1,1,1), goalColor, portalTeleportProgress)
	
	else:
		angle = (portal2.angle) % 4
		position = lerp(portal2.position, portal2.position + (angleToVector(angle) * endDistance), portalTeleportProgress - 1)
		var goalColor = portal1.sprite.modulate
		goalColor.a = 0
		sprite.modulate = lerp(goalColor, Color(1,1,1), portalTeleportProgress - 1)
	
	portalTeleportProgress += (delta * 2) / portalTeleportSpeed
	updateSprite(250, delta)
	if portalTeleportProgress > 2: 
		position = portal2.position + (angleToVector(angle) * endDistance)
		sprite.modulate = Color(1, 1, 1)
	
	processDisplacement(delta)

func getCameraPos() -> Vector2:
	if portalTeleportProgress < 2:
		var pos1 = portal1.position + (angleToVector((portal1.angle + 2) % 4) * -32)
		var pos2 = portal2.position + (angleToVector((portal2.angle) % 4) * 40)
		var t = portalTeleportProgress / 2
		t = t * t * (3.0 - (2.0 * t))
		return lerp(pos1, pos2, t)
	elif displacedByField:
		return position + displacementFieldOffset / 2
	else:
		return position

func shootPortal(orange: bool):
	portalRaycast.target_position = angleToVector(angle) * 5000
	normalRaycast.target_position = angleToVector(angle) * 5000
	portalRaycast.force_raycast_update()
	normalRaycast.force_raycast_update()
	if portalRaycast.get_collision_point() == normalRaycast.get_collision_point() && portalRaycast.is_colliding():
		var portalPos = portalRaycast.get_collision_point()
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
		newPortal.orangePortal = orange
		
		# first see if portal should be rejected
		for p in get_tree().get_nodes_in_group("Portals"):
			if p.orangePortal != orange && portalPos == p.position:
				return
		
		# then after confirming wall is empty clear all portals of current color
		for p in get_tree().get_nodes_in_group("Portals"):
			if p.orangePortal == orange:
				p.queue_free()
		
		get_tree().root.add_child(newPortal)
		newPortal.updateSprite(0)

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
