extends State

@export_group("States")
@export var fall_state: State # transition implemented
@export var idle_state: State # transition implemented

@export_group("Properties")
@export var float_constant: float = -100.
@export var max_speed: float = 10.
@export var rotation_speed: float = 10.

var _direction: Vector3 # direction the player wants to move to
var _input_dir: Vector2 # vector 2 which stores both input axis
var _initial_velocity: Vector3
var _at_blend_value: float

@onready var wingflaps = %ASP_Wingflaps

func enter() -> void:
	super() # prints out the name of the current state for debugging
	_initial_velocity = abs(parent.velocity.normalized())*3.5
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	wingflaps.finished.connect(_on_asp_wingflaps_finished)
	wingflaps.play()
	_at_blend_value = parent.crane_anim_tree.get("parameters/Blend_wf/blend_amount")

func exit() -> void:
	wingflaps.finished.disconnect(_on_asp_wingflaps_finished)

func process_input(event: InputEvent) -> State:
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if Input.is_action_pressed("jump"):
		return fall_state
	return null

func process_physics(delta: float) -> State:
	# anim blending
	_at_blend_value = lerp(_at_blend_value, 1.0, delta * 10.)
	parent.crane_anim_tree.set("parameters/Blend_wf/blend_amount", _at_blend_value)
	
	# steer player while floating a little bit
	parent._get_cam_rotation()
	_direction = (_input_dir.x * parent._camera_right + _input_dir.y * parent._camera_forward).normalized()
	parent.velocity.x = _direction.x * (max_speed+_initial_velocity.x)
	parent.velocity.z = _direction.z * (max_speed+_initial_velocity.z)
	
	if _input_dir != Vector2.ZERO: parent._rotate_character(delta, rotation_speed, _direction) # Smoothly rotate the player towards the movement direction
	
	parent.velocity.y = float_constant * delta # floating
	parent.move_and_slide() # calculate physics
	
	# transition to idle state
	if parent.is_on_floor():
		return idle_state
	return null

func _on_asp_wingflaps_finished():
	wingflaps.play()
