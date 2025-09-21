extends Camera2D

@export var desired_size: Vector2 = Vector2(1152, 648)
@export var ui_control: Control

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
	ui_control.size = current_size / zoom_float
	ui_control.position = ui_control.size / -2
