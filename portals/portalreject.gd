extends Node2D

var timer = 0.0

func _process(delta: float) -> void:
	timer += delta * 4
	$Sprite2D.frame = floori(timer * 5)
	modulate.a = 1.0 - (timer)
	if timer > 1: queue_free()
