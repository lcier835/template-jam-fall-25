class_name Portal extends Area2D

@export var orangePortal : bool = false

@export var angle: int = 0
var animationTimer: float = 0
var animSpeed: float = 8
var sprite: Sprite2D

func _ready() -> void:
	sprite = $Sprite2D
	print($PhysicsHitbox.position)
	$PhysicsHitbox.position = angleToVector(angle) * 32
	print($PhysicsHitbox.position)
	pass

func angleToVector(ang) -> Vector2:
	match(ang):
		0: return Vector2(0, -1)
		1: return Vector2(1, 0)
		2: return Vector2(0, 1)
		3: return Vector2(-1, 0)
		_: return Vector2(0, 0)

func _process(delta: float) -> void:
	if orangePortal:
		sprite.modulate = Color(1.0, 0.500, 0.0, 1.0)
	else:
		sprite.modulate = Color(0.0, 0.500, 1.0, 1.0)
	
	animationTimer += delta * animSpeed
	if animationTimer > 4:
		animationTimer -= 4
	sprite.frame = floori(animationTimer) + angle * 4
	
func _on_body_entered(body) -> void:
	if body.name == "Player":
		var pl: Player = body
		if (pl.angle + 2) % 4 == angle:
			portal_transition(pl)

func portal_transition(body: Player):
	for p in get_tree().get_nodes_in_group("Portals"):
		if p.orangePortal != orangePortal:
			body.startPortalTransition(self, p)
	return
