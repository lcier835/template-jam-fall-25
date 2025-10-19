class_name LaserCatcher extends StaticBody2D

var powered: bool
var wasPowered: bool

signal OnLaserPowered
signal OnLaserUnpowered

func _process(_delta: float) -> void:
	if powered && !wasPowered:
		emit_signal("OnLaserPowered")
		$Sprite2D.modulate = Color(1, 1, 0)
	if wasPowered && !powered:
		emit_signal("OnLaserUnpowered")
		$Sprite2D.modulate = Color(1, 1, 1)
	wasPowered = powered
	powered = false
