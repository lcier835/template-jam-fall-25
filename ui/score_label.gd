extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SAVE.get_signleton().score_update.connect(_score_updated)
	_score_updated(SAVE.get_signleton().score)

func _score_updated(new_score: int) -> void:
	text = "Score: " + str(new_score)
