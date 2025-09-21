extends Area2D

func _interacted_by_player(_player: Player):
	SAVE.get_signleton().switch_to_next_level(get_tree())
	SAVE.get_signleton().set_checkpoint()
