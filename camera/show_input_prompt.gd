extends Node2D

func showPrompt(icon):
	get_tree().get_nodes_in_group("Camera")[0]._showIcon(icon)

func bluePrompt():
	showPrompt("blue")
func movePrompt():
	showPrompt("move")
func orangePrompt():
	showPrompt("orange")
func pickupPromp():
	showPrompt("pickup")
func pressPrompt():
	showPrompt("press")
func strafePrompt():
	showPrompt("shift")
func takePrompt():
	showPrompt("take")
