class_name Cube extends RigidBody2D

var held: bool = false
var p: Player
var goalPos: Vector2

var dropper: CubeDropper
var fizzleTimer: float = -1

var playerPortalTeleportProgressLastFrame: float = 2

var displacementFieldOffset := Vector2(0, 0)
var displacedByField := false

func _interacted_by_player(_player: Player):
	collision_layer = 6
	_player.heldObject = self
	p = _player
	held = true

func _unuse(_player: Player):
	if p.interaction_area.get_overlapping_bodies().find(self) != -1:
		return
	collision_layer = 7
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
	else:
		$CloneSprite.visible = false
