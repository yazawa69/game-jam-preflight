extends State

@export_group("States")
@export var fall_state: State # transition implemented

@export_group("Properties")
@export var jump_force: float = 10.0
@export var max_speed: float = 4.
@export var rotation_speed: float = 2.
@export var jump_amplifier = .25

var _direction: Vector3 # direction the player wants to move to
var _input_dir: Vector2 # vector 2 which stores both input axis
var _initial_velocity: Vector3
var _at_blend_value: float


func enter() -> void:
	super() # prints out the name of the current state for debugging
	_initial_velocity = abs(parent.velocity.normalized())*3.5
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	parent.velocity.y = 0.0
	parent.velocity.y = jump_force # add jump force once
	_at_blend_value = parent.human_anim_tree.get("parameters/Blend_IWJ/blend_amount")
	parent.human_anim_tree.set("parameters/TimeSeek/seek_request", 0.0) # reset anim
	parent.human_anim_tree.set("parameters/TimeScale/scale", .1)

func exit() -> void:
	parent.human_anim_tree.set("parameters/TimeScale/scale", 1.)

func process_input(event: InputEvent) -> State:
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	return null

func process_physics(delta: float) -> State:
	# anim blending
	_at_blend_value = lerp(_at_blend_value, 1.0, delta * 10.)
	parent.human_anim_tree.set("parameters/Blend_IWJ/blend_amount", _at_blend_value)
	
	# steer player while jumping a little bit
	parent._get_cam_rotation()
	_direction = (_input_dir.x * parent._camera_right + _input_dir.y * parent._camera_forward).normalized()
	parent.velocity.x = _direction.x * (max_speed+_initial_velocity.x)
	parent.velocity.z = _direction.z * (max_speed+_initial_velocity.z)
	
	if _input_dir != Vector2.ZERO: parent._rotate_character(delta, rotation_speed, _direction) # Smoothly rotate the player towards the movement direction
	
	# make jump taller when button is held down
	if Input.is_action_pressed("jump"):
		parent.velocity.y += jump_amplifier
		jump_amplifier = max(0.0, jump_amplifier-.01)
	
	parent.velocity.y -= gravity * 2. * delta # gravity 
	parent.move_and_slide() # calculate physics
	
	# transition to fall state
	if parent.velocity.y <= 0:
		return fall_state
	return null
