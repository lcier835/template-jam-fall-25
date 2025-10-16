class_name Portal extends Area2D

@export var orangePortal : bool = false

var angle: int = 0
var animationTimer: float = 0
var animSpeed: float = 8
var sprite: Sprite2D

func _ready() -> void:
	sprite = $Sprite2D
	pass

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
		portal_transition(body)

func portal_transition(body: Player):
	print(get_tree().get_nodes_in_group("Portals"))
	for p in get_tree().get_nodes_in_group("Portals"):
		if p.orangePortal != orangePortal:
			body.startPortalTransition(self, p)
	return
