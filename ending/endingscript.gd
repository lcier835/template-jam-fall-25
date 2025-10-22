extends StaticBody2D

var p: Player

var timer = -1
@export var pedestalbutton: PedestalButton
@export var neurotoxinFill: Sprite2D
@export var neurotoxinSprite: Sprite2D

func _interacted_by_player(_player: Player):
	p = _player
	p.movementEnabled = false
	p.inputVector = Vector2(0, 0)
	timer = 0
	pedestalbutton._interacted_by_player(p)

func _process(delta: float):
	neurotoxinSprite.frame = floori(fmod(timer * 3, 1) * 4)
	if timer == -1: return
	if timer < 1 && (timer + delta) >= 1:
		p.angle = 1
		p.updateSprite(0, 0)
		p.displacedByField = true
		p.displacementFieldOffset = Vector2(1088, 0)
	
	if timer < 5 && (timer + delta) >= 5:
		p.angle = 2
		p.updateSprite(0, 0)
		p.displacedByField = false
	
	if timer > 0.5 && timer < 5.5:
		neurotoxinSprite.modulate.a = (timer - 0.5) / 5
	
	# neurotoxin fog
	if timer > 3:
		
		neurotoxinFill.modulate.g = sqrt((10 - timer) / 7.0)
		neurotoxinFill.modulate.a = (timer - 3.0) / 7.0
		if timer > 10:
			neurotoxinFill.modulate.a = 1
			neurotoxinFill.modulate.g = 0
	
	if timer < 13 && (timer + delta) >= 13:
		get_tree().change_scene_to_file("res://titlescreen/titlescreen.tscn")
		Musichandler.enableLayer(8)
	
	timer += delta
	pass
