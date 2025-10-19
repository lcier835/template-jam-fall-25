class_name Autoportal extends Node2D

var portal: Portal
@export var startWithPortal = false
@export var startPortalOrange = false

@onready var portalScene = preload("res://portals/portal.tscn")

var angle = 0

func _ready() -> void:
	angle = (global_rotation + (PI * 2)) / (PI / 2)

func _process(_delta: float) -> void:
	if startWithPortal: 
		placePortal(startPortalOrange)
		startWithPortal = false

func placeBluePortal():
	placePortal(false)

func placeOrangePortal():
	placePortal(true)

func clearPortal():
	portal.queue_free()

func placePortal(orange: bool):
	if portal != null:
		clearPortal()
	portal = portalScene.instantiate()
	portal.position = global_position
	portal.angle = int(angle + 3) % 4
	portal.orangePortal = orange
	portal.placedByPlayer = false
	
	# first see if portal should be rejected
	for p in get_tree().get_nodes_in_group("Portals"):
		if p.orangePortal != orange && position == p.position:
			return
	
	# then after confirming wall is empty clear all portals of current color
	for p in get_tree().get_nodes_in_group("Portals"):
		if p.orangePortal == orange:
			p.queue_free()
	
	get_tree().get_current_scene().add_child(portal)
	portal.updateSprite(0)
