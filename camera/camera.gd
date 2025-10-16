extends Camera2D

@export var desired_size: Vector2 = Vector2(1440, 1080)

@export var player: Player

var smoothedPosition: Vector2

func _ready() -> void:
	get_tree().get_root().size_changed.connect(update_camera_zoom_level)
	update_camera_zoom_level()

func update_camera_zoom_level() -> void:
	var current_size: Vector2 = get_tree().get_root().size
	var zoom_vec := current_size / desired_size
	var zoom_float := minf(zoom_vec.x, zoom_vec.y)
	GLOBAL.get_singleton().camera_zoom = zoom_float
	zoom.x = zoom_float
	zoom.y = zoom_float

func smoothMin(a: float, b: float, k: float) -> float:
	k *= 2
	var x = b-a
	return 0.5 * (a + b - sqrt (x * x + k * k))

func _process(delta: float) -> void:
	var goalPosition = player.getCameraPos()
	smoothedPosition = lerp(smoothedPosition, goalPosition, delta * 3)
	var usePosition = smoothedPosition
	
	position = usePosition
