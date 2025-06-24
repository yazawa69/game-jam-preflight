extends State

@export_group("States")
@export var idle_state: State # transition implemented
@export var jump_state: State # transition implemented
@export var float_state: State # transition implemented

@export_group("Properties")
@export var max_speed: float = 8.0
@export var acceleration: float = 4.0
@export var deceleration: float = 10.0
@export var rotation_speed: float = 3.0 # Speed at which the player rotates to face movement direction
@export var acceleration_curve: Curve # for non linear interpolation

var _direction: Vector3 # direction the player wants to move to
var _input_dir: Vector2 # vector 2 which stores both input axis
var _time: float

func enter() -> void:
	super() # used for debugging, just prints out the name of the current state
	# check once for input right after entering the state, if this is not done then there is input delay
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

func process_input(event: InputEvent) -> State:
	# check for input
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# transition to jump state
	if Input.is_action_just_pressed('jump') and parent.is_on_floor():
		return jump_state
	return null

func process_physics(delta: float) -> State:
	_time = clamp(_time, 0.0, 1.0)
	var non_linear_acc := acceleration_curve.sample(_time)
	parent.velocity.y -= gravity * delta # gravity
	
	# retrieve camera forward and right axis to make player movement relative to it (code is in the state class)
	parent._get_cam_rotation() 
	# the direction the player will walk towards
	_direction = (_input_dir.x * parent._camera_right + _input_dir.y * parent._camera_forward).normalized()
	if  _input_dir != Vector2.ZERO: # Accelerate when moving
		_time += delta
		parent.velocity = parent.velocity.lerp(_direction * max_speed, non_linear_acc * acceleration * delta)
		parent._rotate_character(delta, rotation_speed, _direction) # Smoothly rotate the player towards the movement direction
		_blend_from_position = _blend_from_position.lerp(_blend_to_position, delta * transition_speed * non_linear_acc + .1) # lerp to idle anim in the blend space
	else: # Decelerate if no input
		_time -= delta * 2.
		parent.velocity = parent.velocity.lerp(Vector3.ZERO, deceleration * delta)
		_blend_from_position = _blend_from_position.lerp(Vector2(-.1, .5), delta * transition_speed) # lerp to walking anim in th blend space
	
	parent.move_and_slide() # calculate physics
	
	#print(rad_to_deg(parent.get_floor_angle())) # debug information
	
	# transition to idle state
	if _input_dir == Vector2.ZERO and parent.velocity == Vector3.ZERO:
		return idle_state
	
	# transition to fall state
	if !parent.is_on_floor():
		return float_state
	
	return null
