class_name enterance_elevator extends Node2D

var openDoorSprite: Texture2D = preload("res://testchamber/resources/elevatorside_open.png")
var closeDoorSprite: Texture2D = preload("res://testchamber/resources/elevatorside_closed.png")


var elevatorDistance: float = 0
var elevatorSpeed: float = 512
@export var startingElevatorDistance: float = 1048
@export var bluePortalgun: bool = true
@export var orangePortalgun: bool = true
#@onready var playerTemplate = preload("res://player/player.tscn")
#@onready var cameraTemplate = preload("res://camera/camera.tscn")
@export var p: Player
@export var camera: FancyCam
var closeDoorTimer: float = 1

# 0: ascending
# 1: 256 units away, start slowing down
# 2: reached top, waiting to open door
# 3: door open, waiting for player to leave, close when they are far enough away
var phase: int = 0

func _ready():
	elevatorDistance = startingElevatorDistance
	$ElevatorBottom.texture = closeDoorSprite
	$ElevatorWalls2.z_index = 4
	camera.target = self
	camera.lag = false
	
	elevatorDistance = startingElevatorDistance
	$ElevatorTop.position.y = elevatorDistance
	$ElevatorBottom.position.y = elevatorDistance
	
	camera.global_position = $ElevatorTop.global_position
	camera.smoothedPosition = $ElevatorTop.global_position
	
	p.global_position = global_position
	p.visible = false
	p.bluePortalgun = bluePortalgun
	p.orangePortalgun = orangePortalgun
	p.movementEnabled = false

func _process(delta: float) -> void:
	match phase:
		0:
			elevatorDistance -= elevatorSpeed * delta
			$ElevatorTop.position.y = elevatorDistance
			$ElevatorBottom.position.y = elevatorDistance
			camera.global_position = $ElevatorTop.global_position
			if (elevatorDistance - (elevatorSpeed * delta)) < 256: # predict next frame to avoid pseudo lag framew
				phase = 1
				return
		1:
			elevatorDistance = lerp(0, 256, closeDoorTimer * closeDoorTimer)
			$ElevatorTop.position.y = elevatorDistance
			$ElevatorBottom.position.y = elevatorDistance
			camera.global_position = $ElevatorTop.global_position
			if elevatorDistance < 36: $ElevatorTop.z_index = 3
			closeDoorTimer -= delta
			if closeDoorTimer < 0:
				closeDoorTimer = 0.75
				phase = 2
				camera.lag = true
				$ElevatorWalls2.z_index = -1
				
				return
		2:
			closeDoorTimer -= delta
			if closeDoorTimer < 0:
				phase = 3
				camera.target = p
				p.movementEnabled = true
				p.visible = true
				camera.target = p
				$ElevatorBottom.texture = openDoorSprite
				return
		3:
			if (p.global_position - global_position).length() > 256:
				phase = 4
				$StaticBody2D2.collision_layer = 1
				$ElevatorBottom.texture = closeDoorSprite
				return
			pass
		_:
			return

func getCameraPos() -> Vector2:
	return $ElevatorTop.global_position
