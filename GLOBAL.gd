class_name GLOBAL extends RefCounted

# for global varribles that are irrelavant to death (for those use SAVE instead)

static var signleton: GLOBAL = null
static func get_singleton() -> GLOBAL:
	if signleton == null:
		signleton = GLOBAL.new()
	return signleton

var camera_zoom: float = 1.
var touchscreen_joystick: Vector2 = Vector2(0,0)
