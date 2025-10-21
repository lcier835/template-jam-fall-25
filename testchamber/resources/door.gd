class_name Door extends StaticBody2D

@export var leftSideBlack: bool = false
@export var rightSideBlack: bool = false
@export var startOpen: bool = false
var open = false
var wantsToClose = false

func _ready() -> void:
	open = startOpen
	updateSprites()

func updateSprite(isTop: bool, isLeft: bool, sprite: Sprite2D):
	var index = 0
	var black = (isLeft && leftSideBlack) || (!isLeft && rightSideBlack)
	if !black: index += 4
	if !isTop: index += 2
	if open: index += 1
	sprite.frame = index

func updateSprites():
	updateSprite(false, false, $RdoorBottom)
	updateSprite(true, false, $RdoorTop)
	updateSprite(false, true, $LdoorBottom)
	updateSprite(true, true, $LdoorTop)

func openDoor():
	open = true
	$StaticBody2D.collision_layer = 0
	updateSprites()

func closeDoor():
	wantsToClose = true

func _process(_delta: float) -> void:
	if wantsToClose && !$PlayerBlocker.has_overlapping_bodies():
		open = false
		updateSprites()
		$StaticBody2D.collision_layer = 273
		wantsToClose = false
