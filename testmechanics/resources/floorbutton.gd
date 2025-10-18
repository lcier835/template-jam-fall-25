class_name FloorButton extends Area2D

var lastFrameCollidingBodyCount = 0

var overlappingCubes = [Cube]

signal OnButtonPressed
signal OnButtonUnpressed

func _process(_delta: float) -> void:
	var currentOverlappingBodies = get_overlapping_bodies().size() + get_overlapping_areas().size()
	if currentOverlappingBodies > 0 && lastFrameCollidingBodyCount == 0:
		emit_signal("OnButtonPressed")
	
	if currentOverlappingBodies == 0 && lastFrameCollidingBodyCount > 0:
		emit_signal("OnButtonUnpressed")
	
	lastFrameCollidingBodyCount = currentOverlappingBodies
	
	# find all cubes
	for b in get_overlapping_bodies():
		if b is Cube:
			if overlappingCubes.find(b) == -1:
				overlappingCubes.append(b)
				b.onFloorButton()
	
	for c in overlappingCubes:
		if get_overlapping_bodies().find(c) == -1:
			c.offFloorButton()
			overlappingCubes.erase(c)
			
