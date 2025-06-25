extends State

@export_group("States")
@export var idle_state: State # transition implemented
@export var move_state: State # transition implemented

var _initial_velocity: Vector3

func enter() -> void:
	super()
	_initial_velocity = abs(parent.velocity.normalized())*3.5

func process_physics(delta: float) -> State:
	parent.velocity.y -= gravity * 20. * delta # gravity
	parent.move_and_slide() # calculate physics
	
	# transition to move state
	if (parent.velocity.x != 0 or parent.velocity.z != 0) and parent.is_on_floor():
		return move_state
	# transition to idle state
	if parent.is_on_floor():
		return idle_state
	return null
