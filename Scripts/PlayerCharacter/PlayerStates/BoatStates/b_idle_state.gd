extends State

@export_group("States")
@export var fall_state: State # transition implemented
@export var move_state: State # transition implemented

func enter() -> void:
	super() #prints out the name of the state for debugging
	parent.velocity = Vector3.ZERO # set velocity of the player to 0 after entering the state

func process_input(event: InputEvent) -> State:
	# transition to Move State
	if Input.get_vector("move_left", "move_right", "move_forward", "move_back"):
		return move_state
	return null

func process_physics(delta: float) -> State:
	parent.velocity.y -= gravity * delta # gravity 
	parent.move_and_slide() # calculate physics
	
	# transition to Fall State
	if !parent.is_on_floor():
		return fall_state
	
	return null
