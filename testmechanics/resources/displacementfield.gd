class_name displacementfield extends Area2D

@export var displacementArea: Vector2
@export var displacementDistance: Vector2
var borders: Array[Fizzler] = []

@export var enabled = true

var currentlyDisplacedObjects: Array[Node2D] = []

func _ready() -> void:
	$CollisionShape2D.shape.size = displacementArea * 64
	$CPUParticles2D.emission_rect_extents = displacementArea * 32
	$CPUParticles2D.direction = displacementDistance.normalized()
	$CPUParticles2D.amount = roundi(displacementArea.x * displacementArea.y)
	
	for c in self.get_children(false):
		if c is Fizzler:
			borders.append(c)

func _process(_delta: float) -> void:
	var potentialMembers = get_tree().get_nodes_in_group("Displaceable")
	
	# add new potential members, update all valid ones
	for m in potentialMembers:
		if objectInside(m):
			if enabled:
				startDisplacing(m)
			else:
				stopDisplacing(m)
			if currentlyDisplacedObjects.find(m) == -1:
				currentlyDisplacedObjects.append(m)
	
	# remove and update invalid ones
	for m in currentlyDisplacedObjects:
		if m == null || !objectInside(m):
			if m != null: stopDisplacing(m)
			currentlyDisplacedObjects.erase(m)

func startDisplacing(object: Node2D):
	object.displacementFieldOffset = displacementDistance * 64
	object.displacedByField = true

func stopDisplacing(object: Node2D):
	object.displacedByField = false

func objectInside(object: Node2D) -> bool:
	var lowerBound:= displacementArea * -32 + global_position - Vector2(8, 8)
	var upperBound:= displacementArea * 32 + global_position + Vector2(8, 8)
	var checkPosition:= object.position
	
	var withinXRange = lowerBound.x < checkPosition.x && checkPosition.x < upperBound.x
	var withinYRange = lowerBound.y < checkPosition.y && checkPosition.y < upperBound.y
	
	return withinXRange && withinYRange

func disableField():
	enabled = false
	$CPUParticles2D.visible = false
	for f in borders:
		f.disableFizzler()

func enableField():
	enabled = true
	$CPUParticles2D.visible = true
	for f in borders:
		f.enableFizzler()
