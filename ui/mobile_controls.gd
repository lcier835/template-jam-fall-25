extends Control

@export var joystick: Control
@export var outer_circle: Control
# measured in radiis of outer_circle
@export var start_joystick_hitbox: float = 2

# static so it persists through deaths
static var touchscreen_movement_index: int = -1

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		visible = true
		var touch_event: InputEventScreenTouch = event
		if touch_event.pressed:
			if touchscreen_movement_index == -1 and touch_position_in_joystick_zone(touch_event.position):
				touchscreen_movement_index = touch_event.index
				set_joystick_position_from_touch_position(touch_event.position)
		else:
			if touchscreen_movement_index == touch_event.index:
				touchscreen_movement_index = -1
				set_joystick_position_to_center()
	
	if event is InputEventScreenDrag:
		visible = true
		var drag_event: InputEventScreenDrag = event
		if drag_event.index == touchscreen_movement_index:
			set_joystick_position_from_touch_position(drag_event.position)


func update_visual_joystick_position() -> void:
	joystick.position = GLOBAL.get_singleton().touchscreen_joystick * outer_circle.size.x / 2. + get_joystick_offset()

func get_joystick_offset() -> Vector2:
	return get_movement_center_position() - joystick.scale * joystick.size * 0.5

func get_movement_center_position() -> Vector2:
	var outer_circle_transform_relative_to_this := get_global_transform().inverse() * outer_circle.get_global_transform()
	var oct := outer_circle_transform_relative_to_this
	var outer_circle_corner = oct.origin + oct.get_scale() * 0.5 * outer_circle.size
	return outer_circle_corner

func get_unlocked_joystick_position_from_touch_position(touch_position: Vector2) -> Vector2:
	var ui_touch_position := touch_position / GLOBAL.get_singleton().camera_zoom
	var joystick_touch_position := ui_touch_position - get_movement_center_position()
	var radius_of_joystick := outer_circle.size.x / 2.
	var unlocked_joystick_position =  joystick_touch_position / radius_of_joystick
	return unlocked_joystick_position

func set_joystick_position_to_center() -> void:
	GLOBAL.get_singleton().touchscreen_joystick = Vector2(0,0)
	update_visual_joystick_position()

func set_joystick_position_from_touch_position(touch_position: Vector2) -> void:
	var unlocked_joystick_location = get_unlocked_joystick_position_from_touch_position(touch_position)
	# confine joystick to the bounds of the circle
	GLOBAL.get_singleton().touchscreen_joystick = unlocked_joystick_location / max(unlocked_joystick_location.length(), 1.)
	update_visual_joystick_position()

func touch_position_in_joystick_zone(touch_position: Vector2) -> bool:
	return get_unlocked_joystick_position_from_touch_position(touch_position).length() < start_joystick_hitbox
