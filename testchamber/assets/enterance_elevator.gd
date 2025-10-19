class_name enterance_elevator extends Node2D

var openDoorSprite: Texture2D = preload("res://testchamber/assets/elevatorside_open.png")
var closeDoorSprite: Texture2D = preload("res://testchamber/assets/elevatorside_closed.png")


var elevatorDistance: float = 0
var elevatorSpeed: float = 512
@export var startingElevatorDistance: float = 1048
@export var bluePortalgun: bool = true
@export var orangePortalgun: bool = true
@onready var playerTemplate = preload("res://player/player.tscn")
@onready var cameraTemplate = preload("res://camera/camera.tscn")
var p: Player
var camera: FancyCam
var closeDoorTimer: float = 1

var doneFirstTickChecks = false

# 0: beginning of chamber
# 1: player has gotten near, open door
# 2: player has entered, close door
# 3: elevator door shut, ascend
# 4: load next map
# 0: ascending
# 1: 256 units away, start slowing down
# 2: reached top, waiting to open door
# 3: door open, waiting for player to leave, close when they are far enough away
var phase: int = 0

func _begin():
	elevatorDistance = startingElevatorDistance
	$ElevatorBottom.texture = closeDoorSprite
	$ElevatorWalls2.z_index = 4

func _process(delta: float) -> void:
	if !doneFirstTickChecks:
		p = playerTemplate.instantiate()
		camera = cameraTemplate.instantiate()
		camera.target = self
		camera.lag = false
		
		elevatorDistance = startingElevatorDistance
		$ElevatorTop.position.y = elevatorDistance
		$ElevatorBottom.position.y = elevatorDistance
		
		camera.position = $ElevatorTop.global_position
		camera.smoothedPosition = $ElevatorTop.global_position
		
		p.position = global_position
		p.visible = false
		p.bluePortalgun = bluePortalgun
		p.orangePortalgun = orangePortalgun
		p.movementEnabled = false
		get_tree().root.add_child(p)
		get_tree().root.add_child(camera)
		doneFirstTickChecks = true
		
	match phase:
		0:
			elevatorDistance -= elevatorSpeed * delta
			$ElevatorTop.position.y = elevatorDistance
			$ElevatorBottom.position.y = elevatorDistance
			camera.position = $ElevatorTop.global_position
			if (elevatorDistance - (elevatorSpeed * delta)) < 256: # predict next frame to avoid pseudo lag framew
				phase = 1
				print("elevator on phase 2 now")
				return
		1:
			elevatorDistance = lerp(0, 256, closeDoorTimer * closeDoorTimer)
			$ElevatorTop.position.y = elevatorDistance
			$ElevatorBottom.position.y = elevatorDistance
			camera.position = $ElevatorTop.global_position
			if elevatorDistance < 36: $ElevatorTop.z_index = 3
			closeDoorTimer -= delta
			if closeDoorTimer < 0:
				closeDoorTimer = 1.5
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
