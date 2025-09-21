class_name SAVE extends RefCounted

# for global varribles that should be reset on death

signal score_update(new_score: int)
var score: int = 0:
	set(new_score):
		if score != new_score:
			score_update.emit(new_score)
			score = new_score

var level: int = 1


static var signleton: SAVE = null
static var checkpoint: SAVE = null
static func get_signleton() -> SAVE:
	if signleton == null:
		signleton = SAVE.new()
		checkpoint = SAVE.new()
	return signleton

func set_checkpoint() -> void:
	checkpoint.score = score
	checkpoint.level = level

func load_checkpoint(tree: SceneTree) -> void:
	score = checkpoint.score
	level = checkpoint.level
	switch_to_level(level, tree)

func switch_to_next_level(tree: SceneTree) -> void:
	level += 1
	switch_to_level(level, tree)

func switch_to_next_level_and_save(tree: SceneTree) -> void:
	switch_to_next_level(tree)
	set_checkpoint()

func switch_to_level(new_level: int, tree: SceneTree) -> void:
	var result = tree.change_scene_to_file(str("res://levels/", new_level, ".tscn"))
	if result != OK:
		level = 1
		push_warning("Next level not found! Going back to level 1")
		tree.change_scene_to_file("res://levels/1.tscn")
