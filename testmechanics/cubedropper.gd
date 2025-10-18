class_name CubeDropper extends Node2D

var cube: RigidBody2D = null
@onready var cubeScene = preload("res://testmechanics/cube.tscn")

@export var startWithCube = true
var cubebuffer = false

func _ready():
	if startWithCube:
		cubebuffer = true

func spawnCube():
	cube = cubeScene.instantiate()
	cube.global_position = global_position
	cube.dropper = self
	get_tree().root.add_child(cube)

func respawn():
	if cube != null && cube is Cube:
		cube._fizzle()
		cube = null
	else:
		respawnNoFizzle()

func _process(_delta: float) -> void:
	if cubebuffer:
		spawnCube()
		cubebuffer = false

func respawnNoFizzle():
	spawnCube()
