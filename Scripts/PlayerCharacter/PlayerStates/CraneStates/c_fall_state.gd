extends State

@export_group("States")
@export var idle_state: State # transition implemented
@export var move_state: State # transition implemented
@export var float_state: State # transition implemented

@export_group("Properties")
@export var max_speed: float = 4.
@export var rotation_speed: float = 2.

var _direction: Vector3 # direction the player wants to move to
var _input_dir: Vector2 # vector 2 which stores both input axis
var _initial_velocity: Vector3

func enter() -> void:
	super()
	_initial_velocity = abs(parent.velocity.normalized())*3.5
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

func exit() -> void:
	super()

func process_input(event: InputEvent) -> State:
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if Input.is_action_just_pressed("jump"):
		return float_state
	return null


func process_physics(delta: float) -> State:
	# steer player a little bit while falling
	parent._get_cam_rotation()
	_direction = (_input_dir.x * parent._camera_right + _input_dir.y * parent._camera_forward).normalized()
	parent.velocity.x = _direction.x * (max_speed+_initial_velocity.x)
	parent.velocity.z = _direction.z * (max_speed+_initial_velocity.z)
	
	if _input_dir != Vector2.ZERO: _rotate_character(delta, rotation_speed, _direction) # Smoothly rotate the player towards the movement direction
	
	parent.velocity.y -= gravity * 4. * delta # gravity
	parent.move_and_slide() # calculate physics
	
	# transition to move state
	if (parent.velocity.x != 0 or parent.velocity.z != 0) and parent.is_on_floor():
		return move_state
	# transition to idle state
	if parent.is_on_floor():
		return idle_state
	return null
