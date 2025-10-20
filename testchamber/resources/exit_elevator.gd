class_name exit_elevator extends Node2D

@export var nextMapName: String

var openDoorSprite: Texture2D = preload("res://testchamber/resources/elevatorside_open.png")
var closeDoorSprite: Texture2D = preload("res://testchamber/resources/elevatorside_closed.png")

var camera: FancyCam

var elevatorDistance: float = 0
var elevatorVelocity: float = 32
var elevatorAcceleration: float = 512
var maxElevatorVelocity: float = 768
@export var maxElevatorDistance: float = 1048
var p: Player
var closeDoorTimer: float = 1.5

# 0: beginning of chamber
# 1: player has gotten near, open door
# 2: player has entered, close door
# 3: elevator door shut, ascend, load next map when ready
var phase: int = 0

func _process(delta: float) -> void:
	match phase:
		0:
			if p == null:
				if get_tree().get_nodes_in_group("Player").size() == 0: return
				p = get_tree().get_nodes_in_group("Player")[0]
			if camera == null:
				if get_tree().get_nodes_in_group("Camera").size() == 0: return
				camera = get_tree().get_nodes_in_group("Camera")[0]
				
			if (p.global_position - global_position).length() < 256:
				phase = 1
				$ElevatorBottom.texture = openDoorSprite
				return
		1:
			if $Area2D.get_overlapping_bodies().size() > 0:
				$ElevatorBottom.texture = closeDoorSprite
				phase = 2
				camera.target = self
				
				# effectively disable player to make it look like they're in the elevator
				p.visible = false
				p.movementEnabled = false
				p.inputVector = Vector2()
				$ElevatorTop.z_index += 2
				$ElevatorBottom.z_index = $ElevatorTop.z_index - 1
				return
		2:
			closeDoorTimer -= delta
			if closeDoorTimer < 0:
				phase = 3
				camera.lag = false
				return
		3:
			elevatorVelocity += elevatorAcceleration * delta
			elevatorVelocity = min(elevatorVelocity, maxElevatorVelocity)
			elevatorDistance += elevatorVelocity * delta
			$ElevatorTop.position.y = -elevatorDistance
			$ElevatorBottom.position.y = -elevatorDistance
			camera.position = $ElevatorTop.global_position
			if elevatorDistance > maxElevatorDistance:
				get_tree().change_scene_to_file("res://levels/" + nextMapName + ".tscn")
				return
		_:
			return

func getCameraPos() -> Vector2:
	
	return $ElevatorTop.global_position
