extends Control

func startGame():
	get_tree().change_scene_to_file("res://levels/intro.tscn")

func process():
	if Input.is_action_pressed("close"):
		get_tree().quit()
