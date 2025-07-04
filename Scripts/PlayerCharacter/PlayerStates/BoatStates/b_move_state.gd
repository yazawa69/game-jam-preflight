extends State

@export_group("States")
@export var idle_state: State # transition implemented
@export var fall_state: State # transition implemented

@export var move_speed: float = 8.
@export var acceleration: float = 2.0
@export var rot_acceleration: float = 0.1
@export var max_rot_angle: float = PI*0.75

@onready var boat = %boat # hotfix
@onready var boat_collision = %BoatCollision # hotfix
@onready var boat_audio_player = %ASP_BoatSounds


var target_velocity: Vector3 = Vector3.ZERO
var target_rotation: float = 0.0
var anim_speed_start: float

func enter() -> void:
	print(move_speed)
	super() #prints out the name of the state for debugging
	boat_collision.global_rotation.y = boat.global_rotation.y + PI*.5 # hotfix
	parent.velocity = Vector3.ZERO # set velocity of the player to 0 after entering the state
	boat_audio_player.play()

func exit() -> void:
	boat_audio_player.stop()

func process_physics(delta: float) -> State:
	var _move_speed = move_speed if parent._is_on_water else .25
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward = boat.global_transform.basis.x.normalized()
	var current_speed = parent.velocity.dot(forward)
	
	if Input.is_action_pressed("move_forward"):
		# Interpolate rotation up to max rotation angle - disallowing sharp turns
		target_rotation = lerpf(target_rotation, -input_dir.x * max_rot_angle, rot_acceleration)
		boat.rotate_y(target_rotation * delta)
		boat_collision.rotate_y(target_rotation * delta) # hotfix
		current_speed = lerpf(current_speed, _move_speed, acceleration * delta)
	else:
		current_speed = lerpf(current_speed, 0.0, acceleration * delta)
		target_rotation = 0.0
		
	target_velocity = forward * current_speed
	parent.velocity = target_velocity
	parent.move_and_slide() # calculate physics
	
	# transition to Idle State
	if current_speed <= 0.0:
		return idle_state
	# transition to Fall State
	if !parent.is_on_floor():
		return fall_state
	
	return null
