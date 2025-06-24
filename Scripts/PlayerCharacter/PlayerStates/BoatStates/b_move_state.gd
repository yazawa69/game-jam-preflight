extends State

@export_group("States")
@export var idle_state: State
@export var fall_state: State # TODO
@export var jump_state: State # TODO

@export var move_speed: float = 5.0
@export var acceleration: float = 2.0
@export var rot_acceleration: float = 0.1
@export var max_rot_angle: float = PI*0.75

var target_velocity: Vector3 = Vector3.ZERO
var target_rotation: float = 0.0
var anim_speed_start: float

func enter() -> void:
	super() #prints out the name of the state for debugging
	parent.velocity = Vector3.ZERO # set velocity of the player to 0 after entering the state

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	# transition to Jump State
	if Input.is_action_just_pressed('jump') and parent.is_on_floor():
		#return jump_state
		pass
	# transition to Move State
	if Input.get_vector("move_left", "move_right", "move_forward", "move_back"):
		#return move_state
		pass
	return null

func process_physics(delta: float) -> State:
	# TODO Maybe change the forward vector? I have to negate a bunch of stuff here.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward = -parent.global_transform.basis.z
	var current_speed = parent.velocity.dot(forward)
	
	if Input.is_action_pressed("move_forward"):
		# Interpolate rotation up to max rotation angle - disallowing sharp turns
		target_rotation = lerpf(target_rotation, -input_dir.x * max_rot_angle, rot_acceleration)
		parent.rotate_y(target_rotation * delta)
		current_speed = lerpf(current_speed, move_speed, acceleration * delta)
	
	else:
		current_speed = lerpf(current_speed, 0.0, acceleration * delta)
		target_rotation = 0.0
		
	target_velocity = forward * current_speed
	
	parent.velocity = target_velocity
	
	parent.move_and_slide() # calculate physics
	
	# transition to Fall State
	if !parent.is_on_floor():
		return fall_state
	
	return null
