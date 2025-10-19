class_name Fizzler extends Area2D

@export var tilesWide: float = 2
@export var kineticGrill: bool = false
@export var displacementFieldBorder: bool = false

var enabled: bool

func _ready():
	tilesWide = round(tilesWide * 2) / 2
	$CollisionShape2D.shape.size.y = tilesWide * 64
	$PortalshotBlocker/CollisionShape2D.shape.size.y = tilesWide * 64
	$Fizzlermiddle.scale.y = tilesWide * 4
	$Side1.position.y = -32 + tilesWide * -32
	$Side2.position.y = 32 + tilesWide * 32
	
	if kineticGrill:
		$Fizzlermiddle.modulate = Color(1, 0.5, 0, 0.5)
		$Side1/Fizzleredge.modulate = Color(1, 0.5, 0, 0.5)
		$Side2/Fizzleredge.modulate = Color(1, 0.5, 0, 0.5)
		collision_mask = 0
		$PortalshotBlocker.collision_layer = 64
	
	if displacementFieldBorder:
		$Fizzlermiddle.modulate = Color(1, 1, 1, 0.5)
		$Side1/Fizzleredge.modulate = Color(1, 1, 1, 0.5)
		$Side2/Fizzleredge.modulate = Color(1, 1, 1, 0.5)
		collision_mask = 0
		$PortalshotBlocker.collision_layer = 0
		

func _objectCollide(body:Node2D):
	if body.has_method("_fizzle") && !kineticGrill: body._fizzle()

func disableFizzler():
	$Fizzlermiddle.modulate.a = 0
	$Side1/Fizzleredge.modulate.a = 0
	$Side2/Fizzleredge.modulate.a = 0
	collision_mask = 0
	$PortalshotBlocker.collision_layer = 0

func enableFizzler():
	$Fizzlermiddle.modulate.a = 0.5
	$Side1/Fizzleredge.modulate.a = 0.5
	$Side2/Fizzleredge.modulate.a = 0.5
	if kineticGrill:
		collision_mask = 0
		$PortalshotBlocker.collision_layer = 64
	elif displacementFieldBorder:
		collision_mask = 0
		$PortalshotBlocker.collision_layer = 0
	else:
		collision_mask = 6
		$PortalshotBlocker.collision_layer = 16
	
