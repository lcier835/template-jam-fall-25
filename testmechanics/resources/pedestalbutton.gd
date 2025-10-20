class_name PedestalButton extends StaticBody2D

var pressTimer = 1
@export var pressTime = 0.5

signal OnButtonPressed
signal OnButtonUnpressed

var displacementFieldOffset := Vector2(0, 0)
var displacedByField := false

func _interacted_by_player(_player: Player):
	if pressTimer > pressTime || (pressTime == -1 && pressTimer != -1):
		$Sprite2D.modulate = Color(1, 1, 0)
		emit_signal("OnButtonPressed")
		if pressTime == -1:
			pressTimer = -1
		else:
			pressTimer = 0

func _process(_delta: float) -> void:
	if pressTimer < pressTime && (pressTimer + _delta) >= pressTime:
		$Sprite2D.modulate = Color(1, 0, 0)
		emit_signal("OnButtonUnpressed")
	
	if pressTime != -1:
		pressTimer += _delta
	
	if displacedByField:
		$CollisionShape2D.position = -displacementFieldOffset
	else:
		$CollisionShape2D.position = Vector2(0, 0)
