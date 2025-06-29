##### this script handles the initialization of the statemachines, characterswitching and has some utility functions

class_name PlayerCharacter
extends CharacterBody3D

@onready var _state_machine = %Human # state machine node inside the player
@onready var player_camera: Camera3D = %PlayerCam

@onready var char_visual: Node3D = %VisualAppearances

# contains the statemachine, the collisionshape and the mesh of all the characters for easier access
@export var char_arr: Array
var _current_index: int = 0

var _camera_forward: Vector3
var _camera_right: Vector3

var _is_boat: bool = false
var _is_on_water: bool = false
var _current_collider

func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	_state_machine.init(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _unhandled_input(event: InputEvent) -> void:
	_state_machine.process_input(event)
	if Input.is_action_just_pressed("switch_character_right"):
		_switch_character(1)
	if Input.is_action_just_pressed("switch_character_left"):
		_switch_character(-1)
	if Input.is_action_just_pressed("test"):
		pass

func _physics_process(delta: float) -> void:
	_state_machine.process_physics(delta)
	# check for water planes
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider != _current_collider:
			_current_collider = collider
			_is_on_water = true if collider.is_in_group("water") else false
			if _is_on_water and not _is_boat:
				await get_tree().create_timer(3.).timeout
				# TODO: player has to die and respawn somewhere
				print("you drowned...")

func _process(delta: float) -> void:
	_state_machine.process_frame(delta)

func _rotate_character(delta: float, rotation_speed: float, direction: Vector3) -> void:
	# get forward direction in which the character should rotate
	var target_direction = -direction
	# calculate target rotation angle in radians (around the Y axis)
	var target_rotation = atan2(target_direction.x, target_direction.z)
	# interpolate current Y rotation towards the target rotation
	char_visual.rotation.y = lerp_angle(char_visual.rotation.y, target_rotation, rotation_speed * delta)
	### hotfix ###
	get_node("CraneCollision").rotation.y = lerp_angle(char_visual.rotation.y, target_rotation, rotation_speed * delta)
	##############

func _get_cam_rotation() -> void:
	# get camera transform in world space
	_camera_forward = player_camera.global_basis.z
	_camera_right = player_camera.global_basis.x
	# we dont want the y components
	_camera_forward.y = 0.0
	_camera_right.y = 0.0
	# normalize to retrieve direction vectors
	_camera_forward.normalized()
	_camera_right.normalized()

func _switch_character(dir: int) -> void:
	if char_arr.size() == 0:
		return
	# Calculate next index
	var next_index = (_current_index + dir) % char_arr.size()
	
	# init new character
	_state_machine.current_state.exit()
	_state_machine = get_node(char_arr[next_index][0]) # state machine of next index
	_state_machine.init(self) # initialize new state machine
	get_node(char_arr[next_index][1]).show() # mesh of next index
	get_node(char_arr[next_index][2]).disabled = false # collision shape of next index
	_is_boat = String(char_arr[next_index][0]) == "StateMachines/Boat"
	
	# terminate old character 
	get_node(char_arr[_current_index][1]).hide() # mesh of current index
	get_node(char_arr[_current_index][2]).disabled = true # collision shape of current index
	
	_current_index = next_index
