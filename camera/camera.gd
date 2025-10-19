class_name FancyCam extends Camera2D

var desired_size: Vector2 = Vector2(1440, 1080)

var target: Node2D

var smoothedPosition: Vector2
var lag = true

func begin():
	position = target.position

func smoothMin(a: float, b: float, k: float) -> float:
	k *= 2
	var x = b-a
	return 0.5 * (a + b - sqrt (x * x + k * k))

func _process(delta: float) -> void:
	if target == null:
		if get_tree().get_nodes_in_group("Player").size() == 0: return
		target = get_tree().get_nodes_in_group("Player")[0]
		position = target.position
		smoothedPosition = target.position
	var goalPosition = target.position
	if target.has_method("getCameraPos"):
		goalPosition = target.getCameraPos()
	if lag:
		smoothedPosition = lerp(smoothedPosition, goalPosition, delta * 3)
	else:
		smoothedPosition = goalPosition
	var usePosition = smoothedPosition
	
	# find all camera magnets and add their pull
	for c in get_tree().get_nodes_in_group("CameraMagnets"):
		var strength = 1 / (1 + (smoothedPosition.distance_to(c.position) / c.strength))
		usePosition = lerp(smoothedPosition, c.position, strength)
	position = usePosition
