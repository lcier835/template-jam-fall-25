extends RigidBody2D

@export var speed: float = 5

func _on_detect_player_body_entered(body: Node2D) -> void:
	if body is not Player:
		push_error("anything with collision layer 3 should be a player")
		return
	
	# restart
	SAVE.get_signleton().load_checkpoint(get_tree())

func _physics_process(delta: float) -> void:
	var movement_vec = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	if movement_vec.length_squared() > 1: return
	movement_vec *= delta * speed
	linear_velocity += movement_vec * 1000
