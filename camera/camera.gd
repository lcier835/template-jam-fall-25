class_name FancyCam extends Camera2D

var desired_size: Vector2 = Vector2(1440, 1080)

var target: Node2D

var smoothedPosition: Vector2
var lag = true

var iconProgress = 0.0
var signProgress = -1.0

func begin():
	global_position = target.global_position

func smoothMin(a: float, b: float, k: float) -> float:
	k *= 2
	var x = b-a
	return 0.5 * (a + b - sqrt (x * x + k * k))

func _process(delta: float) -> void:
	if iconProgress > 0:
		$Sprite2D.modulate.a = min(1, iconProgress)
		iconProgress -= delta
	
	$Sprite2D2.frame = int(get_tree().current_scene.name.to_int())
	if target is not Player: signProgress = -1
	signProgress += delta
	if signProgress > 0 && signProgress < 1:
		$Sprite2D2.modulate.a = signProgress
	elif signProgress > 1 && signProgress < 5:
		$Sprite2D2.modulate.a = 1
	elif signProgress > 5 && signProgress < 6:
		$Sprite2D2.modulate.a = 6 - signProgress
	else:
		$Sprite2D2.modulate.a = 0
	
	
	if target == null:
		if get_tree().get_nodes_in_group("Player").size() == 0: return
		target = get_tree().get_nodes_in_group("Player")[0]
		global_position = target.global_position
		smoothedPosition = target.global_position
	var goalPosition = target.position
	if target.has_method("getCameraPos"):
		goalPosition = target.getCameraPos()
	if lag:
		smoothedPosition = lerp(smoothedPosition, goalPosition, delta * 3)
	else:
		smoothedPosition = goalPosition
	global_position = smoothedPosition

func _showIcon(icon: String):
	iconProgress = 5
	$Sprite2D.texture = load("res://camera/" + icon + ".png")
