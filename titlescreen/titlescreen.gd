extends Control

func startGame():
	loadChamber(0)

func _process(_delta):
	if Input.is_action_pressed("close"):
		get_tree().quit()


func _ready():
	$Sprite2D2.position.x = 5000

func chamberselector() -> void:
	# idk if enabling/disabling visibility makes buttons still do their thing so i'm doing this crap instead
	var isEnabled = $Sprite2D2.position.x == 720
	if isEnabled:
		$Sprite2D2.position.x = 5000
	else:
		$Sprite2D2.position.x = 720

func loadChamber(index):
	var chambers = ["intro", "kgintro", "kgcontrolroom", "laserintro", "portalgun1", "cubefizzler", "laserswapper", "ldintro", "ldlaserswapper", "portalgun2", "ldlaserchainer", "climb"]
	get_tree().change_scene_to_file("res://levels/" + chambers[index] + ".tscn")
	Musichandler.enableLayer(0)
	Musichandler.disableLayer(8)
	


func mute() -> void:
	Musichandler.muteMusic()
	pass # Replace with function body.
