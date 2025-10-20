extends Area2D

signal trigger

@export var once = false

@export var player = true

func _ready():
	collision_mask = 0
	if player:
		collision_mask += 128

func _hit(node: Node2D):
	emit_signal("trigger")
