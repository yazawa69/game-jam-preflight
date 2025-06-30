extends State

@export_group("States")
@export var fall_state: State # transition implemented
@export var jump_state: State # transition implemented
@export var move_state: State # transition implemented

var _at_blend_value: float

func enter() -> void:
	super() #prints out the name of the state for debugging
	parent.velocity = Vector3.ZERO # set velocity of the player to 0 after entering the state
	_at_blend_value = parent.human_anim_tree.get("parameters/Blend_IWJ/blend_amount")

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	# transition to Jump State
	if Input.is_action_just_pressed('jump') and parent.is_on_floor():
		return jump_state
	# transition to Move State
	if Input.get_vector("move_left", "move_right", "move_forward", "move_back"):
		return move_state
	return null

func process_physics(delta: float) -> State:
	# anim blending
	_at_blend_value = lerp(_at_blend_value, -1.0, delta * 10.)
	parent.human_anim_tree.set("parameters/Blend_IWJ/blend_amount", _at_blend_value)
	
	parent.velocity.y -= gravity * delta # gravity 
	parent.move_and_slide() # calculate physics
	
	# transition to Fall State
	if !parent.is_on_floor():
		return fall_state
	
	return null
