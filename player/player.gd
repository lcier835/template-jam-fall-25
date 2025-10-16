class_name Player extends RigidBody2D

# how far through the animation the charater is in a range between [0 and 4)
var animation_frame: float = 0
# counts up as you move when it passes 1, a walking sound effect is played
var sound_delay: float = 0.5
var angle: int = 0

# The values on an exported varrible is merely the default value
# to control the actual value, look in the of what used this script (the player)

# the speed the tries to move at when a movement key is pressed
@export var mov_speed: float = 15000
# how quickly the player goes to theu desired speed
@export var mov_speed_correction: float = 10
# how quick to animate the player's movement based on their speed
@export var anim_speed: float = 0.03
@export var walk_sfx_speed: float = 0.035
@export var sprite: Sprite2D
# how far the interaction hitbox is from the player
@export var interaction_hitbox_distance: float = 0
@export var interaction_hitbox: CollisionShape2D
@export var interaction_area: Area2D
@export var step_sfx: AudioStreamPlayer


# Returns a Vector2i indicating (non-normalized) movement direction based on user input
# If "up"  and "right" will return Vector2i(-1, 1)
# If "up", "down", and "right" will return Vector2i(0, 1)
func get_input_movement_vector() -> Vector2:
	var keyboard_movement_vector = Vector2()
	if Input.is_action_pressed(&"up"):
		keyboard_movement_vector.y -= 1
	if Input.is_action_pressed(&"down"):
		keyboard_movement_vector.y += 1
	if Input.is_action_pressed(&"left"):
		keyboard_movement_vector.x -= 1
	if Input.is_action_pressed(&"right"):
		keyboard_movement_vector.x += 1
	
	return keyboard_movement_vector

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement_vector := get_input_movement_vector()
	if not movement_vector.is_zero_approx():
		var movement_angle = movement_vector.angle() / TAU * 360
		# set animation direction
		if movement_vector.y == 1: # down
			interaction_hitbox.position = Vector2(0, interaction_hitbox_distance)
			angle = 0
		elif movement_vector.y == -1:
			interaction_hitbox.position = Vector2(0, -interaction_hitbox_distance)
			angle = 1
		elif movement_vector.x == -1: # left
			interaction_hitbox.position = Vector2(-interaction_hitbox_distance, 0)
			angle = 2
		elif movement_vector.x == 1: # right
			interaction_hitbox.position = Vector2(interaction_hitbox_distance, 0)
			angle = 3
	
	var actingLinearVelocityLength := (250 if linear_velocity.length() > 1 else 0)
	
	animation_frame = fmod(delta * anim_speed * actingLinearVelocityLength + animation_frame, 4)
	sprite.frame = floori(animation_frame) + angle * 4
	sound_delay += delta * walk_sfx_speed * actingLinearVelocityLength
	if sound_delay > 1.0:
		sound_delay = fmod(sound_delay, 1.0)
		step_sfx.play()

# For like _process, but runs at a fixed frame rate
# better for physics realated code
func _physics_process(delta: float) -> void:
	var basic_movement_vector := get_input_movement_vector()
	var goal_movement_vector: Vector2 = basic_movement_vector * delta * mov_speed
	linear_velocity = goal_movement_vector

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"):
		interact()

# finds any (physics) bodies or areas that are in the interaction hitbox
# then calls their _interacted_by_player if they have that method passing the player
# note that that interactable object needs to have collision layer 2 enabled
func interact() -> void:
	for area in interaction_area.get_overlapping_areas():
		if area.has_method(&"_interacted_by_player"):
			area._interacted_by_player(self)
	for bodies in interaction_area.get_overlapping_bodies():
		if bodies.has_method(&"_interacted_by_player"):
			bodies._interacted_by_player(self)
