class_name Cube extends RigidBody2D

var held: bool = false
var p: Player
var goalPos: Vector2

var dropper: CubeDropper
var fizzleTimer: float = -1

var playerPortalTeleportProgressLastFrame: float = 2

var displacementFieldOffset := Vector2(0, 0)
var displacedByField := false

@export var reflector = false

var angle: int

func _interacted_by_player(_player: Player):
	collision_layer = 262
	_player.heldObject = self
	p = _player
	held = true

func _unuse(_player: Player):
	collision_layer = 263
	linear_velocity = Vector2(0, 0)
	_player.heldObject = null
	held = false

func _physics_process(_delta: float) -> void:
	if fizzleTimer > -1: return
	if held && p.portalTeleportProgress >= 2:
		linear_velocity = (goalPos - position) * 15
		if(position - goalPos).length() > 196:
			_unuse(p)
	else:
		linear_velocity = Vector2(0, 0)

func _process(_delta: float) -> void:
	if reflector:
		add_to_group("LaserInteract", false)
		$Sprite2D.frame = angle + 1
		$CloneSprite.frame = $Sprite2D.frame
	if fizzleTimer > -1:
		fizzleTimer += _delta * 4
		modulate.a = 1 - fizzleTimer
		if fizzleTimer > 1: 
			if dropper != null:
				dropper.respawnNoFizzle()
			queue_free()
	
	$Sprite2D.position = Vector2(0, 0)
	$Sprite2D.global_position = ($Sprite2D.global_position / 4).round() * 4
	processDisplacement(_delta)
	if held:
		angle = p.angle
		# logic for portal teleportation
		
		# just left portal
		if playerPortalTeleportProgressLastFrame < 2 && 2 < p.portalTeleportProgress:
			modulate.a = 1
		
		# just reached halfway point of portaling
		if playerPortalTeleportProgressLastFrame < 1 && 1 < p.portalTeleportProgress:
			linear_velocity = Vector2(0, 0)
			var endDistance: int = 56
			if p.angle == 0: endDistance = 68
			if p.angle == 2: endDistance = 40
			var goalPos2 = p.portal2.position + (p.angleToVector(p.portal2.angle) * (endDistance + 60))
			PhysicsServer2D.body_set_state(
			get_rid(),
			PhysicsServer2D.BODY_STATE_TRANSFORM,
			Transform2D.IDENTITY.translated(goalPos2)
			)
		
		# every frame during portal transition
		if p.portalTeleportProgress < 2:
			modulate.a = p.sprite.modulate.a
		
		playerPortalTeleportProgressLastFrame = p.portalTeleportProgress

func _fizzle():
	fizzleTimer = 0
	collision_layer = 0
	collision_mask = 0

func onFloorButton():
	$Sprite2D.modulate = Color(1, 1, 0)

func offFloorButton():
	$Sprite2D.modulate = Color(0, 0.5, 1)

func processDisplacement(_delta: float):
	if displacedByField:
		$CloneSprite.position = $Sprite2D.position + displacementFieldOffset
		$CloneSprite.visible = true
		$CloneSprite.modulate = $Sprite2D.modulate
		$CloneSprite.modulate.a /= 2
		if collision_layer >= 256: collision_layer -= 256
		$CloneReflector.collision_layer = 256
		$CloneReflector.position = displacementFieldOffset
	else:
		$CloneSprite.visible = false
		if collision_layer < 256: collision_layer += 256
		$CloneReflector.collision_layer = 0
