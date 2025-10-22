class_name MusicHandler extends Node2D

var enabled = [false, false, false, false, false, false, false, false, true]
var fullVolumes =                           [1.0,   0.25,   0.75,        1.0,    0.5,         0.5,         1.25,         1.5,        1.25]
var references: Array[AudioStreamPlayer]#   [$Base, $Climb, $Displacer, $Kinetic, $LaserEarly, $LaserLate, $Portalgun1, $Portalgun2, $Title]
var masterVolume = 1

func _ready():
	for i in range(0, 9):
		references.append(null)

func _process(delta: float) -> void:
	for i in range(0, 9):
		
		if references[i] == null:
			var temp =  [$Base, $Climb, $Displacer, $Kinetic, $LaserEarly, $LaserLate, $Portalgun1, $Portalgun2, $Title]
			references[i] = temp[i]
			if enabled[i]:
				references[i].volume_linear = fullVolumes[i]
			else:
				references[i].volume_linear = 0
		
		if !references[i].playing:
			references[i].play()
		
		if enabled[i]:
			references[i].volume_linear = lerp(references[i].volume_linear, fullVolumes[i], delta) * masterVolume
		else:
			references[i].volume_linear = lerp(references[i].volume_linear, 0.0, delta) * masterVolume

func enableLayer(layer):
	if layer < 9 && layer > -1:
		enabled[layer] = true

func disableLayer(layer):
	if layer < 9 && layer > -1:
		enabled[layer] = false

func muteMusic():
	if masterVolume == 0:
		masterVolume = 1
	else:
		masterVolume = 0
	
