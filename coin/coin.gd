extends Area2D

@export var pickup_sfx: AudioStreamPlayer2D
var already_picked_up: bool = false

func _interacted_by_player(_player: Player):
	# prevent being picked up again while its waiting for its sound effect to complete playing
	if already_picked_up: return
	already_picked_up = true
	SAVE.get_signleton().score += 1
	pickup_sfx.play()
	visible = false

func _on_pickup_sfx_finished() -> void:
	# queue_free delete its a node (and its children)
	queue_free()
